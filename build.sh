#! /bin/bash

FILE=$1
NAME="${FILE%.*}"

./build/faustdir/pfx/bin/faust ${NAME}.dsp -a ./myDspFaust.cpp -lang cpp -ct 1 -es 1 -mcd 16 -single -ftz 0 -o ${NAME}.cpp
luajit ./luafpp.lua $(realpath ${NAME}.cpp)
g++ ${NAME}.cpp -I$(pwd) -I./architecture -D JACK_DRIVER=1 -D BUILD=1 -lOSCFaust `pkg-config --cflags --static --libs jack` -o ${NAME}