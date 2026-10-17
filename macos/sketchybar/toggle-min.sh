#!/usr/bin/env bash
# Alt+M: si la app enfocada tiene ventanas minimizadas, las restaura;
# si no, minimiza la ventana actual.
osascript <<'OSA'
tell application "System Events"
  set p to first application process whose frontmost is true
  tell p
    set mins to (every window whose value of attribute "AXMinimized" is true)
    if (count of mins) > 0 then
      repeat with w in mins
        set value of attribute "AXMinimized" of w to false
      end repeat
    else
      try
        set value of attribute "AXMinimized" of window 1 to true
      end try
    end if
  end tell
end tell
OSA
