#!/usr/bin/env bash
# Rescate: restaura TODAS las ventanas minimizadas de todas las apps.
osascript <<'OSA' 2>/dev/null
tell application "System Events"
  repeat with p in (every process whose background only is false)
    try
      repeat with w in (every window of p whose value of attribute "AXMinimized" is true)
        set value of attribute "AXMinimized" of w to false
      end repeat
    end try
  end repeat
end tell
OSA
