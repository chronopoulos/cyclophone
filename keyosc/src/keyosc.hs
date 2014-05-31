-- module Main where
import System.Environment
import Spidev
import Text.Printf
import Text.Show.Pretty
import qualified Sound.OSC.FD as O
import Scales

import qualified Data.ByteString.Char8 as B

import Data.Bits
import Foreign.C.Types
import Foreign.C.String

import Control.Monad
import Control.Concurrent
import Control.Concurrent.MVar
import System.IO
import System.Directory
import System.Serial
import System.Posix.Terminal
import Data.Time.Clock
import Data.List
import Data.Maybe
-- import qualified Data.Map.Strict as M
import qualified Data.Map as M
import qualified Data.Foldable as F

import qualified CycloMap as CM


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
  targetPort :: Int,
  outwritecount :: Int,
  soundmap :: String,
  arduinoserial :: Maybe String
  }
  deriving (Show, Read)

data AdcSettings = AdcSettings { 
  adcs :: [Adc],
  spiSpeed :: CInt,
  spiDelay :: Int,
  keythreshold :: Int,
  velthreshold :: Int,
  positionUpdateIntervalSecs :: Float
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
                [(Adc "/dev/spidev0.0" [0..11] []),
                 (Adc "/dev/spidev0.1" [0..11] [])]
                2000000
                0
                50
                25
                100)
    True 
    True
    True
    True
    "127.0.0.1"
    8000
    2500
    "soundmap"
    Nothing

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
  delay :: Int,
  keythres :: Int,
  velthres :: Int,
  posuptime :: NominalDiffTime    -- min time between position updates.
  }
  deriving (Show)

data KeyoscState = KeyoscState {
  sensets :: SensorSets,
  keysendstate :: CM.KeySendState,
  -- for keys, send osc, print, or something. 
  oscsendfun :: (O.Message -> IO ()),  
  -- get a line from the arduino serial port, if any. 
  getarduinoline :: IO (Maybe String),
  -- stuff for thres-send
  thres_onlist :: [Int],          -- what keys have values over their thresholds. [Index] 
  thres_sendlist :: [(Int,Int)],  -- what keys were just turned on - (index,value)
  maxes_sendlist :: [(Int,Int)],  -- max to send out. 
  maxes_sent :: [Int] ,           -- maxes already sent, need reset by going below thres
  maxes :: [Int] ,                -- max bucket.  zero out when sent.
  baseline :: [Int],              -- 'zero position' for each key
  -- stuff for overThresSend
  otsstate :: OtsState,
  -- stuff for framerate
  fr_itercount :: Int,
  fr_lasttime :: UTCTime,
  fr_lastfr :: Float,
  -- stuff for velocity
  prevvals :: [Int],
  velocities :: [Int], 
  prevvelocities :: [Int],
  velocity_sendlist :: [(Int,Int)],
  velsent :: [Int],           
  -- writing out data.
  out_count_init :: Int,      -- how many records to write
  out_count :: Int,           -- counter for writing records.
  out_start :: UTCTime,       -- time at counter start.
  out_vals :: [[Int]],        -- data to write.  store in memory, then write.
  -- since functions can't be compared, we have string IDs for them.
  updateftns :: M.Map String (Input -> KeyoscState -> KeyoscState),
  ioftns :: M.Map String (Input -> KeyoscState -> IO ())
  } 
  -- deriving (Show)

data Input = Input { 
  sensorvals :: [(Int,Int)],
  commandline :: Maybe String,
  arduinoline :: Maybe String,
  now :: UTCTime
  }

-----------------------------------------------------------------------

sendKeyBzzt :: (O.Message -> IO ()) -> CM.KeySendState -> Int -> Float -> IO () 
sendKeyBzzt sendfun kss index val = 
 case (CM.processKeyInput kss index val) of 
  Just msg -> sendfun msg
  Nothing -> return ()

sendKey :: KeyoscState -> Int -> Float -> IO ()
sendKey state index val = 
  sendKeyBzzt (oscsendfun state) (keysendstate state) index val

