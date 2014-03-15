/***********************************************************************
 *
 * simple key press.  
 *
 * *********************************************************************/
#include "spidevice.h"
#include <stdio.h>
// #include "lo/lo.h"
#include <sstream>
#include <iomanip>
 
using namespace std;

int gIThres = -25;

//assumes little endian
void printBits(void const * const ptr, size_t const size)
{
  // return;
  unsigned char *b = (unsigned char*) ptr;
  unsigned char byte=0;
  unsigned int i;
  int j;  // MUST be int for countdown loop; otherwise never < 0.

  for (i=0; i<size ;i++)
  {
    for (j=7;j>=0;j--)
    {
      byte = b[i] & (1<<j);
      byte >>= j;
      printf("%u", byte);
    }
  }
  puts("");
}

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

class IRSensor
{
public:
  IRSensor(char aUcInputPin)
   :mUcInputPin(aUcInputPin), mILast(0), mBActive(false) 
  {
    setupcontrolword(aUcInputPin, mUcControlWord);
  }

  void SetLast(int aILast)
  {
    // if the last was above the thres and the current is below, then 
    // the sensor is active.  So its only active on the threshold crossing.
    mBActive = mILast >= mIThres && aILast < mIThres;
      
    mILast = aILast;
  }
  int GetLast() { return mILast; }

  void SetBaseline(int aIBaseline)
  {
    mIBaseline = aIBaseline;
    mIThres = mIBaseline + gIThres; 
  }
  int GetBaseline() { return mIBaseline; }

  bool IsActive() { return mBActive; }

  unsigned char mUcControlWord[2];
  const char mUcInputPin;
private: 
  bool mBActive;
  int mILast;
  int mIBaseline;
  int mIThres;
  void ActiveCheck();
};

void UpdateSensors(spidevice &aSpi, 
		unsigned int aUiCount, IRSensor aIrsArray[], 
                IRSensor* aIrsByPin[])
{
  unsigned char data[2];
  unsigned int adcnumber, adcvalue;

  // cout << "count: " << aUiCount << endl;

  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    data[0] = aIrsArray[i].mUcControlWord[0];
    data[1] = aIrsArray[i].mUcControlWord[1];

    aSpi.spiWriteRead(data, sizeof(data));

    sleep(.001);

    // ---------------- decode the recieved data ---------------
    // first 4 bits are adc number. 
    adcnumber = (data[0] & 0b11110000) >> 4; 
    // next 10 bits are the adc value.
    adcvalue = ((data[0] & 0b00001111) << 6) | ((data[1] & 0b11111100) >> 2); 

    // if new is different from last by more than thres, print.
    // int diff = abs(adcvalue - aIrsByPin[adcnumber]->mUsLast);
    // if (diff > gIThres) 
    //   cout << (int)adcnumber << "\t" << (int)adcvalue << "\t" << diff << "\n";

    aIrsByPin[adcnumber]->SetLast(adcvalue);
  }

}

void setBaselines(unsigned int aUiCount, IRSensor aIrsArray[])
{
  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    aIrsArray[i].SetBaseline(aIrsArray[i].GetLast());
  }  
}

void printVals(unsigned int aUiCount, IRSensor aIrsArray[])
{
  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    cout << setw(4) << setfill(' ');
    cout << aIrsArray[i].GetLast() << " ";
  }  
}

void printDiffs(unsigned int aUiCount, IRSensor aIrsArray[])
{
  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    cout << setw(4) << setfill(' ');
    cout << aIrsArray[i].GetLast() - aIrsArray[i].GetBaseline() << " ";
  }  
}

// print the index of any activated sensor, added to the offset.
void printActDiff(unsigned int aUiOffset, unsigned int aUiCount, IRSensor aIrsArray[])
{
  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    int lIDiff = aIrsArray[i].GetLast() - aIrsArray[i].GetBaseline();
    if (lIDiff < gIThres)
      cout << "U" << setw(3) << setfill(' ') << lIDiff;
    else
      cout << "_" << setw(3) << setfill(' ') << lIDiff;

  }  
}

