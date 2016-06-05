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
#include <fstream>
#include <iomanip>
#include <iostream>
#include <vector>

#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include "lo/lo.h"
#include <deque>
#include <set>
#include "cyclomap.h"
#include <sys/time.h>

using namespace std;

// --------------------------------------------------------------------
// global consts.
// --------------------------------------------------------------------

string gSTargetIpAddress = "127.0.0.1";     // address of sound server
string gSTargetPort = "8000";          // port of sound server

string gSSerial = "/dev/ttyACM0";

int gIThres = 35;           // threshold for activating key
int gIInactiveThres = 50;   // threshold for deactivating key.
float gFGain = 1.2;         // multiply key intensity by this!

int gISleep = 0;            // microseconds of sleep per scan 

// deque length for determining velocity (current val - last in deque)
int gIDequeLength = 5;
// secondary peak elimination 
int gIPrevHitCountdownStart = 100;   // was about 200 in haskell, w 580 framerate
int gIPrevHitThres = 350;

// 'dynabase' parms.
int gIDynabaseTurns = 1000;
float gFDynabaseBandSize = 35;

float gFDynabaseTurns = gIDynabaseTurns;
float gFDynabaseTurnsInverse2 = 1.0 / (gFDynabaseTurns * gFDynabaseTurns);
float gFDynabaseBandSizeSquared = gFDynabaseBandSize * gFDynabaseBandSize;    

// PdMap or BasicMap
string gSMapType = "BasicMap";

bool gBSendHits = true;
bool gBSendContinuous = false;
bool gBSendEnds = false;

int gIContinuousCount = 1;    // send continuous update every N turns.

vector<float> gVMaxes;
vector<float> gVMults;

void ReadMaxes(istream &aIs)
{
  gVMaxes.clear();
  float lF;

  aIs >> lF;
  while (!aIs.eof())
  {
    gVMaxes.push_back(lF);
    aIs >> lF;
  }

}

void BuildMults()
{
  // load up with defaults in case of failure below.
  gVMults.clear();
  for (int i = 0; i < 24; ++i)
    gVMults.push_back(1.0);

  bool lBZeros = false;
  for (int i = 0; i < gVMaxes.size() ; ++i)
  {
    if (gVMaxes[i] == 0.0)
    {
      cout << "zero found in maxes.array!  using 1.0 defalts." << endl;
      return;
    }
  }

  if (gVMaxes.size() == 24)
  {
    cout << "Building key range mults vector" << endl; 
    for (int i = 0; i < 24; ++i)
    {
      gVMults[i] = 1.0 / gVMaxes[i];
    }
    cout << "key mult array built:" << endl;
    for (int i = 0; i < 24; ++i)
    {
      cout << i << " " << gVMults[i] << endl;
    }
  }
  else
  {
    cout << "Maxes count (" << gVMaxes.size() << ") is != 24!  Using defaults mults (1.0)." << endl;
  }
}


void WriteSettings(ostream &aOs)
{
  aOs << "TargetIpAddress" << " " << gSTargetIpAddress << endl;
  aOs << "TargetPort" << " " << gSTargetPort << endl;
  aOs << "Serial" << " " << gSSerial << endl;
  aOs << "Thres" << " " << gIThres << endl; 
  aOs << "InactiveThres" << " " << gIInactiveThres << endl; 
  aOs << "Gain" << " " << gFGain << endl; 
  aOs << "Sleep" << " " << gISleep << endl; 
  aOs << "DequeLength" << " " << gIDequeLength << endl; 
  aOs << "PrevHitThres" << " " << gIPrevHitThres << endl; 
  aOs << "PrevHitCountdownStart" << " " << gIPrevHitCountdownStart << endl; 
  aOs << "DynabaseTurns" << " " << gIDynabaseTurns << endl; 
  aOs << "DynabaseBandSize" << " " << gFDynabaseBandSize << endl; 
  aOs << "SendHits" << " " << gBSendHits << endl;
  aOs << "SendContinuous" << " " << gBSendContinuous << endl;
  aOs << "SendEnds" << " " << gBSendEnds << endl;
  aOs << "ContinuousCount" << " " << gIContinuousCount << endl;
  aOs << "MapType" << " " << gSMapType << endl;
  aOs << "Maxes.Array" << endl;
}

