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
import SoundMap 

-- tests = [SMap blah, SMapFile (T.pack "/thisisapth")]
-- blah = SampMap (T.pack "blah") [(1,(T.pack "blah2")), (2, (T.pack "dsfa"))]

printsyntax = do
  print "syntax:"
  print "scoscandir -notescan <firstnote> <directory> <output filename>"
  print "scoscandir -idxscan <directory> <output filename>"
  print "scoscandir -synthmap <synthname> <output filename>"
  print "scoscandir -combine <indexfile1> <indexfile2> <outputfile>" 


main = do 
  args <- getArgs
  if (length args < 3) || (length args > 4) then 
    printsyntax
  else case (args !! 0) of
    "-combine" -> do
      i1s <- readFile (args !! 1)
      i2s <- readFile (args !! 2)
      let km1 = read i1s :: SoundMap 
          km2 = read i2s :: SoundMap in do
       writeFile (args !! 3) $ ppShow $ 
        km1 { 
          sm_soundsets = (sm_soundsets km1) ++ (sm_soundsets km2),
          sm_keymaps = (sm_keymaps km1) ++ (sm_keymaps km2) }
    "-notescan" -> do
      filez <- treein (args !! 2)
      let note = read (args !! 1) :: Integer 
          rdstr = if (last (args !! 2) == '/') then (args !! 2) 
                                               else ((args !! 2) ++ "/")
          rootdir = FP.decodeString rdstr 
          fpfiles = map FP.decodeString (sort filez)
          wavsetname = either id id (FP.toText $ FP.dirname rootdir)
          conv pdir (name, note) = 
            (note, 
             either id id $ FP.toText (makeRelativePath pdir name),
             Vol) 
          ws = NoteWavSet { 
            nws_rootdir = T.pack $ args !! 2,
            nws_denominator = 12,   -- default to 12!
            nws_notemap = map (conv rootdir) 
                             (zip fpfiles [note..]) } in do
       writeFile (args !! 3) $ ppShow $ SoundMap { 
          sm_soundsets = [(wavsetname, ws)],
          sm_keymaps = [[(All, wavsetname)]] }
    "-idxscan" -> 
      let infilename = (args !! 1)
          outfilename = (args !! 2) in do
        filez <- treein infilename 
        let rdstr = if (last infilename == '/') then infilename 
                                               else (infilename ++ "/")
            rootdir = FP.decodeString rdstr 
            fpfiles = map FP.decodeString (sort filez)
            wavsetname = either id id (FP.toText $ FP.dirname rootdir)
            conv pdir name = 
              (either id id $ FP.toText (makeRelativePath pdir name),
               Vol) 
            ws = KeyWavSet { 
              kws_rootdir = T.pack $ infilename,
              kws_wavs = map (conv rootdir) fpfiles
              } in do
         writeFile outfilename $ ppShow $ SoundMap { 
            sm_soundsets = [(wavsetname, ws)],
            sm_keymaps = [[(All, wavsetname)]] }
    "-synthmap" -> 
        let synthname = (args !! 1)
            outfilename = (args !! 2)
            syn = Synth { 
              syn_name = synthname,
              syn_keytype = Vol
              } in do
         writeFile outfilename $ ppShow $ SoundMap { 
            sm_soundsets = [(T.pack synthname, syn)],
            sm_keymaps = [[(All, T.pack synthname)]] }
    _ -> printsyntax 

