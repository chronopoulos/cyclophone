module Main where

import System.Directory
import System.Environment
import Data.List.Split
import Data.List
import qualified Data.Text as T
import qualified Data.Array as A
import qualified Data.Map as M
--import qualified Data.MultiMap as MM
--import qualified Data.Map.Strict as M
import qualified Data.Set as S
-- import System.FilePath
import qualified Filesystem.Path.CurrentOS as FP
import Data.Maybe
import Text.Show.Pretty
import Control.Monad
import Control.Monad.Fix
import GHC.Float
import Sound.SC3
import qualified Sound.OSC.FD as OSC
-- import qualified Sound.SC3.Server.Command.Double as F
import qualified Sound.SC3.Server.Command as F

import Data.Ratio
import Data.Bits
import Data.Functor

import Treein
import SoundMap
import Scales 

-- pathlist fpath = splitOneOf "/" fpath
-- fname fullpath = last (pathlist fullpath)

-- make a synth from the sample..  'graph' type.
-- actually is synthdef?

--gDefGain = 0.5
gDefGain = 1.3

readBuf fname bufno = 
  withSC3 (do
    async (b_allocRead bufno fname 0 0))

gDelayOut = (numOutputBuses + numInputBuses)
gSynthOut = (numOutputBuses + numInputBuses) + 1
gLoopWk = (numOutputBuses + numInputBuses) + 2
gLoopOut = (numOutputBuses + numInputBuses) + 3

makeSampleSynthDef :: String -> Int -> Synthdef
makeSampleSynthDef name bufno = 
    synthdef name (out gSynthOut
                    ((playBuf 1 AR (constant bufno) 1.0 1 0 NoLoop RemoveSynth) 
                         * (control KR "amp" gDefGain)))

makePitchSampleSynthDef :: Rational -> String -> Int -> Synthdef
makePitchSampleSynthDef note name bufno = 
  let pitch = 1.0 / (toFreq note) in 
    synthdef name (out gSynthOut
                    ((playBuf 1 AR (constant bufno) ((constant pitch) * (control KR "pitch" 0.0)) 1 0 NoLoop RemoveSynth) 
                         * (control KR "amp" gDefGain)))

makeSawSynthDef :: String -> Synthdef 
makeSawSynthDef name = 
    synthdef name (out gSynthOut ((saw AR (control KR "pitch" 0.0))
                          * (control KR "amp" (gDefGain * 0.7))))

makeTremSawSynthDef :: String -> Synthdef
makeTremSawSynthDef name =
    synthdef name (out gSynthOut ((saw AR (control KR "pitch" 0.0))
                          * (sinOsc KR (15.0 * (control KR "amp" 0.5)) 0.0)
                          * (control KR "amp" (gDefGain * 0.7))))

makeSineSynthDef :: String -> Synthdef 
makeSineSynthDef name = 
    synthdef name (out gSynthOut ((sinOsc AR (control KR "pitch" 0.0) 0 * 0.1)
                          * (control KR "amp" gDefGain)))

makeTremSineSynthDef :: String -> Synthdef
makeTremSineSynthDef name =
    synthdef name (out gSynthOut ((sinOsc AR (control KR "pitch" 0.0) 0 * 0.1)
                          * (sinOsc KR (15.0 * (control KR "amp" 0.5)) 0.0)
                          * (control KR "amp" gDefGain)))

