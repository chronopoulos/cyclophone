/***********************************************************************
 * spideviceTest.cpp. Sample program that tests the spidevice class.
 * an spidevice class object (a2d) is created. the a2d object is instantiated
 * using the overloaded constructor. which opens the spidev0.0 device with
 * SPI_MODE_0 (MODE 0) (defined in linux/spi/spidev.h), speed = 1MHz &
 * bitsPerWord=8.
 *
 * call the spiWriteRead function on the a2d object 20 times. Each time make sure
 * that conversion is configured for single ended conversion on CH0
 * i.e. transmit ->  byte1 = 0b00000001 (start bit)
 *                   byte2 = 0b1000000  (SGL/DIF = 1, D2=D1=D0=0)
 *                   byte3 = 0b00000000  (Don't care)
 *      receive  ->  byte1 = junk
 *                   byte2 = junk + b8 + b9
 *                   byte3 = b7 - b0
 *    
 * after conversion must merge data[1] and data[2] to get final result
 *
 *
 *
 * *********************************************************************/
#include "spidevice.h"
 
using namespace std;

int main(void)
{
    int i = 20;
    spidevice a2d("/dev/spidev0.0", SPI_MODE_0, 1000000, 8);

    // int a2dVal = 0;
    // int a2dChannel = 0;
  
    unsigned short data;
 
    while(i > 0)
    {
        // --------------- set up the control word -------------
        //          |              indicates manual mode.
        //           |             "enables programming of bits DI6-00"  
        //            ||||         address of the ADC for the next frame.
        //                |        5V range.  0 = 2.5v
        //                 |       0 = normal operation.  1 = power down.
        //                  |      0 = return ADC address.  
        //                         1 = return digital IO vals.
        //                   ||||  digital IO vals, if they are configged for output
        //                         numbering is 3210.
        data = 0b0001101011000000;

        a2d.spiWriteRead((unsigned char*)&data, sizeof(data) );

        // ---------------- decode the recieved data ---------------
       
        // first 4 bits are adc number. 
        unsigned char adcnumber = (data & 0b1111000000000000) >> 12; 
        // these 10 bits are the adc value.
        unsigned char adcvalue = (data & 0b0000111111111100) >> 2; 

        cout << "adc number: " << adcnumber << " returned: " << adcvalue << endl;

    }
    return 0;
}
