#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh" 2>/dev/null; : "${GREEN:=0xff73daca}" "${DIM:=0xff565f89}"
ICON=$(printf '\xef\x80\xa3')   # nf  candado (U+F023)
VPN=""
for ifc in $(ifconfig -l 2>/dev/null | tr ' ' '\n' | grep -E '^(utun|tun|ipsec)'); do
  ip=$(ifconfig "$ifc" 2>/dev/null | awk '/inet /{print $2; exit}')
  case "$ip" in
    10.*|172.1[6-9].*|172.2[0-9].*|172.3[01].*) VPN="$ip"; break;;
  esac
done
if [ -n "$VPN" ]; then
  sketchybar --set "$NAME" icon="$ICON" icon.color=$GREEN label="$VPN"
else
  sketchybar --set "$NAME" icon="$ICON" icon.color=$DIM label="disconnected"
fi
