import sys, serial

if len(sys.argv)>=2:
    devicefile = sys.argv[1]
else:
    devicefile = '/dev/ttyACM0'

device = serial.Serial(devicefile, 115200)

while True:
    print device.readline()


