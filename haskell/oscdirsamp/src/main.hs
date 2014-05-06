import System.Directory
import System.Environment
import Data.List.Split
import Text.Show.Pretty
import qualified Data.Map as M

import Csound.Base



-- args:
-- prefix
-- directory

data DTree = 
    DeeFile FilePath
  | DeeTree FilePath [DTree]

instance Show DTree where
  show (DeeFile fp) = show fp
  show (DeeTree fp dtl) = (show fp) ++ (foldl (++) "" (map show dtl))

pathlist fpath = splitOneOf "/" fpath

fname fullpath = last (pathlist fullpath)

-- dac $ ar2 $ diskin2 (text "/home/bburdette/ownCloud/Cyclophone/starsplash.wav") 2

main = do 
 args <- getArgs
 if (length args /= 2) 
    then do
      print "syntax:"
      print "oscdirsamp <oscprefix> <sample directory>"
    else do
      print $ "prefix" ++ args !! 0
      blah <- treein (args !! 1)
      putStr $ ppShow $ M.keys blah

{-
dirtree :: FilePath -> IO DTree
dirtree rootdir = do
  files <- getDirectoryContents rootdir
  blah <- mapM treein (map (\f -> rootdir ++ "/" ++ f) (filter (\e -> notElem e [".", ".."]) files))
  return $ DeeTree rootdir blah
-}

 
treein :: FilePath -> IO (M.Map String (Sig, Sig))
treein fileordir = 
  treeinm M.empty fileordir
    
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

