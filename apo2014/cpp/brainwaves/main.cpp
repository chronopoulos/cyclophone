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
#include <sstream>
#include <iomanip>
#include <iostream>

#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include "lo/lo.h"
#include <deque>
#include "cyclomap.h"

using namespace std;

// --------------------------------------------------------------------
// global consts.
// --------------------------------------------------------------------

int gIThres = 50;
float gFGain = 1.2;     // multiply key intensity by this!


// --------------------------------------------------------------------

// int main(int argc,char** argv)
int openserial(const char *aCSerial) 
{
  struct termios tio;
  int tty_fd;

  // unsigned char c='D';

  // printf("Please start with %s /dev/ttyS1 (for example)\n",argv[0]);
  /*
  struct termios stdio;
  struct termios old_stdio;
  
  tcgetattr(STDOUT_FILENO,&old_stdio);
  memset(&stdio,0,sizeof(stdio));
  stdio.c_iflag=0;
  stdio.c_oflag=0;
  stdio.c_cflag=0;
  stdio.c_lflag=0;
  stdio.c_cc[VMIN]=1;
  stdio.c_cc[VTIME]=0;
  tcsetattr(STDOUT_FILENO,TCSANOW,&stdio);
  tcsetattr(STDOUT_FILENO,TCSAFLUSH,&stdio);
  // make the reads non-blocking
  fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK);       
  */

  memset(&tio,0,sizeof(tio));
  tio.c_iflag=0;
  tio.c_oflag=0;
  // 8n1, see termios.h for more information
  tio.c_cflag=CS8|CREAD|CLOCAL;           
  tio.c_lflag=0;
  tio.c_cc[VMIN]=1;
  tio.c_cc[VTIME]=5;

  tty_fd=open(aCSerial, O_RDWR | O_NONBLOCK);      
  cfsetospeed(&tio,B115200);            // 115200 baud
  cfsetispeed(&tio,B115200);            // 115200 baud

  tcsetattr(tty_fd,TCSANOW,&tio);

  return tty_fd;       
}
 
/*
        printf("hit 'q' to x-it");
        while (c!='q')
        {
            // if new data is available on the serial port, print it out
            if (read(tty_fd,&c,1)>0)
              write(STDOUT_FILENO,&c,1);              
            // if new data is available on the console, send it to the serial port
            // if (read(STDIN_FILENO,&c,1)>0)  write(tty_fd,&c,1);
            printf("blah");
        }
 
        close(tty_fd);
        tcsetattr(STDOUT_FILENO,TCSANOW,&old_stdio);
 
        return EXIT_SUCCESS;
}
*/

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

int gIDequeLength = 10;

class DKeySigProc 
{
public:
  DKeySigProc()
    :mIBase(0), mIPrevVal(0), mIPrevVel(0)
  {
  }
  // add the current measure.
  // if there's a number to send, return true.
  bool AddMeasure(int aIMeasure, float &aF)
  {
    // current value over thres.
    int val = aIMeasure;
    val -= mIBase;

    // store normalized against baseline.
    mDPrevs.push_front(val);

    if (mDPrevs.size() > gIDequeLength)
    {
      mDPrevs.pop_back();
    }
    else
    {
      // wait until full count.
      return false;
    }

    int prev = mDPrevs.back();

    // current velocity.
    int vel = val;
    vel -= prev;
    
    bool ret = false;
    // if (val > gIThres)
    if (vel <=0 && mIPrevVel > 0 && val > gIThres)
    {
      aF = (float)val / 1024.0;
      ret = true;
    }

    mIPrevVel = vel;
    mIPrevVal = val;

    return ret;
  }

  int GetLastVal() { return mIPrevVal; }
  
  void SetBaseline(int aIBaseline) { mIBase = aIBaseline; }
  int GetBaseline() { return mIBase; }

private:
  int mIBase;
  int mIPrevVel;
  int mIPrevVal;
  deque<int> mDPrevs;
};

