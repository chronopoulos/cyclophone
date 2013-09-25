#!/usr/bin/python

import serial, liblo, threading, scales

pd = liblo.Address(8000)

keymapping = {'A':0,
            'B':1,
            'C':2,
            'D':3,
            'E':4,
            'F':5,
            'G':6,
            'H':7,
            'I':8,
            'J':9,
            'K':10,
            'L':11,
            'M':12,
            'N':13,
            'O':14,
            'P':15,
            'Q':16,
            'R':17,
            'S':18,
            'T':19,
            'U':20,
            'V':21,
            'W':22,
            'X':23}

knobmapping = {'A':'/delay/time',
                'B':'/synth/filter',
                'C':'/synth/sustain'
                }

buttonmapping = {'a':'/delay/onoff',
                'b':'/kill/on',
                'B':'/kill/off',
                'c':'/loop'
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
    global scale, key
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
            scale = scales.harmonicMinor
        elif mode=='d':
            scale = scales.hungarianMinor
        elif mode=='e':
            scale = scales.majorPentatonic
    elif head=='@':
        button = msg[1]
        pathstr = buttonmapping[button]
        liblo.send(pd, pathstr)
    else:
        t = float(msg[1:])
        index = keymapping[head]
        midi = key + scale(index)
        liblo.send(pd, '/fm/note', midi, velocurve(t))

############

class ArduinoThread(threading.Thread):

    def __init__(self, deviceFile):
        threading.Thread.__init__(self)
        self.arduino = serial.Serial(deviceFile, 115200)

    def run(self):
        while True:
            try:
                handleMsg(self.arduino.readline())
            except KeyboardInterrupt:
                raise KeyboardInterrupt
            except:
                print 'Something weird happened'

    def startKingpin(self):
        while True:
            try:
                handleMsg(self.arduino.readline())
            except KeyboardInterrupt:
                raise KeyboardInterrupt
            except:
                print 'Something weird happened'

#######

if __name__ == '__main__':

    leo = ArduinoThread('/dev/ttyACM1')
    leo.setDaemon(True)
    leo.start()
    due = ArduinoThread('/dev/ttyACM0')
    due.startKingpin()
    try:
        while True: time.sleep(0.1)
    except KeyboardInterrupt:
        print 'Quitting threads...'
        leo.join()
        due.join()

