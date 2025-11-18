#!/usr/bin/env bash

# Under Basic:
#     Name: Move To...
#     Description: Move to selected destination
#     Command: ${HOME}/.local/bin/move_to_action.sh %F

# Under Appearance Conditions:
#     File Pattern: *
#     Appears if selection contains: 
#         Directories
#         Audio Files
#         Image Files
#         Text Files
#         Video Files
#         Other Files

DESTINATION=$(/usr/bin/zenity --file-selection --directory --filename="$(pwd)/" --title="Select Destination Folder")
if [ $? -ne 0 ]; then
    exit 1
fi

mv "$@" "$DESTINATION/"

exit 0