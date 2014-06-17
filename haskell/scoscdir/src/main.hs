import System.Directory
import System.Environment
import Data.List.Split
import Text.Show.Pretty
import Control.Monad
import Control.Monad.Fix
import Sound.SC3
import qualified Sound.OSC.FD as OSC

import qualified Data.Map as M
import qualified Data.Set as S

import Treein

-- pathlist fpath = splitOneOf "/" fpath
-- fname fullpath = last (pathlist fullpath)

-- make a synth from the sample..  'graph' type.
-- actually is synthdef?
makeSynth fname bufno =
  withSC3 (do
    async (b_allocRead bufno fname 0 0)
    return $ synth (out 0 ((playBuf 1 AR (constant bufno) 1.0 1 0 NoLoop RemoveSynth) * (control KR "amp" 0.5)))
    )

stopp = 
 withSC3 (do {reset
             ;_ <- async (b_close 0)
             ;async (b_free 0)})

data SampleStuff = SampleStuff {
  s_synth :: Graph,
  s_bufId :: Int
  }

fn2on :: String -> String -> String -> String
fn2on rootdir oscprefix fname = 
  let len = length rootdir in
    oscprefix ++ (take len fname)

loadSample :: String -> String -> Int -> IO (String, SampleStuff)
loadSample filename oscname bufno = do
  synth <- makeSynth filename bufno
  return (oscname, SampleStuff synth bufno)

newtype SynthMap = Synthmap (M.Map String SampleStuff)

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
      smap <- synthmap slist (args !! 3) (args !! 2) 
      putStrLn $ ppShow $ M.keys smap
      let port = OSC.readMaybe (args !! 1) :: (Maybe Int)
          ip = (args !! 0)
          soundstate = SoundState S.empty 
       in case port of
         -- Just p -> startoscloop ip p soundmap soundstate 
         Just p -> print "start"
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
  soundchannels :: S.Set String
  }

{-
startoscloop :: String -> Int -> M.Map String Mix.Chunk -> SoundState -> IO ()
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

-- expecting 0 to 1.0
getoscamt :: OSC.Message -> Maybe Float
getoscamt msg = 
  let lst = OSC.messageDatum msg
    in case lst of
      ((OSC.Float x):xs) -> Just x
      _ -> Nothing

computevolume :: Float -> Int
computevolume fl = 
  if fl < 0 
    then 0
    else if fl > 1.0 
      then 128
      else floor (fl * 128.0)
  
-- if sound does not exist and volume is positive, create a channel playing the sound at the given volume.
-- if sound exists and volume is positive, change the volume.
-- if sound exists and volume is zero, fade it and remove from soundstate.
onoscmessage :: M.Map String Mix.Chunk -> SoundState -> OSC.Message -> IO SoundState
onoscmessage soundmap soundstate msg = do
  -- print msg
  let soundname = OSC.messageAddress msg 
      sound = M.lookup soundname soundmap
      chan = getSoundChan soundstate soundname
      amt = getoscamt msg 
   in case (sound, chan, amt) of 
    (Just s, Just c, Just a) -> 
     if (a > 0.0) 
      then do
        -- print $ "setvol: " ++ (show (computevolume a))
        Mix.volume c (computevolume a)
        return soundstate
      else do
        -- print $ "fadeout "
        -- Mix.fadeOutChannel c 250
        Mix.haltChannel c 
        return $ removeSoundChan soundstate soundname
    (Just s, Nothing, Just a) -> 
      if (a > 0.0)
        then do
          chan <- Mix.playChannel anyChannel s 0
          -- print $ "playchan, setvol: " ++ (show (computevolume a))
          Mix.volume chan (computevolume a)
          return $ addSoundChan soundstate soundname chan
        else
          return soundstate
    (Nothing, _, _) -> 
      return soundstate

-}
