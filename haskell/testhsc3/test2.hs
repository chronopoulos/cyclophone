import Sound.SC3

-- yay, works!

playit = do
 -- let {fn = "/home/rohan/data/audio/pf-c5.snd"
 let {fn = "/home/bburdette/samples/mellotron/Cello/A2.wav"
     ;nc = 1
     ;s = bufRateScale KR 0
     ;gr = out 0 (playBuf 1 AR 0 s 1 0 Loop DoNothing)}
  in withSC3 (do {_ <- async (b_allocRead 0 fn 0 0) 
                ;play gr})

stopp = 
 withSC3 (do {reset
             ;_ <- async (b_close 0)
             ;async (b_free 0)})

