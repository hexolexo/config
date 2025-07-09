read -r t</sys/class/thermal/thermal_zone3/temp;c=t/1000;printf ' %d°C\n' $((c))
