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
try {
    aqt --help | Out-Null
    $aqtinstallFound = $true    
    Write-Host "aqtinstall is already installed."
}
catch {
    Write-Warning "aqtinstall is not found."
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

# --- MSVC Compiler Check for AMD64 ---
Write-Host "Checking for Visual Studio 2022 AMD64 C++ Build Tools..."

$vsWherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$amd64CompilerFound = $false

if (Test-Path $vsWherePath) {
    $vs2022Path = & $vsWherePath -latest -prerelease -products Microsoft.VisualStudio.Product.BuildTools `
                                 Microsoft.VisualStudio.Product.Community `
                                 Microsoft.VisualStudio.Product.Professional `
                                 Microsoft.VisualStudio.Product.Enterprise `
                                 -version "[17.0,18.0)" -property installationPath

    if ($vs2022Path) {
        Write-Host "Found Visual Studio 2022 installation at: $vs2022Path"
        $amd64CompilerFound = $true
    } else {
        Write-Warning "Visual Studio 2022 installation not found by vswhere."
    }
} else {
    Write-Warning "vswhere.exe not found at $vsWherePath. Cannot reliably check for MSVC compiler."
    Write-Warning "This is common on systems where VS Build Tools are not installed in the default location."
}

if (-not $amd64CompilerFound) {
    Write-Error "=============================================================================="
    Write-Error "ERROR: Visual Studio 2022 AMD64 C++ Build Tools were not found."
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
# Always refer to 'aqt list-qt windows_amd64 desktop --arch <version>' for exact arch strings.
$qtVersion = "6.9.1"
$targetOsHost = "windows" # Explicitly specify the AMD64 host
$targetPlatform = "desktop"      # The target platform/SDK
$arch = "win64_msvc2022" # Confirmed exact architecture from aqt list-qt
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
    aqt list-qt windows desktop --arch 6.9.1
    aqt list-qt windows desktop --archives 6.9.1 win64_msvc2022_arm64

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

# Load the build environment

# Invokes a Cmd.exe shell script and updates the environment.
function Invoke-CmdScript {
  param(
    [String] $scriptName
  )
  $cmdLine = """$scriptName"" $args & set"
  & $Env:SystemRoot\system32\cmd.exe /c $cmdLine |
  select-string '^([^=]*)=(.*)$' | foreach-object {
    $varName = $_.Matches[0].Groups[1].Value
    $varValue = $_.Matches[0].Groups[2].Value
    set-item Env:$varName $varValue
  }
}

$vcvarsallBatPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"
Invoke-CmdScript $vcvarsallBatPath arm64

$env:Path

cl.exe


cmake -S . -B $buildDir -DCMAKE_PREFIX_PATH=$Qt6_Dir -DCMAKE_BUILD_TYPE=Release

cmake --build $buildDir --config Release

Write-Host "CMake configure and build complete."
Write-Host "Script finished."





# Configure the build



Write-Host "Script finished."