module Treein where 

import System.Directory
import System.Environment
import Data.List.Split
import qualified Filesystem.Path.CurrentOS as FP
import Data.Maybe
import Data.List

-----------------------------------------------------------------------
-- reading in a directory tree
-- results in a list of filenames.
-----------------------------------------------------------------------

dropslash :: FilePath -> FilePath
dropslash fp = 
  if ((last fp) == '/') then
    (take ((length fp) - 1) fp)
  else
    fp 

treein :: FilePath -> IO [String]
treein fileordir = treeinm [] (dropslash fileordir)
  
treeinm :: [String] -> FilePath -> IO [String]
treeinm array fileordir = do
  doesit <- doesDirectoryExist fileordir
  if doesit
    then do
      files <- getDirectoryContents fileordir
      let fullfiles = (map (\f -> fileordir ++ "/" ++ f) (filter (\e -> notElem e [".", ".."]) files)) in
        treeind array fullfiles 
    else do
      return $ fileordir : array 
   
treeind :: [String] -> [FilePath] -> IO [String] 
treeind paths (f:fs) = do
  nwlist <- treeinm paths f
  treeind nwlist fs
treeind paths [] = return paths

-------------------------------------------------------
-- make a relative path from one file/dir to another.
-------------------------------------------------------

makeRelativePath :: FP.FilePath -> FP.FilePath -> FP.FilePath
makeRelativePath frompath topath = 
  let common = FP.commonPrefix [frompath, topath]
      -- len = length . FP.splitDirectories . fromJust 
      --        (FP.stripPrefix common (FP.directory frompath)) 
      fj = fromJust 
              (FP.stripPrefix common (FP.directory frompath)) 
      len = length (FP.splitDirectories fj)
      topart = fromJust (FP.stripPrefix common topath) 
      relpart = (FP.decodeString (concat (replicate len "../")))
    in
      FP.append relpart topart
 
testRelPath :: String -> String -> String
testRelPath s1 s2 = FP.encodeString $ 
  makeRelativePath (FP.decodeString s1) (FP.decodeString s2)

testComPre :: String -> String -> String
testComPre s1 s2 = FP.encodeString $ 
  FP.commonPrefix [(FP.decodeString s1), (FP.decodeString s2)]



