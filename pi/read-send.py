import serial, liblo

pd = liblo.Address(8000)

mapping0 = {'A':'/chimes/0',
            'B':'/chimes/1',
            'C':'/chimes/2',
            'D':'/chimes/3',
            'E':'/chimes/4',
            'F':'/chimes/5'}

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