class KeySigProc 
{
public:
  KeySigProc()
    :mIBase(0), mIPrevVal(0), mIPrevVel(0)
  {
  }
  // add the current measure.
  // if there's a number to send, return true.
  bool AddMeasure(int aIMeasure, float &aF);

  int GetLastVal() { return mIPrevVal; }
  
  void SetBaseline(int aIBaseline) { mIBase = aIBaseline; }
  int GetBaseline() { return mIBase; }

private:
  int mIBase;
  // int mIThres;
  int mIPrevVal;
  int mIPrevVel;
};

bool KeySigProc::AddMeasure(int aIMeasure, float &aF)
{
  // current value over thres.
  int val = aIMeasure;
  val -= mIBase;

  // current velocity.
  int vel = val;
  vel -= mIPrevVal;
  
  bool ret = false;
  // if (val > gIThres)
  if (vel <=0 && mIPrevVel > 0 && val > gIThres)
  {
    aF = (float)val / 1024.0;
    ret = true;
  }

  mIPrevVal = val;
  mIPrevVel = vel;

  return ret;
}

class IRSensor
{
public:
  IRSensor(unsigned char aUcInputPin)
   :mUsLast(0), mUcInputPin(aUcInputPin)
  {
    setupcontrolword(aUcInputPin, mUcControlWord);
  }

  DKeySigProc mKsp;

  unsigned short mUsLast;
  // unsigned short mUsBaseline;
  unsigned char mUcControlWord[2];
  const unsigned char mUcInputPin;
};

// The algorithm:
//   when velocity stops increasing, 
//   and value is over the threshold, 
//   report the previous position value as a value 0.0->1.0


class SerialReader
{
public:
  SerialReader()
    :mBComplete(false)
  {}
  // returns true if this char completes a command (newline)
  bool AddChar(char aC)
  {
    if (aC == '\n')
    {
      mBComplete = true;
      return true;
    }
    else if (mBComplete)
    {
      mBComplete = false;
      mSCommand = "";
    }

    mSCommand.push_back(aC);
    return false;
  }
  const char* GetCommand() const { return mSCommand.c_str(); }
private:
  string mSCommand;
  bool mBComplete;

};


void UpdateSensors(spidevice &aSpi, 
                   unsigned int aUiCount,       // IRSensor count. 
                   unsigned int aUiKeyOffset,   // add to key index for OSC msgs
                   IRSensor aIrsArray[], 
                   IRSensor* aIrsByPin[],
                   lo_address aLoAddress = 0, 
                   CycloMap *aCm = 0 )
{
  unsigned char data[2];
  unsigned int adcnumber, adcvalue;

  // cout << "count: " << aUiCount << endl;

  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    data[0] = aIrsArray[i].mUcControlWord[0];
    data[1] = aIrsArray[i].mUcControlWord[1];

    aSpi.spiWriteRead(data, sizeof(data));

    // sleep(.001);

    // ---------------- decode the recieved data ---------------
    // first 4 bits are adc number. 
    adcnumber = (data[0] & 0b11110000) >> 4; 
    // next 10 bits are the adc value.
    adcvalue = ((data[0] & 0b00001111) << 6) | ((data[1] & 0b11111100) >> 2); 

    // if new is different from last by more than thres, print.
    // int diff = abs(adcvalue - aIrsByPin[adcnumber]->mUsLast);
    // if (diff > gIThres) 
    //   cout << (int)adcnumber << "\t" << (int)adcvalue << "\t" << diff << "\n";

    aIrsByPin[adcnumber]->mUsLast = adcvalue;
    float lF;
    if (aIrsByPin[adcnumber]->mKsp.AddMeasure(adcvalue, lF))
    {
      if (aCm && aLoAddress)
        aCm->OnKeyHit(aLoAddress, i + aUiKeyOffset, lF);
 
      cout << "value!" << lF << endl;
    }
  }
}

void setBaselines(unsigned int aUiCount, IRSensor aIrsArray[])
{
  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    aIrsArray[i].mKsp.SetBaseline(aIrsArray[i].mUsLast);
  }  
}

