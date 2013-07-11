import serial, sys, pyo
import instruments as inst
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

# Start Audio Server

if 'jack' in sys.argv:
    s = pyo.Server(audio='jack').boot()
else:
    s = pyo.Server().boot()
s.start()


class Cyclophone():

    def __init__(self):
        self.instruments = []

        self.tr909 = inst.Sampler(packs.tr909, amp=1.5)
        self.instruments.append(self.tr909)

        self.myVol = 1.

        self.mapping0 = {'b':(0,0)}

        self.mapping = self.mapping0

    def play(self, msg):
        flmsg = float(msg)
        level = 400./flmsg
        self.instruments[0].play(1, level)

###

cyclophone = Cyclophone()
arduino = serial.Serial(deviceFile, 230400)
while True:
    msg = arduino.readline()
    print msg
    try:
        cyclophone.play(msg)
    except KeyError:
        pass
