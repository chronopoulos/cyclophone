#include "spidevice.h"
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

/**********************************************************
 * spiOpen() 
 * It is responsible for opening the spidev device
 * "devspi" and then setting up the spidev interface.

  suggested defaults:

    mode = SPI_MODE_0 ;
    bitsPerWord = 8;
    speed = 1000000;

 * *********************************************************/
int spiOpen(const char *aCDevspi,
            unsigned char mode,
            unsigned char bitsPerWord, 
            unsigned int speed){
  int statusVal = -1;
  int fd = -1;
  fd = open(aCDevspi, O_RDWR);
  if(fd < 0){
      perror("could not open SPI device");
      return -1;
  }

  // printf("SPI_MODE_0 = %i", SPI_MODE_0);

  statusVal = ioctl (fd, SPI_IOC_WR_MODE, &mode);
  if(statusVal < 0){
      perror("Could not set SPIMode (WR)...ioctl fail");
      return -1;
  }

  statusVal = ioctl (fd, SPI_IOC_RD_MODE, &mode);
  if(statusVal < 0) {
    perror("Could not set SPIMode (RD)...ioctl fail");
    return -1;
  }

  statusVal = ioctl (fd, SPI_IOC_WR_BITS_PER_WORD, &bitsPerWord);
  if(statusVal < 0) {
    perror("Could not set SPI bitsPerWord (WR)...ioctl fail");
    return -1;
  }

  statusVal = ioctl (fd, SPI_IOC_RD_BITS_PER_WORD, &bitsPerWord);
  if(statusVal < 0) {
    perror("Could not set SPI bitsPerWord(RD)...ioctl fail");
    return -1;
  }  

  statusVal = ioctl (fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);    
  if(statusVal < 0) {
    perror("Could not set SPI speed (WR)...ioctl fail");
    return -1;
  }

  statusVal = ioctl (fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);    
  if(statusVal < 0) {
    perror("Could not set SPI speed (RD)...ioctl fail");
    return -1;
  }

  // return file descriptor
  return fd;
}
 
/***********************************************************
 * spiClose(): Responsible for closing the spidev interface.
 * *********************************************************/
int spiClose(int fd){
    int statusVal = -1;
    statusVal = close(fd);
    if(statusVal < 0) {
      perror("Could not close SPI device");
      exit(1);
    }
    return statusVal;
}
 
/********************************************************************
 * This function writes data "data" of length "length" to the spidev
 * device. Data shifted in from the spidev device is saved back into
 * "data".
 * ******************************************************************/
int spiWriteRead( int fd,
                  unsigned char *data, 
                  int length,
                  unsigned char bitsPerWord, 
                  unsigned int speed)
{
  struct spi_ioc_transfer spi[length];
  int i = 0;
  int retVal = -1; 
 
  // one spi transfer for each byte
 
  for (i = 0 ; i < length ; i++)
  {
    spi[i].tx_buf        = (unsigned long)(data + i); // transmit from "data"
    spi[i].rx_buf        = (unsigned long)(data + i) ; // receive into "data"
    spi[i].len           = sizeof(*(data + i)) ;
    spi[i].delay_usecs   = 0 ;
    spi[i].speed_hz      = speed ;
    spi[i].bits_per_word = bitsPerWord ;
    spi[i].cs_change = 0;
  }

  retVal = ioctl (fd, SPI_IOC_MESSAGE(length), &spi) ;
 
  if(retVal < 0){
    perror("Problem transmitting spi data..ioctl");
    return -1;
  }

  return retVal;
}
 

