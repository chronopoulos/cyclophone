-- module Main where
import System.Environment
import Spidev
import Text.Printf
import Text.Show.Pretty
import qualified Sound.OSC.FD as O

import qualified Data.ByteString.Char8 as S

import Data.Bits
import Foreign.C.Types
import Foreign.C.String

import Control.Concurrent
import Control.Monad
import System.Directory
import System.IO
import Data.Time.Clock
import Data.List
-- import qualified Data.Map.Strict as M
import qualified Data.Map as M
import qualified Data.Foldable as F

-- mode = SPI_MODE_0 ;
-- bitsPerWord = 8;
-- speed = 1000000;
-- spifd = -1;

bitsperword = 8

-- application settings data structs.

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

-- runtime data structures.

data Sensor = Sensor {
  pin :: CUChar,
  fd :: CInt,
  ignore :: Bool,
  controlword :: (CUChar, CUChar)
  }
  deriving (Show)

data SensorSets = SensorSets {
  sensors :: [Sensor],
  speed :: CInt,
  delay :: Int
  }
  deriving (Show)

data KeyoscState = KeyoscState {
  sensets :: SensorSets,
--  udpconn :: UDP,         -- udp connection, for osc.
  sendfun :: (Int -> String -> IO ()),  -- send osc, print, or something. 
  keythres :: Int,
  pts_onlist :: [Int],    -- what keys are currently on. (ptSendOsc)
  baseline :: [Int],      -- 'zero position' for each key
--  keyseqactive :: Bool,   -- are we doing the 'keysequence' thing?
--  keysequence :: [Int],
--  rangefindingactive :: Bool,-- are we doing the 'rangefinding' calibration?
--  keyrange :: [Int],
  fr_itercount :: Int,
  fr_lasttime :: UTCTime,
  -- since functions can't be compared, we have string IDs for them.
  activeftns :: M.Map String ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
  } 
  -- deriving (Show)

-- keyoscSend :: UDP -> Int -> String -> IO ()
keyoscSend conn amt str = do 
  print (str, amt)
  O.sendOSC conn (O.Message str [O.Int32 (fromIntegral amt)])

--   let sendo msg = sendOSC t (Message msg [Int32 1])

-- if a key is over the threshold, and it wasn't in the 'onlist' before, then
-- send a message and turn it on.


--  t <- openUDP (targetIP appsettings) (targetPort appsettings)  
-- 'Position Threshold send'
ptSend :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
ptSend sensorvals state =
 let  kt = (keythres state)
      baselines = (baseline state)
      onlist = (pts_onlist state) 
      sf = (sendfun state)
      -- reindex and subtract baselines
      indexeson = filter (\(x,y) -> y > kt) 
                    (zip [0..] 
                      (zipWith (\(i,v) b -> v-b) sensorvals baselines))
      sendlist = filter (\(i, v) -> (not (elem i onlist))) indexeson
  in do 
    mapM (\(i,v) -> sf v (drumlist !! i)) sendlist
    return (state { pts_onlist = (map fst indexeson) }) 

-- 'Max Send' - when the threshold is crossed, wait until successive values no longer are 
-- increasing.  send the next-to-last number from that.  
-- how to do:
--    have max array in the state, and keep updated.  
--    another way would be to have the state be local to the function, 
--    and update the function in the keyoscState.  then, not shared state.  but efficiency! 


-- 'Velocity print'
-- 



{-
     if (length sendlist) > 0
      then do
        print "sensorvals"
        print sensorvals
        print "baselines"
        print baselines
        print "zipwith"
        print (zipWith (\(i,v) b -> v-b) sensorvals baselines)
        print "indexeson"
        print indexeson
        print "sendlist"
        print sendlist
        -- sequence_ (map (\(i,v) -> sf (fromIntegral v) (drumlist !! i)) sendlist)
        mapM (\(i,v) -> sf v (drumlist !! i)) sendlist
        return (state { pts_onlist = (map fst indexeson) }) 
      else do
        -- sequence_ (map (\(i,v) -> sf ((fromIntegral v) / 1024.0) (drumlist !! i)) sendlist)
        sequence_ (map (\(i,v) -> sf (fromIntegral v) (drumlist !! i)) sendlist)
        return (state { pts_onlist = (map fst indexeson) }) 
-}

