-- module Main where
import System.Environment
-- import System.Posix.IOCtl
-- import System.Posix.IO
-- import GHC.IO.Device
import Spidev
import Text.Printf
import Text.Show.Pretty
import Sound.OSC.FD

import qualified Data.ByteString.Char8 as S
-- import qualified Data.ByteString.Unsafe   as S
-- import qualified Data.ByteString.Internal as S

import Data.Bits
import Foreign.C.Types
import Foreign.C.String

import Control.Concurrent
import System.Directory

-- mode = SPI_MODE_0 ;
-- bitsPerWord = 8;
-- speed = 1000000;
-- spifd = -1;

-- speed = 2000000
-- sensors = map setupcontrolword [2..13]
-- sensorcount = length sensors

bitsperword = 8

data AppSettings = AppSettings {
  adcSettings :: AdcSettings,
  printSensorsValues :: Bool,
  diffFormat :: Bool,
  targetIP :: String,
  targetPort :: Int
  }
  deriving (Show, Read)

data AdcSettings = AdcSettings { 
  adcs :: [Adc],
  spiSpeed :: CInt,
  spiDelay :: Int,
  keythreshold :: Int
  }
  deriving (Show, Read)

data Adc = Adc {
  devname :: String,
  inputPins :: [CUChar]
  }
  deriving (Show, Read)

defaultAppSettings = 
 AppSettings (AdcSettings 
                [(Adc "/dev/spidev0.0" [2..13]),
                 (Adc "/dev/spidev0.1" [2..13])]
                4000000
                0
                (-25))
    True 
    True
    "127.0.0.1"
    8000

data Sensor = Sensor {
  fd :: CInt,
  controlword :: (CUChar, CUChar)
  }
  deriving (Show)

data SensorSets = SensorSets {
  sensors :: [Sensor],
  speed :: CInt,
  delay :: Int
  }
  deriving (Show)

-- makeSensorSets :: AdcSettings -> IO SensorSets
makeSensorSets adcSettings = 
  do
    blah <- sequence (map (\adc -> makeAdcSensors adc (spiSpeed adcSettings)) 
                 (adcs adcSettings))
    let sensors = concat blah
     in 
     return (SensorSets sensors (spiSpeed adcSettings) (spiDelay adcSettings))
 
makeAdcSensors :: Adc -> CInt -> IO [Sensor]
makeAdcSensors adc speed = 
  do
    sensorfd <- spiOpen (devname adc) 0 bitsperword speed
    return (map (\i -> makeSensor sensorfd i) (inputPins adc))
    
makeSensor :: CInt -> CUChar -> Sensor
makeSensor sensorfd pin = 
  (Sensor sensorfd (setupcontrolword pin))



{-
    // --------------- set up the control word -------------
    //            |              indicates manual mode.
    //             |             "enables programming of bits DI6-00"
    //              ||||         address of the ADC for the next frame.
    //                  |        1 = 5V range.  0 = 2.5v
    //                   |       0 = normal operation.  1 = power down.
    //                    |      0 = return ADC address.
    //                           1 = return digital IO vals.
    //                     ||||  digital IO vals, if they are configged for output
    //                           numbering is 3210.
    //data = 0b0001100001000000;

    // last 3 bits are 1st 3 bits of adc index.
    data[0] = 0b00011000 | ((adcindex & 0b00001110) >> 1);

    // first digit is least sig. bit of adc index.
    data[1] = 0b01000000 | (adcindex << 7);
-}

-- let b1 = 0b00011000 .|. (shift -1 (adcindex .&. 0b00001110))
--     b2 = 0b01000000 .|. (shift 7 adcindex)

setupcontrolword :: CUChar -> (CUChar, CUChar)
setupcontrolword adcindex = 
 let intdex = fromIntegral adcindex
     b1 = (24::CUChar) .|. ((shift (adcindex .&. (14::CUChar)) (-1))::CUChar)
     b2 = (64::CUChar) .|. ((shift adcindex 7)::CUChar)
 in (b1,b2)

--  // first 4 bits are adc number. 
--  adcnumber = (data[0] & 0b11110000) >> 4; 
--  // next 10 bits are the adc value.
--  adcvalue = ((data[0] & 0b00001111) << 6) | ((data[1] & 0b11111100) >> 2); 

decodedata :: CUChar -> CUChar -> (Int, Int)
decodedata b1 b2 = 
  let i1 = (fromIntegral b1) :: Int
      i2 = (fromIntegral b2) :: Int
      adcindex = shift (i1 .&. 0xF0) (-4)
      adcvalue = (shift (i1 .&. 0x0F) 6) .|. 
                 (shift (i2 .&. 0xFA) (-2))
  in (adcindex, adcvalue)


-- map setupcontrolword [2..12]

  
-- int spiWriteRead( int fd,
--                   unsigned char *data,
--                   int length,
--                   unsigned char bitsPerWord,
--                   unsigned int speed);

poll :: CInt -> CInt -> Int -> (CUChar, CUChar) -> IO (Int, Int)
poll fd speed delay (b1,b2) = 
 do 
  S.useAsCStringLen (S.pack [castCUCharToChar b1,castCUCharToChar b2]) 
   (\sendbytes -> do
    threadDelay delay 
    c_spiWriteRead fd (fst sendbytes) 2 bitsperword speed
    bs <- S.packCStringLen sendbytes
    return (decodedata (castCharToCUChar (S.index bs 0)) (castCharToCUChar (S.index bs 1)))
    )

