#!/bin/bash

# Function to install the latest version of Python 3 if not already installed
install_python() {
    # Check if Python 3 is installed
    if ! command -v python3 &> /dev/null; then
        echo "Python 3 not found. Installing the latest version..."
        sudo apt-get update
        sudo apt-get install -y python3 python3-pip
        echo "Python 3 and pip installed successfully."
    else
        echo "Python 3 is already installed."
    fi
}

# Function to set up environment variables
setup_environment() {
    export PATH_TO_SCRIPTS="/home/antlers/project_antlers"
    export MOTOR_SCRIPT_PATH="$PATH_TO_SCRIPTS/control_motor.py"
    export START_SCRIPT_PATH="$PATH_TO_SCRIPTS/start_antlers.sh"
    export RC_LOCAL="/etc/rc.local"
}

# Function to create the start script
create_start_script() {
    cat > "$START_SCRIPT_PATH" << EOL
#!/bin/bash
cd $PATH_TO_SCRIPTS
python3 app.py
EOL
    chmod +x "$START_SCRIPT_PATH"
    echo "Start script created and made executable."
}

# Function to add the start script to rc.local
add_to_rc_local() {
    if ! grep -q "$START_SCRIPT_PATH" "$RC_LOCAL"; then
        sed -i "s|^exit 0|$START_SCRIPT_PATH \&\nexit 0|" "$RC_LOCAL"
        echo "Added start script to rc.local."
    else
        echo "Start script already in rc.local."
    fi
    chmod +x "$RC_LOCAL"
}

# Function to install required Python dependencies
install_dependencies() {
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt --break-system-packages
        echo "Python dependencies installed."
    else
        echo "requirements.txt not found. Skipping dependencies installation."
    fi
}

# Function to run the start script immediately
run_start_script() {
    "$START_SCRIPT_PATH"
    echo "App started immediately."
}

# Main function to execute all setup steps
main() {
    install_python
    setup_environment
    create_start_script
    add_to_rc_local
    install_dependencies
    echo "Setup complete. The app will now run on boot."
    run_start_script
}

# Execute the main function
main
