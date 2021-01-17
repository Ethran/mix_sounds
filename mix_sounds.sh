#!/bin/bash
# skrypcik do mixowania mikrofonu wraz z dziękiem z jednej lub kilku aplikacji
# autor: 	Wikor Wichrowski
# version:  	1.5

# before runing this script make sure that you replace microphone and audio output
# with specific to your computer inpu/output names

microphone="nui_mic_denoised_out.monitor";
audio_output="alsa_output.pci-0000_00_1b.0.analog-stereo";

echo microphone:     $microphone;
echo audio_output:   $audio_output;

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
#declarete table for keeping sinks numbers:
declare -a sinks_nubers;


clean(){
   for i in "${sinks_nubers[@]}"
   do
     echo cleaning sink $i;
     pactl unload-module $i;
   done
}
check(){
# check if last command success
  echo sink number: $sink;
  RESULT=$?
  if [ $RESULT -eq 0 ]; then
     sinks_nubers+=($sink);
     echo -e "${GREEN}success during: $1${NC}";
  else
     echo -e "${RED}error during: $1 ${NC}";
     clean;
     exit -1;
  fi
}



# stowrzyć sink, aby przekierowac do niego dzięki z aplikacji:
sink=$(pactl load-module module-null-sink sink_name=fsound sink_properties=device.description="#1_sound_from_aplication");
check "creating sink: #1_sound_from_aplication";


# przekierowac monitor stworzonego sinku na wyjscie audio aby nadal słyszeć z niego dzięk:
sink=$(pactl load-module module-loopback source=fsound.monitor sink=$audio_output)
check "directing #1_sound_from_aplication to audio output: $audio_output";



# stworzyc sink aby polaczyc dzwięk z aplikacji z mikrofonem:
sink=$(pactl load-module module-null-sink sink_name=micro_app  sink_properties=device.description="sound_from_#1_and_noise_tourch_microfone");
check "creating sink: sound_from_#1_and_noise_tourch_microfone";



# przekierowac do  micro_app dzięk z mikrofonu
# tutaj przekierowujemy z noise toutch microfone:
sink=$(pactl load-module module-loopback sink=micro_app source=$microphone);
check "directing audio input: $microphone to sound_from_#1_and_noise_tourch_microfone";



sink=$(pactl load-module module-loopback sink=micro_app source=fsound.monitor);
check "directing audio input: #1_sound_from_aplication to sound_from_#1_and_noise_tourch_microfone";




sink=$(pactl load-module module-remap-source \
master=micro_app.monitor \
source_properties=device.description=Computer-sound)
echo $sink;
check "feke microphone";


echo "if you want clean and exit pleace type somethink: ";
read a;
clean;
exit 0;

