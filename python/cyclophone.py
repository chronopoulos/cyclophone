import serial, pyo, sys, os
from poly import Poly
from tonality import Tonality
import instruments as inst
import synths
import samplepacks as packs
from string import uppercase, lowercase

# Parse Arguments

try:
    if sys.argv[1][:5]=='/dev/':
        deviceFile = sys.argv[1]
    else:
        deviceFile = '/dev/ttyACM0'
except IndexError:
    deviceFile = '/dev/ttyACM0'

if 'debug' in sys.argv:
    debug = True
else:
    debug = False


# Start Audio Server

if 'jack' in sys.argv:
    s = pyo.Server(audio='jack').boot()
else:
    s = pyo.Server().boot()
s.start()

class SoundFlower():

    def __init__(self):
        self.instruments = []

	#instrument 0
        '''
        self.FMchromatic = inst.BrutePoly(order=24, key=30)
        self.FMchromatic.setTonality(Tonality(range(12)))
        self.instruments.append(self.FMchromatic)
        '''

        """
        self.FMpentatonic = inst.BrutePoly(order=6, key=60)
        self.FMpentatonic.setTonality(Tonality([0,2,4,7,9]))
        self.instruments.append(self.FMpentatonic)
        """

        self.FMmajor = inst.BrutePoly(order=24, key=40)
        self.FMmajor.setTonality(Tonality([0,2,4,5,7,9,10]))
        self.instruments.append(self.FMmajor)

	#instrument 1
        self.tr909 = inst.Sampler(packs.tr909, amp=2.0)
        self.instruments.append(self.tr909)

	#instrument 2
        self.rhodes = inst.Sampler(packs.rhodes, amp=1.5)
        self.instruments.append(self.rhodes)

	#instrument 3
        self.koto = inst.Sampler(packs.koto)
        self.instruments.append(self.koto)

	#instrument 4
        self.chimes = inst.Sampler(packs.chimes)
        self.instruments.append(self.chimes)

	#instrument 5
        self.tr606 = inst.Sampler(packs.tr606, amp=1.5)
        self.instruments.append(self.tr606)

	#instrument 6
        self.tr707 = inst.Sampler(packs.tr707, amp=1.5)
        self.instruments.append(self.tr707)

	#instrument 7
        self.tr808 = inst.Sampler(packs.tr808, amp=2.0)
        self.instruments.append(self.tr808)

	#instrument 8
        #self.piano = inst.Sampler(packs.piano, amp=3.)
        #self.instruments.append(self.piano)

        #self.newbass = inst.Sampler(packs.newbass, amp=3.)
        #self.instruments.append(self.newbass)

        self.guitar = inst.Sampler(packs.guitar, amp=3.)
        self.instruments.append(self.guitar)
        
	#instrument 9
        self.newbass = inst.Sampler(packs.newbass, amp=3.)
        self.instruments.append(self.newbass)

	#instrument 10
	self.sine = inst.BrutePoly(voice=synths.Sine, order=24, key=60)
        self.sine.setTonality(Tonality(range(12)))
	self.instruments.append(self.sine)

	#instrument 11
        self.tabla = inst.Sampler(packs.tabla, amp=1.5)
        self.instruments.append(self.tabla)

	#instrument 12
        self.piano = inst.Sampler(packs.piano, amp=3.)
        self.instruments.append(self.piano)
        #self.newbass = inst.Sampler(packs.newbass, amp=3.)
        #self.instruments.append(self.newbass)
	
        #instrument 13
        self.dundunba = inst.Sampler(packs.dundunba, amp=3.)
        self.instruments.append(self.dundunba)

        self.myVol = 1.

        self.mapping0 = {'a':(0,0),
                       'b':(0,1),
                       'c':(0,2),
                       'd':(0,3),
                       'e':(0,4),
                       'f':(0,5),
                       'g':(0,6),
                       'h':(0,7),
                       'i':(0,8),
                       'j':(0,9),
                       'k':(0,10),
                       'l':(0,11),
                       'm':(0,12),
                       'n':(0,13),
                       'o':(0,14),
                       'p':(0,15),
                       'q':(0,16),
                       'r':(0,17),
                       's':(0,18),
                       't':(0,19),
                       'u':(0,20),
                       'v':(0,21),
                       'w':(0,22),
                       'x':(0,23)}

	# pentatonic plus tabla
        self.mapping1 = {'a':(11,0),
                       'b':(11,1),
                       'c':(11,2),
                       'd':(11,3),
                       'e':(11,4),
                       'f':(11,5),
		       # rhodes
                       #'g':(2,0),
                       #'h':(2,1),
                       #'i':(2,2),
                       #'j':(2,3),
                       #'k':(2,4),
                       #'l':(2,5),
                       'g':(8,0),
                       'h':(8,2),
                       'i':(8,4),
                       'j':(8,7),
                       'k':(8,9),
                       'l':(8,12),
                       'm':(3,0),
                       'n':(3,1),
                       'o':(3,2),
                       'p':(3,3),
                       'q':(3,4),
                       'r':(3,5),
                       's':(4,0),
                       't':(4,1),
                       'u':(4,2),
                       'v':(4,3),
                       'w':(4,4),
                       'x':(4,5)}

        self.mapping2 = {'a':(1,0),
                       'b':(1,1),
                       'c':(1,2),
                       'd':(1,3),
                       'e':(1,4),
                       'f':(1,5),
                       'g':(11,0),
                       'h':(11,1),
                       'i':(11,2),
                       'j':(11,3),
                       'k':(11,4),
                       'l':(11,5),
                       'm':(11,6),
                       'n':(13,0),
                       'o':(13,1),
                       'p':(13,2),
                       'q':(13,3),
                       'r':(6,5),
                       's':(7,0),
                       't':(7,1),
                       'u':(7,2),
                       'v':(7,3),
                       'w':(7,4),
                       'x':(7,5)}

        '''
        self.mapping2 = {'a':(1,0),
                       'b':(1,1),
                       'c':(1,2),
                       'd':(1,3),
                       'e':(1,4),
                       'f':(1,5),
                       'g':(5,0),
                       'h':(5,1),
                       'i':(5,2),
                       'j':(5,3),
                       'k':(5,4),
                       'l':(5,5),
                       'm':(6,0),
                       'n':(6,1),
                       'o':(6,2),
                       'p':(6,3),
                       'q':(6,4),
                       'r':(6,5),
                       's':(7,0),
                       't':(7,1),
                       'u':(7,2),
                       'v':(7,3),
                       'w':(7,4),
                       'x':(7,5)}

        self.mapping3 = {'a':(8,0),
                       'b':(8,1),
                       'c':(8,2),
                       'd':(8,3),
                       'e':(8,4),
                       'f':(8,5),
                       'g':(8,6),
                       'h':(8,7),
                       'i':(8,8),
                       'j':(8,9),
                       'k':(8,10),
                       'l':(8,11),
                       'm':(8,12),
                       'n':(8,13),
                       'o':(8,14),
                       'p':(8,15),
                       'q':(8,16),
                       'r':(8,17),
                       's':(8,18),
                       't':(8,19),
                       'u':(8,20),
                       'v':(8,21),
                       'w':(8,22),
                       'x':(8,23)}
        '''

	# guitar, bass harmonic minor?
        self.mapping3 = {'a':(12,0),
                       'b':(12,2),
                       'c':(12,3),
                       'd':(12,5),
                       'e':(12,7),
                       'f':(12,8),
                       'g':(12,11),
                       'h':(12,12),
                       'i':(12,14),
                       'j':(12,15),
                       'k':(12,17),
                       'l':(12,19),
                       'm':(8,0),
                       'n':(8,2),
                       'o':(8,3),
                       'p':(8,5),
                       'q':(8,7),
                       'r':(8,8),
                       's':(8,11),
                       't':(8,12),
                       'u':(8,14),
                       'v':(8,15),
                       'w':(8,17),
                       'x':(8,19)}

        self.mapping4 = {'a':(9,0),
                       'b':(9,1),
                       'c':(9,2),
                       'd':(9,3),
                       'e':(9,4),
                       'f':(9,5),
                       'g':(9,6),
                       'h':(9,7),
                       'i':(9,8),
                       'j':(9,9),
                       'k':(9,10),
                       'l':(9,11),
                       'm':(9,12),
                       'n':(9,13),
                       'o':(9,14),
                       'p':(9,15),
                       'q':(9,16),
                       'r':(9,17),
                       's':(9,18),
                       't':(9,19),
                       'u':(9,20),
                       'v':(9,21),
                       'w':(9,22),
                       'x':(9,23)}

        self.mapping5 = {'a':(10,0),
                       'b':(10,1),
                       'c':(10,2),
                       'd':(10,3),
                       'e':(10,4),
                       'f':(10,5),
                       'g':(10,6),
                       'h':(10,7),
                       'i':(10,8),
                       'j':(10,9),
                       'k':(10,10),
                       'l':(10,11),
                       'm':(10,12),
                       'n':(10,13),
                       'o':(10,14),
                       'p':(10,15),
                       'q':(10,16),
                       'r':(10,17),
                       's':(10,18),
                       't':(10,19),
                       'u':(10,20),
                       'v':(10,21),
                       'w':(10,22),
                       'x':(10,23)}

        self.mapping = self.mapping1

    def play(self, letter):
        i,n = self.mapping[letter]
        self.instruments[i].play(n, 0.25*self.myVol)

    def stop(self, letter):
        i,n = self.stops[letter]
        self.instruments[i].stop(n)

    def handleKnobA(self, value):
        #self.FMchromatic.handleKnobA(value)
        self.FMmajor.handleKnobA(value)
        #self.FMpentatonic.handleKnobA(value)

    def handleKnobB(self, value):
        self.myVol = value/1000.

    def handleKnobC(self, value):
        pass

    def handleSelector(self, letter):
        if letter=='a':
            self.mapping = self.mapping0
            print 'Mode 0 selected'
        elif letter=='b':
            self.mapping = self.mapping1
            print 'Mode 1 selected'
        elif letter=='c':
            self.mapping = self.mapping2
            print 'Mode 2 selected'
        elif letter=='d':
            self.mapping = self.mapping3
            print 'Mode 3 selected'
        elif letter=='e':
            self.mapping = self.mapping5
            print 'Mode 4 selected'

##

soundflower = SoundFlower()
arduino = serial.Serial(deviceFile, 9600)
while True:
    msg = arduino.readline()
    print msg
    if msg[0]=='K':
        if msg[1] in lowercase:
            try:
                soundflower.play(msg[1])
            except KeyError:
                pass
        """
        elif msg[1] in uppercase:
            try:
                soundflower.stop(msg[1])
            except KeyError:
                pass
        """
    elif msg[0]=='A':
        soundflower.handleKnobA(float(msg[1:]))
    elif msg[0]=='B':
        soundflower.handleKnobB(float(msg[1:]))
    elif msg[0]=='C':
        soundflower.handleKnobC(float(msg[1:]))
    elif msg[0]=='S':
        soundflower.handleSelector(msg[1])

