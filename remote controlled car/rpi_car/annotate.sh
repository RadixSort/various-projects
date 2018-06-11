#!/bin/sh
FROM='/tmp/test.jpg'
TO='/tmp/stream/test.jpg'
DATE=$(date +"%d/%m/%Y")
HOUR=$(date +"%R")
/usr/bin/convert $FROM -gravity north \
-pointsize 14 -fill white -annotate -90+15 $DATE \
-pointsize 14 -fill white -annotate +100+15 $HOUR \
-pointsize 20 -draw "gravity south fill white text 6,6 'test' " \
$TO
done
