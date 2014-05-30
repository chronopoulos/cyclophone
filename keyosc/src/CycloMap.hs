module CycloMap where 

import qualified Sound.OSC.FD as O
import qualified Scales as Scales

------------------------------------------------------------
-- mapping arduino and key inputs to osc outputs.
------------------------------------------------------------

data KeySendMode = 
  SampleList { samplenames :: [String] } |
  SynthPrefix { prefix :: String,
                scale :: (Int -> Int)
               }

data KeySendState = KeySendState 
  { kssSendModes :: [(Char, KeySendMode)],
    kssSendMode :: KeySendMode,
    kssStartNote :: Int
  }

data KeySendPrefs = KeySendPrefs { 
  samples :: [String],
  synth :: String
  }
  deriving (Read, Show)

makeSendModes keysendprefs = 
  let synthprefix = synth keysendprefs
      samplelist = samples keysendprefs
   in 
      [ ('a', SynthPrefix synthprefix Scales.chromatic),
        ('b', SynthPrefix synthprefix Scales.major),
        ('c', SynthPrefix synthprefix Scales.hungarianMinor),
        ('d', SynthPrefix synthprefix Scales.majorPentatonic),
        ('e', SampleList samplelist) ]

makeKeySendState keysendprefs = 
  let modes = (makeSendModes keysendprefs) in
    KeySendState modes (snd (head modes)) 25

knobmapping = [ ('A',"/arduino/delay/time"),
                ('B',"/arduino/fm/harmonic")
              ]

buttonmapping = [ ('a',"/arduino/delay/onoff"),
                  ('b',"/arduino/kill/on"),
                  ('B',"/arduino/kill/off"),
                  ('c',"/arduino/loop")
                ]

processArduinoLine :: KeySendState -> String -> (KeySendState, Maybe O.Message)
processArduinoLine kss line = 
  case line of 
    ('#':'C':numstring) -> 
       -- adjust start note!  (transpose)
       let pos = (read numstring) :: Float 
        in (kss { kssStartNote = floor (pos / 21.3125)} , Nothing)
    ('#':nobchar:numstring) ->
       -- send knob value via osc. 
       let pos = (read numstring) :: Float
           lkp = (lookup nobchar knobmapping)
        in case lkp of 
           Just msg -> (kss , Just (O.Message msg [O.Float (pos/1024.0)]))
           Nothing -> (kss, Nothing) 
    ('$':nobchar:_) ->
       -- change keysendmode
       case (lookup nobchar (kssSendModes kss)) of
         Just ksm -> (kss { kssSendMode = ksm }, Nothing)
         Nothing -> (kss, Nothing)
    ('@':bchar:_) -> 
       case (lookup bchar buttonmapping) of 
         Just msgstring -> (kss, Just (O.Message msgstring []))
         Nothing -> (kss, Nothing)
    _ -> (kss, Nothing)

  
-- turn key input into appropriate osc message, based on 
-- KeySendState.
processKeyInput :: KeySendState -> Int -> Float -> Maybe O.Message
processKeyInput (KeySendState _ (SampleList names) start) index val = 
  Just $ O.Message (names !! (mod (length names) index)) [(O.Float val)]
processKeyInput (KeySendState _ (SynthPrefix prefix scale) start) 
                index val = 
  Just $ O.Message prefix [O.Int32 (fromIntegral ((scale index) + start)), 
                           O.Float val]

   

