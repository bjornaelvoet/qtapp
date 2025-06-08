# Function to check and install Qt with specific modules
# Arguments:
#   $1: Qt Version (e.g., "6.9.1")
#   $2: Qt Architecture (e.g., "clang_64" - used for aqt commands)
#   $3: Base Installation Directory (e.g., "/Users/youruser/Qt")
#   $4: Space-separated list of required modules (e.g., "qtquick3d qtcharts")
check_and_install_qt() {
    local qt_version="$1"
    local qt_arch_for_aqt_cmd="$2" # This is clang_64 or similar
    local qt_install_base_dir="$3"
    local required_modules_list="$4"

    # --- THIS IS THE CRUCIAL CHANGE ---
    # aqtinstall creates 'macOS' folder for desktop installs, not 'clang_64' or similar
    local qt_folder_platform_name="macOS" # The actual folder name created by aqtinstall
    local qt_install_dir="${qt_install_base_dir}/${qt_version}/${qt_folder_platform_name}"
    # --- END OF CRUCIAL CHANGE ---

    local qmake_path="${qt_install_dir}/bin/qmake"

    echo "--- Qt Installation Check for ${qt_version} (${qt_arch_for_aqt_cmd}) with modules '${required_modules_list}' ---"
    echo "Expected install directory: ${qt_install_dir}"

    local needs_install=false # Flag to track if any module is missing or Qt is not found

    # Check if the main Qt installation directory exists and contains qmake
    if [ -d "$qt_install_dir" ] && [ -f "$qmake_path" ]; then
        echo "Qt version ${qt_version} for ${qt_arch_for_aqt_cmd} found at ${qt_install_dir}."

        # Iterate through each required module
        for module_name in ${required_modules_list}; do
            echo "  Checking for module: ${module_name}..."
            local module_found=false

            # You need to define logic here for checking each specific module.
            # Paths relative to qt_install_dir
            case "${module_name}" in
                "qtquick3d")
                    if [ -f "${qt_install_dir}/lib/QtQuick3D.framework/QtQuick3D" ] || \
                       [ -d "${qt_install_dir}/qml/QtQuick3D" ]; then
                        module_found=true
                    fi
                    ;;
                "qtcharts")
                    if [ -f "${qt_install_dir}/lib/QtCharts.framework/QtCharts" ] || \
                       [ -d "${qt_install_dir}/qml/QtCharts" ]; then
                        module_found=true
                    fi
                    ;;
                "qtsvg")
                    if [ -f "${qt_install_dir}/lib/QtSvg.framework/QtSvg" ]; then
                        module_found=true
                    fi
                    ;;
                *)
                    echo "    WARNING: No specific check logic for module '${module_name}'. Assuming it's part of base install or relying on 'aqt' to handle."
                    module_found=true
                    ;;
            esac

            if ! $module_found; then
                echo "    Module '${module_name}' is missing or incomplete."
                needs_install=true
                break
            else
                echo "    Module '${module_name}' found."
            fi
        done

        if $needs_install; then
            echo "One or more required modules are missing. Proceeding with Qt installation to ensure all modules are present."
            # Use qt_arch_for_aqt_cmd here as it's the parameter for aqt
            aqt install-qt mac desktop "${qt_version}" "${qt_arch_for_aqt_cmd}" --outputdir "${qt_install_base_dir}" --modules ${required_modules_list}
        else
            echo "All required modules appear to be installed. Skipping Qt installation."
        fi

    else
        echo "Qt version ${qt_version} for ${qt_arch_for_aqt_cmd} not found at ${qt_install_dir}. Proceeding with full installation."
        # Use qt_arch_for_aqt_cmd here as it's the parameter for aqt
        aqt install-qt mac desktop "${qt_version}" "${qt_arch_for_aqt_cmd}" --outputdir "${qt_install_base_dir}" --modules ${required_modules_list}
        needs_install=true
    fi

    echo "--- Qt Installation Check Complete ---"
}