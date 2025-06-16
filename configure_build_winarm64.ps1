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
        $arm64CompilerFound = $true
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
    #exit 1 # Exit if the necessary compiler is not found

    # Install Visual Studio 2022
    # Define variable
    $vsEdition = "Enterprise" # Options: Community, Professional, Enterprise
    $vsBootstrapperUrl = "https://aka.ms/vs/17/release/vs_${vsEdition}.exe"
    $downloadPath = "$env:TEMP\vs_bootstrapper.exe"
    $installPath = "C:\Program Files\Microsoft Visual Studio\2022\$vsEdition" # Customize install path
    $logFile = "$env:TEMP\vs_install_log.txt"

    # Define the C++ workloads and components you want to install specifically for ARM64 development.
    # Refer to https://learn.microsoft.com/en-us/visualstudio/install/workload-and-component-ids
    # Ensure you are referencing the correct IDs for ARM64 components.

    $workloads = @(
        #"Microsoft.VisualStudio.Workload.NativeDesktop" # Desktop development with C++
        #"Microsoft.VisualStudio.Workload.NativeGame"    # Game development with C++ (consider if ARM64 gaming is relevant)
        #"Microsoft.VisualStudio.Workload.NativeCrossPlat" # Linux and embedded development with C++
    )

    $components = @(
        # Essential C++ Build Tools (VS 2022) for ARM64
        "Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
        "Microsoft.VisualStudio.Component.VC.Tools.ARM64"
        #"Microsoft.VisualStudio.Component.VC.Tools.ARM64"           # MSVC v143 - VS 2022 C++ ARM64 build tools (Crucial for ARM64 targeting)
        #"Microsoft.VisualStudio.Component.VC.ATLMFC.ARM64"          # C++ ATL/MFC for ARM64 (if needed)

        # If you also need to target x64/x86 from your ARM64 host (cross-compilation)
        #"Microsoft.VisualStudio.Component.VC.Tools.x86.x64"         # MSVC v143 - VS 2022 C++ x64/x86 build tools

        # Windows SDKs
        #"Microsoft.VisualStudio.Component.Windows11SDK.10.0.22621.0" # Windows 11 SDK (adjust version as needed for your target OS)
        "Microsoft.VisualStudio.Component.Windows11SDK.26100"

        # Optional but often useful:
        #"Microsoft.VisualStudio.Component.VC.Redist.14.ARM64"        # Visual C++ Redistributable for VS 2015-2022 (ARM64)
        #"Microsoft.VisualStudio.Component.VC.Redist.14"              # Visual C++ Redistributable for VS 2015-2022 (x86/x64) - if needed
        #"Microsoft.VisualStudio.Component.CppBuildTools.MSBuild"     # MSBuild for C++
        #"Microsoft.VisualStudio.Component.TestTools.Core"            # Test tools core features
    )

    # Convert workloads and components to command-line arguments
    $addArguments = ""
    foreach ($w in $workloads) {
        $addArguments += "--add $w "
    }
    foreach ($c in $components) {
        $addArguments += "--add $c "
    }

    # Construct the full argument list for the installer
    # --quiet: completely silent
    # --wait: waits for the installation to complete before the process exits
    # --norestart: suppresses reboots (handle reboots separately if needed)
    # --includeRecommended: installs recommended components for selected workloads
    # --lang en-US: installs English language pack
    $arguments = "--productId Microsoft.VisualStudio.Product.$vsEdition $addArguments --quiet --wait --norestart"

    Write-Host "Starting Visual Studio 2022 unattended installation for C++ ARM64 development..."

    # Check if running with administrator privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This script must be run with Administrator privileges. Please right-click and 'Run as Administrator'."
        exit 1
    }

    # 1. Download the Visual Studio bootstrapper (the bootstrapper itself is usually x86 but orchestrates ARM64 downloads)
    Write-Host "Downloading Visual Studio 2022 bootstrapper from $vsBootstrapperUrl to $downloadPath..."
    try {
        Invoke-WebRequest -Uri $vsBootstrapperUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "Bootstrapper downloaded successfully."
    }
    catch {
        Write-Error "Failed to download Visual Studio bootstrapper: $($_.Exception.Message)"
        exit 1
    }

    # 2. Start the unattended installation
    Write-Host "Starting Visual Studio installation in unattended mode..."
    Write-Host "Command: ""$downloadPath"" $arguments"

    try {
        # Start the process and wait for it to complete
        $process = Start-Process -FilePath $downloadPath -ArgumentList $arguments -NoNewWindow -PassThru -Wait

        if ($process.ExitCode -eq 0) {
            Write-Host "Visual Studio 2022 for C++ ARM64 development installed successfully!"
            Write-Host "Installation log: $logFile"
        }
        elseif ($process.ExitCode -eq 3010) {
            Write-Warning "Visual Studio 2022 installation completed, but a reboot is required (exit code 3010)."
            # You might want to prompt for a reboot or schedule one here
            # Restart-Computer -Confirm -Force # Example: If you want to force a reboot    
        }
        else {
            Write-Error "Visual Studio 2022 installation failed with exit code $($process.ExitCode)."
            Write-Error "Please check the log file for details: $logFile"
            exit $process.ExitCode
        }
    }
    catch {
        Write-Error "An error occurred during Visual Studio installation: $($_.Exception.Message)"
        exit 1
    }
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
$targetOsHost = "windows_arm64" # Explicitly specify the AMD64 host
$targetPlatform = "desktop"      # The target platform/SDK
$arch = "win64_msvc2022_arm64" # Confirmed exact architecture from aqt list-qt
$archfolder = "msvc2022_arm64" # Name of the folder for the architecture
$outputDir = "$PSScriptRoot\Qt" # Downloads Qt to a 'Qt' folder next to the script

