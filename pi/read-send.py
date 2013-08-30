import serial, liblo

pd = liblo.Address(8000)

mapping0 = {'A':'/chimes/0',
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

mapping = mapping0

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
    key, t = msg[0], float(msg[1:])
    try:
        pathstr = mapping[key]
        liblo.send(pd, pathstr, velocurve(t))
    except KeyError:
        pass



############

due = serial.Serial('/dev/ttyACM0', 115200)
while True:
    handleMsg(due.readline())
