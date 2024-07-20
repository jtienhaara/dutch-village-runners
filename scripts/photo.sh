#!/bin/sh

if test $# -lt 1
then
    echo "Usage: $0 (photo).jpg ..." >&2
    echo "" >&2
    echo "Given the specified photos/(photo).jpg file(s), creates a page" >&2
    echo "for each called photos/(photo).html, then links to that page" >&2
    echo "from photos/index.html." >&2
    echo "" >&2
    echo "Whatever path is provided to (photo).jpg, the path is ignored." >&2
    echo "The file must exist in the photos/ sub-directory." >&2
    exit 0
fi

echo "Processing photo(s)..."

RUN_DIR=`dirname $0`
PHOTOS_DIR="$RUN_DIR/../photos"

PHOTOS=""
ERRORS=""
for PHOTO_PATH in $*
do
    PHOTO=`echo "$PHOTO_PATH" \
               | sed 's|^.*/\([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][^/]*\)\.jpg$|\1|'`
    if test "$PHOTO" = "$PHOTO_PATH"
    then
        NEW_ERRORS=`echo "$ERRORS" \
                        | awk \
                              -v "path=$PHOTO_PATH" \
                              '
                               { print $0; }
                               END {
                                   print "Expected (date)....jpg file but found : " path;
                               }
                              '`
        ERRORS="$NEW_ERRORS"
        continue
    elif test ! -f "$PHOTOS_DIR/${PHOTO}.jpg"
    then
        NEW_ERRORS=`echo "$ERRORS" \
                        | awk \
                              -v "path=$PHOTO_PATH" \
                              -v "photo=$PHOTO" \
                              '
                               { print $0; }
                               END {
                                   print "No jpg file photos/" photo ".jpg: " path;
                               }
                              '`
        ERRORS="$NEW_ERRORS"
        continue
    fi

    NEW_PHOTOS="$PHOTOS $PHOTO"
    PHOTOS="$NEW_PHOTOS"
done

if test ! -z "$ERRORS"
then
    echo "ERROR Failed to process photo(s) $*:" >&2
    echo "$ERRORS" >&2
    exit 2
fi

ERRORS=""
for PHOTO in $PHOTOS
do
    export PHOTO

    echo "  $PHOTO:"

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

    #
    # Create a smaller photo for the index page, if necessary.
    #
    if test ! -f "$PHOTOS_DIR/${PHOTO}_640x480.jpg"
    then
        echo "    Creating photos/${PHOTO}_640x480.jpg for index page:"
        $RUN_DIR/shrink_to_640x480.sh "$PHOTOS_DIR/$PHOTO.jpg"
        if test $? -ne 0 \
                -o ! -f "$PHOTOS_DIR/${PHOTO}_640x480.jpg"
        then
            NEW_ERRORS=`echo "$ERRORS" \
                            | awk \
                                  -v "photo=$PHOTO" \
                                  '
                                   { print $0; }
                                   {
                                       print "Photo " photo " failed: no HTML template";
                                   }
                                  '`
            ERRORS="$NEW_ERRORS"
            continue
        fi
    fi

    echo "    Creating photos/$PHOTO.html:"
    #
    # Replace the ${VARIABLE}s in TEMPLATE_photo.html with the appropriate
    # dates etc calculated above.
    #
    PHOTO_HTML=`envsubst < $RUN_DIR/TEMPLATE_photo.html`
    if test $? -ne 0 \
            -o -z "$PHOTO_HTML"
    then
        NEW_ERRORS=`echo "$ERRORS" \
                        | awk \
                              -v "photo=$PHOTO" \
                              '
                               { print $0; }
                               {
                                   print "Photo " photo " failed: no HTML template";
                               }
                              '`
        ERRORS="$NEW_ERRORS"
        continue
    fi

    #
    # Create the (photo).html file:
    #
    PHOTO_HTML_FILE="$PHOTOS_DIR/$PHOTO.html"
    echo "$PHOTO_HTML" \
        > "$PHOTO_HTML_FILE"
    if test $? -ne 0
    then
        NEW_ERRORS=`echo "$ERRORS" \
                        | awk \
                              -v "photo=$PHOTO" \
                              '
                               { print $0; }
                               {
                                   print "Photo " photo " failed: could not write out HTML file";
                               }
                              '`
        ERRORS="$NEW_ERRORS"
        continue
    fi
done

if test ! -z "$ERRORS"
then
    echo "ERROR Failed to properly process (some) photo(s):" >&2
    echo "$ERRORS" >&2
    exit 3
fi

echo "Finished processing photos: $PHOTOS"

echo "SUCCESS processing photo(s)"
exit 0