keysendfun :: KeyoscState -> (Int -> Float -> IO ())
keysendfun ks = sendKey ks

-----------------------------------------------------------------------
-- simple position threshold for osc send.
-- send one message per over-threshold excursion.
-- good for simple on/off.
-----------------------------------------------------------------------

-- if a key is over the threshold, and it wasn't in the 'onlist' before, then
-- send a message and turn it on.

togglePosThres :: Input -> KeyoscState -> KeyoscState
togglePosThres input state =
  toggleIOU "thressend" thresUpdate thresSend input state

-- if over the thres, put it into the sendlist.
-- don't report keys that are already in the 'onlist'. 
thresUpdate :: Input -> KeyoscState -> KeyoscState
thresUpdate input state =
 let  vals = (sensorvals input)
      kt = (keythres (sensets state))
      baselines = (baseline state)
      onlist = (thres_onlist state) 
      -- reindex and subtract baselines
      indexeson = filter (\(x,y) -> y > kt) 
                    (zip [0..] 
                      (zipWith (\(i,v) b -> v-b) vals baselines))
      sendlist = filter (\(i, v) -> (not (elem i onlist))) indexeson
  in 
    (state { thres_onlist = (map fst indexeson), thres_sendlist = sendlist }) 

-- 'Position Threshold send'
thresSend :: Input -> KeyoscState -> IO ()
thresSend input state =
 let sf = (keysendfun state)
  in do 
    mapM_ (\(i,v) -> sf i (scaleToOsc v)) (thres_sendlist state)
    return ()

-----------------------------------------------------------------------
-- send position over thres, with minimum time interval in between sends. 
-- initial position message is sent right away; always send a '0' message
-- when the key goes below the thres.
-----------------------------------------------------------------------

data OtsState = OtsState {
  otsLastTimes :: [Maybe UTCTime],
  otsSend :: [(Int,Int)],
  otsMinTime :: NominalDiffTime
  }

-- if a key is over the threshold, and it wasn't in the 'onlist' before, then
-- send a message and turn it on.

toggleOts :: Input -> KeyoscState -> KeyoscState
toggleOts input state =
  toggleIOU "thressend" overThresUpdate overThresSend input state

-- if over the thres, put it into the sendlist.
-- if it was over thres last time but not this time, send 0.
overThresUpdate :: Input -> KeyoscState -> KeyoscState
overThresUpdate input state =
 let  ots = (otsstate state)
      vals = (sensorvals input)
      kt = (keythres (sensets state))
      baselines = (baseline state)
      -- overthreslist.  if over thres AND time interval since last send is 
      -- exceeded.
      ot = zipWith (compval (otsMinTime ots) kt (now input)) 
                    vals 
                    (zip baselines (otsLastTimes ots)) 
      compval timethres kt now (i,v) (b, lasttime) = 
            let overtime = isot timethres now lasttime
                ot = v - b 
             in 
              if overtime && (ot > kt)
                then Just (ot - kt)
                else Nothing
      isot timethres n (Just t) = (diffUTCTime n t) > timethres
      isot timethres n Nothing = True 
      -- overthreslist in (i,v) form.
      onsends = map sendextract (filter (\(i,v) -> isJust v) (zip [0..] ot))
      sendextract (i,Just v) = (i,v)
      sendextract (i,Nothing) = (i,0)
      -- send 0 if was over last time but not this time.
      offsends = map (\(i, (ot, t)) -> (i,0)) 
                   (filter (\(i, (ot, t)) -> (isNothing ot) && (isJust t)) (zip [0..] (zip ot (otsLastTimes ots))))
      newtimes = zipWith (timeupdate (now input)) ot (otsLastTimes ots)
      timeupdate now (Just v) _ = Just now  
      timeupdate now Nothing oldval = Nothing
      sendlist = onsends ++ offsends 
      newots = ots { otsLastTimes = newtimes, otsSend = sendlist }
  in 
    (state { otsstate = newots }) 

