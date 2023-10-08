#! /bin/bash

./build/faustdir/pfx/bin/faust -d mytablethings1.dsp -a ./myDspFaust.cpp -lang cpp -ct 1 -es 1 -mcd 16 -single -ftz 0 -o mytablethings1.cpp
g++ mytablethings1.cpp -I$(pwd) -I./architecture -D JACK_DRIVER=1 -D BUILD=1 -lOSCFaust `pkg-config --cflags --static --libs jack` -o mytablethings1