# This script installs aqtinstall and downloads a specific Qt version for Windows ARM64.

Write-Host "Checking for Python and pip..."

$pythonFound = $false
$pipFound = $false

# Check if Python is installed
try {
    python --version | Out-Null
    $pythonFound = $true
    Write-Host "Python is installed."
}
catch {
    Write-Warning "Python is not found in your PATH."
}

# Check if pip is installed
if ($pythonFound) {
    try {
        pip --version | Out-Null
        $pipFound = $true
        Write-Host "pip is installed."
    }
    catch {
        Write-Warning "pip is not found. It usually comes with Python."
    }
}

if (-not $pythonFound -or -not $pipFound) {
    Write-Error "=============================================================================="
    Write-Error "ERROR: Python and/or pip are not installed or not found in your system's PATH."
    Write-Error "=============================================================================="
    exit 1
}

# --- Check and Install aqtinstall ---
Write-Host "Checking for aqtinstall..."

$aqtinstallFound = $false
# Use pip show to robustly check if aqtinstall is present
try {
    # If pip show aqtinstall succeeds, it means it's installed.
    # We check for specific text in the output to confirm it's an actual package, not just an empty result.
    $pipShowOutput = pip show aqtinstall 2>&1
    if ($pipShowOutput -match "Name: aqtinstall") {
        $aqtinstallFound = $true
        Write-Host "aqtinstall is already installed."
    } else {
        Write-Warning "aqtinstall not found via pip. Installing it now..."
    }
}
catch {
    # This catch block would hit if 'pip' itself wasn't found, but we already checked that.
    Write-Warning "Could not verify aqtinstall presence using 'pip show'. Attempting installation anyway."
}

if (-not $aqtinstallFound) {
    try {
        # --upgrade ensures it's the latest version if a partial install existed
        pip install aqtinstall --upgrade
        Write-Host "aqtinstall installed successfully."
    }
    catch {
        Write-Error "Failed to install aqtinstall. Please check your internet connection or pip configuration."
        Write-Error "Error details: $($_.Exception.Message)"
        exit 1
    }
}

# --- MSVC Compiler Check for ARM64 ---
Write-Host "Checking for Visual Studio 2022 ARM64 C++ Build Tools..."

$vsWherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$arm64CompilerFound = $false

if (Test-Path $vsWherePath) {
    $vs2022Path = & $vsWherePath -latest -prerelease -products Microsoft.VisualStudio.Product.BuildTools `
                                 Microsoft.VisualStudio.Product.Community `
                                 Microsoft.VisualStudio.Product.Professional `
                                 Microsoft.VisualStudio.Product.Enterprise `
                                 -version "[17.0,18.0)" -property installationPath

    if ($vs2022Path) {
        Write-Host "Found Visual Studio 2022 installation at: $vs2022Path"
        # Check for the presence of the ARM64 specific compiler executable (cl.exe)
        # The path to cl.exe varies. A common structure for cross-compilation from x64 host to ARM64 target is Hostx64\ARM64.
        $clExePath = Join-Path $vs2022Path "VC\Tools\MSVC\*\bin\Hostx64\ARM64\cl.exe"
        $foundClExe = Get-ChildItem -Path $clExePath -ErrorAction SilentlyContinue | Select-Object -First 1

        if ($foundClExe) {
            Write-Host "Found MSVC 2022 ARM64 C++ compiler (cl.exe) at: $($foundClExe.FullName)"
            $arm64CompilerFound = $true
        } else {
            Write-Warning "MSVC 2022 ARM64 C++ compiler (cl.exe) not found at expected location: $clExePath"
        }
    } else {
        Write-Warning "Visual Studio 2022 installation not found by vswhere."
    }
} else {
    Write-Warning "vswhere.exe not found at $vsWherePath. Cannot reliably check for MSVC compiler."
    Write-Warning "This is common on systems where VS Build Tools are not installed in the default location."
}

if (-not $arm64CompilerFound) {
    Write-Error "=============================================================================="
    Write-Error "ERROR: Visual Studio 2022 ARM64 C++ Build Tools were not found."
    Write-Error "=============================================================================="
    exit 1 # Exit if the necessary compiler is not found
}

# --- CMake Check ---
Write-Host "Checking for CMake..."

$cmakeFound = $false
try {
    # Attempt to run cmake --version and capture output
    $cmakeVersionOutput = cmake --version 2>&1
    if ($LASTEXITCODE -eq 0 -and $cmakeVersionOutput -match "cmake version") {
        $cmakeFound = $true
        Write-Host "CMake is installed: $($cmakeVersionOutput.Split("`n")[0])" # Output first line, e.g., "cmake version X.Y.Z"
    } else {
        Write-Warning "CMake not found in PATH or 'cmake --version' command failed."
    }
}
catch {
    Write-Warning "Error running 'cmake --version': $($_.Exception.Message)"
    Write-Warning "This usually means CMake is not installed or not in your system's PATH."
}

if (-not $cmakeFound) {
    Write-Error "=============================================================================="
    Write-Error "ERROR: CMake was not found."
    Write-Error "=============================================================================="
    exit 1 # Exit if CMake is not found
}

# --- Qt Download Configuration ---
# Customize these variables to download a different Qt version or architecture.
# Always refer to 'aqt list-qt windows_arm64 desktop --arch <version>' for exact arch strings.
$qtVersion = "6.9.1"
$targetOsHost = "windows_arm64" # Explicitly specify the ARM64 host
$targetPlatform = "desktop"      # The target platform/SDK
$arch = "win64_msvc2022_arm64" # Confirmed exact architecture from aqt list-qt
$outputDir = "$PSScriptRoot\Qt" # Downloads Qt to a 'Qt' folder next to the script

Write-Host "Attempting to download Qt version $qtVersion for $targetOsHost ($arch)..."
Write-Host "Download location: $outputDir"

try {
    # Create the output directory if it doesn't exist
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force
        Write-Host "Created output directory: $outputDir"
    }

    # Try listing for debug
    aqt list-qt windows_arm64 desktop --arch 6.9.1
    aqt list-qt windows_arm64 desktop --archives 6.9.1 win64_msvc2022_arm64

    # Execute aqtinstall command with the correct subcommand and argument order:
    # Order: aqt install-qt [options] <host> <target> <version> [arch]
    aqt install-qt --outputdir $outputDir $targetOsHost $targetPlatform $qtVersion $arch
    Write-Host "Qt $qtVersion for $targetOsHost ($arch) downloaded successfully to $outputDir."
}
catch {
    Write-Error "Failed to download Qt. Please check the Qt version, OS, and architecture, or your internet connection."
    Write-Error "Ensure the specified '$qtVersion' and '$arch' are valid combinations for Qt $targetOsHost."
    Write-Error "Error details: $($_.Exception.Message)"
    exit 1
}

Write-Host "Script finished."