-- 'Position Threshold send'
overThresSend :: Input -> KeyoscState -> IO ()
overThresSend input state =
 let  sf = (keysendfun state)
      sends = (otsSend (otsstate state))
  in do 
    mapM_ (\(i,v) -> sf i (scaleToOsc v)) sends 
    return ()

-----------------------------------------------------------------------
-- 'Max Send' - when the threshold is crossed, wait until successive 
-----------------------------------------------------------------------
-- values no longer are increasing.  send the next-to-last number from that.  
-- how to do:
--    have max array in the state, and keep updated.  
--    another way would be to have the state be local to the function, 
--    and update the function in the keyoscState.  then, not shared state.  but efficiency! 
-- while a key is on, collect its max. 
-- reqiuires thresUpdate to be updating the thres_onlist.
-- we have a max if:
--   - prevval is over thres
--   - velocity is less than zero
--   

-- complex thing that doesn't really work right.
maxUpdate_old :: Input -> KeyoscState -> KeyoscState
maxUpdate_old input prevstate =
 let  state = velUpdate input prevstate
      blah = zip [0..] (zip (velocities state) (zipWith (-) (prevvals state) (baseline state)))
      maxes = map (\(i,(v,p)) -> (i,p)) 
        (filter (\(i,(v,p)) -> 
                  p > (keythres (sensets state)) 
                  && v < 0
                  && (not (elem i (maxes_sent state))))
                blah)
      subbedvals = zipWith (\(i,p) b -> (i,p-b)) (sensorvals input) (baseline state)
      underthres = map (\(i,p) -> i) 
                       (filter (\(i,p) -> p < (keythres (sensets state))) subbedvals)
      sent = (filter (\i -> (not (elem i underthres)))
                     (maxes_sent state)) 
             ++ (map (\(i,p) -> i) maxes)
  in (state { maxes_sendlist = maxes, maxes_sent = sent }) 

-- if a key is over the threshold, update its max.
-- if a key is under the threshold but has a max, send the max.
-- if a key is under the threshold but has a max, zero the max.

updmax thres pos max = 
 if (pos > thres) 
  then 
   if (pos > max)
     then pos
     else max
  else
    0
  

maxUpdate :: Input -> KeyoscState -> KeyoscState
maxUpdate input state =
 let kt = keythres (sensets state)
     bastevals = zipWith (\(i,p) b -> p - b) (sensorvals input) (baseline state)
     newmaxes = zipWith (updmax kt) bastevals (maxes state)
     maxes_send = filter (\(i,v) -> v > 0) 
                    (zip [0..] 
                         (zipWith (\b m -> if (b < kt) then m else 0) 
                                  bastevals (maxes state)))
   in 
    state { maxes_sendlist = maxes_send, maxes = newmaxes }

scalef = 1.0 / 1024.0 :: Float
scaleToOsc :: Int -> Float
scaleToOsc i = (fromIntegral i) * scalef

maxPrint :: Input -> KeyoscState -> IO ()     
maxPrint input state = 
  let sf = (keysendfun state) in do 
    mapM_ (\(i,v) -> sf i (scaleToOsc v)) (maxes_sendlist state)
    return ()

toggleMaxPrint :: Input -> KeyoscState -> KeyoscState
toggleMaxPrint input state =
  toggleIOU "maxprint" maxUpdate maxPrint input state

-----------------------------------------------------------------------
-- velmax
-----------------------------------------------------------------------
toggleVelMax :: Input -> KeyoscState -> KeyoscState
toggleVelMax input state =
  toggleIOU "velmax" velMaxUpdate velMaxPrint input state

