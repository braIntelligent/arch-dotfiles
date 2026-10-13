#!/bin/sh
killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 0.2; done
polybar main 2>&1 | tee /tmp/polybar.log &
