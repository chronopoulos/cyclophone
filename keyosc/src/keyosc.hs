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

import Control.Concurrent

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


--  // first 4 bits are adc number. 
--  adcnumber = (data[0] & 0b11110000) >> 4; 
--  // next 10 bits are the adc value.
--  adcvalue = ((data[0] & 0b00001111) << 6) | ((data[1] & 0b11111100) >> 2); 

decodedata :: CUChar -> CUChar -> (Int, Int)
decodedata b1 b2 = 
  let i1 = (fromIntegral b1) :: Int
      i2 = (fromIntegral b2) :: Int
      adcindex = shift (i1 .&. 0xF0) (-4)
      adcvalue = (shift (i1 .&. 0x0F) 6) .|. 
                 (shift (i2 .&. 0xFA) (-2))
  in (adcindex, adcvalue)


-- map setupcontrolword [2..12]

  
-- int spiWriteRead( int fd,
--                   unsigned char *data,
--                   int length,
--                   unsigned char bitsPerWord,
--                   unsigned int speed);

speed = 1000000
bitsperword = 8

poll :: CInt -> (CUChar, CUChar) -> IO (Int, Int)
poll fd (b1,b2) = 
 do 
  S.useAsCStringLen (S.pack [castCUCharToChar b1,castCUCharToChar b2]) 
   (\sendbytes -> do
    threadDelay 1000
    c_spiWriteRead fd (fst sendbytes) 2 bitsperword speed
    bs <- S.packCStringLen sendbytes
    return (decodedata (castCharToCUChar (S.index bs 0)) (castCharToCUChar (S.index bs 1)))
    )

sensors = map setupcontrolword [2..13]

printsensorval :: Show a => IO (a1, a) -> IO ()
printsensorval x = 
 do 
   y <- x
   putStr (show (snd y))
   putStr " "

spiOpen :: String -> CUChar -> CUChar -> CInt -> IO CInt
spiOpen devname mode bitsperword speed = 
 S.useAsCString (S.pack devname) 
  (\bdevname -> do
    c_spiOpen bdevname mode bitsperword speed)

-- assuming two spi devices both using the same 'sensors', ie input pins.
pollall :: CInt -> CInt -> IO b
pollall fd1 fd2 = 
 do 
  mapM printsensorval (map (\x -> poll fd1 x) sensors)
  mapM printsensorval (map (\x -> poll fd2 x) sensors)
  putStrLn ""
  pollall fd1 fd2

getvallist fd = 
  (map (\x -> poll fd x) sensors)


getvallists fd1 fd2 =
  do 
    a <- sequence (getvallist fd1)
    b <- sequence (getvallist fd2) 
    return (a ++ (map (\(x,y) -> ((x + 16), y)) b))


repete :: CInt -> CInt -> [Int] -> IO ()
repete fd1 fd2 baselines = 
 do 
  newvals <- (getvallists fd1 fd2)
  putStrLn (show (zipWith (-) (map snd newvals) baselines))
  repete fd1 fd2 baselines

main = 
 do
   putStrLn "keyosc v1.0"
   fd1 <- spiOpen "/dev/spidev0.0" 0 bitsperword speed
   fd2 <- spiOpen "/dev/spidev0.1" 0 bitsperword speed
   vals <- getvallists fd1 fd2
   repete fd1 fd1 (map snd vals)


