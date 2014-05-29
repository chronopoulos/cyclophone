import System.IO
import System.Environment
import System.Hardware.Serialport
import qualified Data.ByteString.Char8 as B
import Control.Concurrent
import Control.Concurrent.MVar

-- let port = "COM3"           -- Windows
-- let port = "/dev/ttyUSB0"   -- Linux

printLines serial = do
  line <- getaline serial
  print line
  printLines serial

getaline :: SerialPort -> IO String
getaline serial = do
  c <- recv serial 1
  if B.null c
    then getaline serial
    else case (B.head c) of
      '\r' -> getaline serial
      '\n' -> return ""
      c -> do
        rest <- getaline serial
        return (c : rest)

printLinez serial line = do
  putStr "0"
  lineres <- checkforline serial line
  case lineres of 
    Left linestr -> printLinez serial linestr
    Right linestr -> do 
      print linestr
      printLinez serial ""


checkforline :: SerialPort -> String -> IO (Either String String)
checkforline serial linestr = do
  c <- recv serial 1
  if B.null c
    then return (Left linestr)
    else case (B.head c) of
      '\r' -> return $ Left linestr
      '\n' -> return $ Right (reverse linestr)
      c -> return $ Left (c : linestr)

-- arduline = MVar String

spinforresult :: MVar String -> IO ()
spinforresult line = do
  putStr "0"
  res <- tryTakeMVar line
  case res of
    Just s -> do
      print s
      spinforresult line
    Nothing -> 
      spinforresult line

dumpaline :: SerialPort -> MVar String -> IO ()
dumpaline serial mvar = do
  line <- getaline serial
  putMVar mvar line
  dumpaline serial mvar


main =
  do
    args <- getArgs
    arduline <- newEmptyMVar :: IO (MVar String)
    if (length args) < 1
      then do 
        putStrLn "serialtest requires at least 1 arg:"
        putStrLn "serialtest <com port>"
        putStrLn "example: 'serialtest /dev/ttyACM0'"
      else do
        serial <- openSerial (head args) 
                (defaultSerialSettings { commSpeed = CS115200 })
        forkIO (dumpaline serial arduline)
        spinforresult arduline
        printLinez serial "its over"

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
        serial <- openSerial (head args) 
                (defaultSerialSettings { commSpeed = CS115200 })
        --printLines serial
        printLinez serial ""
-}