printsensorval :: Show a => IO (a1, a) -> IO ()
printsensorval x = 
 do 
   y <- x
   putStr (show (snd y))
   putStr " "

spiOpen :: String -> CUChar -> CUChar -> CInt -> IO CInt
spiOpen devname mode bitsperword speed = 
 S.useAsCString (S.pack devname) 
  (\bdevname -> do
    c_spiOpen bdevname mode bitsperword speed)

getval :: Sensor -> CInt -> Int -> IO (Int,Int)
getval sensor speed delay = 
 poll (fd sensor) speed delay (controlword sensor) 

getsetvals :: SensorSets -> IO [(Int,Int)]
getsetvals sensets = sequence (map (\s -> getval s (speed sensets) (delay sensets)) (sensors sensets)) 

repetay :: SensorSets -> ([(Int,Int)] -> [Int] -> IO [Int]) -> [Int] -> IO ()
repetay sensets theftn onlist =  
 do 
  newvals <- (getsetvals sensets)
  onlist <- theftn newvals onlist
  repetay sensets theftn onlist

drumlist = ["/arduino/drums/tr909/0",
            "/arduino/drums/tr909/1",
            "/arduino/drums/tr909/2",
            "/arduino/drums/tr909/3",
            "/arduino/drums/tr909/4",
            "/arduino/drums/tr909/5",
            "/arduino/drums/dundunba/0",
            "/arduino/drums/dundunba/1",
            "/arduino/drums/dundunba/2",
            "/arduino/drums/dundunba/3",
            "/arduino/drums/rx21Latin/0",
            "/arduino/drums/rx21Latin/1",
            "/arduino/drums/rx21Latin/2",
            "/arduino/drums/rx21Latin/3",
            "/arduino/drums/rx21Latin/4",
            "/arduino/drums/rx21Latin/5",
            "/arduino/drums/tabla/0",
            "/arduino/drums/tabla/1",
            "/arduino/drums/tabla/2",
            "/arduino/drums/tabla/3",
            "/arduino/drums/tabla/4",
            "/arduino/drums/tabla/5",
            "/arduino/drums/tabla/6",
            "/arduino/drums/tabla/7"]

niceprint [] = 
 do 
   putStrLn ""
niceprint lst = 
 do 
  printf "%4d " (head lst)
  niceprint (tail lst)

-- makes a ftn which contains its own sendfun, msglist, and baselines.
thressend :: (String -> IO ()) -> Int -> [String] -> [Int] -> ([(Int, Int)] -> [Int] -> IO [Int])
thressend sendfun thres msglist baselines = (\newvals onlist ->
 let indexeson = map fst (filter (\(x,y) -> y < thres) (zip [0..] (zipWith (\(i,v) b -> v-b) newvals baselines)))
     sendlist = filter (\i -> not (elem i onlist)) indexeson
  in do
   sequence_ (map (\i -> sendfun (msglist !! i)) sendlist)
   return (sendlist ++ (filter (\i -> (elem i indexeson)) onlist))
  )

-- ftn that subtracts the baselines and prints.
mkniceprint :: [Int] -> ([(Int, Int)] -> [Int] -> IO [Int])
mkniceprint baselines = (\newvals onlist ->
 let diffs = (zipWith (\(i,v) b -> v-b) newvals baselines)
  in do
   niceprint diffs
   return onlist
 )

-- ftn that calls multiple ftns.
-- 'onlist' is updated by the first ftn, the rest are ignored.
mkmulti :: [([(Int, Int)] -> [Int] -> IO [Int])] -> ([(Int, Int)] -> [Int] -> IO [Int])
mkmulti ftnlist = (\newvals onlist ->
 do
  wut <- mapM (\ftn -> ftn newvals onlist) ftnlist
  return (wut !! 0)
 )

--getspeed :: [String] :: CInt
getspeed args = 
  if (length args) > 2 
    then (read (args !! 2)) :: CInt 
    else 4000000

prefsfile = "keyosc.prefs"

main = 
  do
    gotPrefs <- doesFileExist prefsfile
    if (not gotPrefs)
      then do 
        putStrLn "keyosc.prefs not found; creating default file."
        writeFile "keyosc.prefs" (ppShow defaultAppSettings)
      else do
        prefs <- (readFile prefsfile)
        nowgo ((read prefs) :: AppSettings)


nowgo appsettings = 
 do 
  putStrLn "keyosc v1.0"
  t <- openUDP (targetIP appsettings) (targetPort appsettings)
  sensets <- makeSensorSets (adcSettings appsettings)
  let sendftn msg = sendOSC t (Message msg [Int32 1])
      thres = (keythreshold (adcSettings appsettings)) 
   in do
    vals <- getsetvals sensets   -- get initial sensor values for baselines.
    if (printSensorsValues appsettings)
      then let blah = thressend sendftn thres drumlist (map snd vals)
               print = mkniceprint (map snd vals)
               multay = mkmulti [blah, print]
       in              
        repetay sensets multay [] 
      else 
        repetay sensets (thressend sendftn thres drumlist (map snd vals)) [] 


