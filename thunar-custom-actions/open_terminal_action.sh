#!/usr/bin/env bash

# Under Basic:
#     Name: Open Terminal
#     Description: Open terminal here
#     Command: ${HOME}/.local/bin/open_terminal_action.sh

# Under Appearance Conditions:
#     File Pattern: *
#     Appears if selection contains: 
#         Directories

/usr/bin/xdg-terminal-exec --dir=.

exit 0