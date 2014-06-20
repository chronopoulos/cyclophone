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

-- make a synth from the sample..  'graph' type.
-- actually is synthdef?
makesynth fname bufno = 
  let aname = show bufno ++ "amp"
   in
    withSC3 (do
      async (b_allocRead bufno fname 0 0)
      return $ synth (out 0 ((playBuf 1 AR (constant bufno) 1.0 1 0 Loop RemoveSynth) * (control KR aname 0.5)))
      )

a = makesynth tf1 1
b = makesynth tf2 2

{-

a' <- a
b' <- b

withSC3 (play a')
withSC3 (play b')

-- set a' volume to .7
withSC3 (send (n_set1 (-1) "1amp" .7))
-- set b' volume to .1
withSC3 (send (n_set1 (-1) "2amp" .1))

-}


-- what I want for handling the osc.
-- 1) get msg from keyboard, with key index 0-24.
-- 2) map to name somehow.  get synth.  
-- 3) get volume from msg.
-- 4) if synth is playing, adjust volume.
-- 5) if synth is not playing, start it and adjust volume.

-- one way:  loop all samples.  initially set vol to zero.  always adjusting vol.
-- that's the lame crappy way.

-- another way:  have sc send an 'on complete' osc message when the sample finishes.
-- when that is received, we'll remove the synth or whatever from our active list.

-- ok another way.  
-- track flags in the haskell or C.
--   when key first exceed thres, then trigger the sample from the beginning.
--   otherwise, send volume adjustments.
--   volume adjustments will do nothing once the sample completes.
--   to start playback again, have to take the key below zero.  

-- roight.  
--   now how about the continuous key stuff?  
--   right off the bat, just fucking hard code it.
--   but later want to be able to switch it on and off.  
--   make sure zero is always sent last from the key scanner!

 
{-
makesynth fname bufno = 
  withSC3 (do
    async (b_allocRead bufno fname 0 0)
    return $ synth (out 0 ((playBuf 1 AR (constant bufno) 1.0 1 0 Loop DoNothing) * (control KR "amp" 0.5)))
    )
-}

stop bufno = 
 withSC3 (do {_ <- async (b_close bufno)
             ;async (b_free bufno)})


-- ok maybe 'SharedIn' will be the way to control volume.
-- http://danielnouri.org/docs/SuperColliderHelp/UGens/InOut/SharedIn.html

-- or, actually use Bus.control?  
-- http://danielnouri.org/docs/SuperColliderHelp/ServerArchitecture/Bus.html

-- stop playback, but leave buffer
stopp = 
 withSC3 (do {reset
             ;_ <- async (b_close 0)
             ;async (b_free 0)})

-- restart stopped playback
-- go = 

-- stop playback and delete buffer.
remove = 
 withSC3 (do {reset
             ;_ <- async (b_close 0)
             ;async (b_free 0)})