togglePtSend :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
togglePtSend sensorvals state = 
  return $ toggleftn "ptSend" ptSend state

-- version where we don't send indexes that are ignored.
-- sendlist = filter (\i -> (not (elem i onlist)) && (not (elem i ignorelist))) indexeson

--  t <- openUDP (targetIP appsettings) (targetPort appsettings)  
-- 'Velocity Threshold send'
--  
vtSend :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
vtSend sensorvals state =
 let  kt = (keythres state)
      baselines = (baseline state)
      onlist = (pts_onlist state) 
      sf = (sendfun state)
      indexeson = map fst (filter (\(x,y) -> y < kt) (zip [0..] (zipWith (\(i,v) b -> v-b) sensorvals baselines)))
      sendlist = filter (\i -> (not (elem i onlist))) indexeson
  in do
   sequence_ (map (\i -> sf 1 (drumlist !! i)) sendlist)
   return (state { pts_onlist = indexeson }) 


data Calibration = Calibration {
  sensorindex :: [Int],
  -- baseline :: [Int],
  max :: [Int]
  }
  deriving (Show)

-- makeSensorSets :: AdcSettings -> IO SensorSets
makeSensorSets adcSettings = 
  do
    blah <- mapM (\adc -> makeAdcSensors adc (spiSpeed adcSettings)) 
                 (adcs adcSettings)
    let sensors = concat blah
     in 
     return (SensorSets sensors (spiSpeed adcSettings) (spiDelay adcSettings))
 
makeAdcSensors :: Adc -> CInt -> IO [Sensor]
makeAdcSensors adc speed = 
  do
    sensorfd <- spiOpen (devname adc) 0 bitsperword speed
    return (map (\(index,ignore) -> makeSensor sensorfd index ignore) 
                (zip (inputPins adc) (map (\i -> elem i (ignorePins adc)) (inputPins adc))))
    
makeSensor :: CInt -> CUChar -> Bool -> Sensor
makeSensor sensorfd pin ignore = 
  (Sensor pin sensorfd ignore (setupcontrolword pin))

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

-- takes control word, calls spi, returns pin index and value.
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

-- returns list of pins, values.  
-- with multiple spi chips, pin numbers are duplicated, so aren't
-- super useful except as diagnostics.
getsetvals :: SensorSets -> IO [(Int,Int)]
getsetvals sensets = sequence (map (\s -> getval s (speed sensets) (delay sensets)) (sensors sensets)) 

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

framerate_count = 1000

-- the primary loop of the program.
repetay :: SensorSets -> ([(Int,Int)] -> [Int] -> IO [Int]) -> [Int] -> Int -> UTCTime -> IO ()
repetay sensets theftn onlist count lasttime =  
 do
  newvals <- getsetvals sensets       -- get new sensor values each iteration.
  onlist <- theftn newvals onlist     -- theftn returns an 'onlist', which is the current state.
  if (count <= 0)
    then do
      now <- getCurrentTime
      putStr "samples/sec: "
      putStrLn (show ((fromIntegral framerate_count) / (realToFrac (diffUTCTime now lasttime))))
      repetay sensets theftn onlist framerate_count now
    else 
      repetay sensets theftn onlist (count - 1) lasttime

----------------------------------------------------------
-- the primary loop of the program.
-- maintains a list of functions, on each iteration 
-- loops through them allowing them to maintain the state.
----------------------------------------------------------