void printVals(unsigned int aUiCount, IRSensor aIrsArray[])
{
  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    cout << setw(4) << setfill(' ');
    cout << aIrsArray[i].mUsLast << " ";
  }  
}

void printDiffs(unsigned int aUiCount, IRSensor aIrsArray[])
{
  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    cout << setw(4) << setfill(' ');
    // cout << aIrsArray[i].mUsLast - aIrsArray[i].mUsBaseline << " ";
    cout << aIrsArray[i].mKsp.GetLastVal() << " ";
  }  
}

int main(int argc, const char *args[])
{
  // cout << "argc: " << argc << endl;

  int sensor = 0;

  if (argc > 1)
  {
    istringstream lIss(args[1]);
    lIss >> sensor;
  }
 
  // cout << "sensor: " << sensor << endl;

  lo_address pd = lo_address_new("192.168.1.144", "8000");
  CycloMap lCycloMap;
  lCycloMap.makeDefaultMap();
  lCycloMap.mFGain = gFGain;

  // lCycloMap.NoteTest();

  spidevice lSpi0("/dev/spidev0.0", SPI_MODE_0, 20000000, 8);
  spidevice lSpi1("/dev/spidev0.1", SPI_MODE_0, 20000000, 8);
 
  IRSensor lIrsSpi0Sensors[] = 
    {
       IRSensor(0), 
       IRSensor(1), 
       IRSensor(2), 
       IRSensor(3), 
       IRSensor(4), 
       IRSensor(5), 
       IRSensor(6), 
       IRSensor(7), 
       IRSensor(8), 
       IRSensor(9), 
       IRSensor(10), 
       IRSensor(11) 
    };
  unsigned int lUi0Count = sizeof(lIrsSpi0Sensors) / sizeof(IRSensor);

  IRSensor lIrsSpi1Sensors[] = 
    {
       IRSensor(0), 
       IRSensor(1), 
       IRSensor(2), 
       IRSensor(3), 
       IRSensor(4), 
       IRSensor(5), 
       IRSensor(6), 
       IRSensor(7), 
       IRSensor(8), 
       IRSensor(9), 
       IRSensor(10), 
       IRSensor(11) 
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
    UpdateSensors(lSpi0, lUi0Count, 0, lIrsSpi0Sensors, lIrsSpi0ByPin,0,0);
    UpdateSensors(lSpi1, lUi1Count, lUi0Count, lIrsSpi1Sensors, lIrsSpi1ByPin,0,0);
  }

  setBaselines(lUi0Count, lIrsSpi0Sensors);
  setBaselines(lUi1Count, lIrsSpi1Sensors);

  cout << setw(4) << setfill('0');

  int tty_fd = openserial("/dev/ttyACM0");

  clock_t l_last = clock();
  int start = 1000;

  char c;

  SerialReader lSr;

  while (true)
  {
    for (int count = start; count > 0; --count)
    {
      // sleep(.2);
      UpdateSensors(lSpi0, lUi0Count, 0, lIrsSpi0Sensors, lIrsSpi0ByPin,pd,&lCycloMap);
      UpdateSensors(lSpi1, lUi1Count, lUi0Count, lIrsSpi1Sensors, lIrsSpi1ByPin,pd,&lCycloMap);

      // try reading from the serial port each time.
      while (read(tty_fd,&c,1)>0)
      {
        cout << c;
        
        // add char to command.
        if (lSr.AddChar(c))
        {
          lCycloMap.ArduinoCommand(lSr.GetCommand(), pd);
          cout << "arduino command received: " << lSr.GetCommand() << endl;
        }
      }
    }

    clock_t l_now = clock();

    double lD = start;
    lD /= l_now - l_last; 
    lD *= CLOCKS_PER_SEC;

    l_last = l_now;

    cout << "framerate for: " << start << ": " << lD << endl;

    // printDiffs(lUi0Count, lIrsSpi0Sensors);
    // printDiffs(lUi1Count, lIrsSpi1Sensors);


    // cout << endl;

    // sleep(0.03);
  }

  return 0;
}

