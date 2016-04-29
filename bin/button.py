#!/usr/bin/python

import os
import sys
from time import sleep
import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)

reboot_wait = 4
halt_wait = 12

# Set the GPIO number of the button here:
gpio_button = 24        # Pin 18 / GPIO.5 / BCM 24
gpio_led    = 13        # Pin 33 / GPIO.23 / BCM 13
GPIO.setup(gpio_button, GPIO.IN)
GPIO.setup(gpio_led, GPIO.OUT)


reboot_cmd = "sudo shutdown -r now"
halt_cmd = "sudo shutdown -h now"
sleep_ms = 0.5

pressed_now = 0
pressed_prev = 0
counter = 0
i = 0

while True:
  # current button status
  if (GPIO.input(gpio_button) == 1):
    pressed_now = 0
  else:
    pressed_now = 1

  # LED on if pressed now and not previously
  if (pressed_now and not pressed_prev):
    GPIO.output(gpio_led, 1)

  # if recently pressed and now released
  if (pressed_prev and not pressed_now):
    GPIO.output(gpio_led, 0)
    #print counter
    if (counter > halt_wait):
      os.system(halt_cmd)
      break
    if (counter > reboot_wait):
      os.system(reboot_cmd)
      break
    counter = 0

  # if still pressed, count up
  if (pressed_now):
    if (counter >= reboot_wait):
      if (counter % 2 == 0):
        GPIO.output(gpio_led, 1)
      else:
        GPIO.output(gpio_led, 0)
    if (counter >= halt_wait):
      GPIO.output(gpio_led, 0)
    counter += 1

  sleep(sleep_ms)
  pressed_prev = pressed_now
  i +=1