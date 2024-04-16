#!/bin/sh

if test $# -lt 1
then
    echo "Usage: $0 (image-filename-to-rotate)..."
    exit 0
fi

for FILENAME in $*
do
    TMP_FILENAME=`echo "$FILENAME" | sed 's|^\(.*/\)*\([^/]*\)$|\1tmp.\2|'`

    convert $FILENAME -rotate 90 $TMP_FILENAME
    RESULT=$?
    if test $RESULT -ne 0
    then
        echo "Failed to rotate $FILENAME 90 degrees"
        rm -f $TMP_FILENAME
        exit $RESULT
    fi

    mv -f $TMP_FILENAME $FILENAME
    RESULT=$?
    if test $RESULT -ne 0
    then
        echo "Could not replace $FILENAME with $TMP_FILENAME"
        exit $RESULT
    fi

    echo "Rotated $FILENAME"
done

exit 0

