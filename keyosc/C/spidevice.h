/***********************************************************************
 * This header file contains the spidevice class definition.
 * Its main purpose is to communicate with the <????> chip using
 * the userspace spidev facility.
 * The class contains four variables:
 * mode        -> defines the SPI mode used. In our case it is SPI_MODE_0.
 * bitsPerWord -> defines the bit width of the data transmitted.
 *        This is normally 8. Experimentation with other values
 *        didn't work for me
 * speed       -> Bus speed or SPI clock frequency. According to
 *                https://projects.drogon.net/understanding-spi-on-the-raspberry-pi/
 *            It can be only 0.5, 1, 2, 4, 8, 16, 32 MHz.
 *                Will use 1MHz for now and test it further.
 * spifd       -> file descriptor for the SPI device
 *
 * The class contains two constructors that initialize the above
 * variables and then open the appropriate spidev device using spiOpen().
 * The class contains one destructor that automatically closes the spidev
 * device when object is destroyed by calling spiClose().
 * The spiWriteRead() function sends the data "data" of length "length"
 * to the spidevice and at the same time receives data of the same length.
 * Resulting data is stored in the "data" variable after the function call.
 * ****************************************************************************/
#ifndef spidevice_h
#define spidevice_h
     

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
 
#endif
