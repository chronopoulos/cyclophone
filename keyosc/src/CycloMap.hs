module CycloMap where 

import qualified Sound.OSC.FD as O

------------------------------------------------------------
-- mapping arduino and key inputs to osc outputs.
------------------------------------------------------------

data KeySendMode = 
  SampleList { samples :: [String] } |
  SynthPrefix { prefix :: String,
                scale :: (Int -> Int)
               }

data KeySendState = KeySendState 
  { kssSendMode :: KeySendMode,
    kssStartNote :: Int
  }

data KeySendPrefs = KeySendPrefs { 
  samples = [String]
  synth = String
  }

makeSendModes keysendprefs = 
  let synthprefix = synth keysendprefs
      samplelist = samples keysendprefs
   in 
    M.fromList
      [ ('a', SynthPrefix synthprefix Scales.chromatic),
        ('b', SynthPrefix synthprefix Scales.major),
        ('c', SynthPrefix synthprefix Scales.hungarianMinor),
        ('d', SynthPrefix synthprefix Scales.majorPentatonic),
        ('e', SampleList samplelist) ]

knobmapping = [ ('A',"/arduino/delay/time"),
                ('B',"/arduino/fm/harmonic")
              ]

buttonmapping = [ ('a',"/arduino/delay/onoff"),
                  ('b',"/arduino/kill/on"),
                  ('B',"/arduino/kill/off"),
                  ('c',"/arduino/loop")
                ]

processArduinoLine :: [(Char, KeySendMode)] -> [Char] -> KeySendState -> (KeySendState, Maybe O.Message)
processArduinoLine sendmodes kss line = 
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
       case (lookup nobchar sendmodes) of
         Just ksm -> (kss { kssSendMode = ksm }, Nothing)
         Nothing -> (kss, Nothing)
    ('@':bchar:_) -> 
       case (lookup bchar buttonmapping) of 
         Just msgstring -> (kss, Just (O.Message msgstring []))
         Nothing -> (kss, Nothing)
    _ -> (kss, Nothing)

-- turn key input into appropriate osc message?       
processKeyInput KeySendState -> Int -> Float -> O.Message
processKeyInput kss index val = 
  
   

