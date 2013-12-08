/***********************************************************************
 * mcp3008SpiTest.cpp. Sample program that tests the mcp3008Spi class.
 * an mcp3008Spi class object (a2d) is created. the a2d object is instantiated
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
#include "mcp3002Spi.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "lo/lo.h"

using namespace std;


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

    mcp3008Spi a2d("/dev/spidev1.0", SPI_MODE_0, 1000000, 8);

    int a2dVal = 0;
    unsigned char data[3];
 
    while(true)
    {

 // First do Channel 0

        data[0] = 1;  //  first byte transmitted -> start bit
        // this means: single ended mode, channel 0 (10) and MSB-first format (1) (and then 5 zeros)
        // -> see page 13 in the datasheet
        data[1] = 0b10100000;
        data[2] = 0; // third byte transmitted....don't care
 
        a2d.spiWriteRead(data, sizeof(data) );

 //       cout << "Channel 0: " << endl;
 //       cout << "Raw: ";
 //       printBits(&data, sizeof(data));
 //       cout << "Cooked: ";
        a2dVal = 0;
        a2dVal = data[1];
        a2dVal &= 0x0f;
        a2dVal <<= 6;
        a2dVal |= data[2] >> 2;
        cout << a2dVal << endl;
        lo_send(pd, "/photodiode", "i", a2dVal);
        sleep(0.1);

 // Now do channel 1
/*
        data[0] = 1;  //  first byte transmitted -> start bit
        // this means: single ended mode, channel 1 (11) and MSB-first format (1) (and then 5 zeros)
        // -> see page 13 in the datasheet
        data[1] = 0b11100000;
        data[2] = 0; // third byte transmitted....don't care
 
        a2d.spiWriteRead(data, sizeof(data) );

        cout << "Channel 1: " << endl;
        cout << "Raw: ";
        printBits(&data, sizeof(data));
        cout << "Cooked: ";
        a2dVal = 0;
        a2dVal = data[1];
        a2dVal &= 0x0f;
        a2dVal <<= 6;
        a2dVal |= data[2] >> 2;
        cout << a2dVal << endl;
        cout << "" << endl; // empty line

        sleep(1);
*/
    }
    return 0;
}
