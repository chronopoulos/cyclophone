#!/usr/bin/python

import serial, liblo, threading

pd = liblo.Address(8000)

keymapping0 = {'A':'/chimes/0',
            'B':'/chimes/1',
            'C':'/chimes/2',
            'D':'/chimes/3',
            'E':'/chimes/4',
            'F':'/chimes/5',
            'G':'/koto/0',
            'H':'/koto/1',
            'I':'/koto/2',
            'J':'/koto/3',
            'K':'/koto/4',
            'L':'/koto/5',
            'M':'/rhodes/0',
            'N':'/rhodes/1',
            'O':'/rhodes/2',
            'P':'/rhodes/3',
            'Q':'/rhodes/4',
            'R':'/rhodes/5',
            'S':'/tr909/0',
            'T':'/tr909/1',
            'U':'/tr909/2',
            'V':'/tr909/3',
            'W':'/tr909/4',
            'X':'/tr909/5'}

keymapping = keymapping0

knobmapping = {'A':'/delay/time',
                'B':'/delay/feedback',
                'C':'/other'
                }

buttonmapping = {'a':'/delay/onoff',
                'b':'/kill/on',
                'B':'/kill/off',
                'c':'/other'
                    }

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

def handleMsg(msg):
    print msg
    head = msg[0]
    if head=='#':
        liblo.send(pd, knobmapping[msg[1]], float(msg[2:])/1023)
    elif head=='$':
        mode = msg[1]
    elif head=='@':
        button = msg[1]
        pathstr = buttonmapping[button]
        liblo.send(pd, pathstr)
    else:
        t = float(msg[1:])
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

