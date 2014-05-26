#include <stdio.h>
#include "SDL.h"
#include "SDL_mixer.h"

int main( int argc, char* args[] )
{

  if (SDL_Init(SDL_INIT_AUDIO) != 0) {
  	fprintf(stderr, "Unable to initialize SDL: %s\n", SDL_GetError());
  		return 1;
  		}
  		 
    // int audio_rate = 22050;
    int audio_rate = 44100;
    Uint16 audio_format = AUDIO_S16SYS;
    int audio_channels = 2;
    int audio_buffers = 4096;
  		  
    if(Mix_OpenAudio(audio_rate, audio_format, audio_channels, audio_buffers) != 0) {
    	fprintf(stderr, "Unable to initialize audio: %s\n", Mix_GetError());
    		exit(1);
    		}	

    Mix_Chunk *sound = NULL;
 
    sound = Mix_LoadWAV("sound.wav");
    if(sound == NULL) {
 	fprintf(stderr, "Unable to load WAV file: %s\n", Mix_GetError());
    }


    int channel;
 
    channel = Mix_PlayChannel(-1, sound, 0);
    if(channel == -1) {
       fprintf(stderr, "Unable to play WAV file: %s\n", Mix_GetError());
    }


    while(Mix_Playing(channel) != 0);
 
    Mix_FreeChunk(sound);
  
    Mix_CloseAudio();
    SDL_Quit();

    return 0;
}
