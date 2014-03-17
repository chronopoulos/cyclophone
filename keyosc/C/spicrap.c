#include "spicrap.h"
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>

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


