import serial, sys, os

deviceFile = '/dev/ttyACM0'

##
arduino = serial.Serial(deviceFile, 115200)
datafile = open('data', 'w')
while True:
    msg = arduino.readline()
    datafile.write(msg)


