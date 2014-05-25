import System.Directory
import System.Environment
import Data.List.Split
import Text.Show.Pretty
import qualified Data.Map as M
import Control.Monad
import Control.Monad.Fix
import Graphics.UI.SDL as SDL
import Graphics.UI.SDL.Mixer as Mix


import Sound.OSC.FD

pathlist fpath = splitOneOf "/" fpath

fname fullpath = last (pathlist fullpath)

-- audioRate     = 22050
audioRate     = 44100
-- audioFormat   = Mix.AudioS16LSB
audioFormat   = Mix.AudioU16LSB
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
        let port = readMaybe (args !! 1) :: (Maybe Int)
         in case port of
           Just p -> oscloop (args !! 0) p soundmap
           Nothing -> putStrLn $ "Invalid port: " ++ (args !! 0) 

oscloop :: String -> Int -> M.Map String Mix.Chunk -> IO ()
oscloop ip port soundmap = do
  withTransport (t ip port) f
  where
    f fd = forever 
      (recvMessage fd >>= 
        (\msg -> 
           case msg of 
              Just msg -> onoscmessage soundmap msg
              Nothing -> return ())) 
    t ip port = udpServer ip port 


onoscmessage :: M.Map String Mix.Chunk -> Message -> IO ()
onoscmessage soundmap msg = do
  let soundname = messageAddress msg 
      sound = M.lookup soundname soundmap
   in case sound of 
    Just s -> do { chn <- Mix.playChannel anyChannel s 0; return () }
    Nothing -> return ()
 
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


