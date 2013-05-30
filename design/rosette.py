import pylab
import numpy as np

alpha = 0.1

thetas = []
for i in range(8):
    thetas.append(np.arange(0,2*np.pi,0.01)+i*np.pi/4)

r = np.exp(alpha*thetas[0])-1

for theta in thetas:
    pylab.polar(theta, r, color='k', linewidth=2.5)
    pylab.polar(-theta, r, color='k', linewidth=2.5)

pylab.rgrids([1.], labels=None)
pylab.thetagrids(np.arange(0., 360., 360./24), labels=None)

pylab.show()
