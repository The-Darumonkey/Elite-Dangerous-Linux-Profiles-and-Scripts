# Elite-Dangerous---Linux-Profiles-and-Scripts
A repo to hold Input Remapper profiles and scripts for joysticks and other devices 

After losing scripts and other useful bits of Elite-related stuff during a reinstall, I decided to create this repository so I don't have to rewrite them all next time. My other repository is a personal fork of Input Remapper that spawns several virtual gamepads instead of just one, enabling multi-stick setup with response curves. This repo holds the config files for Input Remapper and scripts for joystick wrangling with evdev-joystick. 

## joystick-init.sh
This is a short Bash script that addresses issues with my joystick (a Winwing Ursa Minor R) in Linux. There are no kernel drivers for it, so while it _is_ recognised as an input device with analogue axes, udev assumes it is a gamepad and sets _very_ conservative defaults, giving it a large deadzone that makes flying generally unpleasant and precision FA-off flying much harder. This script automatically sets both the flat (deadzone) value and fuzz (event filtering) value to zero. I use Input Remapper to implement a response curve on the joystick. The stick's sensors are all Hall effect. I don't need a deadzone or event filtering for noisy potentiometers.

### Usage
If you want to use this script on your own machine, you will need to edit the  script to reflect the input IDs of your peripheral(s).

1. Navigate to /dev/event/input/by-id
2. Find the device ID for your stick. There are multiple entries, each prefixed wuth usb- and with a different suffix (-event-joystick, -hidraw and -joystick on my system). You want to copy the name of the device with the -event-joystick suffix. Mine is `usb-Winwing_WINWING_URSA_MINOR_FIGHTER_FLIGHT_STICK_R_DCE860721456622163E650B2-event-joystick`. Yours will, of course, be different.
3. Replace the ID in the script with the ID of your device.
4. Save the file in `/usr/local/bin`
5. You can name the script as you please, but this name must be reflected excatly in the `99-joystick.rules` file or it won't work.
6. You must include the complementary `.rules` file or the script won't be triggered automatically.

## 99-joystick.rules
This rule triggers `joystick-init.sh`, either during boot or when the joystick is connected. In other words, when you plug your joystick in (or turn your machine on with the joystick plugged in), the deadzone and fuzz values will be set automatically. 

### Usage
To get the rule working for your device, you will need to edit it. 

1. Open a terminal. Enter `lsusb`.
2. In the list of USB devices, find the entry for your stick in the list.
3. The entry will look something like this : `Bus 005 Device 003: ID 4098:bc2a Winwing WINWING URSA MINOR FIGHTER FLIGHT STICK R`
4. You need the vendor ID (VID) and product ID (PID) of your device. This is shown as two 4-character hex values in the `VID:PID` format.
5. In my case, the VID is 4098 and the PID is bc2a - `4098:bc2a`.
6. Replace these values with those from your device.
7. Make sure that the filename specified after `RUN+=` matches the name of the Bash script you saved. 
8. Save the file to `etc/udev/rules.d/` as `99-joystick.rules`.
