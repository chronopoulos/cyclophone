import System.IO
import System.Environment
import System.Hardware.Serialport

-- let port = "COM3"           -- Windows
-- let port = "/dev/ttyUSB0"   -- Linux

printLines h = do
  line <- hGetLine h
  print line
  printLines h

main =
  do
    args <- getArgs
    if (length args) < 4
      then do 
        putStrLn "serialtest requires at least 1 arg:"
        putStrLn "serialtest <com port>"
        putStrLn "example: 'serialtest /dev/ttyACM0'"
      else do
        h <- hOpenSerial (head args) defaultSerialSettings
        printLines h     
        -- hGetLine h >>= print
        -- hPutStr h "AT\r"
        -- hClose h
