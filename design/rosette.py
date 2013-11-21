import pylab
import numpy as np
import sys

alpha = 0.1
narms = int(sys.argv[1])
cyclo_radius = 20.5 # inches

thetas = []
for i in range(narms):
    thetas.append(np.arange(0,2*np.pi+0.001,2*np.pi/128.)+i*2*np.pi/narms)

r = np.exp(alpha*thetas[0])-1

measurements = []
for rr in r:
    inch = int( cyclo_radius*rr/np.max(r) )
    sixteenth = ((cyclo_radius*rr/np.max(r)) - inch) / (1./16)
    measurements.append((inch,sixteenth))

for m in measurements:
    print m



fig = pylab.figure()
ax = fig.add_subplot(111, polar=True)
ax.grid(False)
for theta in thetas:
    ax.plot(theta, r, color='k', linewidth=2.5)
    ax.plot(-theta, r, color='k', linewidth=2.5)

#pylab.grid(False)
pylab.rgrids([1.], labels=None)
#pylab.thetagrids(np.arange(0., 360., 360./24), labels=None)
#pylab.grids(False)

pylab.show()
