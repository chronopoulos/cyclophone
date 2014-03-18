#!/bin/bash

# make the .o file.
cc -Wall -c spidevice.c
# DO NOT USE A CPP FILE!  ARRRRGHG

# put one or more .o files into a .a static library.
ar -cvq libspidevice.a spidevice.o 