// print the index of any activated sensor, added to the offset.
void printActive(unsigned int aUiOffset, unsigned int aUiCount, IRSensor aIrsArray[])
{
  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    if (aIrsArray[i].IsActive())
      cout << "active: " << aUiOffset + i << endl;
  }  
}


int main(int argc, const char *args[])
{
  cout << "argc: " << argc << endl;

  int sensor = 0;

  if (argc > 1)
  {
    istringstream lIss(args[1]);
    lIss >> sensor;
  }
 
  cout << "sensor: " << sensor << endl;

  // lo_address pd = lo_address_new(NULL, "8000");

  spidevice lSpi0("/dev/spidev0.0", SPI_MODE_0, 4000000, 8);
  spidevice lSpi1("/dev/spidev0.1", SPI_MODE_0, 4000000, 8);
 
  IRSensor lIrsSpi0Sensors[] = 
    {
       IRSensor(2), 
       IRSensor(3), 
       IRSensor(4), 
       IRSensor(5), 
       IRSensor(6), 
       IRSensor(7), 
       IRSensor(8), 
       IRSensor(9), 
       IRSensor(10), 
       IRSensor(11), 
       IRSensor(12), 
       IRSensor(13) 
    };
  unsigned int lUi0Count = sizeof(lIrsSpi0Sensors) / sizeof(IRSensor);

  IRSensor lIrsSpi1Sensors[] = 
    {
       IRSensor(2), 
       IRSensor(3), 
       IRSensor(4), 
       IRSensor(5), 
       IRSensor(6), 
       IRSensor(7), 
       IRSensor(8), 
       IRSensor(9), 
       IRSensor(10), 
       IRSensor(11), 
       IRSensor(12), 
       IRSensor(13) 
    };
  unsigned int lUi1Count = sizeof(lIrsSpi1Sensors) / sizeof(IRSensor);

  unsigned int i;
  
  // lookup table for IRSensors by pin, for SPI device 0.
  IRSensor *lIrsSpi0ByPin[16];
  for (i = 0; i < 16; ++i)
    lIrsSpi0ByPin[i] = 0;

  for (i = 0; i < lUi0Count; ++i)
    lIrsSpi0ByPin[lIrsSpi0Sensors[i].mUcInputPin] = &(lIrsSpi0Sensors[i]);

  // lookup table for IRSensors by pin, for SPI device 1.
  IRSensor *lIrsSpi1ByPin[16];
  for (i = 0; i < 16; ++i)
    lIrsSpi1ByPin[i] = 0;

  for (i = 0; i < lUi1Count; ++i)
    lIrsSpi1ByPin[lIrsSpi1Sensors[i].mUcInputPin] = &(lIrsSpi1Sensors[i]);

  // baseline values.
  for (i = 0; i < 10; ++i)
  {
    UpdateSensors(lSpi0, lUi0Count, lIrsSpi0Sensors, lIrsSpi0ByPin);
    UpdateSensors(lSpi1, lUi1Count, lIrsSpi1Sensors, lIrsSpi1ByPin);
  }

  setBaselines(lUi0Count, lIrsSpi0Sensors);
  setBaselines(lUi1Count, lIrsSpi1Sensors);

  cout << setw(4) << setfill('0');

  while (true)
  {
    UpdateSensors(lSpi0, lUi0Count, lIrsSpi0Sensors, lIrsSpi0ByPin);
    UpdateSensors(lSpi1, lUi1Count, lIrsSpi1Sensors, lIrsSpi1ByPin);

    // printDiffs(lUi0Count, lIrsSpi0Sensors);
    // printDiffs(lUi1Count, lIrsSpi1Sensors);
    // cout << endl;

    //printActDiff(0, lUi0Count, lIrsSpi0Sensors);
    //printActDiff(lUi0Count, lUi1Count, lIrsSpi1Sensors);
    //cout << endl;

    printActive(0, lUi0Count, lIrsSpi0Sensors);
    printActive(lUi0Count, lUi1Count, lIrsSpi1Sensors);

    sleep(0.03);
  }

  return 0;
}

