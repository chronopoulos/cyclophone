#ifndef CycloMap_h
#define CycloMap_h

#include <vector>
#include <map>
#include <iostream>

using namespace std;

class CycloMap
{
public:
  CycloMap() {}

  void ArduinoCommand(const char *aC);

  void OnKeyHit(int aIKeyIndex, float aFIntensity);
  void OnKeyPressed(int aIKeyIndex, float aFIntensity);
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

  vector<map<int,KeyDest> > mVKeyMaps;

  vector<vector<int> > mVScales;
  int mIScale;

  void makeDefaultMap();

//   inline int CalcNote(int aIKeyIndex) { CalcNote(aIKeyIndex, mVScales[mIScale]); }

  void WriteToStream(ostream &aOs);

  int mIStartNote;  // current lowest note of cyclophone.
  int mIBottomStart;  // 
  int mITopStart;
};

int CalcNote(int aIKeyIndex, const vector<int> &aVScale);

#endif

