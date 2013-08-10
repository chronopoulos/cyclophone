import serial, pyo, sys, os
from poly import Poly
from tonality import Tonality
import instruments as inst
import synths
import samplepacks as packs
from string import uppercase, lowercase

deviceFile = '/dev/ttyACM0'

# Start Audio Server
s = pyo.Server(duplex=0, audio='jack').boot()

class Velociphone():

    def __init__(self):
        self.instruments = []

	#instrument 0
        self.tr909 = inst.Sampler(packs.tr909, amp=2.0)
        self.instruments.append(self.tr909)

	#instrument 1
        self.rhodes = inst.Sampler(packs.rhodes, amp=1.5)
        self.instruments.append(self.rhodes)

	#instrument 2
        self.koto = inst.Sampler(packs.koto)
        self.instruments.append(self.koto)

	#instrument 3
        self.chimes = inst.Sampler(packs.chimes)
        self.instruments.append(self.chimes)

        self.myVol = 1.

        self.mapping0 = {'A':(0,0,0),
                       'B':(1,0,1),
                       'C':(2,0,2),
                       'D':(3,0,3),
                       'E':(4,0,4),
                       'F':(5,0,5),

                       'G':(6,1,0),
                       'H':(7,1,1),
                       'I':(8,1,2),
                       'J':(9,1,3),
                       'K':(10,1,4),
                       'L':(11,1,5),

                       'M':(12,2,0),
                       'N':(13,2,1),
                       'O':(14,2,2),
                       'P':(15,2,3),
                       'Q':(16,2,4),
                       'R':(17,2,5),

                       'S':(18,3,0),
                       'T':(19,3,1),
                       'U':(20,3,2),
                       'V':(21,3,3),
                       'W':(22,3,4),
                       'X':(23,3,5)}


        self.max = [0.4 for i in range(24)]
        self.min = [0.05 for i in range(24)]
        self.t1 = [800. for i in range(24)]
        self.t2 = [6000. for i in range(24)]
        self.m = [(self.max[i]-self.min[i])/(self.t1[i]-self.t2[i]) for i in range(24)]
        self.b = [(self.max[i]+self.min[i]-self.m[i]*(self.t1[i]+self.t2[i]))/2. for i in range(24)]

        self.mapping = self.mapping0

    def play(self, msg):
        key = msg[0]
        i,j,k = self.mapping[key]
        t = int(msg[1:])
        if t<self.t1[i]:
            vol = self.max[i]
        elif t>self.t2[i]:
            vol = self.min[i]
        else:
            vol = self.m[i]*t+self.b[i]
        print 'Volume: ', vol
        self.instruments[j].play(k, vol)

##
s.start()
velociphone = Velociphone()
arduino = serial.Serial(deviceFile, 115200)
while True:
    msg = arduino.readline()
    print msg
    try:
        velociphone.play(msg)
    except KeyError:
        pass

