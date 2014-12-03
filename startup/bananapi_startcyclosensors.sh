#!/bin/bash

gpio load spi

cd ~/code/cyclophone/cpp/cyclosensors/

screen -d -m ./cyclosensors
