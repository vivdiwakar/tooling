#!/usr/bin/env bash

# Under Basic:
#     Name: Convert to JPEG
#     Description: Convert HEIF images to JPEG
#     Command: ${HOME}/.local/bin/convert_to_jpeg.sh %F

# Under Appearance Conditions:
#     File Pattern: *.heic
#     Appears if selection contains: 
#         Image Files

for f in "$@"; do
    /usr/bin/heif-convert "$f" "${f%.*}.jpg"
done

exit 0