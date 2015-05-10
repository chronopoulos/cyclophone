import Control.Concurrent
import Control.Monad
import Sound.OSC.FD
import System.Environment
import Data.Time.Clock

{-
main = 
  let {f fd = forever (recvMessage fd >>= print)
     ;t = udpServer "127.0.0.1" 57300}
  in void (forkIO (withTransport t f))
-}

getArgsIp args = 
 if (length args) < 1 
   then "127.0.0.1"
   else (args !! 0)

getArgsPort args = 
 if (length args) < 2 
   then 9000
   else (read (args !! 1))

main = do
  args <- getArgs
  if (length args) < 2
    then do 
      putStrLn "oscrecv requires 2 args:"
      putStrLn "oscrecv <ip> <port>"
    else do
      withTransport (t (getArgsIp args) (getArgsPort args)) f
      where
        f fd = forever $ do 
          msg <- recvMessage fd
          time <- getCurrentTime
          print $ show time
          print msg
        t ip port = udpServer ip  port 
