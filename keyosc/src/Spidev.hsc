{-# LANGUAGE CPP, ForeignFunctionInterface #-}

module Spidev where

import Foreign
import Foreign.C.Types
import Foreign.C.String
import System.Posix.IO
import GHC.IO.Device

-- #include <linux/types.h>
-- #include <linux/spi/spidev.h>

-- #include "spicrap.h"

-- spihigh = #const SPI_CS_HIGH 
-- rdmode = #const SPI_IOC_RD_MODE

-- unsigned char GetSPICrap8(SPIThing8 aSpit)
-- unsigned char GetSPICrap32(SPIThing32 aSpit)


-- int spiOpen(const char *aCDevspi,
--            unsigned char mode,
--            unsigned char bitsPerWord, 
--            unsigned int speed);
foreign import ccall unsafe "spiOpen"
   c_spiOpen :: CString -> CUChar -> CUChar -> CInt -> IO CInt

-- int spiWriteRead( int fd,
--                   unsigned char *data, 
--                   int length,
--                   unsigned char bitsPerWord, 
--                   unsigned int speed);
foreign import ccall unsafe "spiWriteRead"
   c_spiWriteRead :: CInt -> CString -> CInt -> CUChar -> CInt -> IO CInt

-- int spiClose(int fd);
foreign import ccall unsafe "spiClose"
   c_spiClose :: CInt -> IO CInt


{- 
foreign import ccall unsafe "GetSPICrap8"
   c_getspicrap8 :: CInt -> IO CInt

printit x = 
 do 
  wha <- c_getspicrap8 x
  putStrLn (show wha)

preent = 
 do
  let blah = #const SPI_CS_HIGH 
  putStrLn (show blah)
  let mahblah = #const SPI_IOC_RD_MODE
  putStrLn (show mahblah)
  mapM printit [0..5]
-}


{-
spiopen pathname mode bitsPerWord speed = 
 do 
  fd <- openFd pathname ReadWrite Nothing defaultFileFlags 

  ioctl fd (c_getspicrap8 WR_MODE) mode
  ioctl fd (c_getspicrap8 RD_MODE) mode
  ioctl fd (c_getspicrap8 SPI_IOC_WR_BITS_PER_WORD) bitsPerWord
  ioctl fd (c_getspicrap8 SPI_IOC_RD_BITS_PER_WORD) bitsPerWord
  ioctl fd (c_getspicrap8 SPI_IOC_WR_MAX_SPEED_HZ) speed
 
  return fd

-}
