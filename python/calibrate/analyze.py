import numpy as np
from string import uppercase

data = {}
for l in uppercase:
    data[l] = []

datafile = open('data','r')
line = '\n'
while line != '':
    line = datafile.readline()
    try:
        l = line[0]
        t = int(line[1:])
        if (t>20) and (t<50000):
            data[l].append(t)
    except KeyError:
        pass
    except IndexError:
        pass

datafile.close()

calfile = open('calibration', 'w')

for l in data.keys():
    if len(data[l])>1:
        mean = np.mean(data[l])
        std = np.std(data[l])
        calfile.write(l+' ')
        calfile.write(str(int(mean-std))+' ')
        calfile.write(str(int(mean+std))+'\n')

calfile.close()
    
