{-# INCLUDE <math.h> #-}
{-# LANGUAGE ForeignFunctionInterface #-}

-- module Main where
import Sound.OSC
import System.Environment
import Foreign.C

foreign import ccall "sin" c_sin :: CDouble -> CDouble
sin :: Double -> Double
sin d = realToFrac (c_sin (realToFrac d))

main = 
 do
  args <- getArgs
  mapM putStrLn args
  putStrLn (show (Main.sin (read (args !! 0))))

