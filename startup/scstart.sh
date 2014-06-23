#!/bin/bash

#jackd -m -p 32 -d dummy --rate 22050 &
jackd -m -p 32 -d dummy &
sleep 1
#alsa_out -d hw:1,0 -r 22050 -q1 2>&1 > /dev/null &
alsa_out -d hw:1,0 -q1 2>&1 > /dev/null &
sleep 1
scsynth -u 57110 &
sleep 1
jack_connect SuperCollider:out_1 alsa_out:playback_1 &
jack_connect SuperCollider:out_2 alsa_out:playback_2 &
