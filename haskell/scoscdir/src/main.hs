module Main where

import System.Directory
import System.Environment
import Data.List.Split
import qualified Data.Text as T
import qualified Data.Array as A
--import qualified Data.Map as M
import qualified Data.MultiMap as MM
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
import qualified Sound.SC3.Server.Command.Float as F

import Data.Ratio

import Treein
import SampMap
import Scales 

-- pathlist fpath = splitOneOf "/" fpath
-- fname fullpath = last (pathlist fullpath)

-- make a synth from the sample..  'graph' type.
-- actually is synthdef?

readBuf fname bufno = 
  withSC3 (do
    async (b_allocRead bufno fname 0 0))

gSynthOut = (numOutputBuses + numInputBuses) + 1
gDelayOut = (numOutputBuses + numInputBuses)

makeSynthDef name bufno = 
    synthdef name (out gSynthOut
                    ((playBuf 1 AR (constant bufno) 1.0 1 0 NoLoop RemoveSynth) 
                         * (control KR "amp" 0.5)))

-- synthdef to connect two buses.
buscon name busfrom busto = 
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
      loc = localIn 1 AR
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
      loc = localIn 1 AR
      sig2 = sig + loc
      initdel = float2Double $ gDelayMax * 0.1
      del = delayC sig2 (constant gDelayMax)
                       (control KR "delaytime" initdel)
      outsig = sig2 + del
      loco = localOut (del * (control KR "delayfeedback" 0.4))
      outs2 = out busto outsig
    in
      synthdef name (mrg [outs2, loco])

-- q: make a single synthdef that does record, playback, and passthrough?
-- or, make separate synthdefs for each, and switch them out?

{-
//write into the buffer with a BufWr
(
y = { arg rate=1;
    var in;
    in = SinOsc.ar(LFNoise1.kr(2, 300, 400), 0, 0.1);
    BufWr.ar(in, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b)));
    0.0 //quiet
}.play;
)

//read it with a BufRd
(
x = { arg rate=1;
    BufRd.ar(1, b, Phasor.ar(0, BufRateScale.kr(b) * rate, 0, BufFrames.kr(b)))
}.play;
)
-}

-- looper stuff.
recordcon name buf busfrom busto = 
  let sig = in' 1 AR busfrom    -- one channel of input.
      phas = (phasor AR 0 1 0 (bufFrames AR buf) 0) 
      bfwr = bufWr buf phas Loop sig
      outs = out busto sig
      outp = out 4 phas     -- hoping to save this value on bus 4. 
   in
    synthdef name (mrg [outs, bfwr, outp])  


playbackcon name buf busfrom busto = 
  let sig = in' 1 AR busfrom    -- one channel of input.
      upto = in' 1 AR 4         -- is the value on bus 4 from recordcon??  don't think so.
      phas = (phasor AR 0 1 0 upto 0) 
      -- bfrd = bufRd 1 AR buf phas Loop NoInterpolation -- buffer loop.
      bfrd = playBuf 1 AR (constant buf) 1.0 1 0 Loop RemoveSynth
    in
      synthdef name (out busto (sig + bfrd)) 

