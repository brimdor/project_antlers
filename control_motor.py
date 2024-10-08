import RPi.GPIO as GPIO
import time
import json

# Pin definitions
relay_pin = 4
print("GPIO:",relay_pin)

# GPIO setup
GPIO.setmode(GPIO.BCM)
GPIO.setup(relay_pin, GPIO.OUT)
GPIO.output(relay_pin, GPIO.LOW)

def activate_motor(duration):
    GPIO.output(relay_pin, GPIO.HIGH)
    time.sleep(duration)
    GPIO.output(relay_pin, GPIO.LOW)

def read_config():
    with open('/home/antlers/project_antlers/config.json', 'r') as file:
        config = json.load(file)
    return config

if __name__ == "__main__":
    config = read_config()
    print("config:",config)
    duration = config["duration"]
    print("duration:",duration)
    activate_motor(duration)
    GPIO.cleanup()