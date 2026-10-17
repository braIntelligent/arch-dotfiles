#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null; : "${BLUE:=0xff7aa2f7}" "${DIM:=0xff565f89}"
IFACE=$(networksetup -listallhardwareports 2>/dev/null | awk '/Wi-Fi/{getline; print $2}')
[ -z "$IFACE" ] && IFACE=en0
ICON_ON=$(printf '\xef\x87\xab')    # nf  wifi (U+F1EB)
if ifconfig "$IFACE" 2>/dev/null | grep -q 'status: active'; then
  SSID=$(ipconfig getsummary "$IFACE" 2>/dev/null | awk -F' SSID : ' '/ SSID :/{print $2; exit}')
  case "$SSID" in ""|*redacted*|*"<"*) SSID="wifi";; esac
  sketchybar --set "$NAME" icon="$ICON_ON" icon.color=$BLUE label="$SSID"
else
  sketchybar --set "$NAME" icon="$ICON_ON" icon.color=$DIM label="sin wifi"
fi
