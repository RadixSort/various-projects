#!/bin/sh
FROM='/tmp'
NAME='test.jpg'
raspistill -n -t 9999999 -tl 0 -w 320 -h 240 -o $FROM"/"$NAME \
& LD_LIBRARY_PATH=/usr/local/lib mjpg_streamer \
-i "input_file.so -f "$FROM"/ -n "$NAME \
-o "output_http.so -w /usr/local/www"
done
