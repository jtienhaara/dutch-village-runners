#!/bin/sh

if test $# -ne 2
then
  echo ""
  echo "Usage:"
  echo "$0 input_filename output_filename"
  echo ""
  echo "Rotates a video 90 degrees counter-clockwise, and re-encodes."
  echo ""
  echo ""
  exit 0
fi

INPUT_FILENAME="$1"
OUTPUT_FILENAME="$2"

exit 1
!!! doesn't work :(
mencoder "$INPUT_FILENAME" \
    -vf rotate=2 \
    -o "$OUTPUT_FILENAME" -fps 25 -ovc lavc vcodec=mpeg4 -oac lavc
RESULT=$?

exit $RESULT

