# Free-Timer
A simple Free Pascal program with GUI (qt5) for GNU/Linux to create a sound signal or power off / reboot the system automatically after a specified time.

To create a sound signal the `paplay` utility (PulseAudio) is used. Make sure you have installed the `pulseaudio-utils` package from your repository:
`sudo apt-get install pulseaudio-utils`

The sound file `alarm.wav` should be located in the program directory.

Lazarus 2.0.0 (qt5) - Debian package.

![Screenshot](timer.png)