velMaxUpdate :: Input -> KeyoscState -> KeyoscState
velMaxUpdate input prevstate =
  let state = velUpdate input (prevstate { prevvelocities = (velocities prevstate) } )
      sendlist = filter (\(i,(v,d)) -> d < 0 
                                   && v > (velthres (sensets state))
                                   && (not (elem i (velsent state))))
        (zip [0..] (zip (velocities state) (zipWith (-) (velocities state) (prevvelocities state))))
      underthres = map fst (filter (\(i,v) -> v < velthres (sensets state)) (zip [0..] (velocities state))) 
      velsent_ = filter (\i -> not (elem i underthres)) ((map (\(i,v) -> i) sendlist) ++ (velsent state))
   in 
    state { velocity_sendlist = map (\(i,(v,d)) -> (i,v)) sendlist, velsent = velsent_ }
            
velMaxPrint :: Input -> KeyoscState -> IO ()
velMaxPrint input state = do 
  if null (velocity_sendlist state)
    then return ()
    else print (velocity_sendlist state)

-----------------------------------------------------------------------
-- velposmax
-- if velocity is negative or zero but was positive.
-- if pos is over thres
-----------------------------------------------------------------------
toggleVelPosMax :: Input -> KeyoscState -> KeyoscState
toggleVelPosMax input state =
  toggleIOU "velposmax" velPosMaxUpdate velPosMaxSend input state

velPosMaxUpdate :: Input -> KeyoscState -> KeyoscState
velPosMaxUpdate input prevstate =
  let kt = (keythres (sensets state))
      state = velUpdate input (prevstate { prevvelocities = (velocities prevstate) } )
      sendlist = filter (\(i,(p, (vnew,vold))) -> vnew < 0 && vold >= 0
                                   && p > (keythres (sensets state)))
        (zip [0..] (zip (zipWith (\v b -> v - b) (prevvals state) (baseline state)) 
                        (zip (velocities state) (prevvelocities state))))
   in 
    state { velocity_sendlist = map (\(i,(p,(v,v2))) -> (i,p)) sendlist }
            
velPosMaxSend :: Input -> KeyoscState -> IO ()
velPosMaxSend input state = do 
 let sf = (keysendfun state) in do 
    mapM_ (\(i,v) -> sf i (scaleToOsc v)) (velocity_sendlist state)
    return ()


-----------------------------------------------------------------------
-- velprint 
-----------------------------------------------------------------------

velUpdate :: Input -> KeyoscState -> KeyoscState
velUpdate input state =
  state { prevvals = (map snd (sensorvals input)), 
          velocities = zipWith (-) (map snd (sensorvals input)) (prevvals state) }

velPrint :: Input -> KeyoscState -> IO ()
velPrint input state = do 
  niceprint (velocities state)

toggleVelPrint :: Input -> KeyoscState -> KeyoscState
toggleVelPrint input state =
  toggleIOU "velprint" velUpdate velPrint input state


-- version where we don't send indexes that are ignored.
-- sendlist = filter (\i -> (not (elem i onlist)) && (not (elem i ignorelist))) indexeson

--  t <- openUDP (targetIP appsettings) (targetPort appsettings)  
-- 'Velocity Threshold send'
--  

data Calibration = Calibration {
  sensorindex :: [Int],
  -- baseline :: [Int],
  max :: [Int]
  }
  deriving (Show)

makeSensorSets :: AdcSettings -> IO SensorSets
makeSensorSets adcSettings = 
  do
    blah <- mapM (\adc -> makeAdcSensors adc (spiSpeed adcSettings)) 
                 (adcs adcSettings)
    let sensors = concat blah
     in 
     return (SensorSets sensors 
                        (spiSpeed adcSettings) 
                        (spiDelay adcSettings) 
                        (keythreshold adcSettings)
                        (velthreshold adcSettings)
                        (realToFrac (positionUpdateIntervalSecs adcSettings)))
 
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
  B.useAsCStringLen (B.pack [castCUCharToChar b1,castCUCharToChar b2]) 
   (\sendbytes -> do
    -- threadDelay delay 
    c_spiWriteRead fd (fst sendbytes) 2 bitsperword speed
    bs <- B.packCStringLen sendbytes
    return (decodedata (castCharToCUChar (B.index bs 0)) (castCharToCUChar (B.index bs 1)))
    )

