module Scales where

import Data.Ratio

chromatic :: Int -> Rational
chromatic = scaleftn chromaticScale 
major :: Int -> Rational 
major = scaleftn majorScale
minor :: Int -> Rational 
minor = scaleftn minorScale
harmonicMinor :: Int -> Rational 
harmonicMinor = scaleftn harmonicMinorScale
hungarianMinor :: Int -> Rational 
hungarianMinor = scaleftn hungarianMinorScale
majorPentatonic :: Int -> Rational 
majorPentatonic = scaleftn majorPentatonicScale
minorPentatonic :: Int -> Rational 
minorPentatonic = scaleftn minorPentatonicScale
diminished :: Int -> Rational 
diminished = scaleftn diminishedScale

-- Scales based on 12 tones.
chromaticScale = [0%12,1%12,2%12,3%12,4%12,5%12,6%12,7%12,8%12,9%12,10%12,11%12]
majorScale = [0%12,2%12,4%12,5%12,7%12,9%12,11%12]
minorScale = [0%12,2%12,3%12,5%12,7%12,8%12,10%12]
harmonicMinorScale = [0%12,2%12,3%12,5%12,7%12,8%12,11%12]
hungarianMinorScale = [0%12,2%12,3%12,6%12,7%12,8%12,11%12]
majorPentatonicScale = [0%12,2%12,4%12,7%12,9%12]
minorPentatonicScale = [0%12,3%12,5%12,7%12,10%12]
diminishedScale = [0%12,2%12,3%12,5%12,6%12,8%12,9%12,11%12]

scaleftn :: [Rational] -> Int -> Rational
scaleftn scale index = 
 let (oct,ind) = divMod index (length scale)
  in 
    (fromIntegral oct) + (scale !! (fromIntegral ind))

-- make an infinite list of notes in the scale starting at rootnote.
noteseries scaleftn rootnote = map (((+) rootnote) . scaleftn) [0..]


-- an octave == 1.  
-- 0 == C0
-- 1 == C1
-- 9 % 12 = A0  =  27.5  =  midi #21
-- 21 % 12 = A1
toMidiNote :: Rational -> Float
toMidiNote ratnote = fromRational $ ratnote * 12

-- a kind of crappy approximation.  close enough for rock n roll?
toFreq :: (Floating a) => Rational -> a
toFreq ratnote = 8.176 * 2.0 ** (fromRational ratnote)

-- float 0->1 maps to range of rationals. 
interp :: Float -> Integer -> Integer -> Integer -> Rational                
interp amt from to denom =  
  let ans = ((floor (amt * (fromIntegral (to - from + 1)))) + from) % denom 
    in  
      if ans > to % denom then  
        to % denom 
      else 
        ans 



