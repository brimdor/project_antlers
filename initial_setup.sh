#!/bin/bash

# Define paths

export PATH_TO_SCRIPTS="/home/antlers/project_antlers"
export MOTOR_SCRIPT_PATH="$PATH_TO_SCRIPTS/control_motor.py"
export START_SCRIPT_PATH="$PATH_TO_SCRIPTS/start_antlers.sh"
export RC_LOCAL="/etc/rc.local"

# Create the start_antlers.sh script
cat > "$START_SCRIPT_PATH" << EOL
#!/bin/bash
cd $PATH_TO_SCRIPTS
python3 app.py
EOL

# Make start_antlers.sh executable
chmod +x "$START_SCRIPT_PATH"

# Check if the line is already in rc.local
if ! grep -q "$START_SCRIPT_PATH" "$RC_LOCAL"; then
    # Add the line to rc.local before "exit 0"
    sudo sed -i "s|^exit 0|$START_SCRIPT_PATH \&\nexit 0|" "$RC_LOCAL"
    echo "Added start script to rc.local"
else
    echo "Start script already in rc.local"
fi

# Ensure rc.local is executable
sudo chmod +x "$RC_LOCAL"

pip install -r requirements.txt --break-system-packages

echo "Setup complete. The app will now run on boot."

# Run the app immediately
"$START_SCRIPT_PATH"
