from flask import Flask, request, render_template, redirect, url_for
import json
import os
from datetime import datetime
import pytz
import subprocess

app = Flask(__name__)

MOTOR_SCRIPT_PATH = os.getenv('MOTOR_SCRIPT_PATH')

def read_config():
    with open('config.json', 'r') as file:
        config = json.load(file)
    return config

def write_config(config):
    with open('config.json', 'w') as file:
        json.dump(config, file)

def update_cronjobs(config):
    # Clear existing cron jobs
    os.system("crontab -r")
    
    # Add cron jobs based on the enabled status
    if config["time1"]["enabled"]:
        hour, minute = config["time1"]["value"].split(':')
        os.system(f"(crontab -l ; echo '{minute} {hour} * * * /usr/bin/python3 {MOTOR_SCRIPT_PATH}') | crontab -")
    if config["time2"]["enabled"]:
        hour, minute = config["time2"]["value"].split(':')
        os.system(f"(crontab -l ; echo '{minute} {hour} * * * /usr/bin/python3 {MOTOR_SCRIPT_PATH}') | crontab -")

def get_system_time():
    tz = pytz.timezone('America/Chicago')
    now = datetime.now(tz)
    return now.strftime('%Y-%m-%d %H:%M:%S')

def update_system_time(new_system_time):
    try:
        # Format the date and time string
        date_string = new_system_time.strftime('%Y-%m-%d %H:%M:%S')
        # Update the system time using sudo
        result = subprocess.run(['date', '-s', date_string], capture_output=True, text=True)
        if result.returncode == 0:
            print("Date/Time Update Successful!")
        else:
            print(f"Error updating date/time: {result.stderr}")
            return f"Failed to update system time: {result.stderr}", 500
    except Exception as e:
        print(f"Exception occurred: {str(e)}")
        return f"Failed to update system time: {str(e)}", 500

@app.route('/')
def index():
    config = read_config()
    system_time = get_system_time()
    success_message = request.args.get('success_message', None)
    error_message = request.args.get('error_message', None)
    snapshot_time = request.args.get('snapshot_time', system_time)
    return render_template('index.html', config=config, system_time=system_time, snapshot_time=snapshot_time, success_message=success_message, error_message=error_message)

@app.route('/update_schedule', methods=['POST'])
def update_schedule():
    try:
        time1_value = request.form['time1']
        time1_enabled = 'time1_enabled' in request.form
        time2_value = request.form['time2']
        time2_enabled = 'time2_enabled' in request.form
        duration = int(request.form['duration'])
        current_system_time = request.form['system_time']
        snapshot_time = request.form['snapshot_time']

        # Validate and sanitize input
        try:
            new_system_time = datetime.strptime(current_system_time, '%Y-%m-%d %H:%M:%S')
            snapshot = datetime.strptime(snapshot_time, '%Y-%m-%d %H:%M:%S')
        except ValueError:
            return "Invalid date format", 400
        
        # Update system time if needed
        if new_system_time != snapshot:
            update_response = update_system_time(new_system_time)
            if update_response:
                return update_response

        # Update configuration and cron jobs
        config = {
            "time1": {"value": time1_value, "enabled": time1_enabled},
            "time2": {"value": time2_value, "enabled": time2_enabled},
            "duration": duration
        }
        write_config(config)
        update_cronjobs(config)

        success_message = "Schedule updated successfully!"
        return redirect(url_for('index', success_message=success_message))
    except Exception as e:
        error_message = f"Failed to update schedule: {str(e)}"
        return redirect(url_for('index', error_message=error_message))

@app.route('/refresh', methods=['GET'])
def refresh():
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=2400)