void UpdateSetting(string aSName, string aSVal)
{
  if (aSName == "TargetIpAddress")
  {
    gSTargetIpAddress = aSVal; 
    return;
  }
  if (aSName == "TargetPort")
  {
    gSTargetPort = aSVal;
    return;
  }
  if (aSName == "Serial")
  {
    gSSerial = aSVal;
    return;
  }
  if (aSName == "Thres")
  {
    gIThres = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "InactiveThres")
  {
    gIInactiveThres = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "Gain")
  {
    gFGain = atof(aSVal.c_str());
    return;
  }
  if (aSName == "Sleep")
  {
    gISleep = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "DequeLength")
  {
    gIDequeLength = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "PrevHitThres")
  {
    gIPrevHitThres = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "PrevHitCountdownStart")
  {
    gIPrevHitCountdownStart = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "DynabaseTurns")
  {
    gIDynabaseTurns = atoi(aSVal.c_str());
    gFDynabaseTurns = gIDynabaseTurns;
    gFDynabaseTurnsInverse2 = 1.0 / (gFDynabaseTurns * gFDynabaseTurns);
    return;
  }
  if (aSName == "DynabaseBandSize")
  {
    gFDynabaseBandSize = atof(aSVal.c_str());
    gFDynabaseBandSizeSquared = gFDynabaseBandSize * gFDynabaseBandSize;
    return;
  }
  if (aSName == "SendHits")
  {
    gBSendHits = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "SendContinuous")
  {
    gBSendContinuous = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "SendEnds")
  {
    gBSendEnds = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "ContinuousCount")
  {
    gIContinuousCount = atoi(aSVal.c_str());
    return;
  }
  if (aSName == "MapType")
  {
    gSMapType = aSVal;
    return;
  }
  if (aSName == "Maxes.Array")
  {
    ifstream lIfs(aSVal.c_str());
    if (lIfs.is_open())
    {
      ReadMaxes(lIfs);
      cout << "Read maxes file: " << aSVal << endl;
      BuildMults();
    }
    else
      cout << "Unable to read maxes file: " << aSVal << endl;
    return;
  }
}

void ReadSettings(istream &aIs)
{
  while (!aIs.eof())
  {
    string lSName, lSVal;
    aIs >> lSName >> lSVal;
    
    UpdateSetting(lSName, lSVal);
  }
}

// --------------------------------------------------------------------

