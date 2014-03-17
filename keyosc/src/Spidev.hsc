{-# LANGUAGE CPP, ForeignFunctionInterface #-}

module Spidev where

import Foreign
import Foreign.C.Types

#include <linux/spi/spidev.h>

spihigh = #const SPI_CS_HIGH 
-- rdmode = #const SPI_IOC_RD_MODE

-- unsigned char GetSPICrap8(SPIThing8 aSpit)
-- unsigned char GetSPICrap32(SPIThing32 aSpit)

foreign import ccall unsafe "GetSPICrap8"
   c_getspicrap8 :: CInt -> IO CInt

preent = 
 do
  let blah = #const SPI_CS_HIGH 
  putStrLn (show blah)
  crap8 <- c_getspicrap8 2
  putStrLn (show crap8)

