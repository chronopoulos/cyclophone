{-# LANGUAGE CPP, ForeignFunctionInterface #-}

module Spidev where

import Foreign
import Foreign.C.Types

#include <linux/spi/spidev.h>

spihigh = #const SPI_CS_HIGH 

preent = 
 do
  let blah = #const SPI_CS_HIGH 
  putStrLn (show blah)