printsensorval :: Show a => IO (a1, a) -> IO ()
printsensorval x = 
 do 
   y <- x
   putStr (show (snd y))
   putStr " "

spiOpen :: String -> CUChar -> CUChar -> CInt -> IO CInt
spiOpen devname mode bitsperword speed = 
 B.useAsCString (B.pack devname) 
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

getCommandInput :: IO (Maybe String)
getCommandInput = do
  ready <- hReady stdin
  if ready 
    then do
     cmd <- getLine
     return $ Just cmd
   else
     return Nothing
 
----------------------------------------------------------
-- the primary loop of the program.
-- maintains a list of functions, on each iteration 
-- loops through them allowing them to maintain the state.
----------------------------------------------------------

repete :: KeyoscState -> IO ()
repete state =  
 do
  -- get new sensor values, other stuff each iteration.
  newvals <- getsetvals (sensets state)
  command <- getCommandInput
  now <- getCurrentTime
  arduinoLine <- (getarduinoline state)
  -- update state
  let input = Input newvals command arduinoLine now
      newstate = M.foldl (\state ftn -> (ftn input state)) state (updateftns state)
   in do
    -- do IO based on state.
    F.traverse_ (\ftn -> (ftn input newstate)) (ioftns newstate)
    repete newstate

----------------------------------------------------------
-- add/remove ftns from the list of current ftns.
----------------------------------------------------------
toggleuftn :: String -> (Input -> KeyoscState -> KeyoscState) -> KeyoscState -> KeyoscState
toggleuftn ftnname ftn state = 
  if (M.member ftnname (updateftns state))
   then removeuftn ftnname state
   else adduftn ftnname ftn state

adduftn :: String -> (Input -> KeyoscState -> KeyoscState) -> KeyoscState -> KeyoscState
adduftn ftnname ftn state = 
  let newmap = M.insert ftnname ftn (updateftns state)
   in 
    state { updateftns = newmap } 
 
removeuftn :: String -> KeyoscState -> KeyoscState
removeuftn ftnname state = 
  let newmap = M.delete ftnname (updateftns state)
   in 
    state { updateftns = newmap } 

----------------------------------------------------------
-- add/remove ftns from the list of current ftns.
----------------------------------------------------------
toggleioftn :: String -> (Input -> KeyoscState -> IO ()) -> KeyoscState -> KeyoscState
toggleioftn ftnname ftn state = 
  if (M.member ftnname (ioftns state))
   then removeioftn ftnname state
   else addioftn ftnname ftn state

addioftn :: String -> (Input -> KeyoscState -> IO ()) -> KeyoscState -> KeyoscState
addioftn ftnname ftn state = 
  let newmap = M.insert ftnname ftn (ioftns state)
   in 
    state { ioftns = newmap } 
 
removeioftn :: String -> KeyoscState -> KeyoscState
removeioftn ftnname state = 
  let newmap = M.delete ftnname (ioftns state)
   in 
    state { ioftns = newmap } 
 
----------------------------------------------------------------
-- various functions that do stuff with state and sensor values.
----------------------------------------------------------------

updateframerate :: Input -> KeyoscState -> KeyoscState
updateframerate input state = 
  if (fr_itercount state) <= 0
    then let nowe = now input in
      state { fr_itercount = framerate_count, 
              fr_lasttime = nowe,
              fr_lastfr = ((fromIntegral framerate_count) / 
                           (realToFrac (diffUTCTime nowe (fr_lasttime state))))
            }
    else 
      state { fr_itercount = (fr_itercount state) - 1 }

showframerate :: Input -> KeyoscState -> IO ()
showframerate input state = 
  if (fr_itercount state) == framerate_count
    then do
      putStr "samples/sec: "
      print (fr_lastfr state)
   else do
      return ()

printDiffs :: Input -> KeyoscState -> IO ()
printDiffs input state = 
   niceprint (zipWith (\(i,v) b -> v-b) (sensorvals input) (baseline state))

printVals :: Input -> KeyoscState -> IO ()
printVals input state = 
   niceprint (map snd (sensorvals input))

