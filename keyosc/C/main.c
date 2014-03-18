#include "spidevice.h" 
#include <stdio.h> 

/*
int spiOpen(const char *aCDevspi,
            unsigned char mode,
            unsigned char bitsPerWord, 
            unsigned int speed);
int spiClose(int fd);
int spiWriteRead( int fd,
                  unsigned char *data, 
                  int length,
                  unsigned char bitsPerWord, 
                  unsigned int speed);
*/

int main() 
{
  printf("start");
  int fd = spiOpen("/dev/spidev0.0", 0, 8, 100000);

  printf("fd: %i \n", fd); 
} 