# Check if dowload if needed
$folderPath = "$outputDir\$qtVersion\$archfolder"
if (Test-Path -Path $folderPath -PathType Container) {
    Write-Host "The folder '$folderPath' exists. No download needed."
} else {
    Write-Host "The folder '$folderPath' does not exist."
    Write-Host "Attempting to download Qt version $qtVersion for $targetOsHost ($arch)..."
    Write-Host "Download location: $outputDir"

    try {
        # Create the output directory if it doesn't exist
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force
            Write-Host "Created output directory: $outputDir"
        }

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

# Loading the visual studio build variables into our environment
Write-Host "Loading Visual Studio Build Variables..."
$vcvarsallBatPath = "C:\Program Files\Microsoft Visual Studio\2022\$vsEdition\VC\Auxiliary\Build\vcvarsall.bat"
Invoke-CmdScript $vcvarsallBatPath arm64

# Some helper paths to feed into cmake
$buildDir = "./build_arm64"
$Qt6_dir = "$PSScriptRoot\Qt\$qtVersion\msvc2022_arm64" 
$toolchainFilePath = "$Qt6_dir\lib\cmake\Qt6\qt.toolchain.cmake"

# Building the arm64 version
Write-Host "Building arm64 version..."
cmake -S . -B "$buildDir" -DCMAKE_PREFIX_PATH="$Qt6_Dir" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE="$toolchainFilePath"
cmake --build "$buildDir" --config Release

# Fix copy missing qwindows.dll as windeployqt missing it
cp "$Qt6_dir\plugins\platforms\qwindows.dll" "$buildDir\Release\qwindows.dll"

# Bundling arm64 application
& "$(Join-Path $Qt6_dir 'bin\windeployqt')" --qmldir=. --release "$BuildDir\Release\QtApp.exe"

# We need the build path exposed to github workflow for artefact upload
if ($env:CI -eq "true") {
    # Remove leading './' if present and append to GITHUB_ENV
    $BuildDirWithoutDotSlash = $buildDir -replace '^\./', ''
    echo "Debug: $BuildDirWithoutDotSlash"
    Add-Content -Path $env:GITHUB_ENV -Value "BUILD_DIR_ARM64=$BuildDirWithoutDotSlash"
}

Write-Host "CMake configure and build complete."
Write-Host "Script finished."