commands :: M.Map String (Input -> KeyoscState -> KeyoscState)
commands = M.fromList [
  ("diffs", togglePrintDiffs),
  ("vals", togglePrintVals),
  ("frate", toggleShowFrameRate),
  ("pthres", togglePosThres),
  ("velprint", toggleVelPrint),
  ("velmax", toggleVelMax),
  ("velposmax", toggleVelPosMax),
  ("maxprint", toggleMaxPrint),
  ("outwrite", startOutWrite),
  ("ots", toggleOts),
  ("?", cuePrintCmds) ]
{-
  ("ptsendosc", togglePtSendOsc)
  ("keyseq", startKeySequence),
  ("range", toggleRangeCalibrate),
  ("resetrange", resetRangeCalibrate),
  ]
-}
 
startOutWrite :: Input -> KeyoscState -> KeyoscState
startOutWrite input state = 
  adduftn "outWrite" outWriteUpdate $ 
    state { out_count = out_count_init state, 
            out_vals = [],
            out_start = now input } 

outWriteUpdate :: Input -> KeyoscState -> KeyoscState
outWriteUpdate input state = 
  if (out_count state) > 0
    then 
      state { out_count = (out_count state) - 1, 
              out_vals = (map snd (sensorvals input)) : (out_vals state) }
    else
      -- remove self from update ftns; add outwrite oneshot.  
      -- addioftn "outWriteDebug" outWriteDebug $
      addOneShotIOFtn "outWrite" outWriteWrite $ removeuftn "outWrite" state
  
outWriteWrite :: Input -> KeyoscState -> IO ()
outWriteWrite input state = do
  let duration = realToFrac (diffUTCTime (now input) (out_start state))
      duration_s = "duration: " ++ 
                  (show duration) ++
                  "\n"
   in do
     writeFile "outWrite-machine" $
        (show (duration, (reverse (out_vals state))))
     writeFile "outWrite-human" $ 
        duration_s ++ ( 
        foldr (\a b -> (a ++ "\n" ++ b)) "" (map niceprints (reverse (out_vals state))))
  print "outWrite complete!"
  
cuePrintCmds :: Input -> KeyoscState -> KeyoscState
cuePrintCmds input state = 
  addOneShotIOFtn "printCmds" printCmds state

printCmds :: Input -> KeyoscState -> IO ()
printCmds input state = do
  mapM print (M.keys commands)
  return ()

-- add this to remove an ioftn next round.
-- removes the ioftn and itself.
removeOneShotIOFtn ioftnname selfname input state = 
  removeuftn selfname (removeioftn ioftnname state)

addOneShotIOFtn :: String -> (Input -> KeyoscState -> IO ()) -> KeyoscState -> KeyoscState
addOneShotIOFtn name ioftn state =
  let rmvname = "remove_" ++ name
   in
    adduftn rmvname (removeOneShotIOFtn name rmvname) (addioftn name ioftn state) 

togglePrintVals :: Input -> KeyoscState -> KeyoscState
togglePrintVals input state = 
  toggleioftn "printVals" printVals state

togglePrintDiffs :: Input -> KeyoscState -> KeyoscState
togglePrintDiffs input state = 
  toggleioftn "printDiffs" printDiffs state

toggleShowFrameRate :: Input -> KeyoscState -> KeyoscState
toggleShowFrameRate input state = 
  toggleIOU "frate" updateframerate showframerate input state

toggleIOU :: String -> (Input -> KeyoscState -> KeyoscState) ->
  (Input -> KeyoscState -> IO ()) -> Input -> KeyoscState -> KeyoscState
toggleIOU name updateftn ioftn input state = 
  if (M.member name (ioftns state))
   then removeioftn name (removeuftn name state)
   else addioftn name ioftn (adduftn name updateftn state)

commandInput :: Input -> KeyoscState -> KeyoscState
commandInput input state = 
  case (commandline input) of 
    (Just cmd) -> 
      case (M.lookup cmd commands) of
        Nothing -> state
        (Just ftn) -> ftn input state
    Nothing -> state
    

