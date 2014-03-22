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

main = 
  let {f fd = forever (recvMessage fd >>= print)
     ;t = udpServer "127.0.0.1" 57300}
  in 
    withTransport t f


