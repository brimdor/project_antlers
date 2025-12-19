# Project Antlers - Automated Deer Feeder System

## Overview

Project Antlers is an automated deer feeder system designed for Raspberry Pi. It provides a web-based interface to schedule feed dispensing at specific times using motorized feeders controlled by relays. The system allows for two configurable time slots with adjustable duration and can automatically start on system boot.

## Features

- **Web-based Configuration**: Easy-to-use web interface accessible from any device on the network
- **Dual Time Slots**: Configure two separate feeding times per day
- **Flexible Scheduling**: Enable/disable individual time slots as needed
- **Automatic Operation**: Uses cron jobs for scheduled feeding without manual intervention
- **System Time Management**: Built-in system time synchronization
- **Boot Auto-start**: Automatically starts the web service when the Raspberry Pi boots
- **Real-time Status**: Live system time display and configuration feedback

## Hardware Requirements

- Raspberry Pi (any model with GPIO pins)
- Relay module for motor control
- Motorized deer feeder mechanism
- Power supply for Raspberry Pi and motors
- Ethernet cable or WiFi adapter for network access

### GPIO Pin Configuration

The system uses GPIO pin 4 (BCM numbering) to control the relay. Ensure your relay is connected to:
- **GPIO 4**: Relay control signal
- **GND**: Ground connection
- **5V/3.3V**: Power for relay (depending on your relay module)

**⚠️ WARNING**: Double-check your wiring before powering on. Incorrect connections can damage your Raspberry Pi or relay module.

## Software Requirements

- Raspberry Pi OS (or any Debian-based Linux distribution)
- Python 3.7+
- Internet connection for initial setup

## Installation

### 1. Clone or Download the Project

```bash
cd /home/antlers
git clone <repository-url> project_antlers
cd project_antlers
```

### 2. Run Initial Setup

The `initial_setup.sh` script will automatically configure your system:

```bash
sudo ./initial_setup.sh
```

This script will:
- Install Python 3 and pip if not present
- Install required Python dependencies
- Configure environment variables
- Create startup scripts
- Enable auto-start on boot
- Start the web service

### 3. Manual Setup (Alternative)

If you prefer to set up manually:

```bash
# Install Python dependencies
pip install -r requirements.txt

# Make scripts executable
chmod +x start_antlers.sh
chmod +x initial_setup.sh
```

### 4. Hardware Setup

1. Connect your relay module to GPIO pin 4
2. Connect the relay to your motorized feeder
3. Ensure proper power connections for both Pi and motors
4. Test the motor control manually (see Testing section below)

## Usage

### Accessing the Web Interface

Once installed and running, access the web interface at:
```
http://<raspberry-pi-ip>:2400
```

The service starts automatically on boot and runs on port 2400.

### Configuring Feeding Schedule

1. **Time 1 & Time 2**: Set feeding times in HH:MM format (24-hour)
2. **Enable Checkboxes**: Check to activate each time slot
3. **Duration**: Set how long the feeder should run (in seconds)
4. **System Time**: Update if the displayed time is incorrect
5. **Update Schedule**: Save your configuration

### Manual Testing

To test the motor control directly:

```bash
python3 control_motor.py
```

This will activate the motor for the duration specified in `config.json`.

## Configuration Files

### config.json

Contains the feeding schedule configuration:

```json
{
  "time1": {
    "value": "07:35",
    "enabled": false
  },
  "time2": {
    "value": "21:00",
    "enabled": false
  },
  "duration": 2
}
```

- `time1.value`: First feeding time (HH:MM)
- `time1.enabled`: Enable/disable first feeding time
- `time2.value`: Second feeding time (HH:MM)
- `time2.enabled`: Enable/disable second feeding time
- `duration`: Motor run time in seconds

### Environment Variables

The system uses these environment variables (set automatically by setup script):

- `MOTOR_SCRIPT_PATH`: Path to `control_motor.py`
- `PATH_TO_SCRIPTS`: Project directory path
- `START_SCRIPT_PATH`: Path to startup script

## How It Works

1. **Web Interface**: Flask app serves configuration interface
2. **Schedule Management**: Updates `config.json` and cron jobs
3. **Automated Feeding**: Cron jobs execute `control_motor.py` at scheduled times
4. **Motor Control**: Python script activates GPIO relay for specified duration
5. **Time Synchronization**: System time can be updated via web interface

### Cron Job Setup

The system creates cron jobs like:
```
35 7 * * * /usr/bin/python3 /home/antlers/project_antlers/control_motor.py
```

This runs the motor control script at the specified times daily.

## Troubleshooting

### Web Interface Not Accessible

1. Check if the service is running:
   ```bash
   ps aux | grep app.py
   ```

2. Check port 2400:
   ```bash
   netstat -tlnp | grep 2400
   ```

3. Restart the service:
   ```bash
   sudo systemctl restart rc-local
   # or manually:
   ./start_antlers.sh
   ```

### Motor Not Working

1. Verify GPIO connections
2. Test relay manually:
   ```bash
   python3 -c "import RPi.GPIO as GPIO; GPIO.setmode(GPIO.BCM); GPIO.setup(4, GPIO.OUT); GPIO.output(4, GPIO.HIGH); import time; time.sleep(2); GPIO.output(4, GPIO.LOW); GPIO.cleanup()"
   ```

3. Check relay power and motor connections
4. Verify `config.json` has correct duration value

### Time Issues

1. Sync system time:
   ```bash
   sudo date -s "YYYY-MM-DD HH:MM:SS"
   ```

2. Check timezone:
   ```bash
   timedatectl
   ```

3. Use the web interface to set time accurately

### Permission Issues

Ensure proper permissions:
```bash
sudo chown -R antlers:antlers /home/antlers/project_antlers
sudo chmod +x /home/antlers/project_antlers/*.sh
sudo chmod +x /home/antlers/project_antlers/*.py
```

### Logs

Check system logs for errors:
```bash
journalctl -u rc-local
# or check cron logs:
grep CRON /var/log/syslog
```

## Security Considerations

- The web interface runs on port 2400 and is accessible from the network
- Consider adding authentication if exposing to untrusted networks
- The system runs with user privileges (not root) except for time updates

## Development

### Project Structure

```
project_antlers/
├── app.py                 # Flask web application
├── control_motor.py       # Motor control script
├── config.json           # Configuration file
├── requirements.txt      # Python dependencies
├── initial_setup.sh      # Initial setup script
├── start_antlers.sh      # Startup script
├── templates/
│   └── index.html        # Web interface template
├── static/
│   └── styles.css        # CSS styling
└── README.md            # This file
```

### Adding Features

The Flask app can be extended with additional endpoints in `app.py`. Motor control logic can be modified in `control_motor.py`.

## License

[Add your license information here]

## Contributing

[Add contribution guidelines here]

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify hardware connections
3. Check system logs
4. Test components individually

---

**Note**: This system is designed for outdoor use with appropriate weatherproofing. Ensure all electrical connections are protected from moisture and animals.
