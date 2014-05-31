import System.IO
import System.Environment
import System.Serial
import System.Posix.Terminal
import qualified Data.ByteString.Char8 as B

-- let port = "COM3"           -- Windows
-- let port = "/dev/ttyUSB0"   -- Linux

printLines serial = do
  ready <- hReady serial
  if ready
    then do 
      line <- hGetLine serial
      print line
      printLines serial
    else do 
      putStr "0"
      printLines serial
      
------------------------------------------------------------------
-- single threaded serial read.
------------------------------------------------------------------

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
        printLines serial
