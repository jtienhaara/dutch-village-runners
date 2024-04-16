#!/bin/sh

if test $# -lt 1
then
    echo "Usage: $0 (image-filename-to-scale)..."
    exit 0
fi

for FILENAME in $*
do
    NEW_FILENAME=`echo "$FILENAME" | sed 's|^\(.*/\)*\([^/]*\)\(\.[^\.]*\)$|\1\2_1024x768\3|'`

    WIDTH=`identify $FILENAME | sed 's|^.* \([0-9]*\)x\([0-9]*\) .*$|\1|'`
    HEIGHT=`identify $FILENAME | sed 's|^.* \([0-9]*\)x\([0-9]*\) .*$|\2|'`

    NEW_WIDTH=1024
    NEW_HEIGHT=768
    if test $WIDTH -gt $HEIGHT
    then
        WIDTH_RATIO=`expr 10 \* $WIDTH / 1024`
        HEIGHT_RATIO=`expr 10 \* $HEIGHT / 768`

        if test $WIDTH_RATIO -lt 10 -o $HEIGHT_RATIO -lt 10
        then
            echo "Cannot scale $FILENAME: ratios are $WIDTH_RATIO x $HEIGHT_RATIO"
            continue
        fi

        if test $WIDTH_RATIO -gt $HEIGHT_RATIO
        then
            NEW_WIDTH=1024
            NEW_HEIGHT=`expr 10 \* $HEIGHT / $WIDTH_RATIO`
        else
            NEW_WIDTH=`expr 10 \* $WIDTH / $HEIGHT_RATIO`
            NEW_HEIGHT=768
        fi
    else
        WIDTH_RATIO=`expr 10 \* $WIDTH / 768`
        HEIGHT_RATIO=`expr 10 \* $HEIGHT / 1024`

        if test $WIDTH_RATIO -lt 10 -o $HEIGHT_RATIO -lt 10
        then
            echo "Cannot scale $FILENAME: ratios are $WIDTH_RATIO x $HEIGHT_RATIO"
            continue
        fi

        if test $WIDTH_RATIO -gt $HEIGHT_RATIO
        then
            NEW_WIDTH=768
            NEW_HEIGHT=`expr 10 \* $HEIGHT / $WIDTH_RATIO`
        else
            NEW_WIDTH=`expr 10 \* $WIDTH / $HEIGHT_RATIO`
            NEW_HEIGHT=1024
        fi
    fi

    echo "Scaling $FILENAME from ${WIDTH}x${HEIGHT} to ${NEW_WIDTH}x${NEW_HEIGHT} as $NEW_FILENAME"

    convert $FILENAME -scale ${NEW_WIDTH}x${NEW_HEIGHT} $NEW_FILENAME
    RESULT=$?
    if test $RESULT -ne 0
    then
        echo "Failed to scale $FILENAME to ${NEW_WIDTH}x${NEW_HEIGHT} as $NEW_FILENAME"
        rm -f $NEW_FILENAME
        exit $RESULT
    fi

    echo "Scaled $FILENAME to $NEW_FILENAME"
done

exit 0