passthroughcon name busfrom busto =
  synthdef name (out busto (in' 1 AR busfrom))

ptname = "looperpassthrough"
recordname = "looperrecord"
playbackname = "looperplayback"

gLoopBufId = 1010 
gLoopSynthId = 1009

doloop :: SoundState -> Bool -> IO SoundState
doloop soundstate False = return soundstate
doloop soundstate True = 
  -- each time the button is pressed, iterate to the next
  -- looper state:  Passthrough -> Record -> Playback 
  case (ss_looperState soundstate) of 
    Passthrough -> do
      print "record"
      -- go to record mode.
      withSC3 (send (n_free [gLoopSynthId]))
      withSC3 (send (s_new recordname gLoopSynthId AddToTail 1 []))
      return $ soundstate { ss_looperState = Record }   
    Record -> do
      print "play"
      -- go to playback mode.
      withSC3 (send (n_free [gLoopSynthId]))
      withSC3 (send (s_new playbackname gLoopSynthId AddToTail 1 []))
      return $ soundstate { ss_looperState = Play }
    Play -> do
      print "passthrough"
      -- go to passthrough mode.
      withSC3 (send (n_free [gLoopSynthId]))
      withSC3 (send (s_new ptname gLoopSynthId AddToTail 1 []))
      return $ soundstate { ss_looperState = Passthrough }

{-
SynthDef(
    \looper,
    {
        arg input_bus=0, output_bus=0, t_rec, t_play, t_stop;
        var out, length=0, buf_num=LocalBuf(SampleRate.ir() * 30);
        var is_recording = SetResetFF.kr(t_rec, t_stop);
        var is_playing = SetResetFF.kr(t_play, t_stop);
        var rec_pos = Sweep.ar(t_rec, SampleRate.ir() * is_recording);
        var play_pos = Phasor.ar(t_play, SampleRate.ir() * is_playing,
0, rec_pos);

        BufWr.ar(SoundIn.ar(input_bus), buf_num, rec_pos);
        out = BufRd.ar(1, buf_num, play_pos);
        Out.ar(output_bus, out);
    }
).add(); 
-}

looper name buf busfrom busto = 
  let sig = in' 1 AR busfrom
      t_rec = control KR "record" 0.0
      t_play = control KR "play" 0.0
      t_stop = control KR "stop" 0.0
      is_recording = setResetFF t_rec t_stop
      is_playing = setResetFF t_play t_stop
      rpos = sweep t_rec is_recording
      ppos = phasor AR t_play is_playing 0 rpos 0 
      bfrd = bufRd 1 AR buf ppos Loop NoInterpolation 
      -- bfrd = bufRd 1 AR buf 0 Loop NoInterpolation 
      bfwr = bufWr buf rpos Loop sig
   in
     synthdef name (out busto (mrg [sig + bfrd, bfwr]))
     -- synthdef name (out busto (mrg [bfrd, bfwr]))

{- 

looper name buf busfrom busto = 
  let sig = in' 1 AR busfrom
      t_rec = control KR "record" 0.0
      t_play = control KR "play" 0.0
      t_stop = control KR "stop" 1.0
      is_recording = setResetFF t_rec t_stop
      is_playing = setResetFF t_play t_stop
      rpos = sweep t_rec (44100 * is_recording)
      ppos = phasor AR t_play (44100 * is_playing) 0 rpos 0 
      bfrd = bufRd 1 AR buf ppos Loop NoInterpolation 
      bfwr = bufWr buf rpos Loop sig
   in
     synthdef name (out busto (mrg [sig + bfrd, bfwr]))
     -- synthdef name (out busto (mrg [bfrd, bfwr]))

looper name buf busfrom busto = 
  let sig = in' 1 AR busfrom
      t_rec = trig 0.5 (control KR "record" 0.0)
      t_play = trig 0.5 (control KR "play" 0.0)
      t_stop = trig 0.5 (control KR "stop" 0.0)
      is_recording = setResetFF t_rec t_stop
      is_playing = setResetFF t_play t_stop
      rpos = sweep t_rec (44100 * is_recording)
      ppos = phasor AR t_play (44100 * is_playing) 0 rpos 0 
      bfrd = bufRd 1 AR buf ppos Loop NoInterpolation 
      bfwr = bufWr buf rpos Loop sig
   in
     synthdef name (out busto (mrg [sig, bfrd, bfwr]))

looper name buf busfrom busto = 
  let sig = in' 1 AR busfrom
      is_recording = (control KR "recording" 0.0)
      is_playing = (control KR "playing" 0.0)
      rpos = sweep is_recording (44100 * is_recording)
      ppos = phasor AR is_playing 1 0 (bufFrames AR buf) 0 
      bfrd = bufRd 1 AR buf ppos Loop NoInterpolation 
      bfwr = bufWr buf rpos Loop sig
   in
     synthdef name (out busto (mrg [sig, bfrd, bfwr]))




looper name buf busfrom busto t_rec t_play t_stop = 
  let sig = in' 1 AR busfrom
      is_recording = setResetFF t_rec t_stop
      is_playing = setResetFF t_play t_stop
      rpos = sweep t_rec (44100 * is_recording)
      ppos = phasor AR t_play 1 0 (bufFrames AR buf) 0 
      bfrd = bufRd 1 AR buf ppos Loop NoInterpolation 
      bfwr = bufWr buf rpos Loop sig
   in
     synthdef name (out busto (mrg [sig, bfrd, bfwr]))
-}

dolooper :: SoundState -> Bool -> IO SoundState
dolooper soundstate False = return soundstate
dolooper soundstate True = 
  -- each time the button is pressed, iterate to the next
  -- looper state:  Passthrough -> Record -> Playback 
  case (ss_looperState soundstate) of 
    Passthrough -> do
      print "dl - record"
      -- go to record mode.
      -- withSC3 (send (F.n_set1 gLoopSynthId "stop" 0.0))
      withSC3 (send (F.n_set1 gLoopSynthId "record" 1.0))
      return $ soundstate { ss_looperState = Record }   
    Record -> do
      print "dl - play"
      -- go to playback mode.
      -- withSC3 (send (F.n_set1 gLoopSynthId "record" 0.0))
      withSC3 (send (F.n_set1 gLoopSynthId "play" 1.0))
      return $ soundstate { ss_looperState = Play }
    Play -> do
      print "dl - passthrough"
      -- go to passthrough mode.
      -- withSC3 (send (F.n_set1 gLoopSynthId "play" 0.0))
      withSC3 (send (F.n_set1 gLoopSynthId "stop" 1.0))
      return $ soundstate { ss_looperState = Passthrough }


 
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

data SampleStuff = SampleStuff {
  s_synth :: Synthdef,
  s_bufId :: Int,
  s_keytype :: KeyType 
  }
  deriving (Show)

-- tests = [SMap blah, SMapFile (T.pack "/thisisapth")]
-- blah = SampMap (T.pack "blah") [(1,(T.pack "blah2")), (2, (T.pack "dsfa"))]

loadSamp :: FP.FilePath -> Rational -> KeyType -> Int -> IO (Rational, SampleStuff)
loadSamp filename note keytype bufno = 
 let fn = (FP.encodeString filename) in do
  readBuf fn bufno
  let syn = (makeSynthDef ("def" ++ (show bufno)) bufno) 
   in do
    withSC3 (async (d_recv syn))
    return (note, SampleStuff syn bufno keytype)

loadSampMapItems :: [SampMapItem] -> IO [SampMap]
loadSampMapItems (itm:rest) = 
 case itm of 
  SMap smap -> do
    smaprest <- loadSampMapItems rest
    return $ smap : smaprest 
  SMapFile file -> do
    str <- readFile (T.unpack file)
    smaprest <- loadSampMapItems rest
    return $ ((read str) :: SampMap) : smaprest 
loadSampMapItems [] = return []

-- pass in the sampmap, and the directory containing the file that 
-- contains the sampmap.  that dir is used to 
loadSampMap :: FP.FilePath -> SampMap -> Int -> IO (MM.MultiMap Rational SampleStuff)
loadSampMap smapfiledir smap bufstart = do
  let rewt = (FP.append (FP.directory smapfiledir)
                        (FP.fromText (sm_rootdir smap)))
      denom = sm_denominator smap in
   if (FP.valid rewt) then do
    lst <- sequence (map 
              (\((nt, fn, kt), bufidx) -> 
                  readsamp denom rewt fn nt bufidx kt)
              (zip (sm_notemap smap) [bufstart..]))
    return $ MM.fromList lst
   else
    return MM.empty
   where
    readsamp denom rtd fn nt idx kt = 
      let file = FP.append rtd (FP.fromText fn) in 
        loadSamp file (nt % denom) kt idx 

gBufStart = 0 
gLowScale = 20
gHighScale = 60
gDenomScale = 12
 
main = do 
 args <- getArgs
 if (length args /= 3) 
    then do
      print "syntax:"
      print "scoscdir <ip> <port> <sample mapfile>"
    else do
      print "scoscdir started."
      -- slist <- treein (args !! 3)
      withSC3 reset
     
      -- add delay to end of the graph ("AddToTail")
      -- will need to create synths with AddToHead so they are before this in 
      -- the graph. 
      withSC3 (async 
        (d_recv (delaycon gDelayConName gSynthOut gDelayOut)))
      withSC3 (send (s_new gDelayConName
                           1000
                           AddToTail 1 
                           []))
      -- create the delay passthrough synthdef too.
      withSC3 (async (d_recv (passthroughcon gDelayPtName gSynthOut gDelayOut)))


      -- create looper buffer.
      withSC3 (send (b_alloc (fromIntegral gLoopBufId) (44100 * 120) 1))

      -- create looper synthdefs.
      withSC3 (async (d_recv (passthroughcon ptname gDelayOut 1)))
      withSC3 (async (d_recv (recordcon recordname gLoopBufId gDelayOut 1)))
      withSC3 (async (d_recv (playbackcon playbackname gLoopBufId gDelayOut 1)))

      -- start off with passthrough
      withSC3 (send (s_new ptname gLoopSynthId AddToTail 1 []))

      {-
      -- create the looper synthdef, and a synth from that.   
      withSC3 (async (d_recv (looper "looper" gLoopBufId gDelayOut 1)))
      withSC3 (send (s_new "looper" gLoopSynthId AddToTail 1 []))
      -}
      
      -- read in the buffers, create synthdefs
      sml_str <- readFile (args !! 2)
      smaplist <- loadSampMapItems ((read sml_str) :: [SampMapItem])

      print "sample map file loaded."
      if (length smaplist) == 0 then
        print "empty sound map file!"
      else do
        samples <- loadSampMap (FP.decodeString (args !! 2)) 
                               (head smaplist) 
                               gBufStart
        -- putStrLn $ ppShow smap
        let port = OSC.readMaybe (args !! 1) :: (Maybe Int)
            ip = (args !! 0)
            scale = majorScale
            root = 4
            soundstate = SoundState {
              ss_activeKeys = S.empty,
              ss_samples = samples,
              ss_keymap = makeKeyMap 24 root scale samples,
              ss_rootnote = root,
              ss_scale = scale,
              ss_sampmapIndex = 0 ,
              ss_sampmaps = smaplist ,
              ss_sampmaprootdir = (FP.decodeString (args !! 2)),
              ss_altkey = False,
              ss_looperState = Passthrough,
              ss_delayon = True
              }
         in case port of
           Just p -> do
              putStrLn $ "keymapping: " ++ (ppShow (map (\(i,e) -> (i, (fst e), dblRat (fst e))) (A.assocs (ss_keymap soundstate))))
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
  ss_samples :: MM.MultiMap Rational SampleStuff,
  ss_keymap :: A.Array Int (Rational, SampleStuff),
  ss_rootnote :: Rational,
  ss_scale :: [Rational],
  ss_sampmapIndex :: Int,
  ss_sampmaps :: [SampMap],
  ss_sampmaprootdir :: FP.FilePath,
  ss_altkey :: Bool,
  ss_looperState :: LooperState,
  ss_delayon :: Bool
  }

updateScale :: SoundState -> Rational -> [Rational] -> SoundState
updateScale ss root scale = 
  ss { ss_rootnote = root,
       ss_scale = scale,
       ss_keymap = makeKeyMap 24 
                    root
                    scale 
                    (ss_samples ss)
     }


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
getoscamt :: OSC.Message -> Maybe Float
getoscamt msg = 
  let lst = OSC.messageDatum msg
    in case lst of
      (_ : (OSC.Float x):xs) -> Just x
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
getsound :: Maybe Int -> A.Array Int (Rational, SampleStuff) -> Maybe (Rational, SampleStuff)
getsound (Just index) soundmap =
  if (inbounds index soundmap) then  
    Just $ soundmap A.! index 
  else
    Nothing
getsound Nothing _ = Nothing

makeKeyMap :: Int -> Rational -> [Rational] -> MM.MultiMap Rational SampleStuff -> A.Array Int (Rational, SampleStuff)
makeKeyMap keycount rootnote scale soundmap = 
  let max = fromJust $ MM.findMax soundmap
      -- make notes a finite list!  only goes up to the max available note
      notes = takeWhile (\n -> n <= max) $ noteseries (scaleftn scale) rootnote
      sounds = foldr (++) [] 
                 (map (\x -> (map (\y -> (x,y)) (MM.lookup x soundmap))) notes)
   in case sounds of 
    [] -> A.array (1,0) []
    _ -> A.array (0,keycount-1) (zip [0..] (take keycount (cycle sounds)))
    -- A.array (0,keycount-1) (zip [0..] (take keycount (cycle sounds)))

makeKeyMap_ :: Int -> Rational -> [Rational] -> MM.MultiMap Rational SampleStuff -> A.Array Int (Rational, SampleStuff)
makeKeyMap_ keycount rootnote scale soundmap = 
  let notes = noteseries (scaleftn scale) rootnote
      sounds = foldr (++) [] 
                 (map (\x -> (map (\y -> (x,y)) (MM.lookup x soundmap))) notes)
   in
    -- nope won't work because requiring compute of whole 'sounds' lists which
    -- is an infinite task.
    A.array (0,keycount-1) (zip [0..] (take keycount (cycle sounds)))
    -- A.array (0,keycount-1) (zip [0..] (take keycount (cycle sounds)))

testKM file = do 
  sml_str <- readFile file 
  smaplist <- loadSampMapItems ((read sml_str) :: [SampMapItem])
  print "sample map file loaded."
  if (length smaplist) == 0 then
    print "empty sound map file!"
  else do
    samples <- loadSampMap (FP.decodeString file) 
                           (head smaplist) 
                           gBufStart
    print $ "sampels: " ++ (show (MM.size samples))
    -- putStrLn $ ppShow smap
    let notes = noteseries (scaleftn majorScale) 4
        km = makeKeyMap 24 4 majorScale samples in do
      print $ take 24 (noteseries (scaleftn majorScale) 4)
      print $ foldr (++) [] (map (\x -> (map (\y -> (x,s_bufId y) ) (MM.lookup x samples))) (take 24 notes))
      print $ "keymaplen: " ++ (show (A.bounds km))


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
  print $ "osc message: " ++ OSC.messageAddress msg 
  return soundstate

onoscmessage :: SoundState -> OSC.Message -> IO SoundState
onoscmessage soundstate msg = do
  -- print $ "osc message: " ++ (show msg)
  print $ "osc message: " ++ OSC.messageAddress msg 
  let soundmap = ss_keymap soundstate
      msgtext = OSC.messageAddress msg 
      idx = getoscindex msg 
      amt = getoscamt msg
      sound = getsound idx soundmap
      node = 1
   in case (msgtext, idx, amt, sound) of 
    ("keyh", Just i, Just a, Just (note, sstuff)) -> do
      print "keyh"
      if (s_keytype sstuff == Hit) || (s_keytype sstuff == HitVol) then 
       let bufid = s_bufId sstuff in do 
        print $ "keyh start: " ++ (show i) ++ " " ++ (show a)
        -- create synth w volume.
        withSC3 (send (n_free [(gNodeOffset + i)]))
        withSC3 (send (s_new ("def" ++ (show bufid))
                             (gNodeOffset + i) 
                             AddToHead 1 
                             [("amp", (float2Double a))]))
        -- put in the active list.
        return $ soundstate { ss_activeKeys = (S.insert i (ss_activeKeys soundstate)) }
      else do
        print "nochange1"
        return soundstate
    ("keyc", Just i, Just a, Just (note, sstuff)) -> do
     print "keyc"
     if (S.member i (ss_activeKeys soundstate)) then
        if (s_keytype sstuff == Vol) || (s_keytype sstuff == HitVol) then do 
          print $ "setvolactive: " ++ (show i) ++ " " ++ (show a)
          -- set the volume.
          withSC3 (send (F.n_set1 (gNodeOffset + i) "amp" a))
          -- no change to soundstate.
          return soundstate
        else do
          print "nochange2"
          -- no change to soundstate.
          return soundstate
      else if (s_keytype sstuff == Vol) then do
          print $ "start inactive: " ++ (show i) ++ " " ++ (show a)
          -- create synth, with initial amplitude setting.
          withSC3 (send (s_new ("def" ++ (show (s_bufId sstuff))) 
                               (gNodeOffset + i) 
                               AddToHead 1 
                               [("amp", (float2Double a))]))
          -- add to active keys.
          return $ soundstate { ss_activeKeys = (S.insert i (ss_activeKeys soundstate)) }
        else do
          print "nochange3"
          -- no change to soundstate.
          return soundstate
    ("keye", Just i, _, Just (note, sstuff)) -> do
        print "keye"
        if (s_keytype sstuff == Vol || s_keytype sstuff == HitVol) then do 
          -- set volume to zero, and/or stop playback.
          print $ "freeing: " ++ (show i)
          withSC3 (send (n_free [(gNodeOffset + i)]))
          -- remove key from active set.
          return $ soundstate { ss_activeKeys = (S.delete i (ss_activeKeys soundstate)) }
        else do
          print "nochange4"
          return soundstate
    ("knob", Just i, Just a, _) -> do
      print $ "knob " ++ (show i) ++ " " ++ (show a)
      case i of 
        0 -> let
          ln = (length (ss_sampmaps soundstate)) 
          mn = max (ln - 1) 0
          index = min mn $ floor $ a * (fromIntegral ln)
          in
         if (index /= (ss_sampmapIndex soundstate)) then do
             print $ "loading sampmap: " ++ (show (index + 1)) ++ " of " ++ (show ln)
             sm <- loadSampMap (ss_sampmaprootdir soundstate) 
                               ((ss_sampmaps soundstate) !! index) 
                               gBufStart
             return $ soundstate { ss_samples = sm, 
                                   ss_keymap = makeKeyMap 24 
                                                (ss_rootnote soundstate) 
                                                (ss_scale soundstate) 
                                                sm,
                                   ss_sampmapIndex = index }
         else
             return soundstate
        1 -> 
          let root = (interp a gLowScale gHighScale gDenomScale) in do
            print $ "updating scale root: " ++ (show root)
            return $ updateScale soundstate 
                      (interp a gLowScale gHighScale gDenomScale)
                      (ss_scale soundstate)
        2 -> case (ss_altkey soundstate) of
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
                withSC3 (send (n_free [1000]))
                withSC3 (send (s_new gDelayPtName
                                     1000
                                     AddBefore gLoopSynthId 
                                     []))
                return $ soundstate { ss_delayon = False }
              (_, True) -> do
                print "setting delay time"
                -- just set the delay time.
                withSC3 (send (F.n_set1 1000 "delaytime" (a * gDelayMax)))
                return soundstate
              (_, False) -> do 
                -- replace passthrough with delay.
                print "delay on"
                withSC3 (send (n_free [1000]))
                withSC3 (send (s_new gDelayConName
                                     1000
                                     AddBefore gLoopSynthId 
                                     [("delaytime", float2Double a)]))
                return $ soundstate { ss_delayon = True }
        _ -> return soundstate
    ("switch", Just i, _, _) -> do 
      print $ "switch " ++ (show i)
      print $ "updating scale to " ++ (show (i + 1)) ++ " of 5"
      let root = (ss_rootnote soundstate) in 
        case i of 
          0 -> return $ updateScale soundstate root chromaticScale 
          1 -> return $ updateScale soundstate root majorScale 
          2 -> return $ updateScale soundstate root majorPentatonicScale 
          3 -> return $ updateScale soundstate root hungarianMinorScale 
          4 -> return $ updateScale soundstate root harmonicMinorScale
          _ -> return soundstate
    ("button", Just i, Just a, _) -> do 
      print $ "button " ++ (show i) ++ " " ++ (show a)
      case i of 
        0 -> return $ soundstate { ss_altkey = (a == 1.0) }
        1 -> doloop soundstate (a == 1.0)
        -- 1 -> dolooper soundstate (a == 1.0)
        _ -> return soundstate
    ("scale",_,_,_) -> do 
      print $ "scale " ++ (show msg)
      onscalemsg soundstate msg
    ("root",_,_,_) -> do 
      print $ "root " ++ (show msg)
      onrootmsg soundstate msg
    (_,_,_,_) -> do 
      -- for anything else, ignore.
      print $ "ignored osc message: " ++ (show msg)
      return soundstate

onscalemsg :: SoundState -> OSC.Message -> IO SoundState
onscalemsg soundstate msg = 
  let scale = getoscscale msg in 
    case scale of 
      Just scl -> return $ updateScale soundstate (ss_rootnote soundstate) scl 
      Nothing -> return soundstate
     
onrootmsg :: SoundState -> OSC.Message -> IO SoundState
onrootmsg soundstate msg = 
  let root = getoscroot msg in 
    case root of 
      Just rt -> return $ updateScale (soundstate { ss_rootnote = rt }) rt (ss_scale soundstate) 
      Nothing -> return soundstate
     
