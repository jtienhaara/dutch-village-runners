#!/bin/sh

echo "Indexing photos..."

#set -o pipefail

RUN_DIR=`dirname $0`
PHOTOS_DIR="$RUN_DIR/../photos"

PHOTOS=`ls -1 $PHOTOS_DIR/*_640x480.jpg \
            | sed 's|^.*/\([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^/]*\)_640x480.jpg$|\1|' \
            | sort -g -r`

INDEX_TEMPLATE_FILE="$RUN_DIR/TEMPLATE_index_all_photos.html"
PHOTO_TEMPLATE_FILE="$RUN_DIR/TEMPLATE_index_photo.html"

INDEX_FILE="$PHOTOS_DIR/index.html"

if test ! -f "$INDEX_TEMPLATE_FILE" \
        -o ! -f "$PHOTO_TEMPLATE_FILE"
then
    echo "ERROR Missing template file(s): $INDEX_TEMPLATE_FILE, $PHOTO_TEMPLATE_FILE must both exist" >&2
    exit 1
fi

TEMP_INDEX_FILE=/tmp/index_photos.html
rm -f "$TEMP_INDEX_FILE"
touch "$TEMP_INDEX_FILE"

ROW_NUM=1
COL_NUM=0
for PHOTO in $PHOTOS
do
    export PHOTO

    echo "  $PHOTO:"

    echo "    Calculating row, col:"
    NEW_COL_NUM=`expr $COL_NUM + 1`
    if test $NEW_COL_NUM -gt 4
    then
        NEW_ROW_NUM=`expr $ROW_NUM + 1`
        ROW_NUM=$NEW_ROW_NUM
        COL_NUM=1
    else
        COL_NUM=$NEW_COL_NUM
    fi

    echo "    Calculating dates:"
    export YEAR=`echo "$PHOTO" \
                     | sed 's|^\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\).*$|\1|'`
    export MONTH=`echo "$PHOTO" \
                      | sed 's|^\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\).*$|\2|'`
    export DAY=`echo "$PHOTO" \
                    | sed 's|^\([0-9][0-9][0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\).*$|\3|'`

    export ISO_DATE="$YEAR-$MONTH-$DAY"
    export DATE_TEXT=`date -d "$ISO_DATE" \
                          '+%B %d, %Y'`
    export MONTH_NAME_LOWER=`date -d "$ISO_DATE" \
                                 '+%B' \
                                 | awk '{ print tolower($0); }'`

    echo "    Adding $PHOTO to index:"
    PHOTO_HTML=`envsubst < "$PHOTO_TEMPLATE_FILE"`
    if test $? -ne 0 \
            -o -z "$PHOTO_HTML"
    then
        echo "ERROR filling in template $PHOTO_TEMPLATE_FILE for photo $PHOTO" >&2
        exit 1
    fi

    if test $COL_NUM -eq 1
    then
        if test $ROW_NUM -gt 1
        then
            echo "      </tr>" >> "$TEMP_INDEX_FILE"
            echo "" >> "$TEMP_INDEX_FILE"
        fi

        echo "      <!-- Row $ROW_NUM: -->" >> "$TEMP_INDEX_FILE"
        echo "      <tr>" >> "$TEMP_INDEX_FILE"
    fi

    echo "$PHOTO_HTML" >> "$TEMP_INDEX_FILE"
done

echo "      </tr>" >> "$TEMP_INDEX_FILE"
echo "" >> "$TEMP_INDEX_FILE"

rm -f "$INDEX_FILE"
touch "$INDEX_FILE"

cat "$INDEX_TEMPLATE_FILE" \
    | awk '
           BEGIN {
               state = "printing";
           }
           $0 ~ /^[ ]*<!-- INSERT_PHOTO_ROWS_HERE -->$/ {
               state = "not_printing";
           }
           state == "printing" {
               print $0;
           }
          ' \
              >> "$INDEX_FILE" \
              || exit 2

cat "$TEMP_INDEX_FILE" \
    >> "$INDEX_FILE" \
    || exit 3

cat "$INDEX_TEMPLATE_FILE" \
    | awk '
           BEGIN {
               state = "not_printing";
           }
           state == "printing" {
               print $0;
           }
           $0 ~ /^[ ]*<!-- INSERT_PHOTO_ROWS_HERE -->$/ {
               state = "printing";
           }
          ' \
              >> "$INDEX_FILE" \
              || exit 4

rm -f "$TEMP_INDEX_FILE"

echo "SUCCESS Indexing photos."
exit 0
