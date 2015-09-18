#!/bin/bash

# gpio load spi

# sudo modprobe spi-sun7i 

cd /home/bananapi/code/cyclophone/cpp/cyclosensors/

screen -dmS cyclosensors sh -c './cyclosensors'
