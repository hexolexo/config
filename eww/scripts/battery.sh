readonly B="/sys/class/power_supply/BAT1";readonly AC_PATH="/sys/class/power_supply/ACAD/online";read -r S < "$B/capacity";read -r I < "$AC_PATH";P=$((S * 100 / 70));if (( I == 1 )); then
    printf '%d%% | \n' "$P";exit
fi;read -r C < "$B/current_now";read -r V < "$B/voltage_now";printf '%d%% | %dW |\n' "$P" "$((C * V / 1000000000000))"
