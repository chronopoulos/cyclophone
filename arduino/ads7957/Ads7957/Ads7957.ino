

// include the SPI library
#include <SPI.h>


// set pin 10 as the slave select for the digital pot:
const int slaveSelectPin0 = 9;
const int slaveSelectPin1 = 10;   // = SS
// const int MOSI = 11;
// const int MISO = 12;
// const int SCK = 13;

const int sensorcount = 12;

unsigned char controlwords[sensorcount * 2];

unsigned int outval[sensorcount];

unsigned int loopcount = 0;

unsigned char data[2];

void setup() {
  // set the slaveSelectPin as an output:
  pinMode (slaveSelectPin0, OUTPUT);
  pinMode (slaveSelectPin1, OUTPUT);
  // initializei SPI:
  SPI.begin(); 
  SPI.setBitOrder(MSBFIRST);
  SPI.setDataMode(SPI_MODE0);
  
  Serial.begin(115200);


  // setup control words.

  unsigned char *lUc = controlwords;
  for (int i = 0; i < sensorcount; ++i)
  {
    setupcontrolword(i, lUc);
    lUc += 2;
  }

  setupcontrolword(4, data);
 
}


void loop() {
  // minimum test loop for SPI comm.
  delay(500);
  unsigned char outpoot[2];
  unsigned int lUiPin, lUiVal;



//  for (int j = 0; j < 10000; ++j)
//  {
  unsigned char *lUc = controlwords;
  for (int i = 0; i < sensorcount; ++i)
  {
    digitalWrite(slaveSelectPin1,LOW);
    //  send in the address and value via SPI:
    outpoot[0] = SPI.transfer(*lUc);
    outpoot[1] = SPI.transfer(*(lUc + 1));
    
    digitalWrite(slaveSelectPin1,HIGH);
    decodeDataWord(outpoot, lUiPin, lUiVal);
    outval[i] = lUiVal;
    
    lUc += 2;
  }
//  }

  for (int i = 0; i < sensorcount; ++i)
  {
    //  send in the address and value via SPI:
    Serial.print(outval[i]);
    Serial.print("\t");
  }
  
  Serial.print(" count ");
  Serial.println(loopcount);
  ++loopcount;

  // zero out 'outvals' to see if they are being refreshed each time.
  for (int i = 0; i < sensorcount; ++i)
  {
    // outval[i] = 0;
  }
  
  // don't bother switching right now.
  // digitalWrite(slaveSelectPin0,HIGH);

  
}   

/*   
void loop() {
  Serial.print("control word:");
  Serial.print(data[0]);
  Serial.println(data[1]);

  // minimum test loop for SPI comm.
  delay(500);
  unsigned char outpoot[2];

  digitalWrite(slaveSelectPin0,HIGH);

  //  send in the address and value via SPI:
  outpoot[0] = SPI.transfer(data[0]);
  outpoot[1] = SPI.transfer(data[1]);

  digitalWrite(slaveSelectPin0,LOW);

  unsigned int lUiPin, lUiVal;

  decodeDataWord(outpoot, lUiPin, lUiVal);

  Serial.print("Pin: ");
  Serial.print(lUiPin);
  Serial.print("Val: ");
  Serial.println(lUiVal);

  
}   
  */ 
 
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

void decodeDataWord(unsigned char *data, unsigned int &adcnumber, unsigned int &adcvalue)
{
    // ---------------- decode the recieved data ---------------
    // first 4 bits are adc number. 
    adcnumber = (data[0] & 0b11110000) >> 4; 
    // next 10 bits are the adc value.
    adcvalue = ((data[0] & 0b00001111) << 6) | ((data[1] & 0b11111100) >> 2); 
}

// --------------------------------------------------
// stuff from sample program
// --------------------------------------------------
/*
  Digital Pot Control
  
  This example controls an Analog Devices AD5206 digital potentiometer.
  The AD5206 has 6 potentiometer channels. Each channel's pins are labeled
  A - connect this to voltage
  W - this is the pot's wiper, which changes when you set it
  B - connect this to ground.
 
 The AD5206 is SPI-compatible,and to command it, you send two bytes, 
 one with the channel number (0 - 5) and one with the resistance value for the
 channel (0 - 255).  
 
 The circuit:
  * All A pins  of AD5206 connected to +5V
  * All B pins of AD5206 connected to ground
  * An LED and a 220-ohm resisor in series connected from each W pin to ground
  * CS - to digital pin 10  (SS pin)
  * SDI - to digital pin 11 (MOSI pin)
  * CLK - to digital pin 13 (SCK pin)
 
 created 10 Aug 2010 
 by Tom Igoe
 
 Thanks to Heather Dewey-Hagborg for the original tutorial, 2005
 
*/

/* 

void loop() {
  // go through the six channels of the digital pot:
  for (int channel = 0; channel < 6; channel++) { 
    // change the resistance on this channel from min to max:
    for (int level = 0; level < 255; level++) {
      digitalPotWrite(channel, level);
      delay(10);
    }
    // wait a second at the top:
    delay(100);
    // change the resistance on this channel from max to min:
    for (int level = 0; level < 255; level++) {
      digitalPotWrite(channel, 255 - level);
      delay(10);
    }
  }
}

void digitalPotWrite(int address, int value) {
  // take the SS pin low to select the chip:
  digitalWrite(slaveSelectPin,LOW);
  //  send in the address and value via SPI:
  SPI.transfer(address);
  SPI.transfer(value);
  // take the SS pin high to de-select the chip:
  digitalWrite(slaveSelectPin,HIGH); 
}

*/
