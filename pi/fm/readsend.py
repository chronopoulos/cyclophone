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

drummapping = {'A':'/arduino/drums/tr909/0',
            'B':'/arduino/drums/tr909/1',
            'C':'/arduino/drums/tr909/2',
            'D':'/arduino/drums/tr909/3',
            'E':'/arduino/drums/tr909/4',
            'F':'/arduino/drums/tr909/5',
            'G':'/arduino/drums/dundunba/0',
            'H':'/arduino/drums/dundunba/1',
            'I':'/arduino/drums/dundunba/2',
            'J':'/arduino/drums/dundunba/3',
            'K':'/arduino/drums/rx21Latin/0',
            'L':'/arduino/drums/rx21Latin/1',
            'M':'/arduino/drums/rx21Latin/2',
            'N':'/arduino/drums/rx21Latin/3',
            'O':'/arduino/drums/rx21Latin/4',
            'P':'/arduino/drums/rx21Latin/5',
            'Q':'/arduino/drums/tabla/0',
            'R':'/arduino/drums/tabla/1',
            'S':'/arduino/drums/tabla/2',
            'T':'/arduino/drums/tabla/3',
            'U':'/arduino/drums/tabla/4',
            'V':'/arduino/drums/tabla/5',
            'W':'/arduino/drums/tabla/6',
            'X':'/arduino/drums/tabla/7'
            }

knobmapping = {'A':'/arduino/delay/time',
                'B':'/arduino/fm/harmonic'
                }

buttonmapping = {'a':'/arduino/delay/onoff',
                'b':'/arduino/kill/on',
                'B':'/arduino/kill/off',
                'c':'/arduino/loop'
                    }

scale = scales.chromatic
key = 60
mode = 'synth'

###############

t1 = 800.
t2 = 6000.
mn = 0.01
mx = 0.25
m = (mx-mn)/(t1-t2)
b = (mx+mn-m*(t1+t2))/2.

def velocurve(t):
    if t<800:
        vol = mx
    elif t>6000:
        vol = mn
    else:
        vol = m*t+b
    print vol
    return vol

##########

def handleMsg(msg):
    global scale, key, mode
    print msg
    head = msg[0]
    if head=='#':
        if msg[1]=='C':
            key = 24 + int(float(msg[2:])/21.3125) # 1023/48. = 21.3125
        else:
            liblo.send(pd, knobmapping[msg[1]], float(msg[2:])/1023)
    elif head=='$':
        mode = msg[1]
        if mode=='a':
            mode = 'synth'
            scale = scales.chromatic
        elif mode=='b':
            mode = 'synth'
            scale = scales.major
        elif mode=='c':
            mode = 'synth'
            scale = scales.hungarianMinor
        elif mode=='d':
            mode = 'synth'
            scale = scales.majorPentatonic
        elif mode=='e':
            mode = 'drum'
    elif head=='@':
        button = msg[1]
        pathstr = buttonmapping[button]
        liblo.send(pd, pathstr)
    else:
        t = float(msg[1:])
        if mode=='synth':
            index = keymapping[head]
            midi = key + scale(index)
            liblo.send(pd, '/arduino/fm/note', midi, velocurve(t))
        else:
            liblo.send(pd, drummapping[head], velocurve(t))

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

