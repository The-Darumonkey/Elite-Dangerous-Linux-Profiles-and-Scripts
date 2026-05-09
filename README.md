# Elite: Dangerous - Linux Profiles and Scripts
## A repo to hold Input Remapper profiles and scripts for joysticks and other devices 

After losing scripts and other useful bits of Elite-related stuff during a reinstall (yes, I am an idiot), I decided to create this repository so I don't have to rewrite them all next time. My other repository is a personal fork of Input Remapper that spawns several virtual gamepads instead of just one, enabling multi-stick setup with response curves. This repo holds the Input Remapper profiles for my devices, my custom `.binds` file for Elite: Dangerous, and scripts for joystick wrangling with `evdev-joystick`. I reasoned that I might as well make the repo public as the files and info contained here might be useful to others.

The various files and their uses are explained below. 

## joystick-init.sh
This is a short Bash script that addresses issues with my joystick (a Winwing Ursa Minor R) in Linux, although it should apply for any device with analogue axes. There are no specific kernel drivers for the Ursa Minor, so while it _is_ recognised as an input device with analogue axes, udev assumes it is a gamepad and sets _very_ conservative defaults, giving it a large deadzone that makes flying generally unpleasant and precision FA-off flight impossible, especially with the Kestrel. 

You can see the values for your stick by running `evtest` and selecting the event ID of your device. Press Ctrl+C to stop the test and scroll up to see the axis values for your device. My device returns the following values for the X, Y and Z axes:

`Fuzz           255`

`Flat          4095`
      
These are much too large. You can set your desired values manually in the terminal with `evdev-joystick`:

`sudo evdev-joystick --e /dev/input/event13 --f 0 --d 0`

You may need to install `evdev-joystick` first. You can do this in Debian-based distros with `sudo apt install joystick`. 

Make sure to change the event ID to that associated with your device (displayed when runnning `evtest`). The `evdev-joystick` command above sets the deadzone (`--d`, also known as `flat` in `evtest`) and fuzz (`--f`) values to zero. You may find some benefit in playing with the fuzz value if you have, say, a Thrustmaster T.16000M with a dodgy potentiometer on the yaw axis. I use Input Remapper to implement a response curve on my joystick and the stick's axis sensors are all Hall effect, so I need neither a deadzone nor filtering for noisy pots, hence the zeros.

While the approach of using `evdev-joystick` in the terminal works, it is suboptimal in that you must run it every time you plug in the joystick or turn on your PC, which gets old pretty quickly. `joystick-init.sh` automatically sets both the `deadzone (flat)` and `fuzz` values to zero. It uses `by-id` symlinks to sidestep the issue where event IDs can - and do - often change. 

### Usage
If you want to use this script on your own machine, you will need to edit it to reflect the input IDs of your peripheral(s).

1. Navigate to `/dev/event/input/by-id`
2. Find the device ID for your stick. There are multiple entries, each prefixed with `usb-` and with a different suffix (`-event-joystick`, `-hidraw` and `-joystick` on my system). You want to copy the name of the device with the `-event-joystick` suffix. Mine is `usb-Winwing_WINWING_URSA_MINOR_FIGHTER_FLIGHT_STICK_R_DCE860721456622163E650B2-event-joystick`. Yours will likely be different.
3. Replace the ID in the script with the ID of your device.
4. Save the file in `/usr/local/bin/`
5. You can name the script as you please, but this name must be reflected exactly in the `99-joystick.rules` file or it won't work.
6. You must include the complementary `99-joystick.rules` file for the script to be triggered automatically. If you don't include it, you'll have to navigate to `/usr/local/bin/` and trigger the script manually. This is about saving time.

## 99-joystick.rules
This rule triggers `joystick-init.sh`, either during boot or when the joystick is connected. In other words, when you plug in your joystick - or turn on your machine with the joystick plugged in - your desired deadzone and fuzz values will be applied automatically. 

### Usage
To get the rule working for your device, you will need to edit it. 

1. Open a terminal. Enter `lsusb`.
2. In the list of USB devices, find the entry for your stick.
3. The entry will look something like this : `Bus 005 Device 003: ID 4098:bc2a Winwing WINWING URSA MINOR FIGHTER FLIGHT STICK R`
4. You need the vendor ID (VID) and product ID (PID) of your device. This is shown as two 4-character hex values in the `VID:PID` format.
5. In my case, the VID is 4098 and the PID is bc2a - `4098:bc2a`.
6. Replace these values in the rule with those from your device.
7. Make sure that the script specified after `RUN+=` EXACTLY matches the name and path of the Bash script you saved. 
8. Save the file to `/etc/udev/rules.d/` as `99-joystick.rules`.

## Input Remapper profiles
I can't vouch that these files will work on another machine, even if you have the exact same input device - I've never tried. Even if they don't work, you may find it useful to inspect them to inform your choices when setting up your own device profiles. Remember that they depend on a modified fork of Input Remapper (in my other repo) that spawns 3 virtual gamepads instead of the usual 1. 

These `.json` files live in the respective folder for each device in `/home/<username>/.config/input-remapper-2/presets/`

### Profile details
1. `Elite-SpacePilot` is a profile for the 3DConnexion SpacePilot Pro. It maps 5 of the axes on the 6-axis puck to gamepad analogue axes, and the buttons to keystrokes. 
2. `Elite-Tartarus-v2` is a profile for the Razer Tartarus v2 keypad (not Pro, not with optical switches). It remaps some of the default keys. I'll be working on a few macros (like docking request) over the coming weeks. 
3. `Elite-Winwing` is a profile for the Winwing Ursa Minor R joystick. It remaps all the analogue axes (except the throttle slider because laziness) to virtual gamepad axes and the buttons on the right of the base to keystrokes.
- `Elite-Winwing` includes a macro for maximising ammunition in all-frag builds when one of the frags has the corrosive special effect. Map the corrosive frag to the secondary fire key (KEY_APOSTROPHE on the profile here) and all other frags to the primary fire (KEY_SEMICOLON). The macro will fire the corrosive frag twice for every three shells fired on the other frags. This compensates for the 20% ammo reduction and extends your effective engagement time.  

## Custom.4.2.binds
These are only really included for when/if I have to reinstall. You may find some benefit from inspecting them, I suppose. Yes, the bindings make no sense at all if you're playing with a keyboard. I don't care what key I'm pressing when I have a control mapped to a joystick emulating a keypress through Input Remapper. 
