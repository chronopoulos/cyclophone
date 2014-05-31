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
#include <stdio.h>
#include "lo/lo.h"
 
using namespace std;


//assumes little endian
void printBits(void const * const ptr, size_t const size)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte=0;
    int i, j;

    //for (i=size-1;i>=0;i--)
    for (i=0; i<size ;i++)
    {
        for (j=7;j>=0;j--)
        //for (j=0;j<8;j++)
        {
            byte = b[i] & (1<<j);
            byte >>= j;
 	    printf("%u", byte);
        }
    }
    puts("");
}

int main(void)
{
    lo_address pd = lo_address_new(NULL, "8000");
    int i = 20;
    // spidevice a2d("/dev/spidev0.0", SPI_MODE_0, 4000000, 16);
    spidevice a2d("/dev/spidev0.0", SPI_MODE_0, 4000000, 8);
    // spidevice a2d("/dev/spidev0.1", SPI_MODE_0, 1000000, 8);

    // int a2dVal = 0;
    // int a2dChannel = 0;
  
    unsigned char data[2];
    unsigned int adcnumber;
    unsigned int adcvalue;


    // verify that data is actually 2 bytes.
    // assert(sizeof(data) == 2);
 
    while(i > 0)
    {
        // --------------- set up the control word -------------
        //          |              indicates manual mode.
        //           |             "enables programming of bits DI6-00"  
        //            ||||         address of the ADC for the next frame.
	    //                |        1 = 5V range.  0 = 2.5v
        //                 |       0 = normal operation.  1 = power down.
        //                  |      0 = return ADC address.  
        //                         1 = return digital IO vals.
        //                   ||||  digital IO vals, if they are configged for output
        //                         numbering is 3210.
     //   data = 0b0001100001000000;
	// input 0
	//data[0]=0b00011000;
	//data[1]=0b01000000;

	// input 15
	//data[0]=0b00011111;
	//data[1]=0b11000000;

	// input 15
	//data[0]=0b00011111;
	//data[1]=0b10000000;

	// input 0101 (5)
	//data[0]=0b00011000;
	//data[1]=0b01000000;

	data[0]=0b00011000;
	data[1]=0b11000000;

	//cout << "sending control word: ";
	//printBits(&data, sizeof(data));
	//cout << endl;

        a2d.spiWriteRead(data, sizeof(data));

        // ---------------- decode the recieved data ---------------
       
        // first 4 bits are adc number. 
        adcnumber = (data[0] & 0b11110000) >> 4; 
        // next 10 bits are the adc value.
        adcvalue = ((data[0] & 0b00001111) << 6) | ((data[1] & 0b11111100) >> 2); 

        cout << "adc number: " << (int)adcnumber << " returned: " << (int)adcvalue << endl;
        // cout << "raw data: " << data << endl; 
	cout << "raw data: ";
        printBits(&data, sizeof(data));
	cout << endl;
        lo_send(pd, "/photodiode", "i", 1023-adcvalue);


	/*

        // --------------- set up the control word -------------
        //          |              indicates manual mode.
        //           |             "enables programming of bits DI6-00"  
        //            ||||         address of the ADC for the next frame.
	//                |        1 = 5V range.  0 = 2.5v
        //                 |       0 = normal operation.  1 = power down.
        //                  |      0 = return ADC address.  
        //                         1 = return digital IO vals.
        //                   ||||  digital IO vals, if they are configged for output
        //                         numbering is 3210.
	data[0]=0b00011000;
	data[1]=0b11000000;

	//cout << "control word is: ";
	//printBits(&data, sizeof(data));
	//cout << endl;

        a2d.spiWriteRead(data, sizeof(data));

        // ---------------- decode the recieved data ---------------
       
        // first 4 bits are adc number. 
        adcnumber = (data[0] & 0b11110000) >> 4; 
        // next 10 bits are the adc value.
        adcvalue = ((data[0] & 0b00001111) << 6) | ((data[1] & 0b11111100) >> 2); 

        // cout << "raw data: " << data << endl; 
        cout << "raw data: ";
        printBits(&data, sizeof(data));
	cout << endl;

        cout << "adc number: " << (int)adcnumber << " returned: " << (int)adcvalue << endl;
 
	*/

 	sleep(0.03);

    }
    return 0;
}
