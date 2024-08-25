#!/bin/bash

# Define paths
SCRIPT_PATH="/home/antlers/project_antlers/start_antlers.sh"
RC_LOCAL="/etc/rc.local"

# Create the start_antlers.sh script
cat > "$SCRIPT_PATH" << EOL
#!/bin/bash
cd /home/antlers/project_antlers
python3 app.py
EOL

# Make start_antlers.sh executable
chmod +x "$SCRIPT_PATH"

# Check if the line is already in rc.local
if ! grep -q "$SCRIPT_PATH" "$RC_LOCAL"; then
    # Add the line to rc.local before "exit 0"
    sudo sed -i "s|^exit 0|$SCRIPT_PATH \&\nexit 0|" "$RC_LOCAL"
    echo "Added start script to rc.local"
else
    echo "Start script already in rc.local"
fi

# Ensure rc.local is executable
sudo chmod +x "$RC_LOCAL"

echo "Setup complete. The app will now run on boot."

# Run the app immediately
"$SCRIPT_PATH"
