#!/bin/bash

# Replace this with your joystick's symlink name from /dev/input/by-id. Don't include the path.
JOYSTICK_SYMLINK="usb-Winwing_WINWING_URSA_MINOR_FIGHTER_FLIGHT_STICK_R_DCE860721456622163E650B2-event-joystick"

DEVICE="/dev/input/by-id/$JOYSTICK_SYMLINK"

{
  echo
  echo "=== JOYSTICK INIT (by symlink) ==="
  echo "Timestamp: $(date)"
  echo "DEVICE: $DEVICE"
  echo "Whoami: $(whoami)"

  if [ -e "$DEVICE" ]; then
    echo "Device found. Applying settings..."
    /usr/bin/evdev-joystick --e "$DEVICE" --d 0 --f 0
    echo "evdev-joystick exit code: $?"
  else
    echo "Device not found at $DEVICE"
  fi
  echo "==============================="
} >> "$LOGFILE" 2>&1
} 2>&1 | logger --skip-empty
