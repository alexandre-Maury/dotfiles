#!/bin/sh

# ~/.config/hypr/hypridle.conf

ogoutput=$(ddcutil getvcp 10)

tmp=${ogoutput#*=}

output=${tmp%,*}

echo $output > /tmp/brightness

