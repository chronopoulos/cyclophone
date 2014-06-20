import Sound.SC3

{-

sinosc_l :: UGen
sinosc_l =
    let k = control KR
        o = sinOsc AR (k "freq" 440) (k "phase" 0) * (k "amp" 0.1)
    in out (k "bus" 0) o

audition sinosc_l
withSC3 (send (n_set1 (-1) "freq" 660))

-}


tf1 = "/home/bburdette/samples/mellotron/Cello/A2.wav"
tf2 = "/home/bburdette/samples/mellotron/Cello/B4.wav"

readBuf fname bufno =
  withSC3 (do
    async (b_allocRead bufno fname 0 0))

makeSynth bufno =
    synth (out 0 ((playBuf 1 AR (constant bufno) 1.0 1 0 NoLoop RemoveSynth)
                  * (control KR (show bufno ++ "amp") 0.5)))

-- ok maybe 'SharedIn' will be the way to control volume.
-- http://danielnouri.org/docs/SuperColliderHelp/UGens/InOut/SharedIn.html

-- or, actually use Bus.control?  
-- http://danielnouri.org/docs/SuperColliderHelp/ServerArchitecture/Bus.html

-- stop playback, but leave buffer
stopp = 
 withSC3 (do {reset
             ;_ <- async (b_close 0)
             ;async (b_free 0)})


