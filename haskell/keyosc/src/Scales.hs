module Scales where

chromatic :: Int -> Int
chromatic i = i
major :: Int -> Int 
major = scaleftn majorScale
minor :: Int -> Int 
minor = scaleftn minorScale
harmonicMinor :: Int -> Int 
harmonicMinor = scaleftn harmonicMinorScale
hungarianMinor :: Int -> Int 
hungarianMinor = scaleftn hungarianMinorScale
majorPentatonic :: Int -> Int 
majorPentatonic = scaleftn majorPentatonicScale
minorPentatonic :: Int -> Int 
minorPentatonic = scaleftn minorPentatonicScale
diminished :: Int -> Int 
diminished = scaleftn diminishedScale

majorScale = [0,2,4,5,7,9,11]
minorScale = [0,2,3,5,7,8,10]
harmonicMinorScale = [0,2,3,5,7,8,11]
hungarianMinorScale = [0,2,3,6,7,8,11]
majorPentatonicScale = [0,2,4,7,9]
minorPentatonicScale = [0,3,5,7,10]
diminishedScale = [0,2,3,5,6,8,9,11]

scaleftn scale index = 
 let (oct,ind) = divMod index (length scale)
  in 
    oct * 12 + (scale !! ind)


