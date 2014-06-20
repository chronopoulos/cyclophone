import Sound.SC3


-- yay, works!
{-
playit = do
 -- let {fn = "/home/rohan/data/audio/pf-c5.snd"
 let {fn = "/home/bburdette/samples/mellotron/Cello/A2.wav"
     ;nc = 1
     ;s = bufRateScale KR 0
     ;gr = out 0 (playBuf 1 AR 0 s 1 0 Loop DoNothing)}
  in withSC3 (do {_ <- async (b_allocRead 0 fn 0 0) 
                ;play gr})
-}

tf1 = "/home/bburdette/samples/mellotron/Cello/A2.wav"
tf2 = "/home/bburdette/samples/mellotron/Cello/B4.wav"

tests = 
  let a = makesynth tf1 1
      b = makesynth tf2 2
   in do 
    a_ <- a
    b_ <- b
    withSC3 (do
      play a_
      play b_)
 
-- make a synth from the sample..  'graph' type.
-- actually is synthdef?
makesynth fname bufno = 
  withSC3 (do
    async (b_allocRead bufno fname 0 0)
    return $ synth (out 0 (playBuf 1 AR (constant bufno) 1.0 1 0 Loop DoNothing))
    )

stop bufno = 
 withSC3 (do {reset
             ;_ <- async (b_close bufno)
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


