module Main where

import System.Directory
import System.Environment
import Data.List.Split
import Text.Show.Pretty
import Control.Monad
import Control.Monad.Fix
import GHC.Float
import Sound.SC3
import qualified Sound.OSC.FD as OSC
import qualified Sound.SC3.Server.Command.Float as F
import qualified Data.Map as M
import qualified Data.Set as S

import Treein

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

{-
-- substitute buffer playback with simple oscillator.
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
  s_bufId :: Int
  }

fn2on :: String -> String -> String -> String
fn2on rootdir oscprefix fname = 
  let len = length rootdir in
    oscprefix ++ (drop len fname)

loadSample :: String -> String -> Int -> IO (String, SampleStuff)
loadSample filename oscname bufno = do
  readBuf filename bufno
  let syn = (makeSynthDef ("def" ++ (show bufno)) bufno) 
   in do
    withSC3 (async (d_recv syn))
    return (oscname, SampleStuff syn bufno)
 
synthmap :: [String] -> String -> String -> IO (M.Map String SampleStuff)
synthmap filenames rootdir oscprefix = do
  leest <- sequence (map (\(fname, bufno) -> 
                            loadSample fname (fn2on rootdir oscprefix fname) bufno)
                         (zip filenames [0..]))
  return $ M.fromList leest

main = do 
 args <- getArgs
 if (length args /= 4) 
    then do
      print "syntax:"
      print "scoscdir <ip> <port> <oscprefix> <sample directory>"
    else do
      slist <- treein (args !! 3)
      print slist
      withSC3 reset
      -- withSC3 (send (g_new [(1, AddToTail, 0)]))
      -- read in the buffers, create synthdefs
      smap <- synthmap slist (args !! 3) (args !! 2) 
      putStrLn $ ppShow $ M.keys smap
      let port = OSC.readMaybe (args !! 1) :: (Maybe Int)
          ip = (args !! 0)
          soundstate = SoundState S.empty 
       in case port of
         Just p -> do 
            startoscloop ip p smap soundstate 
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
  activeKeys :: S.Set Int
  }

startoscloop :: String -> Int -> M.Map String SampleStuff -> SoundState -> IO ()
startoscloop ip port soundmap soundstate = do
  OSC.withTransport (OSC.udpServer ip port) (oscloop soundmap soundstate)
    
-- oscloop :: M.Map String Mix.Chunk -> SoundState -> IO ()
oscloop soundmap soundstate fd = do
  msg <- OSC.recvMessage fd
  case msg of 
    Just msg -> do 
      newsoundstate <- onoscmessage soundmap soundstate msg
      oscloop soundmap newsoundstate fd
    Nothing -> 
      oscloop soundmap soundstate fd

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
getsound :: Maybe Int -> M.Map String SampleStuff -> Maybe (String, SampleStuff)
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
onoscmessage :: M.Map String SampleStuff -> SoundState -> OSC.Message -> IO SoundState
onoscmessage soundmap soundstate msg = do
  -- print $ "osc message: " ++ (show msg)
  -- print $ "osc message: " ++ OSC.messageAddress msg 
  let msgtext = OSC.messageAddress msg 
      idx = getoscindex msg 
      amt = getoscamt msg
      sound = getsound idx soundmap
      node = 1
   in case (msgtext, idx, amt, sound) of 
    ("keyc", Just i, Just a, Just (name, sstuff)) -> 
     if (S.member i (activeKeys soundstate)) then
        do
          print $ "setvolactive: " ++ (show i) ++ " " ++ (show a)
          -- print "here" 
          -- set the volume.
          withSC3 (send (F.n_set1 (i + gNodeOffset) "amp" a))
          -- no change to soundstate.
          return soundstate
      else
        do
          print $ "start inactive: " ++ (show i) ++ " " ++ (show a)
          -- print "there" 
          -- set the volume.
          -- create synth.
          withSC3 (send (s_new ("def" ++ (show i)) (i + gNodeOffset) AddToTail 1 [("amp", (float2Double a))]))
          -- withSC3 (play 
          -- withSC3 (send (F.n_set1 node (show (s_bufId sstuff) ++ "amp") a))
          -- start sample.
          -- withSC3 (play (s_synth sstuff))
          -- print (s_synth sstuff)
          -- add to active keys.
          return $ soundstate { activeKeys = (S.insert i (activeKeys soundstate)) }
    ("keye", Just i, _, Just (name, sstuff)) -> do 
        -- print "stopping"
        -- set volume to zero, and/or stop playback.
        -- withSC3 (send (F.n_set1 node (show (s_bufId sstuff) ++ "amp") 0))
        -- remove key from active set.
        -- return $ soundstate { activeKeys = (S.delete i (activeKeys soundstate)) }
        print $ "freeing: " ++ (show i)
        withSC3 (send (n_free [(gNodeOffset + i)]))
        return $ soundstate { activeKeys = (S.delete i (activeKeys soundstate)) }
        -- return soundstate
    (_,_,_,_) -> do 
      -- for anything else, ignore.
      print "ignore"
      return soundstate

