#!/bin/bash
if ! pgrep -x "openscad" > /dev/null 2>&1; then
    openscad "$1"&
fi
