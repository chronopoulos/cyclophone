module Main where

import System.Directory
import System.Environment
-- import Data.List.Split
import Data.List
import qualified Data.Text as T
-- import System.FilePath
import qualified Filesystem.Path.CurrentOS as FP
import Text.Show.Pretty
import Control.Monad
import Control.Monad.Fix
import GHC.Float
import qualified Data.Map as M
import qualified Data.Set as S

import qualified Data.Text as T
import Data.Ratio

import Treein
import SampMap

-- tests = [SMap blah, SMapFile (T.pack "/thisisapth")]
-- blah = SampMap (T.pack "blah") [(1,(T.pack "blah2")), (2, (T.pack "dsfa"))]

printsyntax = do
  print "syntax:"
  print "scoscandir -scan <firstnote> <directory> <output filename>"
  print "scoscandir -combine <indexfile1> <indexfile2> <outputfile>" 

main = do 
  args <- getArgs
  if (length args < 4) then 
    printsyntax
  else case (args !! 0) of
    "-combine" -> do
      i1s <- readFile (args !! 1)
      i2s <- readFile (args !! 2)
      let index1 = read i1s :: [SampMapItem]
          index2 = read i2s :: [SampMapItem] in do
       writeFile (args !! 3) $ ppShow $ index1 ++ index2
    "-scan" -> do
      filez <- treein (args !! 2)
      let note = read (args !! 1) :: Integer 
          fpfiles = map FP.decodeString (sort filez)
          conv pdir (name, note) = 
            (note, either id id $ FP.toText (makeRelativePath pdir name)) 
          sm = SampMap { 
            sm_rootdir = T.pack $ args !! 2,
            sm_denominator = 12,   -- default to 12!
            sm_notemap = map (conv (FP.decodeString (args !! 2))) 
                             (zip fpfiles [note..]) } in do
       -- writeFile (args !! 3) $ ppShow (zip (sort filez) [note..])
       writeFile (args !! 3) $ ppShow [SMap sm]
    _ -> printsyntax 

