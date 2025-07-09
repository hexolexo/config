#!/bin/bash
brightness=$(brightnessctl get)
if (( brightness > 50 )); then
  brightnessctl set 0%
else
  brightnessctl set 100%
fi
if (( $1 > 0)); then
  grimblast copysave output ~/Pictures/Screenshots/"$(date)".png
else
  grimblast copysave active ~/Pictures/Screenshots/"$(date)".png
fi
brightnessctl set "$brightness"
