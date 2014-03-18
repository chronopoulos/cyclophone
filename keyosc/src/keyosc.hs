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

import Data.Bits
import Foreign.C.Types
import Foreign.C.String

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

{-
    // --------------- set up the control word -------------
    //            |              indicates manual mode.
    //             |             "enables programming of bits DI6-00"
    //              ||||         address of the ADC for the next frame.
    //                  |        1 = 5V range.  0 = 2.5v
    //                   |       0 = normal operation.  1 = power down.
    //                    |      0 = return ADC address.
    //                           1 = return digital IO vals.
    //                     ||||  digital IO vals, if they are configged for output
    //                           numbering is 3210.
    //data = 0b0001100001000000;

    // last 3 bits are 1st 3 bits of adc index.
    data[0] = 0b00011000 | ((adcindex & 0b00001110) >> 1);

    // first digit is least sig. bit of adc index.
    data[1] = 0b01000000 | (adcindex << 7);
-}

-- let b1 = 0b00011000 .|. (shift -1 (adcindex .&. 0b00001110))
--     b2 = 0b01000000 .|. (shift 7 adcindex)

setupcontrolword :: CUChar -> (CUChar, CUChar)
setupcontrolword adcindex = 
 let intdex = fromIntegral adcindex
     b1 = (24::CUChar) .|. ((shift (adcindex .&. (14::CUChar)) (-1))::CUChar)
     b2 = (64::CUChar) .|. ((shift adcindex 7)::CUChar)
 in (b1,b2)


-- map setupcontrolword [2..12]

  
-- int spiWriteRead( int fd,
--                   unsigned char *data,
--                   int length,
--                   unsigned char bitsPerWord,
--                   unsigned int speed);

poll fd (b1,b2) = 
 do 
  S.useAsCString (S.pack [castCUCharToChar b1,castCUCharToChar b2]) 
   (\sendbytes -> do
    c_spiWriteRead fd sendbytes 2 8 1000000)

main = 
 do
   putStrLn "Hello"
   S.useAsCString (S.pack "/dev/spidev0.0")
    (\devname -> do
      fd1 <- c_spiOpen devname 0 8 1000000
      putStr "fd1 = "
      putStrLn (show fd1)
      wut <- (poll fd1 (setupcontrolword 2))
      putStrLn (show wut))

