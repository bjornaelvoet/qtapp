# Function to check and install Android SDK
# Arguments:
#   $1: Android SDK path (e.g. ~/AndroidSDK)
#   $2: Android SDK component (e.g. ndk;26.1.10909125)
check_and_install_android_sdk() {
    local android_sdk_path="$1"
    local android_component="$2"

    # --- PRIMARY TARGET (e.g., iOS or Desktop) Check and Install ---
    local primary_qt_install_dir="${qt_install_base_dir}/${qt_version}/${qt_folder_name}"
    local primary_qmake_path="${primary_qt_install_dir}/bin/qmake" # Crucial check for base SDK

    echo "--- Checking Android SDK Component (SDK path: ${android_sdk_path}, Component: ${android_component}) ---"

    # List installed packages and check for the component
    if sdkmanager --sdk_root="${android_sdk_path}" --list_installed | grep "${android_component}" > /dev/null; then
        echo "Android SDK component '${android_component}' is already installed."
    else
        echo "Android SDK component '${android_component}' is NOT installed."
        echo "Installing Android SDK component '${android_component}'..."
        # Accept licenses automatically. Be cautious with this in production if you need to review licenses.
        yes | sdkmanager --sdk_root="${android_sdk_path}" "${android_component}"
        if [ $? -eq 0 ]; then
            echo "Successfully installed Android SDK component '${android_component}'."
        else
            echo "Failed to install Android SDK component '${android_component}'. Please check your SDK installation and network."
            exit 1
        fi
    fi

    echo "--- Android SDK Component Check Complete ---"
}