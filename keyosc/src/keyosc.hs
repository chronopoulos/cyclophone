-- module Main where
import System.Environment
-- import System.Posix.IOCtl
-- import System.Posix.IO
-- import GHC.IO.Device
import Spidev
import Text.Printf
import Sound.OSC.FD

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

speed = 2000000
bitsperword = 8

poll :: CInt -> (CUChar, CUChar) -> IO (Int, Int)
poll fd (b1,b2) = 
 do 
  S.useAsCStringLen (S.pack [castCUCharToChar b1,castCUCharToChar b2]) 
   (\sendbytes -> do
    -- threadDelay 500
    c_spiWriteRead fd (fst sendbytes) 2 bitsperword speed
    bs <- S.packCStringLen sendbytes
    return (decodedata (castCharToCUChar (S.index bs 0)) (castCharToCUChar (S.index bs 1)))
    )

sensors = map setupcontrolword [2..13]
sensorcount = length sensors

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

getvallist :: CInt -> IO [(Int,Int)]
getvallist fd = 
  sequence (map (\x -> poll fd x) sensors)

{-
getvallists fd1 fd2 =
  do 
    a <- sequence (getvallist fd1)
    b <- sequence (getvallist fd2) 
    return (a ++ (map (\(x,y) -> ((x + 16), y)) b))
-}

getallvals :: [CInt] -> IO [(Int,Int)]
getallvals fdlst = getallvalz fdlst 0

getallvalz :: [CInt] -> Int -> IO [(Int,Int)]
getallvalz (fd:fdr) offset = 
 do 
   a <- getvallist fd
   b <- getallvalz fdr (offset + sensorcount)
   return ((map addoff a) ++ b)
   where addoff (a,b) = (a + offset, b)
getallvalz [] offset = return []

repete :: [CInt] -> [Int] -> IO ()
repete fdlist baselines = 
 do 
  newvals <- (getallvals fdlist)
  -- putStrLn (show newvals)
  -- putStrLn (show (zipWith (-) (map snd newvals) baselines))
  niceprint (zipWith (-) (map snd newvals) baselines)
  repete fdlist baselines

repetay :: [CInt] -> ([(Int,Int)] -> IO [()]) -> IO ()
repetay fdlist theftn =  
 do 
  newvals <- (getallvals fdlist)
  theftn newvals
  repetay fdlist theftn


thres = -50

drumlist = ["/arduino/drums/tr909/0",
            "/arduino/drums/tr909/1",
            "/arduino/drums/tr909/2",
            "/arduino/drums/tr909/3",
            "/arduino/drums/tr909/4",
            "/arduino/drums/tr909/5",
            "/arduino/drums/dundunba/0",
            "/arduino/drums/dundunba/1",
            "/arduino/drums/dundunba/2",
            "/arduino/drums/dundunba/3",
            "/arduino/drums/rx21Latin/0",
            "/arduino/drums/rx21Latin/1",
            "/arduino/drums/rx21Latin/2",
            "/arduino/drums/rx21Latin/3",
            "/arduino/drums/rx21Latin/4",
            "/arduino/drums/rx21Latin/5",
            "/arduino/drums/tabla/0",
            "/arduino/drums/tabla/1",
            "/arduino/drums/tabla/2",
            "/arduino/drums/tabla/3",
            "/arduino/drums/tabla/4",
            "/arduino/drums/tabla/5",
            "/arduino/drums/tabla/6",
            "/arduino/drums/tabla/7"]

{-
getvalseries count fd1 fd2 appendtome = 
  if (count <= 0)
   then 
    return appendtome
   else
    do 
      newvals <- getvallists fd1 fd2
      getvalseries (count - 1) fd1 fd2 (newvals : appendtome)
-}

niceprint [] = 
 do 
   putStrLn ""
niceprint lst = 
 do 
  printf "%4d " (head lst)
  niceprint (tail lst)

-- makes a ftn which contains its own sendfun, msglist, and baselines.
thressend sendfun msglist baselines = (\newvals ->
 let indexlist = filter (\(x,y) -> y < -50) (zipWith (\(i,v) b ->(i,v-b)) newvals baselines)
  in do
   sequence (map (\(i,v) -> sendfun (msglist !! i)) indexlist)
  )


main = 
  do
    args <- getArgs
    if (length args) < 2
      then do
        putStrLn "keyosc requires at least 2 args:"
        putStrLn "keyosc <ip> <port>"
      else do
        putStrLn "keyosc v1.0"
        t <- openUDP (args !! 0) (read (args !! 1))
        fd1 <- spiOpen "/dev/spidev0.0" 0 bitsperword speed
        fd2 <- spiOpen "/dev/spidev0.1" 0 bitsperword speed
        let fdlst = [fd1, fd2]
            sendftn msg = sendOSC t (Message msg [Int32 1])
         in do
          vals <- getallvals fdlst 
          repetay fdlst (thressend sendftn drumlist (map snd vals))


{-
main = 
 do
   putStrLn "keyosc v1.0"
   fd1 <- spiOpen "/dev/spidev0.0" 0 bitsperword speed
   fd2 <- spiOpen "/dev/spidev0.1" 0 bitsperword speed
   let fdlst = [fd1, fd2]
    in do
     vals <- getallvals fdlst 
     repete fdlst (map snd vals)
-}

