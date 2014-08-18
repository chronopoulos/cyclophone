import Sound.SC3

playit = do
 let {fn = "/home/bburdette/cyclophone_samples/mellotron/Cello/A2.wav"
     ;nc = 1
     ;gr = out 0 (diskIn nc 0 Loop)}
--  in withSC3 (do {_ <- async (b_alloc 0 65536 nc)
  in withSC3 (do {_ <- async (b_alloc 0 16384 nc)
                ;_ <- async (b_read 0 fn 0 (-1) 0 True)
                ;play gr})

stopp = 
 withSC3 (do {reset
             ;_ <- async (b_close 0)
             ;async (b_free 0)})

