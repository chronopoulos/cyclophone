#include "spidevice.h" 
#include <stdio.h> 

// data is a two byte array of unsigned char.
void setupcontrolword(unsigned char adcindex, unsigned char *data)
{
    // --------------- set up the control word -------------
    //            |              indicates manual mode.
    //             |             "enables programming of bits DI6-00"  
    //              ||||         address of the ADC for the next frame.
    //                  |        1 = 5V range.  0 = 2.5v
    //                   |       0 = normal operation.  1 = power down.
    //                    |      0 = return ADC address.  
    //                           1 = return digital IO vals.
    //                     ||||  digital IO vals, if they are configged for output
    //                           numbering is 3210.
    //data = 0b0001100001000000;

    // last 3 bits are 1st 3 bits of adc index.  	
    data[0] = 0b00011000 | ((adcindex & 0b00001110) >> 1);
 
    // first digit is least sig. bit of adc index.
    data[1] = 0b01000000 | (adcindex << 7);
}

void decodeAdsWord(unsigned char data[2], unsigned int &adcnumber, unsigned int &adcvalue)
{
  // cout << "count: " << aUiCount << endl;

    // ---------------- decode the recieved data ---------------
    // first 4 bits are adc number. 
    adcnumber = (data[0] & 0b11110000) >> 4; 
    // next 10 bits are the adc value.
    adcvalue = ((data[0] & 0b00001111) << 6) | ((data[1] & 0b11111100) >> 2); 
}

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
  printf("sensorcheck - start");
  int fd = spiOpen("/dev/spidev0.0", 0, 8, 1000000);

  unsigned char data[2];
  unsigned int sensorindex, sensorval;

  while (true)
  {
    for (unsigned char index = 0; index < 16; ++index)
    {
      setupcontrolword(index, data);
      spiWriteRead(fd, data, 2, 8, 1000000);
      decodeAdsWord(data, sensorindex, sensorval);
      printf ("%i ", sensorval);
    }
    printf("\n");
  }
} 