repete :: KeyoscState -> IO ()
repete state =  
 do
  newvals <- getsetvals (sensets state)       -- get new sensor values each iteration.
  newstate <- F.foldlM (\state ftn -> (ftn newvals state)) state (activeftns state)
  repete newstate

----------------------------------------------------------
-- add/remove ftns from the list of current ftns.
----------------------------------------------------------
toggleftn :: String -> ([(Int,Int)] -> KeyoscState -> IO KeyoscState) -> KeyoscState -> KeyoscState
toggleftn ftnname ftn state = 
  if (M.member ftnname (activeftns state))
   then removeftn ftnname state
   else addftn ftnname ftn state

addftn :: String -> ([(Int,Int)] -> KeyoscState -> IO KeyoscState) -> KeyoscState -> KeyoscState
addftn ftnname ftn state = 
  let newmap = M.insert ftnname ftn (activeftns state)
   in 
    state { activeftns = newmap } 
 
removeftn :: String -> KeyoscState -> KeyoscState
removeftn ftnname state = 
  let newmap = M.delete ftnname (activeftns state)
   in 
    state { activeftns = newmap } 
 

-- given a list of functions of the form ([(Int,Int)] -> KeyoscState -> IO KeyoscState), 
-- builds a function that calls them all in sequence, each using the state emitted by the previous ftn.
--mkmultistate ftnlist = (\newvals state ->
--  foldM (\state ftn -> (ftn newvals state)) state ftnlist)

----------------------------------------------------------------
-- various functions that do stuff with state and sensor values.
----------------------------------------------------------------

showframerate :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
showframerate sensorvals state = 
  if (fr_itercount state) <= 0
    then do
      now <- getCurrentTime
      putStr "samples/sec: "
      putStrLn (show ((fromIntegral framerate_count) / (realToFrac (diffUTCTime now (fr_lasttime state)))))
      return state { fr_itercount = framerate_count, fr_lasttime = now }
    else do
      return state { fr_itercount = (fr_itercount state) - 1 }

printDiffs :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
printDiffs sensorvals state = do
   niceprint (zipWith (\(i,v) b -> v-b) sensorvals (baseline state))
   return state

printVals :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
printVals sensorvals state = do
   niceprint (map snd sensorvals) 
   return state

commands :: M.Map String ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
commands = M.fromList [
  ("diffs", togglePrintDiffs),
  ("vals", togglePrintVals),
  ("frate", toggleShowFrameRate),
  ("ptsend", togglePtSend),
  ("?", printCmds) ]
{-
  ("ptsendosc", togglePtSendOsc)
  ("keyseq", startKeySequence),
  ("range", toggleRangeCalibrate),
  ("resetrange", resetRangeCalibrate),
  ]
-}
   
printCmds :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
printCmds sensorvals state = do
  mapM print (M.keys commands)
  return state

togglePrintVals :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
togglePrintVals sensorvals state = 
  return $ toggleftn "printVals" printVals state

togglePrintDiffs :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
togglePrintDiffs sensorvals state = 
  return $ toggleftn "printDiffs" printDiffs state

toggleShowFrameRate :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
toggleShowFrameRate sensorvals state = 
  return $ toggleftn "frate" showframerate state

