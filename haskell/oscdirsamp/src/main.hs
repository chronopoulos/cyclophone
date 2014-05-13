import System.Directory
import System.Environment
import Data.List.Split
import Text.Show.Pretty
import qualified Data.Map as M
import Control.Monad

import Sound.OSC.FD
import Csound.Base

pathlist fpath = splitOneOf "/" fpath

fname fullpath = last (pathlist fullpath)

-- dac $ ar2 $ diskin2 (text "/home/bburdette/ownCloud/Cyclophone/starsplash.wav") 2

main = do 
 args <- getArgs
 if (length args /= 3) 
    then do
      print "syntax:"
      print "oscdirsamp <port> <oscprefix> <sample directory>"
    else do
      print $ "prefix" ++ args !! 1
      smap <- treein (args !! 2)
      let soundmap = addkeyprefix (args !! 1) smap in do 
        putStrLn $ ppShow $ M.keys soundmap
        let port = readMaybe (args !! 0) :: (Maybe Int)
         in case port of
           Just p -> oscloop p soundmap
           Nothing -> putStrLn $ "Invalid port: " ++ (args !! 0) 

{-
oscevts :: Int -> M.Map String (Sig, Sig) -> Evt (D,D)

data OscEvts = OscEvts Int (M.Map String (Sig, Sig))

instance Functor OscEvts where
 fmap f oe = 
-}

oscloop :: Int -> M.Map String (Sig, Sig) -> IO ()
oscloop port soundmap = do
  withTransport (t port) f
  where
    f fd = forever 
      (recvMessage fd >>= 
        (\msg -> 
           case msg of 
              Just msg -> onoscmessage soundmap msg
              Nothing -> return ())) 
    t port = udpServer "127.0.0.1" port 


-- this will play a sound, but it never returns.  supposed to call dac 
-- and do stuff in the functions that are its args, I suppose.
onoscmessage :: M.Map String (Sig, Sig) -> Message -> IO ()
onoscmessage soundmap msg = do
  let soundname = messageAddress msg 
      sound = M.lookup soundname soundmap
   in case sound of 
    Just s -> dac s
    Nothing -> return ()
 
treein :: FilePath -> IO (M.Map String (Sig, Sig))
treein fileordir = do 
  sigtree <- treeinm M.empty fileordir
  return (stripkeys (length fileordir) sigtree)
    
treeinm :: (M.Map String (Sig, Sig)) -> FilePath -> IO (M.Map String (Sig, Sig))
treeinm tomap fileordir = do
  doesit <- doesDirectoryExist fileordir
  if doesit
    then do
      files <- getDirectoryContents fileordir
      let fullfiles = (map (\f -> fileordir ++ "/" ++ f) (filter (\e -> notElem e [".", ".."]) files)) in
        treeind tomap fullfiles 
    else
      return $ M.insert fileordir (ar2 $ diskin2 (text fileordir) 2) tomap
   
treeind :: (M.Map String (Sig, Sig)) -> [FilePath] -> IO (M.Map String (Sig, Sig))
treeind tomap (f:fs) = do
  mp <- treeinm tomap f
  treeind mp fs
treeind tomap [] = return tomap

addkeyprefix prefix inmap =
  M.foldWithKey (\k s mp -> M.insert (prefix ++ k) s mp) M.empty inmap 

stripkeys count inmap =
  M.foldWithKey (\k s mp -> M.insert (drop count k) s mp) M.empty inmap 


