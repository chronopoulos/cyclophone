import Control.Monad
import Control.Monad.Fix
import Graphics.UI.SDL as SDL
import Graphics.UI.SDL.Mixer as Mix

main = do
  SDL.init [SDL.InitAudio]
  result <- openAudio audioRate audioFormat audioChannels audioBuffers
  wat <- Mix.loadWAV "A2.wav"
  wat2 <- Mix.loadWAV "A3.wav"
  ch1 <- Mix.playChannel anyChannel wat 0
  SDL.delay 1000
  ch2 <- Mix.playChannel anyChannel wat2 0
  fix $ \loop -> do
    SDL.delay 50
    stillPlaying <- numChannelsPlaying
    when (stillPlaying /= 0) loop
  Mix.closeAudio
  SDL.quit

  where audioRate     = 22050
        audioFormat   = Mix.AudioS16LSB
        audioChannels = 2
        audioBuffers  = 4096
        anyChannel    = (-1)
