import System.IO
import System.Environment
import System.Hardware.Serialport
import qualified Data.ByteString.Char8 as B

-- let port = "COM3"           -- Windows
-- let port = "/dev/ttyUSB0"   -- Linux

printLines serial = do
  line <- getaline serial
  print line
  printLines serial

getaline :: SerialPort -> IO B.ByteString
getaline serial = do
  c <- recv serial 1
  if c == B.pack "\n"
    then return $ B.pack ""
    else do 
      rest <- getaline serial
      return $ B.append c rest 

main =
  do
    args <- getArgs
    if (length args) < 1
      then do 
        putStrLn "serialtest requires at least 1 arg:"
        putStrLn "serialtest <com port>"
        putStrLn "example: 'serialtest /dev/ttyACM0'"
      else do
        serial <- openSerial (head args) 
                (defaultSerialSettings { commSpeed = CS115200 })
        printLines serial     
