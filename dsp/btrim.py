import aifc, sys, os, pylab
import numpy as np

threshold = 65.
windowSize = 100
delay = 3

if 'plot' in sys.argv:
    plot = True
else:
    plot = False

srcdir = sys.argv[1]
destdir = sys.argv[2]
filelist = os.listdir(srcdir)

for f in filelist:
    aifobject = aifc.open(srcdir+f, 'r')
    allparams = aifobject.getparams()

    nchannels = allparams[0]
    if nchannels==2:
        stereo = True
    else:
        stereo = False

    nframes = allparams[3]

    dataString = aifobject.readframes(nframes)
    aifobject.close()

    data_interleaved = np.fromstring(dataString, np.short).byteswap()

    ieven = [2*i for i in range(nframes)]
    iodd = [2*i+1 for i in range(nframes)]
    data_split = np.array([data_interleaved[ieven], data_interleaved[iodd]])

    onsets = []

    ndownsample = nframes//windowSize
    RMS = np.zeros(ndownsample)

    for i in range(ndownsample):
        RMS[i] = np.sqrt(np.mean(data_split[:, i*100:(i+1)*100]**2))
        print 'Percent Complete: ', i/float(ndownsample)*100
        if i>=1:
            if (RMS[i]-RMS[i-1])>threshold:
                onsets.append(i)

    if (len(onsets) > 0):
      startIndex = onsets[0]*windowSize
      nframes -= startIndex
      allparams = allparams[:3] + (nframes,) + allparams[4:]
      if plot:
          fig = pylab.figure(figsize=(16,8))
          fig.canvas.set_window_title(f)
          pylab.subplot(311, axisbg='k')
          pylab.plot(data_split[0],'r-')
          pylab.axvline(startIndex, color='y')
          pylab.subplot(312, axisbg='k')
          pylab.plot(data_split[1],'g-')
          pylab.axvline(startIndex, color='y')
          pylab.subplot(313, axisbg='k')
          pylab.plot(RMS,'b-')
          for onset in onsets:
              pylab.axvline(onset, color='y')
          pylab.show()
	

    aifobject = aifc.open(destdir+f, 'w')
    aifobject.setparams(allparams)
    aifobject.writeframes(dataString[(startIndex-delay)*4:])
    aifobject.close()
