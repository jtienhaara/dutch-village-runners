#!/bin/sh

if test $# -ne 2
then
  echo ""
  echo "Usage:"
  echo "$0 input_filename output_filename"
  echo ""
  echo "  Flips the video upside-down."
  echo ""
  echo ""
  exit 0
fi

INPUT_FILENAME="$1"
OUTPUT_FILENAME="$2"

mencoder "$INPUT_FILENAME" \
    -vf flip \
    -o "$OUTPUT_FILENAME" -fps 25 -ovc lavc -oac lavc
RESULT=$?

exit $RESULT

