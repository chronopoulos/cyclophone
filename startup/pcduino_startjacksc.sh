#!/bin/bash

# don't forget this!  maybe needs to go into rc.local or somethign???

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
export DISPLAY=:0

#jackd -m -p 32 -d dummy --rate 22050 &
#jackd -P70 -t2000 -d alsa -d hw:1,0 -p 128 -n 3 -r 44100 -s
#jackd -P70 -t2000 -d alsa -d hw:1,0 -p 256 -n 3 -r 44100 -s

#jackd -P70 -t2000 -d alsa -d hw:0,0 -p 512 -n 3 -r 48000 -s

screen -d -m jackd -R -P70 -t2000 -d alsa -d hw:0,0 -p1024 -n2 -r 44100
# jackd -P70 -t2000 -d alsa -d hw:0,0 -n 3 -r 44100 -s &
# jackd -m -p 32 -d dummy &
sleep 5
#alsa_out -d hw:1,0 -r 22050 -q1 2>&1 > /dev/null &
# alsa_out -d hw:0,0 -q1 2>&1 > /dev/null &
sleep 1
screen -d -m scsynth -u 57110 
sleep 5
jack_connect SuperCollider:out_1 system:playback_1 &
jack_connect SuperCollider:out_2 system:playback_2 &
