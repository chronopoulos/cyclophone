import Sound.OSC.FD
import System.Environment

main = 
  do 
    args <- getArgs
    if (length args) < 4
      then do 
        putStrLn "oscsend requires at least 4 args:"
        putStrLn "oscsend <ip> <port> <prefix> <quantities>"
      else do
        t <- openUDP (args !! 0) (read (args !! 1))
        let quants = (read (args !! 3)) :: [Float]
            dtm = map d_put quants
         in do
           putStrLn (show quants)
           sendOSC t (Message (args !! 2) dtm)

