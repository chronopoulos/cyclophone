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
void printBits(const void *ptr, size_t const bytes)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte=0;
    unsigned int i;
    int j;

    for (i=0; i<bytes ;i++)
    {
        for (j=7;j>=0;j--)
        {
            byte = b[i] & (1<<j);
            byte >>= j;
            // cout << i << ", " << j << ": " << (int)byte << endl;
            cout << (int)byte;
 	        // printf("%u", byte);
        }
    }
    //cout << endl;
    //puts("");
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
  
    // unsigned char data[2];
    unsigned int adcnumber;
    unsigned int adcvalue;

    size_t iocount = 6;
    unsigned char iodata[12];
    unsigned int inputstatus[6];

    for (unsigned int i =0; i < iocount; ++i)
        inputstatus[i] = 0;
     
    while(i > 0)
    {
    // --------------- set up the control word -------------
    //             |              indicates manual mode.
    //              |             "enables programming of bits DI6-00"  
    //               ||||         address of the ADC for the next frame.
    //                   |        1 = 5V range.  0 = 2.5v
    //                    |       0 = normal operation.  1 = power down.
    //                     |      0 = return ADC address.  
    //                            1 = return digital IO vals.
    //                      ||||  digital IO vals, if they are configged for output
    //                           numbering is 3210.
    //        0b0001100110000000

    // input 0
    iodata[0]=0b00011000;    // input 0
    iodata[1]=0b00000000;

    iodata[2]=0b00011000;    // input 1
    iodata[3]=0b10000000;

    iodata[4]=0b00011001;    // input 2
    iodata[5]=0b00000000;

    iodata[6]=0b00011001;    // input 3
    iodata[7]=0b10000000;

    iodata[8]=0b00011010;    // input 4
    iodata[9]=0b00000000;

    iodata[10]=0b00011010;    // input 5
    iodata[11]=0b10000000;

    for (unsigned int i = 0; i < 6; ++i)
    {   
        // cout << "send::::: ";
        // printBits((void*)(iodata + i), 2);
        // cout << "\n";
    
        int j = i + i;
        
        a2d.spiWriteRead((iodata + j), 2); 

        // a2d.spiWriteRead((unsigned char*)&(iodata[i]), sizeof(iodata[0]));
        // ---------------- decode the recieved data ---------------

        // cout << "received: ";
        // printBits((void*)(iodata + j), 2);
        // cout << "\n";
        
        // first 4 bits are adc number. 
        adcnumber = (iodata[j] & 0b11110000) >> 4; 
        // next 10 bits are the adc value.
        adcvalue = ((iodata[j] & 0b00001111) << 6) | ((iodata[j+1] & 0b11111100) >> 2); 

        // first 4 bits are adc number. 
        // adcnumber = (iodata[i] & 0b1111000000000000) >> 12; 
        // next 10 bits are the adc value.
        // adcvalue =  (iodata[i] & 0b0000111111111100) >> 2;


        // cout << "received " << adcnumber << " " << adcvalue << "\n";

        // keep the array of inputs updated.
        if (0 <= adcnumber && adcnumber < 6)
        {
            // cout << "updating " << adcnumber << " " << adcvalue << "\n";
            inputstatus[adcnumber] = adcvalue;
        }
    }

    // spew out the input status.
    
    cout << "inputstatus ";
 
    for (unsigned int i =0; i < iocount; ++i)
        cout << inputstatus[i] << " ";

    cout << endl;
     
       // cout << "adc number: " << (int)adcnumber << " returned: " << (int)adcvalue << endl;
        // cout << "raw data: " << data << endl; 
	    //cout << "raw data: ";
        //printBits(&data, sizeof(data));
	    //cout << endl;
        lo_send(pd, "/photodiode", "ii", 1023-inputstatus[4], 1023-inputstatus[5]);

 	//sleep(0.03);
 	sleep(0.1);

    }
    return 0;
}
