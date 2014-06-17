module Treein where 

import System.Directory
import System.Environment
import Data.List.Split

-----------------------------------------------------------------------
-- reading in a directory tree of sounds.
-- for now just results in a list of filenames.
-----------------------------------------------------------------------

treein :: FilePath -> IO [String]
treein fileordir = treeinm [] fileordir
  
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