fmlist = zipWith (\a b -> a ++ (show b)) (repeat "/arduino/fm/note/") [11..42]

niceprint [] = 
 do 
   putStrLn ""
niceprint lst = 
 do 
  printf "%4d " (head lst)
  niceprint (tail lst)

niceprints [] = ""
niceprints l = foldr (\a b -> (printf "%4d " a) ++ b) "" l

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

getbaselines sensets count appsettings = do
  -- get initial sensor values for baselines.
  vals <- getsvmulti sensets 20 (spiDelay (adcSettings appsettings))
  -- mapM niceprint (map (\vs -> (map (\(i,v) -> v) vs)) vals)
  return $ meadvals vals

initialuftns appsettings = 
 M.fromList [
  ("commands", commandInput)]

initialioftns appsettings = 
 M.fromList []

{-
simpleprint :: O.Message -> IO ()
simpleprint msg = do
 print msg

-- keyoscSend :: O.UDP -> O.Message -> IO ()
keyoscSend conn msg 
  O.sendOSC conn (O.Message str [O.Float amt])
-}

-- intermediary ftn to optionally print osc messages 
-- instead of, or in addition to, sending them.
makeOscSendFun :: O.UDP -> AppSettings -> (O.Message -> IO ())
makeOscSendFun conn appsets = 
  if (sendKeyMsgs appsets) 
    then
      if (printKeyMsgs appsets) 
        then
          (\msg -> do 
            print msg
            O.sendOSC conn msg)
        else
          O.sendOSC conn
    else
      if (printKeyMsgs appsets) 
        then
          print 
        else
          (\msg -> return ())

-------------------------------------------------------
-- serial port stuff, for arduino
-------------------------------------------------------

{-
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

checkforarduinoline :: MVar String -> IO (Maybe String)
checkforarduinoline mvar = tryTakeMVar mvar

dumpaline :: SerialPort -> MVar String -> IO ()
dumpaline serial mvar = do
  line <- getaline serial
  putMVar mvar line
  dumpaline serial mvar
-}

checkforarduinoline2 :: Handle -> IO (Maybe String)
checkforarduinoline2 serial = do 
  ready <- hReady serial
  if ready 
    then do
      line <- hGetLine serial
      return $ Just line
    else 
      return Nothing
    
dummycheckline :: IO (Maybe String)
dummycheckline = return Nothing


makeGetArduinoLine :: AppSettings -> IO (Maybe String)
makeGetArduinoLine appsettings = 
  case (arduinoserial appsettings) of
    (Just serialname) -> do
      serial <- openSerial serialname B115200 8 One Even Software
      hSetNewlineMode serial universalNewlineMode
      checkforarduinoline2 serial
    Nothing -> dummycheckline

-----------------------------------------------------------

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
  t <- O.openUDP (targetIP appsettings) (targetPort appsettings)
  sensettings <- makeSensorSets (adcSettings appsettings)
  printsensors (sensors sensettings)
  baselines <- getbaselines sensettings 20 appsettings
  print "baselines:"
  niceprint baselines
  stwing <- readFile (soundmap appsettings)
  now <- getCurrentTime
  let leEtat = KeyoscState sensettings 
                          (CM.makeKeySendState ((read stwing) :: CM.KeySendPrefs) )
                          (makeOscSendFun t appsettings) 
                          (makeGetArduinoLine appsettings)
                          []
                          [] 
                          []
                          []
                          (replicate (length baselines) 0)  -- maxes
                          baselines 
                          otsstate
                          framerate_count now 0.0 
                          [] [] [] [] []
                          (outwritecount appsettings) 0 now []
                          inituftns initioftns
      inituftns = (initialuftns appsettings) 
      initioftns = (initialioftns appsettings)
      otsstate = OtsState (take (length baselines) (repeat Nothing)) [] (fromIntegral 0)
   in do 
    repete leEtat


