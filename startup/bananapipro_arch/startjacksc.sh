#!/bin/bash

# don't forget this!  maybe needs to go into rc.local or somethign???

#export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket
#export DISPLAY=:0

#screen -d -m jackd -R -P70 -t2000 -d alsa -d hw:0,0 -p1024 -n2 -r 22050

# bananapi onboard sound
#screen -d -m jackd -R -P70 -t2000 -d alsa -d hw:0,0 -p1024 -n2 -r 44100

# creative soundblaster
#screen -d -m jackd -R -P70 -t2000 -d alsa -d hw:1,0 -p128 -n2 -r 44100
#screen -d -m jackd -R -P70 -t2000 -d alsa -d hw:1,0 -p256 -n2 -r 44100
#screen -d -m jackd -R -P70 -t2000 -d alsa -d hw:1,0 -p512 -n2 -r 44100
#screen -d -m jackd -R -P70 -t2000 -d alsa -d hw:1,0 -p256 -n3 -r 44100

#screen -d -m jackd -R -P70 -t2000 -d alsa -d hw:1,0 -p1024 -n2 -r 44100
#id > /home/bananapi/id.out

#capsh --print > /home/bananapi/capshout.print.fromservice

#chrt -p $$ > /home/bananapi/chrt.print.fromservice

# screen -dmS jack_session sh -c 'chrt -r 80 jackd -R -P70 -t2000 -d alsa -d hw:1,0 -p1024 -n2 -r 44100; exec bash'


sleep 30


screen -dmS jack_session sh -c 'jackd -R -P70 -t2000 -d alsa -d hw:1,0 -p1024 -n2 -r 44100; exec bash'


# screen -dmS session_name sh -c 'my-prog; exec bash'

#jackd -m -p 32 -d dummy --rate 22050 &
#jackd -P70 -t2000 -d alsa -d hw:1,0 -p 128 -n 3 -r 44100 -s
#jackd -P70 -t2000 -d alsa -d hw:1,0 -p 256 -n 3 -r 44100 -s

#jackd -P70 -t2000 -d alsa -d hw:0,0 -p 512 -n 3 -r 48000 -s


# jackd -P70 -t2000 -d alsa -d hw:0,0 -n 3 -r 44100 -s &
# jackd -m -p 32 -d dummy &
# alsa_out -d hw:1,0 -r 22050 -q1 2>&1 > /dev/null &
# alsa_out -d hw:0,0 -q1 2>&1 > /dev/null &

sleep 5
#screen -d -m scsynth -u 57110 
screen -dmS scsynth_session sh -c 'scsynth -u 57110; exec bash'

sleep 5
jack_connect SuperCollider:out_1 system:playback_1 &
jack_connect SuperCollider:out_2 system:playback_2 &
#  hopefully will connect audio in to sc correctly.  
#jack_connect system:capture_1 SuperCollider:in_1 &
#jack_connect system:capture_2 SuperCollider:in_2 &
