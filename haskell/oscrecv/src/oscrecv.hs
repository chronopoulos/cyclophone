import Control.Concurrent
import Control.Monad
import Sound.OSC.FD
import System.Environment

{-
main = 
  let {f fd = forever (recvMessage fd >>= print)
     ;t = udpServer "127.0.0.1" 57300}
  in void (forkIO (withTransport t f))
-}

getArgsPort args = 
 if (length args) < 1 
   then 9000
   else (read (head args))

main = do
  args <- getArgs
  withTransport (t (getArgsPort args)) f
  where
    f fd = forever (recvMessage fd >>= print)
    t port = udpServer "127.0.0.1" port 
