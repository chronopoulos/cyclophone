#ifndef CycloMap_h
#define CycloMap_h

#include <vector>
#include <map>
#include <iostream>
#include "lo/lo.h"

using namespace std;

// abstract class, ancestor of maps.
class CycloMap
{
public:

  virtual void SetGain(float aF) = 0;

  virtual void OnArduinoCommand(const char *aC, lo_address aLoAddress) = 0;
  virtual void OnKeyHit(lo_address aLoAddress, int aIKeyIndex, float aFIntensity) = 0;
  virtual void OnContinuous(lo_address aLoAddress, int aIKeyIndex, float aFIntensity) = 0;
};

// map that just sends the key messages and button/knob messages, 
// no interpretation, no modes or scales. 
class BasicMap : public CycloMap
{
public:
  BasicMap()
  :mFGain(1.0), mBSendHits(true), mBSendContinuous(false)
  {} 

  void SetGain(float aF) { mFGain = aF; } 
  
  float mFGain;

  bool mBSendHits;
  bool mBSendContinuous;
  
  void OnArduinoCommand(const char *aC, lo_address aLoAddress);
  void OnKeyHit(lo_address aLoAddress, int aIKeyIndex, float aFIntensity);
  void OnContinuous(lo_address aLoAddress, int aIKeyIndex, float aFIntensity);
};

// Map for the PD patch used at apo 2014, maker faire, etc.
class PdMap : public CycloMap
{
public:
  PdMap()
  :mIKeyMap(0), 
  mIScale(0), 
  mIBottomStart(0),
  mITopStart(60),
  mFGain(1.0)
  {
    mIStartNote = mIBottomStart;
    makeDefaultMap();
  }

  void SetGain(float aF) { mFGain = aF; } 
  
  void PrintScale(int aIScale); 

  void OnArduinoCommand(const char *aC, lo_address aLoAddress);
  void OnKeyHit(lo_address aLoAddress, int aIKeyIndex, float aFIntensity);
  void OnContinuous(lo_address aLoAddress, int aIKeyIndex, float aFIntensity);
 
  class KeyDest
  {
  public:
    KeyDest() 
      :mBSendNote(false), 
      mBSendHits(false), 
      mBSendContinuous(false) {}
     KeyDest(const char *aCName, bool aBSendNote, 
             bool aBSendHits, bool aBSendContinuous) 
      :mSName(aCName), 
      mBSendNote(aBSendNote), 
      mBSendHits(aBSendHits), 
      mBSendContinuous(aBSendContinuous) {}
    KeyDest(const KeyDest &aKd) 
      :mSName(aKd.mSName), 
      mBSendNote(aKd.mBSendNote), 
      mBSendHits(aKd.mBSendHits),
      mBSendContinuous(aKd.mBSendContinuous) {}
    KeyDest& operator=(const KeyDest &aKd)
    {
      mSName = aKd.mSName;
      mBSendNote = aKd.mBSendNote;
      mBSendHits = aKd.mBSendHits;
      mBSendContinuous = aKd.mBSendContinuous;
      return *this;
    }
    virtual ~KeyDest() {}
    string mSName;
    // send note number or just name?
    bool mBSendNote;
    // send 'hits'?
    bool mBSendHits;
    // send continuous position update messages?
    bool mBSendContinuous;
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


