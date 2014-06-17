-- module Main where
import System.Environment
import Spidev
import Text.Printf
import Text.Show.Pretty
import Sound.OSC.FD

import qualified Data.ByteString.Char8 as S

import Data.Bits
import Foreign.C.Types
import Foreign.C.String

import Control.Concurrent
import System.Directory
import Data.Time.Clock
import Data.List

-- mode = SPI_MODE_0 ;
-- bitsPerWord = 8;
-- speed = 1000000;
-- spifd = -1;

bitsperword = 8

------------------------------------------------------------
-- settings data types.  
------------------------------------------------------------
data AppSettings = AppSettings {
  adcSettings :: AdcSettings,
  printSensorsValues :: Bool,
  diffFormat :: Bool,
  sendKeyMsgs :: Bool,
  printKeyMsgs :: Bool,
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
  inputPins :: [CUChar],
  ignorePins :: [CUChar]
  }
  deriving (Show, Read)

defaultAppSettings = 
 AppSettings (AdcSettings 
                [(Adc "/dev/spidev0.0" [2..13] []),
                 (Adc "/dev/spidev0.1" [2..13] [])]
                4000000
                0
                (-25))
    True 
    True
    True
    True
    "127.0.0.1"
    8000

------------------------------------------------------------
-- runtime data types for sensors.  build using settings. 
------------------------------------------------------------

data SensorAdc = SensorAdc {
  fd :: CInt,
  adcWord :: S.ByteString,
  pins :: [CUChar]
  }
  deriving (Show)

data SensorSets = SensorSets {
  sensorAdcs :: [SensorAdc],
  speed :: CInt,
  delay :: Int
  }
  deriving (Show)

-- makeSensorSets :: AdcSettings -> IO SensorSets
makeSensorSets adcSettings = 
  do
    adcs <- mapM (\adc -> makeSensorAdc adc (spiSpeed adcSettings)) 
                 (adcs adcSettings)
    return (SensorSets adcs (spiSpeed adcSettings) (spiDelay adcSettings))
 
makeSensorAdc :: Adc -> CInt -> IO SensorAdc
makeSensorAdc adc speed = 
  do
    sensorfd <- spiOpen (devname adc) 0 bitsperword speed
    return $ SensorAdc sensorfd (makeBigWord adc) (inputPins adc)
 
-- makeSensorAdc :: CInt -> S.ByteString -> SensorAdc
-- makeSensorAdc fd adcword = SensorAdc fd adcword

-- makeSensor :: CInt -> CUChar -> Bool -> Sensor
-- makeSensor sensorfd pin ignore = 
--   (Sensor pin sensorfd ignore (setupcontrolword pin))

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
    -- threadDelay delay 
    c_spiWriteRead fd (fst sendbytes) 2 bitsperword speed
    bs <- S.packCStringLen sendbytes
    return (decodedata (castCharToCUChar (S.index bs 0)) (castCharToCUChar (S.index bs 1)))
    )

grupe count list = grupel count list (length list)

grupel count list len =
 if (len < count)
  then if (len == 0)
    then []
    else [list]
  else (take count list) : (grupel count (drop count list) (len - count))

pollall :: CInt -> CInt -> S.ByteString -> IO [(Int,Int)]
pollall fd speed bigword = 
 do 
  S.useAsCStringLen bigword 
   (\sendbytes -> do
    c_spiWriteRead fd (fst sendbytes) (fromIntegral (S.length bigword)) bitsperword speed
    bs <- S.packCStringLen sendbytes
    return (map (\i -> (decodedata (castCharToCUChar (S.index bs i)) (castCharToCUChar (S.index bs (i + 1)))))
                [0,2..((S.length bigword) - 1)])
    )

polladc s_adc speed = 
 pollall (fd s_adc) speed (adcWord s_adc) 
  
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

-- getval :: Sensor -> CInt -> Int -> IO (Int,Int)
-- getval sensor speed delay = 
--  poll (fd sensor) speed delay (controlword sensor) 

getsetvals :: SensorSets -> IO [(Int,Int)]
getsetvals sensets = 
 do 
  vals <- sequence (map (\s -> polladc s (speed sensets)) (sensorAdcs sensets)) 
  return $ concat vals

--getsetvals :: SensorSets -> IO [(Int,Int)]
--getsetvals sensets = sequence (map (\s -> getval s (speed sensets) (delay sensets)) (sensors sensets)) 

-- instead of individual calls to c_spiWriteRead, put all the calls into one long word.
-- use one bigword per Adc.

