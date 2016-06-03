module SoundMap where

import qualified Data.Text as T
import Data.Ratio

-- sample holding data struct.

data KeyType = Hit | Vol | HitVol | VolHit
  deriving (Show, Read, Eq)

data KeyRange = All | 
                FromTo Int Int
  deriving (Show, Read)
  
data SoundSet = 
  Synth { 
    syn_name :: String, 
    syn_keytype :: KeyType } | 
  ShiftWav {
    sw_wavfile :: T.Text,
    sw_pitch :: Rational,
    sw_keytype :: KeyType
  } |
  NoteWavSet {
    nws_rootdir :: T.Text,
    nws_denominator :: Integer,
    nws_notemap :: [(Integer, T.Text, KeyType)]
  } | 
  KeyWavSet {
    kws_rootdir :: T.Text,
    kws_wavs :: [(T.Text, KeyType)]
  }  
  deriving (Show, Read)

data SoundMap = SoundMap { 
    sm_soundsets :: [(T.Text, SoundSet)],
    sm_keymaps :: [[(KeyRange, T.Text)]]
  } 
  deriving (Show, Read)

isValid sm = 
  let invalid = ((length (sm_soundsets sm)) == 0) || ((length (sm_keymaps sm)) == 0)
   in 
    not invalid

inRange :: Int -> KeyRange -> Bool
inRange idx All = True
inRange idx (FromTo a b) = a <= idx && idx <= b

   
