#!/bin/bash

notify() {
  # usage: notify "Title" "Message"
  osascript -e "display notification \"$2\" with title \"$1\""
}

rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt

# Start backend.py in background, save its PID
python3 backend.py &
BACKEND_PID=$!

# Open the default browser with the URL (e.g., Safari)
# Launch Safari with the URL, get its PID
# delay 3 sesconds
sleep 3

notify "MacStats" "Opening the MacStats storage page in Safari."

sleep 1

open -a Safari http://127.0.0.1:4637/storage

sleep 1

notify "MacStats" "Refresh the page if it doesn't load immediately."

sleep 3

notify "MacStats" "To stop the backend, close the browser tab."

# Find the Safari process running the page (wait until the tab is closed)
# We'll poll Safari until it no longer has that tab open.

while true; do
    # Check if Safari has that URL open
    # Using osascript (AppleScript) to check open tabs in Safari
    
    TAB_OPEN=$(osascript <<EOF
tell application "Safari"
    set window_list to windows
    repeat with the_window in window_list
        set tab_list to tabs of the_window
        repeat with the_tab in tab_list
            if (URL of the_tab) contains "127.0.0.1:4637/storage" then
                return "open"
            end if
        end repeat
    end repeat
    return "closed"
end tell
EOF
)

    if [ "$TAB_OPEN" = "closed" ]; then
        echo "Browser tab closed, killing backend."
        kill $BACKEND_PID
        wait $BACKEND_PID 2>/dev/null
        break
    fi

    sleep 2
done
