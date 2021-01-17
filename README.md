# mix_sounds
Simple script for mixing sound for one or more application.

Develop/tested on Ubuntu 20.04.01 LTS
### Requirements
1. pulseaudio volume control

	``` sudo apt install pavucontrol ```
	
2. pactl

### How to use?

1. Change name of microphone and audio output to specific to your computer input/output names
	* How to get name of audio divices?
	
	Run this command to obtain every possible sources:
	
	```pacmd list-sources | awk '/index:/ {print $0}; /name:/ {print $0}; /device.description/ {print $0}'```
	
	* choose your microphone input and headphones/speekers output
	* change varibles:
		microphone and audio_output
	to this names
	
2. Give permission for executing file:

	``` chmod +x mix_sounds.sh```
	
3. Run the script:

	``` ./mix_sounds.sh ```
	
4. Go to pulseaudio volume control:
	* playbacks
		
	* choose application for which you want redirect sounds
		
	* change from default audio output to #1_sound_from_aplication
		
	* you can do this multiple application.
	
It should save between sessions;

5. In aplication (for example discord) change sound input device;
6. All done


PS usefull links and commends:
https://unix.stackexchange.com/questions/576785/redirecting-pulseaudio-sink-to-a-virtual-source



pactl unload-module 
pacmd list-sources | awk '/index:/ {print $0}; /name:/ {print $0}; /device.description/ {print $0}'
pactl list sources
pactl list sinks
pactl load-module module-loopback sink=MySink source=alsa_output.pci-0000_00_1b.0.analog-stereo.monitor
