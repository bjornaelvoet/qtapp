# This file contains the check_and_install_qt function

# Function to check and install Qt with specific modules
# Arguments:
#   $1: Qt Version (e.g., "6.9.1")
#   $2: aqtinstall host platform (e.g., "mac")
#   $3: aqtinstall target OS (e.g., "desktop" or "ios")
#   $4: aqtinstall architecture (e.g., "clang_64" or "ios")
#   $5: Base Installation Directory (e.g., "/Users/youruser/Qt")
#   $6: Space-separated list of required modules (e.g., "qtquick3d qtcharts")
#   $7: The actual folder name created by aqtinstall (e.g., "macOS" or "iOS")
check_and_install_qt() {
    local qt_version="$1"
    local aqt_host_platform="$2"
    local aqt_target_os="$3"
    local aqt_arch_arg="$4"
    local qt_install_base_dir="$5"
    local required_modules_list="$6"
    local qt_folder_name="$7"

    # --- PRIMARY TARGET (e.g., iOS or Desktop) Check and Install ---
    local primary_qt_install_dir="${qt_install_base_dir}/${qt_version}/${qt_folder_name}"
    local primary_qmake_path="${primary_qt_install_dir}/bin/qmake" # Crucial check for base SDK

    echo "--- Checking Primary Qt SDK Installation (Target: ${aqt_target_os}, Arch: ${aqt_arch_arg}, Folder: ${qt_folder_name}) ---"
    echo "Expected primary install directory: ${primary_qt_install_dir}"

    local needs_full_reinstall=false # Flag to re-install if base Qt or critical modules are missing

    # Check if the base Qt SDK directory exists and contains qmake
    if [ -d "$primary_qt_install_dir" ] && [ -f "$primary_qmake_path" ]; then
        echo "Primary Qt SDK version ${qt_version} for ${aqt_arch_arg} found at ${primary_qt_install_dir}."

        # Iterate through each required module to check if its QML directory is installed
        for module_name in ${required_modules_list}; do
            echo "  Checking for QML module: ${module_name}..."
            if [ -d "${primary_qt_install_dir}/qml/${module_name}" ]; then
                echo "    QML Module '${module_name}' found."
            else
                echo "    QML Module '${module_name}' is missing"
                needs_full_reinstall=true
                break # Break after finding the first missing module
            fi
        done

        if $needs_full_reinstall; then
            echo "One or more required primary QML modules are missing. Proceeding with Qt installation to ensure all modules are present."
            aqt install-qt "${aqt_host_platform}" "${aqt_target_os}" "${qt_version}" "${aqt_arch_arg}" --outputdir "${qt_install_base_dir}" --modules ${required_modules_list}
        else
            echo "All required primary QML modules appear to be installed. Skipping primary Qt installation."
        fi

    else # Primary Qt SDK (base directory or qmake) was NOT found
        echo "Base Primary Qt SDK version ${qt_version} for ${aqt_arch_arg} not found at ${primary_qt_install_dir} or qmake is missing."
        echo "Proceeding with full installation of primary Qt SDK and all required modules."
        aqt install-qt "${aqt_host_platform}" "${aqt_target_os}" "${qt_version}" "${aqt_arch_arg}" --outputdir "${qt_install_base_dir}" --modules ${required_modules_list}
    fi

    # --- CONDITIONAL CHECK AND INSTALL FOR MAC OS DESKTOP SDK (if primary target is iOS) ---
    # This block is independent of the primary target's module check success
    if [ "${aqt_target_os}" = "ios" ]; then
        echo ""
        echo "--- Building for iOS, checking for required macOS Desktop SDK ---"
        local desktop_host_platform="mac"
        local desktop_target_os="desktop"
        local desktop_arch_arg="clang_64"
        local desktop_folder_name="macOS" # Desktop folder name is always 'macOS' for aqtinstall

        local desktop_qt_install_dir="${qt_install_base_dir}/${qt_version}/${desktop_folder_name}"
        local desktop_qmake_path="${desktop_qt_install_dir}/bin/qmake" # qmake is essential for desktop tools

        echo "Expected macOS Desktop SDK directory: ${desktop_qt_install_dir}"

        if [ -d "$desktop_qt_install_dir" ] && [ -f "$desktop_qmake_path" ]; then
            echo "macOS Desktop Qt SDK version ${qt_version} for ${desktop_arch_arg} found at ${desktop_qt_install_dir}."
            echo "Skipping macOS Desktop Qt SDK installation."
        else
            echo "macOS Desktop Qt SDK version ${qt_version} for ${desktop_arch_arg} not found at ${desktop_qt_install_dir} or qmake is missing."
            echo "Proceeding with installation of macOS Desktop Qt SDK (base components)."
            # Install only base desktop components, no specific modules needed unless explicitly required for desktop host tools
            aqt install-qt "${desktop_host_platform}" "${desktop_target_os}" "${qt_version}" "${desktop_arch_arg}" --outputdir "${qt_install_base_dir}" --modules ""
        fi
    fi
    echo "--- Qt SDK Installation Check Complete ---"
}