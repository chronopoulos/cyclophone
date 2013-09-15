#!/usr/bin/python

import serial, liblo, threading, scales

pd = liblo.Address(8000)

keymapping = {'A':('/fm',0),
            'B':('/fm',1),
            'C':('/fm',2),
            'D':('/fm',3),
            'E':('/fm',4),
            'F':('/fm',5),
            'G':('/fm',6),
            'H':('/fm',7),
            'I':('/fm',8),
            'J':('/fm',9),
            'K':('/fm',10),
            'L':('/fm',11),
            'M':('/fm',12),
            'N':('/fm',13),
            'O':('/fm',14),
            'P':('/fm',15),
            'Q':('/fm',16),
            'R':('/fm',17),
            'S':('/fm',18),
            'T':('/fm',19),
            'U':('/fm',20),
            'V':('/fm',21),
            'W':('/fm',22),
            'X':('/fm',23)}

knobmapping = {'A':'/delay/time',
                'B':'/fm/harmonic',
                'C':'/fm/index'
                }

buttonmapping = {'a':'/delay/onoff',
                'b':'/kill/on',
                'B':'/kill/off',
                'c':'/other'
                    }

scale = scales.chromatic
key = 60

###############

t1 = 800.
t2 = 6000.
mn = 0.05
mx = 0.25
m = (mx-mn)/(t1-t2)
b = (mx+mn-m*(t1+t2))/2.

def velocurve(t):
    if t<800:
        vol = 0.25
    elif t>6000:
        vol = 0.05
    else:
        vol = m*t+b
    print vol
    return vol

##########

def handleMsg(msg):
    global keymapping, synth
    print msg
    head = msg[0]
    if head=='#':
        liblo.send(pd, knobmapping[msg[1]], float(msg[2:])/1023)
    elif head=='$':
        mode = msg[1]
        if mode=='a':
            scale = scales.chromatic
        elif mode=='b':
            scale = scales.major
        elif mode=='c':
            scale = scales.minor
        elif mode=='d':
            scale = scales.majorPentatonic
        elif mode=='e':
            scale = scales.minorPentatonic
    elif head=='@':
        button = msg[1]
        pathstr = buttonmapping[button]
        liblo.send(pd, pathstr)
    else:
        t = float(msg[1:])
        if synth:
            pathstr, midi = keymapping[head]
            liblo.send(pd, pathstr, midi, velocurve(t))
        else:
            pathstr = keymapping[head]
            liblo.send(pd, pathstr, velocurve(t))

############

class ArduinoThread(threading.Thread):

    def __init__(self, deviceFile):
        threading.Thread.__init__(self)
        self.arduino = serial.Serial(deviceFile, 115200)

    def run(self):
        while True:
            try:
                handleMsg(self.arduino.readline())
            except:
                pass # lol

#######

if __name__ == '__main__':

    leo = ArduinoThread('/dev/ttyACM1')
    leo.setDaemon(True)
    leo.start()
    due = ArduinoThread('/dev/ttyACM0')
    due.start()