int openserial(const char *aCSerial) 
{
  struct termios tio;
  int tty_fd;

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

class DKeySigProc 
{
public:
  DKeySigProc()
    :mIBase(0), mIThresBase(0), mIInactiveBase(0), mIPrevVal(0), mIPrevVel(0),
    mIPrevHitVal(0), mIPrevHitCountdown(0),
    mBGotHit(false), mBGotEnd(false),
    mBOverThres(false), mBOverInactiveThres(false),     
    mIContinuousCount(gIContinuousCount),
    mBHitAllowed(true)
  {
  }

  inline bool GetHitVal(float &aF)
  {
    if (mBGotHit)
      aF = (float)mIPrevVal / 1023.0;

    return mBGotHit;
  }
  inline bool GetContinuousVal(float &aF)
  {
    if (mBOverThres && --mIContinuousCount == 0)
    {
      aF = (float)mIPrevVal / 1023.0;
      mIContinuousCount = gIContinuousCount;

      return true;
    }
    else
      return false;
  }
  inline bool GetEnd() { return mBGotEnd; }

  int GetLastVal() { return mIPrevVal; }
  
  void SetBaseline(int aIBaseline) { mIBase = aIBaseline; mIThresBase = mIBase; }
  int GetBaseline() { return mIBase; }

  // add the current measure.  updating flags and etc.
  void AddMeasure(int aIMeasure)
  {
    // current value over thres.
    int val = aIMeasure;
    val -= mIBase;

    // ----------------------------------------------------------------
    // update the thresbase. 
    // ----------------------------------------------------------------
    // mIThresBase is updated to be the min key value since deactivation, ie since 
    // crossing the inactive threshold. 
    // ----------------------------------------------------------------
   
    // have we crossed from over the InactiveThres to under it??
    bool lBOverInactiveThres = val > gIInactiveThres;
    if (!lBOverInactiveThres && mBOverInactiveThres)
    {
       // we just crossed from active to inactive.  Set the thresbase!!
       mIThresBase = aIMeasure;
    }

    mBOverInactiveThres = lBOverInactiveThres;
    if (!mBOverInactiveThres)
    {
      if (mIThresBase > aIMeasure && aIMeasure >= mIBase)
        mIThresBase = aIMeasure;
    }
   
    // Change 'val' to be val-over-thresbase.
    val = aIMeasure - mIThresBase;

    // ----------------------------------------------------------------
    //  update 'over thres' flag
    // ----------------------------------------------------------------
    bool lBOverThres = val > gIThres;

    // if it was over thres, but now its not, then 'got end'
    // ie end of a period of over-threshold-ness
    mBGotEnd = !lBOverThres && mBOverThres;

    mBOverThres = lBOverThres; 

    // ----------------------------------------------------------------
    //  update 'got hit' flag
    // ----------------------------------------------------------------
    // if it was under thres last time, then thres has been crossed.
    if (!mBOverThres)
      mBHitAllowed = true;
    // but if over thres, don't update. 

    // store normalized against baseline.
    mDPrevs.push_front(val);

    // start with assuming no hit.
    mBGotHit = false;

    // if deque isn't full, no hit.
    if (mDPrevs.size() > gIDequeLength)
    {
      mDPrevs.pop_back();
    }
    else
    {
      // wait until full count.
      return;
    }

    bool ret = false;
    if (mIPrevHitCountdown > 0)
    { 
      --mIPrevHitCountdown;
    }

    // we don't allow any hits until zero is crossed.  
    if (mBHitAllowed)
    {
      // current velocity is front of deque minus back of deque.
      int prev = mDPrevs.back();
      int vel = val;
      vel -= prev;
      
      if (vel <=0 && mIPrevVel > 0 && val > gIThres)
      {
        //   logic for rejection based on 'prevhit'.  
        //  supposed to reject secondary peaks right after big peaks.  
        if (mIPrevHitCountdown > 0 && 
            mIPrevHitVal - val > gIPrevHitThres)
        {
          // reject! 
          // cout << "rejected: " << val << " " << mIPrevHitVal << " " << mIPrevHitCountdown << endl;
        }
        else
        {
          // cout << "accepted: " << val << " " << mIPrevHitVal << " " << mIPrevHitCountdown << endl;
          mIPrevHitVal = val;
          mIPrevHitCountdown = gIPrevHitCountdownStart;
          mBGotHit = true;
          // will stay false until value goes under thres.
          mBHitAllowed = false;
        }
      }

      mIPrevVel = vel;
    }

    mIPrevVal = val;
  }

private:
  int mIBase;
  int mIThresBase;
  int mIInactiveBase;
  int mIPrevVel;
  int mIPrevVal;
  int mIPrevHitVal;
  int mIPrevHitCountdown;
  deque<int> mDPrevs;

  bool mBGotHit;
  bool mBOverThres;
  bool mBOverInactiveThres;
  bool mBGotEnd;

  int mIContinuousCount;

  bool mBHitAllowed;
};

// if key goes to new steady value, then establish new baseline.
// steady value is within X points for more than N turns.
class DynabaseKeySig
{
public:
  DynabaseKeySig()
    :mFSum(0) 
  {
  }
  // add the current measure.
  // if there's a number to send, return true.
  bool AddMeasure(float aFMeasure, int &aINewBaseline)
  {
    mFSum += aFMeasure;
    
    float lFSq = aFMeasure * aFMeasure;

    mFSquaredSum += lFSq;

    // store raw vals
    mDVals.push_front(aFMeasure);

    // subtract the old vals to update sums.

    if (mDVals.size() > gIDynabaseTurns)
    {
      float lF = mDVals.back();
      lFSq = lF * lF;
      mDVals.pop_back();
      mFSum -= lF;
      mFSquaredSum -= lFSq;
    }
    else
    {
      // wait until full count.
      return false;
    }

    // variance = 1/N * sum (( Xi - avg) ^ 2)  for all Xi, avg = avg of all Xi.
    //          = 1/N * sum ( Xi ^ 2 ) - avg^2
    //          = 

    // calc the variance.
    mFVariance = (gFDynabaseTurns * mFSquaredSum - mFSum * mFSum) * gFDynabaseTurnsInverse2;

    // is variance within the band?
    if (mFVariance < gFDynabaseBandSizeSquared)
    {
      // cout << mFSquaredSum << " " << mFSum << " " << sqrt(mFVariance) << endl;
      // cout << mFSquaredSum << " " << mFSum << " " << endl;

      // cout << "updating with variance: " << mFVariance << " less than " << gFDynabaseBandSizeSquared << endl;
      // new baseline is average of all vals.
      aINewBaseline = mFSum / mDVals.size();

      // cout << "mDVals.size() = " << mDVals.size() << " mMsSortedVals.size() = " << mMsSortedVals.size() << endl;
      return true;
    }
    else
    {
      // no new baseline.
      return false;     
    }
    return false;
    
 }

private:
  float mFSum;
  float mFSquaredSum;

  float mFVariance;

  deque<float> mDVals;
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
    aF = (float)val / 1023.0;
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
  DynabaseKeySig mDks;

  unsigned short mUsLast;
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


    // ---------------- decode the recieved data ---------------
    // first 4 bits are adc number. 
    adcnumber = (data[0] & 0b11110000) >> 4; 
    // next 10 bits are the adc value.
    adcvalue = ((data[0] & 0b00001111) << 6) | ((data[1] & 0b11111100) >> 2); 

    // if new is different from last by more than thres, print.
    // int diff = abs(adcvalue - aIrsByPin[adcnumber]->mUsLast);
    // if (diff > gIThres) 
    //   cout << (int)adcnumber << "\t" << (int)adcvalue << "\t" << diff << "\n";

    int lIBaseline;
    if (aIrsByPin[adcnumber]->mDks.AddMeasure(adcvalue, lIBaseline))
    {
      // cout << "new baseline : " << aUiKeyOffset + i << " " << lIBaseline << endl;

      // set the new baseline in the KeySigProc obj.
      aIrsByPin[adcnumber]->mKsp.SetBaseline(lIBaseline);

      // cout << "value!" << lF << endl;
    }

    aIrsByPin[adcnumber]->mUsLast = adcvalue;
    float lF;
    aIrsByPin[adcnumber]->mKsp.AddMeasure(adcvalue);
    if (aIrsByPin[adcnumber]->mKsp.GetHitVal(lF))
    {
      if (aCm && aLoAddress)
        aCm->OnKeyHit(aLoAddress, i + aUiKeyOffset, lF);
    }
    if (aIrsByPin[adcnumber]->mKsp.GetContinuousVal(lF))
    {
      if (aCm && aLoAddress)
        aCm->OnContinuous(aLoAddress, i + aUiKeyOffset, lF);
    }
    if (aIrsByPin[adcnumber]->mKsp.GetEnd())
    {
      if (aCm && aLoAddress)
        aCm->OnKeyEnd(aLoAddress, i + aUiKeyOffset);
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

void printBaselines(unsigned int aUiCount, IRSensor aIrsArray[])
{
  for (unsigned int i = 0; i < aUiCount; ++i)
  {
    cout << setw(4) << setfill(' ');
    cout << aIrsArray[i].mKsp.GetBaseline() << " ";
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
    cout << aIrsArray[i].mKsp.GetLastVal() << " ";
  }  
}

/*
struct timespec {
    time_t   tv_sec;         seconds 
    long     tv_nsec;        nanoseconds
};
*/

#define USECS_PER_SEC 1000000

void timeval_normalize(timeval &t) 
{
   if (t.tv_usec >= USECS_PER_SEC) { 
       t.tv_usec -= USECS_PER_SEC; 
       t.tv_sec++; 
   } else if ((t).tv_usec < 0) { 
       t.tv_usec += USECS_PER_SEC; 
       t.tv_sec -- ; 
   } 
}

void timeval_sub(timeval &t1, const timeval &t2)
{
   t1.tv_usec -= t2.tv_usec; 
   t1.tv_sec  -= t2.tv_sec; 
   timeval_normalize(t1); 
} 

void timeval_add_us(timeval &t, long n) 
{ 
   t.tv_usec += n; 
   timeval_normalize(t); 
}

double timeval_to_secs(const timeval &t)
{
  double lD = t.tv_usec;
  lD /= USECS_PER_SEC;
  lD += t.tv_sec;
  return lD;
}

#define NSECS_PER_SEC 1000000000

void timespec_normalize(timespec &t) 
{
   if (t.tv_nsec >= NSECS_PER_SEC) { 
       t.tv_nsec -= NSECS_PER_SEC; 
       t.tv_sec++; 
   } else if ((t).tv_nsec < 0) { 
       t.tv_nsec += NSECS_PER_SEC; 
       t.tv_sec -- ; 
   } 
}

void timespec_sub(timespec &t1, const timespec &t2)
{
   t1.tv_nsec -= t2.tv_nsec; 
   t1.tv_sec  -= t2.tv_sec; 
   timespec_normalize(t1); 
} 

void timespec_add_ns(timespec &t, long n) 
{ 
   t.tv_nsec += n; 
   timespec_normalize(t); 
}

int main(int argc, const char *args[])
{
  // cout << "argc: " << argc << endl;

  const char *lCSettingsFile = "sensorsettings.txt";

  if (argc > 1)
  {
    lCSettingsFile = args[1];
  }

  // default mults, in case maxes array isn't read in.
  for (int i = 0; i < 24; ++i)
    gVMults.push_back(1.0);

  // read settings file
  ifstream lIfs(lCSettingsFile);
  if (lIfs.is_open())
  {
    ReadSettings(lIfs);
  }
  else
  {
    ofstream lOfs("sensorsettings.txt");
    WriteSettings(lOfs);
    
    cout << "unable to read settings file.  wrote default file: 'sensorsettings.txt'" << endl;
    return 0;
  }

  lo_address lotarget = lo_address_new(gSTargetIpAddress.c_str(), gSTargetPort.c_str());
  CycloMap *lCycloMap;
  if (gSMapType == "PdMap")
  {
    lCycloMap = new PdMap; 
  }
  else
  {
    BasicMap *lBm= new BasicMap(32); 
    lBm->mBSendHits = gBSendHits;
    lBm->mBSendContinuous = gBSendContinuous;
    lBm->mBSendEnds = gBSendEnds;
    lBm->mVMults = gVMults;
    lCycloMap = lBm; 
  }

  lCycloMap->mFGain = gFGain;
  /*
  lCycloMap->SetGain(gFGain);
  lCycloMap->SetHits(gBHits);
  lCycloMap->SetContinuous(gBContinuous);
  */
  spidevice lSpi0("/dev/spidev0.0", SPI_MODE_0, 20000000, 8);
  spidevice lSpi1("/dev/spidev0.1", SPI_MODE_0, 20000000, 8);
  //spidevice lSpi0("/dev/spidev0.0", SPI_MODE_0, 10000, 8);
  // spidevice lSpi1("/dev/spidev0.1", SPI_MODE_0, 10000, 8);
 
  IRSensor lIrsSpi0Sensors[] = 
    {
       IRSensor(9), 
       IRSensor(8), 
       IRSensor(7), 
       IRSensor(6), 
       IRSensor(5), 
       IRSensor(4), 
       IRSensor(3), 
       IRSensor(2), 
       IRSensor(1), 
       IRSensor(0), 
       IRSensor(11), 
       IRSensor(10) 
    };
  unsigned int lUi0Count = sizeof(lIrsSpi0Sensors) / sizeof(IRSensor);

  IRSensor lIrsSpi1Sensors[] = 
    {
       IRSensor(9), 
       IRSensor(8), 
       IRSensor(7), 
       IRSensor(6), 
       IRSensor(5), 
       IRSensor(4), 
       IRSensor(3), 
       IRSensor(2), 
       IRSensor(1), 
       IRSensor(0), 
       IRSensor(11), 
       IRSensor(10) 
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

  int tty_fd = openserial(gSSerial.c_str());

  // clock_t l_last = clock();
  int start = 100;
  // int start = 25;

  timeval ts_last;
  gettimeofday(&ts_last, 0);

  char c;

  SerialReader lSr;

  while (true)
  {
    for (int count = start; count > 0; --count)
    {
      usleep(gISleep);
      
      UpdateSensors(lSpi0, lUi0Count, 0, lIrsSpi0Sensors, lIrsSpi0ByPin,
        lotarget,lCycloMap);
      UpdateSensors(lSpi1, lUi1Count, lUi0Count, lIrsSpi1Sensors, lIrsSpi1ByPin,
        lotarget,lCycloMap);

      // try reading from the serial port each time.
      while (read(tty_fd,&c,1)>0)
      {
        cout << c;
        
        // add char to command.
        if (lSr.AddChar(c))
        {
          lCycloMap->OnArduinoCommand(lSr.GetCommand(), lotarget);
          cout << "arduino command received: " << lSr.GetCommand() << endl;
        }
      }
    }

    timeval ts_now;
    gettimeofday(&ts_now, 0);
    // clock_gettime(CLOCK_MONOTONIC, &ts_now);

    cout << "now: " << ts_now.tv_sec << " " << ts_now.tv_usec << endl;

    double lD = start;
   
    timeval tv_diff;
    tv_diff = ts_now;
    timeval_sub(tv_diff, ts_last);
    lD /= timeval_to_secs(tv_diff);

    ts_last = ts_now;

    // cout << "interval: " << l_interval << "  " << ((float)l_interval) / CLOCKS_PER_SEC << endl;
    cout << "framerate for: " << start << ": " << lD << endl;

    printBaselines(lUi0Count, lIrsSpi0Sensors);
    printBaselines(lUi1Count, lIrsSpi1Sensors);
    cout << endl;
    printDiffs(lUi0Count, lIrsSpi0Sensors);
    printDiffs(lUi1Count, lIrsSpi1Sensors);
    cout << endl;
  }

  return 0;
}