makeBigWord :: Adc -> S.ByteString
makeBigWord adc = 
 let cws = (map setupcontrolword (inputPins adc)) ++ [setupcontrolword (head (inputPins adc))]
  in S.concat (map (\(b1,b2) -> S.pack([castCUCharToChar b1,castCUCharToChar b2])) cws)

{-
getsvmw :: SensorSets -> IO [(Int,Int)]
let bigword = (concat (map ( [castCUCharToChar b1,castCUCharToChar b2])
getsvmw sensets = sequence (map (\s -> getval s (speed sensets) (delay sensets)) (sensors sensets)) 
-}

{- a purely functional implementation of if-then-else -}
if' :: Bool -> a -> a -> a
if' True  x _ = x
if' False _ y = y

getsvmulti :: SensorSets -> Int -> Int -> IO [[(Int,Int)]]
getsvmulti sensets count delay =
 if' (count <= 0) (return []) $
  do 
    vals <- getsetvals sensets
    threadDelay delay
    moarvals <- getsvmulti sensets (count - 1) delay
    return $ vals : moarvals 

-- not-really-median.  
-- for a real median you average the two middle elts in the case
-- of an even length.  
meadian :: (Ord a) => [a] -> a
meadian (a:b) = (sort (a:b)) !! (quot (length (a:b)) 2)

meadvals :: [[(Int,Int)]] -> [Int]
meadvals lst = 
  map meadian $ transpose (map (\l -> map (\(i,v) -> v) l) lst)

repetay_count = 1000

repetay :: SensorSets -> ([(Int,Int)] -> [Int] -> IO [Int]) -> [Int] -> Int -> UTCTime -> IO ()
repetay sensets theftn onlist count lasttime =  
 do
  newvals <- getsetvals sensets
  onlist <- theftn newvals onlist
  if (count <= 0)
    then do
      now <- getCurrentTime
      putStr "samples/sec: "
      putStrLn (show ((fromIntegral repetay_count) / (realToFrac (diffUTCTime now lasttime))))
      repetay sensets theftn onlist repetay_count now
    else 
      repetay sensets theftn onlist (count - 1) lasttime

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
     sendlist = filter (\i -> (not (elem i onlist))) indexeson
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

printvalues :: [(Int, Int)] -> [Int] -> IO [Int]
printvalues vals onlist = 
 do 
  niceprint (map snd vals)
  return onlist

printindexes :: [(Int, Int)] -> [Int] -> IO [Int]
printindexes vals onlist = 
 do 
  niceprint (map fst vals)
  return onlist

-- ftn that subtracts the baselines and prints.
{-
printsensors :: [Sensor] -> IO ()
printsensors sensors = 
 do
  niceprint ((map (\x -> fromIntegral (fd x)) sensors) :: [Int])
  niceprint ((map (\x -> fromIntegral (pin x)) sensors) :: [Int])
-}

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

makeSendFtn appsettings sendftn printftn = 
 case ((printKeyMsgs appsettings), (sendKeyMsgs appsettings)) of
  (True,True) -> (\msg -> do {sendftn msg; printftn msg})
  (True,False) -> printftn
  (False,True) -> sendftn
  (False,False) -> (\msg -> return ())

-- calcignorelist sensors = 
--  map snd $ filter (\(s,i) -> ignore s) (zip sensors [0..])

nowgo appsettings = 
 do 
  putStrLn "keyosc v1.0"
  t <- openUDP (targetIP appsettings) (targetPort appsettings)
  sensets <- makeSensorSets (adcSettings appsettings)
  -- printsensors (sensors sensets)
  let sendo msg = sendOSC t (Message msg [Int32 1])
      printo msg = putStrLn msg 
      sendftn = makeSendFtn appsettings sendo printo
      thres = (keythreshold (adcSettings appsettings))
      -- ignorelist = (calcignorelist (sensors sensets)) 
   in do
    -- get initial sensor values for baselines.
    vals <- getsvmulti sensets 20 (spiDelay (adcSettings appsettings))
    mapM niceprint (map (\vs -> (map (\(i,v) -> v) vs)) vals)
    now <- getCurrentTime
    -- let medvals = map snd $ head vals
    let medvals = meadvals vals 
     in 
     if (printSensorsValues appsettings)
      then let blah = thressend sendftn thres drumlist medvals
               print = mkniceprint medvals 
               -- multay = mkmulti [blah, printvalues, print]
               -- multay = mkmulti [blah, printindexes, print]
               multay = mkmulti [printvalues]
       in do            
        -- putStrLn (show vals)
        -- niceprint medvals
        -- niceprint (map snd (head vals))
        repetay sensets multay [] repetay_count now 
      else 
        repetay sensets (thressend sendftn thres drumlist medvals) [] repetay_count now