{-
toggleRangeCalibrate :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
toggleRangeCalibrate sensorvals state =
  -- if calibrating, write table and stop calibrating.
  -- if not calibrating, start calibrating. 
  return $ toggleftn "rangeCalibrate" printDiffs state


-----------------------------------------------------------------------
-- simple position threshold for osc send.
-----------------------------------------------------------------------

togglePtSendOsc :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
togglePtSendOsc sensorvals state = 
  return $ toggleftn "sendOsc" sendOsc state

toggleSendOsc :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
toggleSendOsc sensorvals state = 
  return $ toggleftn "sendOsc" sendOsc state

to do::: retwrite thressend below to work with the new regime.
also uh... update the onlist in state.  right?

how about have an onlist ftn that will contain other ftns that depend on the onlist?


thressend :: (String -> IO ()) -> Int -> [String] -> [Int] -> [Int] -> ([(Int, Int)] -> [Int] -> IO [Int])
thressend sendfun thres msglist ignorelist baselines = (\newvals onlist ->
 let indexeson = map fst (filter (\(x,y) -> y < thres) (zip [0..] (zipWith (\(i,v) b -> v-b) newvals baselines)))
     sendlist = filter (\i -> (not (elem i onlist)) && (not (elem i ignorelist))) indexeson
  in do
   sequence_ (map (\i -> sendfun (msglist !! i)) sendlist)
   return (sendlist ++ (filter (\i -> (elem i indexeson)) onlist))
  )
-}

commandInput :: ([(Int,Int)] -> KeyoscState -> IO KeyoscState)
commandInput sensorvals state = do
  ready <- hReady stdin
  if ready 
    then do
     cmd <- getLine
     case (M.lookup cmd commands) of
      Nothing -> return state
      (Just ftn) -> ftn sensorvals state
    else
      return state


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

fmlist = zipWith (\a b -> a ++ (show b)) (repeat "/arduino/fm/note/") [11..42]

niceprint [] = 
 do 
   putStrLn ""
niceprint lst = 
 do 
  printf "%4d " (head lst)
  niceprint (tail lst)

-- makes a ftn which contains its own sendfun, msglist, and baselines.
thressend :: (String -> IO ()) -> Int -> [String] -> [Int] -> [Int] -> ([(Int, Int)] -> [Int] -> IO [Int])
thressend sendfun thres msglist ignorelist baselines = (\newvals onlist ->
 let indexeson = map fst (filter (\(x,y) -> y < thres) (zip [0..] (zipWith (\(i,v) b -> v-b) newvals baselines)))
     sendlist = filter (\i -> (not (elem i onlist)) && (not (elem i ignorelist))) indexeson
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

-- print the sensor info as a heading. 
printsensors :: [Sensor] -> IO ()
printsensors sensors = 
 do
  niceprint ((map (\x -> fromIntegral (fd x)) sensors) :: [Int])
  niceprint ((map (\x -> fromIntegral (pin x)) sensors) :: [Int])

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

initialftns appsettings = 
 M.fromList [
  ("commands", commandInput)]

simpleprint :: Int -> String -> IO ()
simpleprint a b = do
 print (a,b)

--  sendKeyMsgs :: Bool,
--  printKeyMsgs :: Bool,
makeSendFun t appsets = 
  if (sendKeyMsgs appsets) 
    then
      if (printKeyMsgs appsets) 
        then
          (\i s -> do 
            simpleprint i s
            keyoscSend t i s)
        else
          keyoscSend t
    else
      if (printKeyMsgs appsets) 
        then
          simpleprint
        else
          (\i s -> return ())

nowgo appsettings = 
 do 
  putStrLn "keyosc v1.0"
  t <- O.openUDP (targetIP appsettings) (targetPort appsettings)
  sensets <- makeSensorSets (adcSettings appsettings)
  printsensors (sensors sensets)
  baselines <- getbaselines sensets 20 appsettings
  print "baselines:"
  niceprint baselines
  now <- getCurrentTime
  let leEtat = KeyoscState sensets (makeSendFun t appsettings) (keythreshold (adcSettings appsettings)) [] baselines framerate_count now initftns 
      initftns = (initialftns appsettings) 
   in do 
    repete leEtat

  -- let leEtat = KeyoscState sensets [] baselines False [] False [] 0 now initftns 
  
getbaselines sensets count appsettings = do
  -- get initial sensor values for baselines.
  vals <- getsvmulti sensets 20 (spiDelay (adcSettings appsettings))
  -- mapM niceprint (map (\vs -> (map (\(i,v) -> v) vs)) vals)
  return $ meadvals vals