-- synthdef to connect two buses.
passthroughcon name busfrom busto =
  synthdef name (out busto (in' 1 AR busfrom))

-- connect buses with delay.
delaycon_o name busfrom busto = 
  let sig = in' 1 AR busfrom
      del = delayN sig (constant gDelayMax) (control KR "delaytime" 0.5 ) 
      outsig = sig + del
    in
      synthdef name (out busto outsig) 

gDelayMax = 2.5 :: Float
gDelayPtName = "delayptname"
gDelayConName = "delayconname"

-- works!
delaycon_w name busfrom busto = 
  let sig = in' 1 AR busfrom
      loc = localIn' 1 AR
      sig2 = sig + loc
      del = delayN sig2 2.5 0.5 
      outsig = sig2 + del
      loco = localOut (del * 0.5)
      outs2 = out busto outsig
    in
      synthdef name (mrg [outs2, loco])

-- delay with feedback. 
delaycon name busfrom busto =
  let sig = in' 1 AR busfrom
      loc = localIn' 1 AR
      sig2 = sig + loc
      initdel = float2Double $ gDelayMax * 0.1
      del = delayC sig2 (constant gDelayMax)
                       (control KR "delaytime" initdel)
      outsig = sig2 + del
      loco = localOut (del * (control KR "delayfeedback" 0.4))
      outs2 = out busto outsig
    in
      synthdef name (mrg [outs2, loco])

-- all-in-one looper synthdef.
loopster name buf busfrom busto = 
  let sig = in' 1 AR busfrom            -- one channel of input.
      rec = control KR "record" 0       -- make this 1.0 to record.
      play = control KR "play" 0        -- make this 1.0 to play.
      r_reset = tr_control "r_reset" 0  -- reset to start of record buffer.
      p_reset = tr_control "p_reset" 0  -- reset to start of play buffer.
      -- recphas starts at 0 up to end of buf.
      -- only changes when rec != 0
      recphas = phasor AR r_reset rec 0 (bufFrames IR buf) 0 
      bfwr = bufWr buf recphas Loop sig
      -- play phasor ranges from 0 to last known recphas.
      -- only plays when 'play' is != 0.
      playphas = phasor AR p_reset play 0 recphas 0 
      bfrd = bufRd 1 AR buf playphas Loop NoInterpolation -- buffer loop.
      -- out signal is 'in' sig plus loop sound.
      -- mult by 'play' to mute the loop when not in use.
      outs = out busto (sig + (bfrd * play))
   in
    synthdef name (mrg [outs, bfwr])  

doloopster :: SoundState -> Bool -> IO SoundState
doloopster soundstate False = return soundstate
doloopster soundstate True = 
  -- each time the button is pressed, iterate to the next
  -- looper state:  Passthrough -> Record -> Playback 
  case (ss_looperState soundstate) of 
    Passthrough -> do
      print "loopster - record"
      -- go to record mode.
      withSC3 (send (F.n_set1 gLoopSynthId "r_reset" 1.0))
      withSC3 (send (F.n_set1 gLoopSynthId "record" 1.0))
      return $ soundstate { ss_looperState = Record }   
    Record -> do
      print "loopster - play"
      -- go to playback mode.
      withSC3 (send (F.n_set1 gLoopSynthId "record" 0.0))
      withSC3 (send (F.n_set1 gLoopSynthId "p_reset" 1.0))
      withSC3 (send (F.n_set1 gLoopSynthId "play" 1.0))
      return $ soundstate { ss_looperState = Play }
    Play -> do
      print "loopster - passthrough"
      -- go to passthrough mode.
      withSC3 (send (F.n_set1 gLoopSynthId "play" 0.0))
      return $ soundstate { ss_looperState = Passthrough }

gLoopBufId = 1010 
gLoopSynthId = 1009

--------------------------------------------------------------
 
gNodeOffset = 100

-- substitute buffer playback with simple oscillator.
{-
readBuf fname bufno = 
  return ()

makeSynthDef :: String-> Int -> Synthdef 
makeSynthDef name bufno = 
    synthdef name (out 0 ((sinOsc AR (200 + 20 * (constant bufno)) 0 * 0.1)
                          * (control KR "amp" 0.5)))

makeSynth :: Int -> Graph 
makeSynth bufno = 
    synth (out 0 ((sinOsc AR (200 + 20 * (constant bufno)) 0 * 0.1)
                  * (control KR (show bufno ++ "amp") 0.5)))
-}

-- get the node ID of the synth, to use for adjustment messages.

stopp = 
 withSC3 (do {reset
             ;_ <- async (b_close 0)
             ;async (b_free 0)})

data SynthStuff = SynthStuff {
  s_synthdef :: String,     -- name of a synthdef on the SC server.
  -- note whether this is a single pitch synthdef or multi??
  -- or, just always send pitch.
  s_keytype :: KeyType     
  }
  deriving (Show)

-- tests = [SMap blah, SMapFile (T.pack "/thisisapth")]
-- blah = SampMap (T.pack "blah") [(1,(T.pack "blah2")), (2, (T.pack "dsfa"))]

-- makeSampleSynthDef :: String -> Int -> Synthdef
loadWav :: FP.FilePath -> KeyType -> Int -> (String -> Int -> Synthdef) -> IO SynthStuff
loadWav filename keytype bufno makesyn = 
 let fn = (FP.encodeString filename) in do
  readBuf fn bufno
  let sdname = "def" ++ (show bufno)
      syn = (makesyn sdname bufno) 
   in do
    withSC3 (async (d_recv syn))
    return $ SynthStuff sdname keytype

-- either one synthdef for all pitches, or synthdefs assigned per note.
data SoundBank = MonoBank SynthStuff | 
                 NoteBank (M.Map Rational SynthStuff) |
                 KeyBank (A.Array Int SynthStuff) |
                 EmptyBank

data KeyRangeMap = KeyRangeMap [(KeyRange, SoundBank)]

loadKeySounds :: FP.FilePath -> SoundMap -> Int -> IO [KeyRangeMap]
loadKeySounds path sm bufidxstart = do
  sbassoc <- loadSoundBanks path (sm_soundsets sm) bufidxstart
  return $ map (\km -> KeyRangeMap (map (\(kr, t) -> 
                                          (kr, fromMaybe EmptyBank (lookup t sbassoc))) 
                                        km))
               (sm_keymaps sm)

loadSoundBanks :: FP.FilePath -> [(T.Text, SoundSet)] -> Int -> IO [(T.Text, SoundBank)]
loadSoundBanks path ((t,ss):moar) bufstart = do
  (sb, bufidx) <- loadSoundSet path bufstart ss
  therest <- loadSoundBanks path moar bufidx
  return $ (t, sb) : therest 
loadSoundBanks path [] bufstart = return []
  
-- loadSoundSet : loads sounds into a soundbank, increments the 
-- buffer index if any buffers were allocated.
loadSoundSet :: FP.FilePath -> Int -> SoundSet -> IO (SoundBank, Int)

loadSoundSet path bufidx (Synth name keytype) = 
  -- basically just assume there is a synth in SC with this name.
  return (MonoBank (SynthStuff name keytype), bufidx)

loadSoundSet path bufidx (NoteWavSet dir denom notemap) = do
  -- load all bufs, with increasing buffer indexes
  wavs <- loadNoteWavSet path (NoteWavSet dir denom notemap) bufidx
  return $ ((NoteBank wavs), bufidx + (length notemap))

loadSoundSet path bufidx (ShiftWav filename note keytype) = do
  let wavfname = (FP.append (FP.directory path)
                         (FP.fromText filename)) in
   if (FP.valid wavfname) then do
     wav <- loadWav wavfname keytype bufidx (makePitchSampleSynthDef note)
     return (MonoBank wav, bufidx + 1)
   else
    error $ "invalid filename to loadSoundSet: " ++ (FP.encodeString wavfname)

loadSoundSet path bufidx (KeyWavSet dir wavlst) = do
  -- load all bufs, with increasing buffer indexes
  wavs <- loadKeyWavSet path (KeyWavSet dir wavlst) bufidx
  let (low,hi) = A.bounds wavs in 
    return $ ((KeyBank wavs), bufidx + hi-low+1)
  
-- pass in a wavset, and the directory containing the file that 
-- contains the wavset.  The file location is:
-- <soundmap file parent dir> + <ws_rootdir> + <filename>
-- idea is that the index file can be in the same dir as samples, and you can move
-- the whole dir to a new location and it still works.
-- if filename is an absolute path, then the other two entries are ignored.
-- if ws_rootdir is absolute, the soundmap file location is ignored.
loadNoteWavSet :: FP.FilePath -> SoundSet -> Int -> IO (M.Map Rational SynthStuff)
loadNoteWavSet smapfiledir (NoteWavSet dir denom notemap) bufstart = do
  let rewt = (FP.append (FP.directory smapfiledir)
                        (FP.fromText dir)) in
   if (FP.valid rewt) then do
    lst <- sequence (map 
              (\((nt, fn, kt), bufidx) -> 
                  readsamp denom rewt fn nt bufidx kt)
              (zip notemap [bufstart..]))
    return $ M.fromList lst
   else
    return M.empty
   where
    readsamp denom rtd fn nt bufidx kt = 
      let file = FP.append rtd (FP.fromText fn) in do
        ss <- loadWav file kt bufidx (makePitchSampleSynthDef (nt % denom))
        return ((nt % denom), ss)  
loadNoteWavSet smapfiledir _ bufstart = return M.empty 

loadKeyWavSet :: FP.FilePath -> SoundSet -> Int -> IO (A.Array Int SynthStuff)
loadKeyWavSet smapfiledir (KeyWavSet dir keywavs) bufstart = do
  let rewt = (FP.append (FP.directory smapfiledir)
                        (FP.fromText dir)) in
   if (FP.valid rewt) then do
    lst <- sequence (map 
              (\((key, (fn, kt)), bufidx) -> 
                  readsamp rewt fn key bufidx kt)
              (zip (zip [0..] keywavs) [bufstart..]))
    return $ A.array (0,(length lst) - 1) lst
   else
    return $ A.array (1,0) []
   where
    readsamp rtd fn key bufidx kt = 
      let file = FP.append rtd (FP.fromText fn) in do
        ss <- loadWav file kt bufidx makeSampleSynthDef 
        return (key, ss)  
loadKeyWavSet smapfiledir _ bufstart = 
    return $ A.array (1,0) []

gBufStart = 0 
--gLowScale = 43
gLowScale = 10
gHighScale = 100
gDenomScale = 12
 
main = do 
 args <- getArgs
 if (length args /= 3 && length args /= 5) 
    then do
      putStrLn "syntax:"
      putStrLn "scoscdir <ip> <port> <sample mapfile> <optional ledip> <optional ledport>"
    else do
      putStrLn "scoscdir started."
      withSC3 $ do 
        reset
        -- create delay synthdef. 
        async 
          (d_recv (delaycon gDelayConName gSynthOut gDelayOut))
        -- create the delay passthrough synthdef too.
        async (d_recv (passthroughcon gDelayPtName gSynthOut gDelayOut))
        -- start off with delay passthrough. 
        -- will need to create synths with AddToHead so they are before this in 
        -- the graph. 
        send (s_new gDelayPtName
                             1000
                             AddToTail 1 
                             [])

        -- create looper buffer.
        send (b_alloc (fromIntegral gLoopBufId) (44100 * 120) 1)

        -- create the looper synthdef, and a synth from that.   
        async (d_recv (loopster "looper" gLoopBufId gDelayOut gLoopOut))
        send (s_new "looper" gLoopSynthId AddToTail 1 [])

        -- connect gLoopOut to out1 and out2.
        async (d_recv (passthroughcon "out0" gLoopOut 0))
        async (d_recv (passthroughcon "out1" gLoopOut 1))
        send (s_new "out0" 
                     1001
                     AddToTail 1 
                     [])

        send (s_new "out1" 
                     1002
                     AddToTail 1 
                     [])

        -- connect in-chans to out.
        -- don't know if this will work or not.  couldn't find a decent 
        -- microphone for testing.
        {-
        async (d_recv (synthdef "inout0" (out 0 (in' 1 AR (numOutputBuses + 0)))))
        async (d_recv (synthdef "inout1" (out 1 (in' 1 AR (numOutputBuses + 1)))))
        send (s_new "inout0" 
                     1003
                     AddToTail 1 
                     [])

        send (s_new "inout1" 
                     1004
                     AddToTail 1 
                     [])
        -}


      -- read in the buffers, create synthdefs
      --sml_str <- readFile (args !! 2)
      --smap <- read sml_str :: SoundMap 
      sml_str <- readFile (args !! 2)
      -- smap <- read sml_str :: SoundMap 
      print "sound map file loaded."
     
      print "loading sounds to supercollider..." 

      -- define simple sine wave synth
      withSC3 $ do 
        async (d_recv (makeSineSynthDef "sine"))
        async (d_recv (makeSawSynthDef "saw"))
        async (d_recv (makeTremSineSynthDef "tremsine"))
        async (d_recv (makeTremSawSynthDef "tremsaw"))
      
      let smap = read sml_str :: SoundMap in 
        if (not (isValid smap)) then
          print "empty sound map file!"
        else do
          sounds <- loadKeySounds (FP.decodeString (args !! 2)) 
                                  (read sml_str :: SoundMap)
                                  0
          -- putStrLn $ ppShow smap
          let port = OSC.readMaybe (args !! 1) :: (Maybe Int)
              ip = (args !! 0)
              scale = majorScale
              root = 4
	      ledip = if (length args == 5) then 
                        Just (IPPort (args !! 3) (read (args !! 4) :: Int))
                      else
                        Nothing
              soundstate = SoundState {
                ss_activeKeys = S.empty,  
                ss_hitKeys = S.empty,
                ss_krmIndex = 0,
                ss_keyrangemaps = sounds, 
                ss_keymap = makeKeyMap 24 root scale (head sounds),
                ss_rootnote = root,
                ss_scale = scale,
                ss_altkey = False,
                ss_looperState = Passthrough,
                ss_delayon = False,
                ss_ledip = ledip
                }
           in case port of
             Just p -> do
                -- putStrLn $ "keymapping: " ++ (ppShow (map (\(i,e) -> (i, (fst e), dblRat (fst e))) (A.assocs (ss_keymap soundstate))))
                updateLEDs soundstate
                print "sounds loaded."
                print "starting osc loop." 
                startoscloop ip p soundstate 
             Nothing -> putStrLn $ "Invalid port: " ++ (args !! 0) 


dblRat :: Rational -> Double
dblRat r = 
 (fromIntegral (numerator r)) / (fromIntegral (denominator r))


data LooperState = Record | Play | Passthrough
 deriving (Read, Show)

-- track active sounds.
-- if a key receives a positive value, and it is inactive, then
--    1) trigger the sound.
--    2) set the volume to the new level 
--    3) make the key active.
-- if a key receives a positive value and it is active,
--    1) send a volume adjustment.
-- if a key receives a zero value (or less?), then 
--    1) send volume adjustment (to zero) or cancel playback.
--    2) make the key inactive.
data SoundState = SoundState {
  ss_activeKeys :: S.Set Int,
  ss_hitKeys :: S.Set Int,
  ss_krmIndex :: Int,
  ss_keyrangemaps :: [KeyRangeMap],
  ss_keymap :: A.Array Int (Maybe (Rational, SynthStuff)),
  ss_rootnote :: Rational,
  ss_scale :: [Rational],
  ss_altkey :: Bool,
  ss_looperState :: LooperState,
  ss_delayon :: Bool,
  ss_ledip :: Maybe IPPort
  }

data IPPort = IPPort { 
  ipp_ip :: String,
  ipp_port :: Int
  }

updateScale :: SoundState -> Rational -> [Rational] -> SoundState
updateScale ss root scale = 
  ss { ss_rootnote = root,
       ss_scale = scale,
       ss_keymap = makeKeyMap 24 
                    root
                    scale 
                    ((ss_keyrangemaps ss) !! (ss_krmIndex ss))
     }

makeColors :: Rational -> A.Array Int (Maybe (Rational, SynthStuff)) -> [(Int, Int)]
makeColors root keymap = 
  let (lo,hi) = (A.bounds keymap) in 
   map (\idx -> makeColor root idx (keymap A.! idx)) [lo..hi] 

makeColor :: Rational -> Int -> (Maybe (Rational, SynthStuff)) -> (Int, Int)
makeColor root idx Nothing = (idx, 0) 
makeColor root idx (Just (note, sstuff)) = (idx + 1, calcColor (note - root))

calcColor :: Rational  -> Int
calcColor note =
  let rem = note - ((floor note) % 1)
      h = (fromIntegral (numerator rem)) / (fromIntegral (denominator rem)) :: Float
      (r,g,b) = hsv_rgb (h * 360) 1.0 0.25
      ri = floor (255 * r)
      gi = floor (255 * g)
      bi = floor (255 * b)
   in
      (shift ri 16) .|. (shift gi 8) .|. bi

sendColorsNew :: String -> Int -> [(Int, Int)] -> IO ()
sendColorsNew ipAddr port colors = do
  OSC.withTransport (OSC.openUDP ipAddr port) 
      (\t -> do 
        OSC.sendOSC t (OSC.Message "updatearray" [OSC.int32 0])
        mapM (\(a,b) -> 
                    (OSC.sendOSC t (OSC.Message "setpixel" 
                                    [OSC.int32 (keyLedIndex a),OSC.int32 b])))
             colors
        OSC.sendOSC t (OSC.Message "showarray" [OSC.int32 0])
      )

sendColorsOld :: String -> Int -> [(Int, Int)] -> IO ()
sendColorsOld ipAddr port colors = 
  let colorz = foldl (++) [] (map (\(a,b) -> [OSC.int32 (keyLedIndex a),OSC.int32 b]) colors) in do
    OSC.withTransport (OSC.openUDP ipAddr port) (\t -> OSC.sendOSC t (OSC.Message "led" colorz))


keyLedIndex :: Int -> Int
keyLedIndex keyIndex = (mod (11 - keyIndex) 24) + 1

-- RGB:
-- R, red =   0 to 1
-- G, green = 0 to 1
-- B, blue =  0 to 1

rgb_hsv :: Float -> Float -> Float -> (Float, Float, Float)
rgb_hsv r g b = (h, (s / maxC), maxC)
  where
    maxC = r `max` g `max` b
    minC = r `min` g `min` b
    s = maxC - minC
    h | maxC == r = (g - b) / s * 60
      | maxC == g = (b - r) / s * 60 + 120
      | maxC == b = (r - g) / s * 60 + 240
      | otherwise = undefined

-- HSV:
-- H, hue        0 to 360
-- S, saturation 0 to 1
-- V, brightness 0 to 1 

hsv_rgb :: Float -> Float -> Float -> (Float, Float, Float)
hsv_rgb h s v
    | h' == 0 = (v, t, p)
    | h' == 1 = (q, v, p)
    | h' == 2 = (p, v, t)
    | h' == 3 = (p, q, v)
    | h' == 4 = (t, p, v)
    | h' == 5 = (v, p, q)
    | otherwise = undefined
    where
        h' = floor (h / 60) `mod` 6 :: Int
        f = h / 60 - fromIntegral h'
        p = v * (1 - s)
        q = v * (1 - f * s)
        t = v * (1 - (1 - f) * s)


startoscloop :: String -> Int -> SoundState -> IO ()
startoscloop ip port soundstate = do
  OSC.withTransport (OSC.udpServer ip port) (oscloop soundstate)
    
oscloop :: (OSC.Transport t) => SoundState -> t -> IO ()
oscloop soundstate fd = do
  msg <- OSC.recvMessage fd
  case msg of 
    Just msg -> do 
      newsoundstate <- onoscmessage soundstate msg
      oscloop newsoundstate fd
    Nothing -> 
      oscloop soundstate fd

-- key, knob, or button index.
getoscindex :: OSC.Message -> Maybe Int
getoscindex msg = 
  let lst = OSC.messageDatum msg
    in case lst of
      ((OSC.Int32 x):xs) -> Just $ fromIntegral x
      _ -> Nothing

-- expecting 0 to 1.0
getoscamt :: OSC.Message -> Maybe Double
getoscamt msg = 
  let lst = OSC.messageDatum msg
    in case lst of
      (_ : (OSC.Float x):xs) -> Just $ float2Double x
      (_ : (OSC.Int32 x):xs) -> Just $ fromIntegral x
      _ -> Nothing

getoscscale :: OSC.Message -> Maybe [Rational]
getoscscale msg = 
  let lst = makelist $ OSC.messageDatum msg
    in case lst of
      Just l -> makescale l
      _ -> Nothing

getoscroot :: OSC.Message -> Maybe Rational
getoscroot msg = 
  let lst = makelist $ OSC.messageDatum msg
    in case lst of
      Just [num,denom] -> Just $ num % denom
      _ -> Nothing

makelist :: [OSC.Datum] -> Maybe [Integer]
makelist [] = Just []
makelist (OSC.Float x:xs) =
  let rest = makelist xs in 
    case rest of 
      Nothing -> Nothing
      Just xs -> Just $ (floor x):xs
makelist (OSC.Int64 x:xs) =
  let rest = makelist xs in 
    case rest of 
      Nothing -> Nothing
      Just xs -> Just $ (fromIntegral x):xs
makelist (OSC.Int32 x:xs) =
  let rest = makelist xs in 
    case rest of 
      Nothing -> Nothing
      Just xs -> Just $ (fromIntegral x):xs
     
makescale :: [Integer] -> Maybe [Rational]
makescale [] = Nothing
makescale (denom:numes) = Just $ map (\n -> n % denom) numes

inbounds :: Int -> A.Array Int a -> Bool
inbounds idx array = 
  let (low, high) = A.bounds array in 
    (low <= idx) && (idx <= high)

-- for key index, get sound. 
getsound :: Maybe Int -> A.Array Int (Maybe (Rational, SynthStuff)) -> Maybe (Rational, SynthStuff)
getsound (Just index) soundmap =
  if (inbounds index soundmap) then  
    soundmap A.! index 
  else
    Nothing
getsound Nothing _ = Nothing

-- data KeyRangeMap = KeyRangeMap [(KeyRange, SoundBank)]
{-

Ok the crux of the biscuit here.

for each key, find a sound and a pitch.  I guess no-sound could also be an option.

for key N, 
  - find a range in the rangemap that fits.  I guess the first range.
  - applying scales.  one way is to determine a pitch for every key first, then get corresponding sounds.  
  or something!  its complicated.

-}

makeKeyMap :: Int -> Rational -> [Rational] -> KeyRangeMap -> 
  A.Array Int (Maybe (Rational, SynthStuff))
makeKeyMap keycount rootnote scale (KeyRangeMap krm) =  
  let -- notes = take 24 $ noteseries (scaleftn scale) rootnote
      soundlist = map (\i -> findSound i rootnote scale (KeyRangeMap krm))
                      [0..(keycount-1)]
   in
    A.array (0,(keycount-1)) (zip [0..] soundlist)

idxInRange :: Int -> KeyRange -> Int
idxInRange keyidx All = keyidx
idxInRange keyidx (FromTo f t) = keyidx - f

findSound :: Int -> Rational -> [Rational] -> KeyRangeMap -> Maybe (Rational, SynthStuff)
findSound keyindex root scale krm = 
  let note = (noteseries (scaleftn scale) root) !! keyindex
      krsb = krmLookup keyindex krm    
   in case krsb of 
    Just (r,sb) -> sbClosestLookup (idxInRange keyindex r) note sb
    Nothing -> Nothing

-- find the soundbank within the KeyRangeMap.
krmLookup :: Int -> KeyRangeMap -> Maybe (KeyRange, SoundBank)
krmLookup keyidx (KeyRangeMap krm) = 
  find (\(r,sb) -> SoundMap.inRange keyidx r) krm
         
-- find the CLOSEST note within the soundbank.  
-- counting on pitch adjustment to keep it in tune.
sbClosestLookup :: Int -> Rational -> SoundBank -> Maybe (Rational, SynthStuff)
sbClosestLookup idx note (MonoBank ss) = Just (note, ss)
sbClosestLookup idx note (NoteBank mp) = 
  -- return note mod the range, and its corresponding synthstuff 
  let low = myLookupLE note mp
      high = myLookupGE note mp
   in case (low, high) of 
    (Just (lk,lv), Nothing) -> Just (note, lv)
    (Nothing, Just (hk,hv)) -> Just (note, hv)
    (Just (lk,lv), Just (hk,hv)) -> 
      -- should cover the equality cases too, ie note == lk or note == hk
      if (note - lk < hk - note) 
        then Just (note, lv)
        else Just (note, hv)
    _ -> Nothing
sbClosestLookup idx note (KeyBank array) = 
  -- return note mod the range, and its corresponding synthstuff 
  let mahkey = mod idx (hi-lo+1)
      (lo, hi) = A.bounds array 
   in
     return (0, array A.! mahkey) 

myLookupLE :: Ord k => k -> M.Map k v -> Maybe (k, v)
myLookupLE k map = 
  let kvs = M.filterWithKey (\key _ -> key <= k) map in
    if (M.null kvs)
      then Nothing 
      else Just $ M.findMax kvs

myLookupGE :: Ord k => k -> M.Map k v -> Maybe (k,v)
myLookupGE k map = 
  let kvs = M.filterWithKey (\key _ -> k <= key) map in
    if (M.null kvs)
      then Nothing 
      else Just $ M.findMin kvs



-- find the EXACT note within the soundbank, or Nothing.
sbLookup :: Int -> Rational -> SoundBank -> Maybe (Rational, SynthStuff)
sbLookup idx note (MonoBank ss) = Just (note, ss)
sbLookup idx note (NoteBank mp) = 
  -- return note mod the range, and its corresponding synthstuff 
  if (M.null mp) then Nothing
    else
      let (l,_) = M.findMin mp
          (h,_) = M.findMax mp
        in 
          case rmod note l h of 
            Just mahnote -> 
              (\x -> (mahnote,x)) <$> M.lookup mahnote mp
            _ -> Nothing
sbLookup idx note (KeyBank array) = 
  -- return note mod the range, and its corresponding synthstuff 
  let mahkey = mod idx (hi-lo+1)
      (lo, hi) = A.bounds array 
   in
     return (0, array A.! mahkey) 

rmod :: Rational -> Rational -> Rational -> Maybe Rational
rmod n low high =
 let fp = n - ((floor n) % 1)
     l = ceiling (low - fp)
     h = floor (high - fp)
     md = h - l + 1
  in
    if md < 1 then 
      Nothing
    else
      Just $ ((mod (floor n - l) md) % 1) + fp + (l%1)

{-

rmod should iterate from L to H, for any values of n + (x % 1), x being an integer.

      note n     n+1 |     n+2       n+3       n+4      | n+5
        |         |  |      |         |         |       | |
                    low     L                   H      high
   |         |          |         |         |         |         |
   -1        0         1         2         3         4         5 

-}

makeKeyMap_ :: Int -> Rational -> [Rational] -> M.Map Rational SynthStuff -> A.Array Int (Rational, SynthStuff)
makeKeyMap_ keycount rootnote scale soundmap = 
  let notes = noteseries (scaleftn scale) rootnote
      sounds = catMaybes
                 (map (\x -> (\y -> (x,y)) <$> (M.lookup x soundmap)) notes)
   in
    -- nope won't work because requiring compute of whole 'sounds' lists which
    -- is an infinite task.
    A.array (0,keycount-1) (zip [0..] (take keycount (cycle sounds)))
    -- A.array (0,keycount-1) (zip [0..] (take keycount (cycle sounds)))

updateLEDs :: SoundState -> IO ()
updateLEDs ss = 
  case (ss_ledip ss) of 
    Nothing -> return ()
    Just ip -> 
     let
       keycolors = makeColors (ss_rootnote ss) (ss_keymap ss)
      in do
         print $ "updating colors: "
         putStrLn $ ppShow keycolors
         sendColorsNew (ipp_ip ip) (ipp_port ip) keycolors
 
-- if its a key, look up synth using the key index.
-- is this something that changes during the program?
-- ultimately how should it work?
--    turning knobs and stuff should change the available sounds.  duh.
--    for samples, have a directory of directories.  each directory is a bank of sounds.
--    assoc sounds with pitches?
--    one way, have index file in directory.
--    or, just go alpha
--    or, name the sounds according to their notes.
--    another way, have a big index file that maps to sounds that could be anywhere.
--    or local to the dir where the index is.  
--    could have multiple index files for different things.  don't have to move samples
--    and, can reuse samples.  
-- could use graph specification in configs??

-- if its not a key, do something else, for now ignore.  

-- if sound does not exist and volume is positive, create a channel playing the sound at the given volume.
-- if sound exists and volume is positive, change the volume.
-- if sound exists and volume is zero, fade it and remove from soundstate.
onoscmessage_ :: SoundState -> OSC.Message -> IO SoundState
onoscmessage_ soundstate msg = do
  -- print $ "osc message: " ++ (show msg)
  -- print $ "osc message: " ++ OSC.messageAddress msg 
  return soundstate

onoscmessage :: SoundState -> OSC.Message -> IO SoundState
onoscmessage soundstate msg = do
  -- print $ "osc message: " ++ (show msg)
  -- print $ "osc message: " ++ OSC.messageAddress msg 
  let soundmap = ss_keymap soundstate
      msgtext = OSC.messageAddress msg 
      idx = getoscindex msg 
      amt = getoscamt msg
      sound = getsound idx soundmap
      node = 1
   in case (msgtext, idx, amt, sound) of 
    ("keyh", Just i, Just a, Just (note, sstuff)) -> do
      -- print "keyh"
      if (s_keytype sstuff == Hit) || (s_keytype sstuff == HitVol) then 
       let sname = s_synthdef sstuff in do 
        -- print $ "keyh start: " ++ (show i) ++ " " ++ (show a)
        -- create synth w volume.
        withSC3 $ do 
          send (n_free [(gNodeOffset + i)])
          send (s_new sname 
               (gNodeOffset + i) 
               AddToHead 1 
               [("amp", a), ("pitch", toFreq note)])
        -- put in the active list, also the hit list.
        return $ soundstate { 
          ss_activeKeys = (S.insert i (ss_activeKeys soundstate)), 
          ss_hitKeys = (S.insert i (ss_hitKeys soundstate)) }
      else do
        -- this key has been hit.
        return $ soundstate { ss_hitKeys = (S.insert i (ss_hitKeys soundstate)) }
        -- print "nochange1"
        -- return soundstate
    ("keyc", Just i, Just a, Just (note, sstuff)) -> do
     -- print "keyc"
     if (S.member i (ss_activeKeys soundstate)) then
        -- active key!
        if (s_keytype sstuff == Vol) || 
           ((s_keytype sstuff == HitVol) && (not (S.member i (ss_hitKeys soundstate)))) then do 
          -- print $ "setvolactive: " ++ (show i) ++ " " ++ (show a)
          -- for HitVol keys, adjust the volume only until a hit is received, 
          -- then don't adjust the volume anymore.  
          -- for Vol keys, always set the volume.
          withSC3 (send (F.n_set1 (gNodeOffset + i) "amp" a))
          -- no change to soundstate.
          return soundstate
        else do
          -- print "nochange2"
          -- no change to soundstate.
          return soundstate
      else if (s_keytype sstuff == Vol || s_keytype sstuff == VolHit) then do
          -- print $ "start inactive: " ++ (show i) ++ " " ++ (show a)
          -- create synth, with initial amplitude setting.
          withSC3 (send (s_new (s_synthdef sstuff)
                               (gNodeOffset + i) 
                               AddToHead 1 
                               [("amp", a), ("pitch", toFreq note)]))
          -- add to active keys.
          return $ soundstate { ss_activeKeys = (S.insert i (ss_activeKeys soundstate)) }
        else do
          -- print "nochange3"
          -- no change to soundstate.
          return soundstate
    ("keye", Just i, _, Just (note, sstuff)) -> do
        -- print "keye"
        if (s_keytype sstuff == Vol || s_keytype sstuff == HitVol) then do 
          -- set volume to zero, and/or stop playback.
          -- print $ "freeing: " ++ (show i)
          withSC3 (send (n_free [(gNodeOffset + i)]))
          -- remove key from active set.
          return $ soundstate { ss_activeKeys = (S.delete i (ss_activeKeys soundstate)) 
                              , ss_hitKeys = (S.delete i (ss_hitKeys soundstate)) }
        else if (s_keytype sstuff == VolHit) then do 
          -- remove key from active set, and from hitkeys.  
          return $ soundstate { ss_activeKeys = (S.delete i (ss_activeKeys soundstate)) 
                              , ss_hitKeys = (S.delete i (ss_hitKeys soundstate)) }
        else do
          -- print "nochange4"
          return soundstate
    ("knob", Just i, Just a, _) -> do
      print $ "knob " ++ (show i) ++ " " ++ (show a)
      case i of 
        0 -> case (ss_altkey soundstate) of
          True -> do  
            -- set the delay feedback.
            withSC3 (send (F.n_set1 1000 "delayfeedback" a))
            return soundstate
          False -> 
            -- set the delay time.
            case (a, ss_delayon soundstate) of 
              (0.0, True) -> do 
                -- replace delay with passthrough.
                print "delay passthrough"
                withSC3 $ do 
                  send (n_free [1000])
                  send (s_new gDelayPtName
                       1000
                       AddBefore gLoopSynthId 
                       [])
                return $ soundstate { ss_delayon = False }
              (_, True) -> do
                print "setting delay time"
                -- just set the delay time.
                withSC3 (send (F.n_set1 1000 "delaytime" (a * (float2Double gDelayMax))))
                return soundstate
              (_, False) -> do 
                -- replace passthrough with delay.
                print "delay on"
                withSC3 $ do
                  send (n_free [1000])
                  send (s_new gDelayConName
                       1000
                       AddBefore gLoopSynthId 
                       [("delaytime", a)])
                return $ soundstate { ss_delayon = True }
        1 -> let
          ln = (length (ss_keyrangemaps soundstate)) 
          mn = max (ln - 1) 0
          index = min mn $ floor $ a * (fromIntegral ln)
          in
         if (index /= (ss_krmIndex soundstate)) then 
          let 
             newsoundstate = soundstate { ss_keymap = makeKeyMap 24 
                                                (ss_rootnote soundstate) 
                                                (ss_scale soundstate) 
                                                ((ss_keyrangemaps soundstate) !! index),
                                          ss_krmIndex = index }
           in do
             print $ "loading sounds: " ++ (show (index + 1)) ++ " of " ++ (show ln)
             updateLEDs newsoundstate
             return newsoundstate 
         else
             return soundstate
        2 -> 
          let root = (interp (double2Float a) gLowScale gHighScale gDenomScale) 
              newsoundstate = updateScale soundstate root (ss_scale soundstate)
           in do
            print $ "Updating root: " ++ (show root)
            updateLEDs newsoundstate
            return newsoundstate 
        _ -> return soundstate
    ("switch", Just i, _, _) -> do 
      print $ "switch " ++ (show i)
      let root = (ss_rootnote soundstate)
          newscale = case i of 
            0 -> chromaticScale 
            1 -> majorScale 
            2 -> majorPentatonicScale 
            3 -> hungarianMinorScale 
            4 -> harmonicMinorScale
            _ -> []
          newsoundstate = if (newscale /= []) then updateScale soundstate root newscale 
                          else soundstate
        in do
          print $ "updating scale to " ++ (show (i + 1)) ++ " of 5"
          updateLEDs newsoundstate
          return newsoundstate 
    ("button", Just i, Just a, _) -> do 
      print $ "button " ++ (show i) ++ " " ++ (show a)
      case i of 
        0 -> return $ soundstate { ss_altkey = (a == 1.0) }
        1 -> doloopster soundstate (a == 1.0)
        -- 1 -> doloop soundstate (a == 1.0)
        -- 1 -> dolooper soundstate (a == 1.0)
        _ -> return soundstate
    ("scale",_,_,_) -> do 
      -- expecting array of ints.  
      -- first number is denominator (ie, 12)
      -- subsequent numbers are numerators.  
      -- ex. major scale [12,0,2,4,5,7,9,11] 
      print $ "scale " ++ (show msg)
      onscalemsg soundstate msg
      -- return soundstate
    ("root",_,_,_) -> do 
      -- expects [num,denom], ex [37%12] == root is 2nd note of 4th octave (i think)
      print $ "root " ++ (show msg)
      onrootmsg soundstate msg
      -- return soundstate
    (_,_,_,_) -> do 
      -- for anything else, ignore.
      print $ "ignored osc message: " ++ (show msg)
      return soundstate

onscalemsg :: SoundState -> OSC.Message -> IO SoundState
onscalemsg soundstate msg = 
  let scale = getoscscale msg in 
    case scale of 
      Just scl ->  
        let newsoundstate = updateScale soundstate (ss_rootnote soundstate) scl 
          in do
            print $ " new scale: " ++ (show scl)
            updateLEDs newsoundstate
            return newsoundstate
      Nothing -> return soundstate
     
onrootmsg :: SoundState -> OSC.Message -> IO SoundState
onrootmsg soundstate msg = 
  let root = getoscroot msg in 
    case root of 
      Just rt -> 
        let newsoundstate = updateScale soundstate rt (ss_scale soundstate) 
          in do 
            print $ " new root: " ++ (show rt)
            updateLEDs newsoundstate
            return newsoundstate
      Nothing -> return soundstate
     
