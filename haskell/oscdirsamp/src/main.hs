import System.Directory
import System.Environment
import Data.List.Split
import Text.Show.Pretty
import qualified Data.Map as M
import Control.Monad
import Control.Monad.Fix
import Graphics.UI.SDL as SDL
import Graphics.UI.SDL.Mixer as Mix


import qualified Sound.OSC.FD as OSC

pathlist fpath = splitOneOf "/" fpath

fname fullpath = last (pathlist fullpath)

audioRate     = 22050
-- audioRate     = 44100
audioFormat   = Mix.AudioS16LSB
-- audioFormat   = Mix.AudioU16LSB
audioChannels = 2   -- make 24??
audioBuffers  = 4096
anyChannel    = (-1)


main = do 
 args <- getArgs
 if (length args /= 4) 
    then do
      print "syntax:"
      print "oscdirsamp <ip> <port> <oscprefix> <sample directory>"
    else do
      SDL.init [SDL.InitAudio]
      -- Mix.allocateChannels(
      result <- openAudio audioRate audioFormat audioChannels audioBuffers
      -- print $ "osc prefix: " ++ args !! 2
      smap <- treein (args !! 3)
      let soundmap = addkeyprefix (args !! 2) smap in do 
        putStrLn $ ppShow $ M.keys soundmap
        let port = OSC.readMaybe (args !! 1) :: (Maybe Int)
            ip = (args !! 0)
            soundstate = SoundState (M.fromList []) 
         in case port of
           Just p -> startoscloop ip p soundmap soundstate 
           Nothing -> putStrLn $ "Invalid port: " ++ (args !! 0) 


data SoundState = SoundState {
  soundchannels :: M.Map String Int
  }


addSoundChan :: SoundState -> String -> Int -> SoundState
addSoundChan soundstate name chn = 
  soundstate { soundchannels = M.insert name chn (soundchannels soundstate) }

removeSoundChan soundstate name = 
  soundstate { soundchannels = M.delete name (soundchannels soundstate) }

getSoundChan :: SoundState -> String -> Maybe Int
getSoundChan soundstate name = M.lookup name (soundchannels soundstate)


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

-----------------------------------------------------------------------
-- reading in a directory tree of sounds.
-----------------------------------------------------------------------

treein :: FilePath -> IO (M.Map String Mix.Chunk)
treein fileordir = do 
  sigtree <- treeinm M.empty fileordir
  return (stripkeys (length fileordir) sigtree)
    
treeinm :: (M.Map String Mix.Chunk) -> FilePath -> IO (M.Map String Mix.Chunk)
treeinm tomap fileordir = do
  doesit <- doesDirectoryExist fileordir
  if doesit
    then do
      files <- getDirectoryContents fileordir
      let fullfiles = (map (\f -> fileordir ++ "/" ++ f) (filter (\e -> notElem e [".", ".."]) files)) in
        treeind tomap fullfiles 
    else do
      chunk <- (Mix.loadWAV fileordir) 
      return $ M.insert fileordir chunk tomap
   
treeind :: (M.Map String Mix.Chunk) -> [FilePath] -> IO (M.Map String Mix.Chunk)
treeind tomap (f:fs) = do
  mp <- treeinm tomap f
  treeind mp fs
treeind tomap [] = return tomap

addkeyprefix prefix inmap =
  M.foldWithKey (\k s mp -> M.insert (prefix ++ k) s mp) M.empty inmap 

stripkeys count inmap =
  M.foldWithKey (\k s mp -> M.insert (drop count k) s mp) M.empty inmap 


