#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

enum SPIThing8
{
  RD_MODE,
  WR_MODE,                 
  RD_LSB_FIRST,           
  WR_LSB_FIRST,          
  RD_BITS_PER_WORD,     
  WR_BITS_PER_WORD    
};

typedef enum SPIThing8 SPIThing8;


enum SPIThing32
{
  RD_MAX_SPEED_HZ,    
  WR_MAX_SPEED_HZ   
};

typedef enum SPIThing32 SPIThing32;

unsigned int GetSPICrap8(SPIThing8 aSpit)
{ 
  switch (aSpit)
  { 
    case RD_MODE:
      return SPI_IOC_RD_MODE;
    case WR_MODE:
      return SPI_IOC_WR_MODE;
    case RD_LSB_FIRST:
      return SPI_IOC_RD_LSB_FIRST;
    case WR_LSB_FIRST:
      return SPI_IOC_WR_LSB_FIRST;
    case RD_BITS_PER_WORD:
      return SPI_IOC_RD_BITS_PER_WORD;
    case WR_BITS_PER_WORD:
      return SPI_IOC_WR_BITS_PER_WORD;
    default:
      return -1;
  }
}

unsigned int GetSPICrap32(SPIThing32 aSpit)
{ 
  switch (aSpit)
  { 
    case RD_MAX_SPEED_HZ:
      return SPI_IOC_RD_MAX_SPEED_HZ;
    case WR_MAX_SPEED_HZ:
      return SPI_IOC_WR_MAX_SPEED_HZ;
    default:
      return -1;
  }
}


