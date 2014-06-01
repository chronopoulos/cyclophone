#ifndef CycloMap_h
#define CycloMap_h

#include <vector>
#include <map>
#include <iostream>
#include "lo/lo.h"

using namespace std;

class CycloMap
{
public:
  CycloMap()
  :mIKeyMap(0), 
  mIScale(0), 
  mIBottomStart(20),
  mITopStart(60),
  mFGain(1.0),
  mIStartNote(mIBottomStart)
  {
    makeDefaultMap();
  }

  void NoteTest();

  void ArduinoCommand(const char *aC, lo_address aLoAddress);

  void OnKeyHit(lo_address aLoAddress, int aIKeyIndex, float aFIntensity);
  // void OnKeyPressed(lo_address *aLoAddress, int aIKeyIndex, float aFIntensity);
  // void OnKeyEnd(int aIKeyIndex, float aFIntensity);

 
  class KeyDest
  {
  public:
    KeyDest() :mBSendNote(false) {}
    KeyDest(const char *aCName, bool aBSendNote) :mSName(aCName), mBSendNote(aBSendNote) {}
    KeyDest(const KeyDest &aKd) :mSName(aKd.mSName), mBSendNote(aKd.mBSendNote) {}
    KeyDest& operator=(const KeyDest &aKd)
    {
      mSName = aKd.mSName;
      mBSendNote = aKd.mBSendNote;
      return *this;
    }
    virtual ~KeyDest() {}
    string mSName;
    bool mBSendNote;
  };

  vector<vector<KeyDest> > mVKeyMaps;
  int mIKeyMap;

  vector<vector<int> > mVScales;
  int mIScale;

  void makeDefaultMap();

  int mIStartNote;  // current lowest note of cyclophone.
  // low note ranges between bottom and top values.
  int mIBottomStart;  
  int mITopStart;

  float mFGain;
};


int CalcNote(int aIKeyIndex, const vector<int> &aVScale);

#endif


