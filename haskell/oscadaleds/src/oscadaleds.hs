import Control.Concurrent
import Control.Monad
import Sound.OSC.FD
import System.Environment
import System.Serial
import System.Posix.Terminal
import Data.List
import qualified Data.ByteString.Char8 as B
import GHC.IO.Handle

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

getArgsSerial args = 
 if (length args) < 3
   then "/dev/ttyACM0"
   else (args !! 2)

main = do
  args <- getArgs
  if (length args) < 3
    then do 
      putStrLn "oscadaleds requires 3 args:"
      putStrLn "oscadaleds <ip> <port> <serial port>"
    else do
      putStrLn "oscadaleds server"
      putStrLn $ "recieving OSC msgs at: " ++ (getArgsIp args) ++ ":" ++ show (getArgsPort args) 
      putStrLn $ "serial comms on: " ++ (getArgsSerial args) 
      serial <- openSerial (getArgsSerial args) B115200 8 One Even Software 
      withTransport (t (getArgsIp args) (getArgsPort args)) (f serial)
      where
        f serial fd = forever (recvMessage fd >>= (toSerial serial))
        t ip port = udpServer ip port 

serializeMessage :: Message -> String
serializeMessage msg = 
  foldr (++) "" 
            (intersperse " " 
                  ((messageAddress msg) : 
                   (map datum2Text (messageDatum msg))))

datum2Text :: Datum -> String
datum2Text dt = 
  case dt of 
    Float n -> show (floor n)
    Double n -> show (floor n)
    Int32 n -> show n
    Int64 n -> show n 
    _ -> ""  

printWriteStr :: Maybe Message -> IO ()
printWriteStr (Just msg) = do
  let writestr = serializeMessage msg
  putStrLn writestr
printWriteStr Nothing = do 
  putStrLn "Nothing"

toSerial :: Handle -> Maybe Message -> IO ()
toSerial sp mbmsg = 
  case mbmsg of 
    Just msg -> do
      hPutStr sp ((serializeMessage msg) ++ "\n")

{-
main =
  do
    args <- getArgs
    if (length args) < 1
      then do 
        putStrLn "serialtest requires at least 1 arg:"
        putStrLn "serialtest <com port>"
        putStrLn "example: 'serialtest /dev/ttyACM0'"
      else do
        serial <- openSerial (head args) B115200 8 One Even Software 
        hSetNewlineMode serial universalNewlineMode 
 -}
