#!/bin/sh
set -e
INSTANCE=$1
CONTROL_FIFO="/var/games/minecraft/in"
OUTPUT_FIFO="/var/games/minecraft/out"
# Create a fifo to control the server

if ! [ -p $CONTROL_FIFO ]; then
    mkfifo $CONTROL_FIFO
fi

if ! [ -p $OUTPUT_FIFO ]; then
    mkfifo $OUTPUT_FIFO
fi

cd "/var/games/minecraft/$INSTANCE"
tail -f $CONTROL_FIFO |\
java -Xmx1024M -Xms512M -jar server.jar nogui |\
tee $OUTPUT_FIFO
cd -

rm $CONTROL_FIFO $OUTPUT_FIFO
