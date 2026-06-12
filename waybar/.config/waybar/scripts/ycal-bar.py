#!/usr/bin/python3
import json
import datetime
import os

CACHE_FILE = os.path.expanduser('~/.cache/waybar-ycal/events.json')

def load_events():
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE) as f:
                return json.load(f)
        except Exception:
            pass
    return {}

now = datetime.datetime.now()
today = now.date()
events = load_events()
today_events = events.get(today.isoformat(), [])

# 󰃭 = calendar icon (U+F00ED), 󰥔 = clock icon (U+F0154)
text = f"\U000f00ed  {now.strftime('%a %d %b')}  \U000f0154  {now.strftime('%H:%M')}"

output = {
    "text": text,
    "tooltip": "",
    "class": "has-events" if today_events else ""
}

print(json.dumps(output))
