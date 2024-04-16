#!/bin/sh

if test $# -ne 6
then
  echo ""
  echo "Usage:"
  echo "$0 input_filename crop_width crop_height crop_x crop_y output_filename"
  echo ""
  echo ""
  exit 0
fi

INPUT_FILENAME="$1"
CROP_WIDTH="$2"
CROP_HEIGHT="$3"
CROP_X="$4"
CROP_Y="$5"
OUTPUT_FILENAME="$6"

mencoder "$INPUT_FILENAME" \
    -vf crop="${CROP_WIDTH}:${CROP_HEIGHT}:${CROP_X}:${CROP_Y}" \
    -o "$OUTPUT_FILENAME" -fps 25 -ovc lavc -oac lavc
RESULT=$?

exit $RESULT

