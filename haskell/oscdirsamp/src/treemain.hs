import System.Directory
import System.Environment
import Data.List.Split

import Text.Show.Pretty

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

main = do 
 args <- getArgs
 if (length args /= 2) 
    then do
      print "syntax:"
      print "oscdirsamp <oscprefix> <sample directory>"
    else do
      print $ "prefix" ++ args !! 0
      blah <- treein (args !! 1)
      putStr $ ppShow blah

dirtree :: FilePath -> IO DTree
dirtree rootdir = do
  files <- getDirectoryContents rootdir
  blah <- mapM treein (map (\f -> rootdir ++ "/" ++ f) (filter (\e -> notElem e [".", ".."]) files))
  return $ DeeTree rootdir blah
 
treein :: FilePath -> IO DTree
treein fileordir = do
  doesit <- doesDirectoryExist fileordir
  if doesit
    then do
      tree <- dirtree fileordir
      return tree
    else
      return $ DeeFile (fname fileordir)
      

