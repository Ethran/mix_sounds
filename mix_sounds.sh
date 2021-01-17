#!/bin/bash
# skrypcik do mixowania mikrofonu wraz z dziękiem z jednej lub kilku aplikacji
# autor: 	Wikor Wichrowski
# version:  	1.3

echo "before runing this script make sure that you replace microphone and audio output";
echo "with specific to your computer inpu/output names";

mikrofon="nui_mic_denoised_out.monitor";
wyjscie_audio="alsa_output.pci-0000_00_1b.0.analog-stereo";

echo microphone:     $mikrofon;
echo audio_output:   $wyjscie_audio;

GREEN='\033[0;32m'
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
  RESULT=$?
  if [ $RESULT -eq 0 ]; then
     sinks_nubers+=($sink);
     echo success during: $1;
  else
     echo error during: $1;
     clean;
     exit -1;
  fi
}



# stowrzyć sink, aby przekierowac do niego dzięki z aplikacji:
sink=$(pactl load-module module-null-sink sink_name=fsound sink_properties=device.description="#1_sound_from_aplication");
# echo sink: $sink;
check "creating sink: #1_sound_from_aplication";

echo -e "${GREEN}pleace open /pulseaudio volume control/";
echo "and go to playbacks → choose aplication for whith you want redirect sounds";
echo "change from defoult audio output to #1_sound_from_aplication";
echo -e "if you arleady did it should be saved ${NC}";
# otwieramy pulseaudio volume control → playbacks → 
# aplikacja z której dziwęk chcemy przekierować(aplikacja musi aktualnie odtwarzać dzwięk)
# wybieramy zamiast wyjscia audio "#1_sound_from_aplication"

# teraz nie powiniśmy słyszeć dzięku z aplikacji;

# przekierowac monitor stworzonego sinku na wyjscie audio aby nadal słyszeć z niego dzięk:
sink=$(pactl load-module module-loopback source=fsound.monitor sink=$wyjscie_audio)
#echo sink: $sink;
# check if last command success
check "directing #1_sound_from_aplication to audio output: $wyjscie_audio";

# stworzyc sink aby polaczyc dzwięk z aplikacji z mikrofonem:
sink=$(pactl load-module module-null-sink sink_name=micro_app sink_properties=device.description="sound_from_#1_and_noise_tourch_microfone");
#echo sink: $sink;

check "creating sink: sound_from_#1_and_noise_tourch_microfone";

# przekierowac do  micro_app dzięk z mikrofonu
# tutaj przekierowujemy z noise toutch microfone:
sink=$(pactl load-module module-loopback sink=micro_app source=$mikrofon);
#echo sink: $sink;
# check if last command success
check "directing audio input: $mikrofon to sound_from_#1_and_noise_tourch_microfone";

# a tu z mikrofonu:
# pactl load-module module-loopback sink=MySink source=alsa_input.pci-0000_00_1b.0.analog-stereo

# przekierowac do micro_app dziwięk z fsound (który zawiera dzwięk z aplikacji):
sink=$(pactl load-module module-loopback sink=micro_app source=fsound.monitor);

check "directing audio input: #1_sound_from_aplication to sound_from_#1_and_noise_tourch_microfone";
#echo sink: $sink;
# check if last command success
#exit 0;

# for loop that iterates over each element in arr
for i in "${sinks_nubers[@]}"
do
    echo sink: $i;
done

echo -e "${GREEN} in pulseaudio volume control go to recording";
echo "find your aplication and change defoult imput to sound_from_#1_and_noise_tourch_microfone";
echo -e "for example for discord aplication name is: /WEBRTC VoiceEngine: recStream / ${NC} ";


echo "if you want clean and exit pleace type somethink: ";
read a;
echo -e "${GREEN} if something went wrong you can just restart your computer to reverse changes";
echo "or you can clean sinks manualy";
echo -e "by executing comend: pactl unload-module number_of_sinc ${NC} ";

clean;


# otwieramy pulseaudio volume control → recording → 
# szukamy wejscia aplikacji do ktorej checmy przekazać dzięk
# dla discord to WEBRTC VoiceEngine: recStream 
# wybieramy zamiast wyjscia audio "sound_from_#1_and_noise_tourch_microfone"



# jak cofnąć te zmiany:
# po resecie wszystku wróci do normy
# lub można:
# pactl unload-module (w odwrotnej kolejności numerki które się wcześnij pojawiły)

#inne przydatne komendy:
#pacmd list-sources | awk '/index:/ {print $0}; /name:/ {print $0}; /device.description/ {print $0}'
# wypisuje co możemy przekierowac do sink
# pactl list sources
# pactl list sinks
#przekierowanie z komputera wszystkich dzwięków
#pactl load-module module-loopback sink=MySink source=alsa_output.pci-0000_00_1b.0.analog-stereo.monitor
