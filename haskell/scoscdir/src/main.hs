module Main where

import System.Directory
import System.Environment
import Data.List.Split
import qualified Data.Text as T
-- import System.FilePath
import qualified Filesystem.Path.CurrentOS as FP
import Text.Show.Pretty
import Control.Monad
import Control.Monad.Fix
import GHC.Float
import Sound.SC3
import qualified Sound.OSC.FD as OSC
import qualified Sound.SC3.Server.Command.Float as F
import qualified Data.Map as M
import qualified Data.Set as S

import Data.Ratio

import Treein
import SampMap

-- pathlist fpath = splitOneOf "/" fpath
-- fname fullpath = last (pathlist fullpath)

-- make a synth from the sample..  'graph' type.
-- actually is synthdef?

readBuf fname bufno = 
  withSC3 (do
    async (b_allocRead bufno fname 0 0))

makeSynthDef name bufno = 
    synthdef name (out 1 ((playBuf 1 AR (constant bufno) 1.0 1 0 NoLoop RemoveSynth) 
                         * (control KR "amp" 0.5)))

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
loadSampMap :: FP.FilePath -> SampMap -> Int -> IO (M.Map Rational SampleStuff)
loadSampMap smapfiledir smap bufstart = do
  let rewt = (FP.append smapfiledir
                        (FP.fromText (sm_rootdir smap)))
      denom = sm_denominator smap in
   if (FP.valid rewt) then do
    lst <- sequence (map 
              (\((nt, fn, kt), bufidx) -> 
                  readsamp denom rewt fn nt bufidx kt)
              (zip (sm_notemap smap) [bufstart..]))
    return $ M.fromList lst
   else
    return M.empty
   where
    readsamp denom rtd fn nt idx kt = 
      let file = FP.append rtd (FP.fromText fn) in 
        loadSamp file (nt % denom) kt idx 

gBufStart = 0 
 
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
      -- withSC3 (send (g_new [(1, AddToTail, 0)]))
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
            soundstate = SoundState {
              ss_activeKeys = S.empty,
              ss_samples = samples,
              ss_sampmapIndex = 0 ,
              ss_sampmaps = smaplist ,
              ss_sampmaprootdir = (FP.decodeString (args !! 2)) 
              }
         in case port of
           Just p -> do
              print "starting osc loop." 
              startoscloop ip p soundstate 
           Nothing -> putStrLn $ "Invalid port: " ++ (args !! 0) 

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
  ss_samples :: M.Map Rational SampleStuff,
  ss_sampmapIndex :: Int,
  ss_sampmaps :: [SampMap],
  ss_sampmaprootdir :: FP.FilePath
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
      _ -> Nothing

-- for key index, get sound. 
getsound :: Maybe Int -> M.Map Rational SampleStuff -> Maybe (Rational, SampleStuff)
getsound (Just index) soundmap =
  if ((M.size soundmap) == 0) then 
    Nothing
  else
    Just $ M.elemAt (rem index (M.size soundmap)) soundmap 
getsound Nothing _ = Nothing


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
onoscmessage :: SoundState -> OSC.Message -> IO SoundState
onoscmessage soundstate msg = do
  -- print $ "osc message: " ++ (show msg)
  print $ "osc message: " ++ OSC.messageAddress msg 
  let soundmap = ss_samples soundstate
      msgtext = OSC.messageAddress msg 
      idx = getoscindex msg 
      amt = getoscamt msg
      sound = getsound idx soundmap
      node = 1
   in case (msgtext, idx, amt, sound) of 
    ("keyh", Just i, Just a, Just (name, sstuff)) ->
      if (s_keytype sstuff == Hit) || (s_keytype sstuff == HitVol) then do 
        print $ "keyh start: " ++ (show i) ++ " " ++ (show a)
        -- create synth w volume.
        withSC3 (send (n_free [(gNodeOffset + i)]))
        withSC3 (send (s_new ("def" ++ (show i)) 
                             (i + gNodeOffset) 
                             AddToTail 1 
                             [("amp", (float2Double a))]))
        -- put in the active list.
        return $ soundstate { ss_activeKeys = (S.insert i (ss_activeKeys soundstate)) }
      else 
        return soundstate
    ("keyc", Just i, Just a, Just (name, sstuff)) -> 
     if (S.member i (ss_activeKeys soundstate)) then
        if (s_keytype sstuff == Vol) || (s_keytype sstuff == HitVol) then do 
          print $ "setvolactive: " ++ (show i) ++ " " ++ (show a)
          -- set the volume.
          withSC3 (send (F.n_set1 (i + gNodeOffset) "amp" a))
          -- no change to soundstate.
          return soundstate
        else 
          -- no change to soundstate.
          return soundstate
      else if (s_keytype sstuff == Vol) then do
          print $ "start inactive: " ++ (show i) ++ " " ++ (show a)
          -- create synth, with initial amplitude setting.
          withSC3 (send (s_new ("def" ++ (show i)) 
                               (i + gNodeOffset) 
                               AddToTail 1 
                               [("amp", (float2Double a))]))
          -- add to active keys.
          return $ soundstate { ss_activeKeys = (S.insert i (ss_activeKeys soundstate)) }
        else 
          -- no change to soundstate.
          return soundstate
    ("keye", Just i, _, Just (name, sstuff)) -> 
        if (s_keytype sstuff == Vol || s_keytype sstuff == HitVol) then do 
          -- set volume to zero, and/or stop playback.
          print $ "freeing: " ++ (show i)
          withSC3 (send (n_free [(gNodeOffset + i)]))
          -- remove key from active set.
          return $ soundstate { ss_activeKeys = (S.delete i (ss_activeKeys soundstate)) }
        else
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
             sm <- loadSampMap (ss_sampmaprootdir soundstate) 
                               ((ss_sampmaps soundstate) !! index) 
                               gBufStart
             return $ soundstate { ss_samples = sm, ss_sampmapIndex = index }
         else
             return soundstate
        _ -> return soundstate
    (_,_,_,_) -> do 
      -- for anything else, ignore.
      print "ignore"
      return soundstate

