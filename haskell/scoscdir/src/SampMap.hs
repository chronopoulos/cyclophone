module SampMap where

import qualified Data.Text as T
import Data.Ratio

-- sample holding data struct.

data SampMap = SampMap {
    sm_rootdir :: T.Text,
    sm_denominator :: Integer,
    sm_notemap :: [(Integer, T.Text)]
  }
  deriving (Show, Read)

data SampMapItem = SMap SampMap | SMapFile T.Text
 deriving (Show, Read)


