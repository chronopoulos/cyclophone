#!/bin/bash
# screen -d -m pd -nogui -audiodev 3 -noadc -audiobuf 15 /home/ccrma/cyclophone/pi/fm/main.pd

# rc.local version:
# 
sudo -H -E -u ccrma screen -d -m pd -nogui -audiodev 3 -noadc -audiobuf 15 /home/ccrma/cyclophone/pi/fm/main.pd
