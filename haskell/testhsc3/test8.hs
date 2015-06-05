import Sound.SC3
import Sound.OSC
--import Sound.OSC.Transport.FD.UDP

-- withPiSC3 = withTransport (openUDP "192.168.123.144" 57110)
wps = withTransport (openUDP "192.168.123.144" 57110)
-- withPiSC3 = withSC3 

{-

sinosc_l :: UGen
sinosc_l =
    let k = control KR
        o = sinOsc AR (k "freq" 440) (k "phase" 0) * (k "amp" 0.1)
    in out (k "bus" 0) o

audition sinosc_l
withPiSC3 (send (n_set1 (-1) "freq" 660))

-}


makeSynthDef :: String-> Int -> Synthdef
makeSynthDef name freak =
     synthdef name (out 0 ((sinOsc AR (200 + 20 * (constant freak)) 0 * 0.1)
                           * (control KR "amp" 0.5)))

-- sensenth sd = wps (d_recv sd)

playit name id  = 
  wps (send (s_new name id AddToTail 1 [("amp", 0.5)])) 

-- adjvol id a = 
--   withSC3


-- ok maybe 'SharedIn' will be the way to control volume.
-- http://danielnouri.org/docs/SuperColliderHelp/UGens/InOut/SharedIn.html

-- or, actually use Bus.control?  
-- http://danielnouri.org/docs/SuperColliderHelp/ServerArchitecture/Bus.html

-- stop playback, but leave buffer
stopp = 
 wps (do {reset
             ;_ <- async (b_close 0)
             ;async (b_free 0)})


