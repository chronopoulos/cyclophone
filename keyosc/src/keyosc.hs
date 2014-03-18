-- module Main where
import Sound.OSC
import System.Environment
import System.Posix.IOCtl
import System.Posix.IO
import GHC.IO.Device
import Spidev

import qualified Data.ByteString.Char8 as S
-- import qualified Data.ByteString.Unsafe   as S
-- import qualified Data.ByteString.Internal as S



-- mode = SPI_MODE_0 ;
-- bitsPerWord = 8;
-- speed = 1000000;
-- spifd = -1;

{-
spiopen devname spimode bitsPerWord speed = 
 do
  fd <- openFd (args !! 0) ReadOnly Nothing defaultFileFlags 

  args <- getArgs
  fd <- openFd (args !! 0) ReadOnly Nothing defaultFileFlags 
  end <- fdSeek fd SeekFromEnd 0
  putStrLn (show end)
  putStrLn (show rdmode)
  mapM putStrLn args

  -} 



main = 
 do
   putStrLn "Hello"
   S.useAsCString (S.pack "/dev/spidev0.0")
    (\devname -> do
      fd1 <- c_spiOpen devname 0 1000000 8
      putStr "fd1 = "
      putStrLn (show fd1))

