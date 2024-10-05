#!/bin/bash
cd /home/antlers/project_antlers
export PATH_TO_SCRIPTS="/home/antlers/project_antlers"
export MOTOR_SCRIPT_PATH="$PATH_TO_SCRIPTS/control_motor.py"
export START_SCRIPT_PATH="$PATH_TO_SCRIPTS/start_antlers.sh"
export RC_LOCAL="/etc/rc.local"
python3 app.py
