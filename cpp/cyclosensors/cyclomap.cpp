#include "cyclomap.h"
#include "lo/lo.h"
#include <string.h>
#include <stdlib.h>


void CycloMap::NoteTest()
{
  cout << "Note Test" << endl;

  for (int lIS = 0; lIS < mVScales.size(); ++lIS)
  {
    cout << "Scale " << lIS << endl;
    for (int lI = 0; lI < 100; ++lI)
    {
      cout << lI << " " << CalcNote(lI, mVScales[lIS]) << endl;
    }
  }
}

int CalcNote(int aIKeyIndex, const vector<int> &aVScale)
{
  int length = aVScale.size();
  int floor = aIKeyIndex / length;
  int rem = aIKeyIndex - (length * floor);

  return floor * 12 + aVScale[rem];
}

void CycloMap::OnKeyHit(lo_address aLoAddress, int aIKeyIndex, float aFIntensity)
{
  aFIntensity *= mFGain;
  if (aFIntensity > 1.0)
    aFIntensity = 1.0;

  if (mVKeyMaps[mIKeyMap][aIKeyIndex].mBSendNote)
  {
    int lINote = CalcNote(aIKeyIndex, mVScales[mIScale]);
    lINote += mIStartNote;
    cout << "sending: key " << aIKeyIndex << " note " << lINote << " intensity " << aFIntensity << endl;
    lo_send(aLoAddress, 
      mVKeyMaps[mIKeyMap][aIKeyIndex].mSName.c_str(), "if", lINote, aFIntensity);
  }
  else
  {
    lo_send(aLoAddress, 
      mVKeyMaps[mIKeyMap][aIKeyIndex].mSName.c_str(), "f", aFIntensity);
  }
}

void CycloMap::ArduinoCommand(const char *aC, lo_address aLoAddress)
{
  int lINob(0);
  float lF(0.0);
  int len = strlen(aC);
  if (len < 2)
    return;

  switch (aC[0])
  {
  case '#':
    if (len < 3)
      return;

    // parse the rest of the string as a number.
    lINob = atoi(aC+2);
    lF = lINob;
    lF /= 1024.0;

    switch (aC[1])
    {
       case 'A':
          lo_send(aLoAddress, "/arduino/delay/time", "f", lF * 1000.0);
          break;
       case 'B':
          lo_send(aLoAddress, "/arduino/fm/harmonic", "f", lF);
          break;
       case 'C':
          // change the start note.
          mIStartNote = (mITopStart - mIBottomStart) * lF + mIBottomStart;
          break;
       default:
          break; 
    }
    return;
  case '$':
    switch (aC[1])
    {
    case 'a':
      mIKeyMap = 0;
      mIScale = 0;
      break;
    case 'b':
      mIKeyMap = 0;
      mIScale = 1;
      break;
    case 'c':
      mIKeyMap = 0;
      mIScale = 2;
      break;
    case 'd':
      mIKeyMap = 0;
      mIScale = 3;
      break;
    case 'e':
      mIKeyMap = 1;
      mIScale = 0;
      break;
    default:
      return;
    }
    break;
  case '@':
    switch (aC[1])
    {
    case 'a':
      lo_send(aLoAddress, "/arduino/delay/onoff", "");
      break;
    case 'b':
      lo_send(aLoAddress, "/arduino/kill/on", "");
      break;
    case 'B':
      lo_send(aLoAddress, "/arduino/kill/off", "");
      break;
    case 'c':
      lo_send(aLoAddress, "/arduino/loop", "");
      break;
    default:
      return;
    }
    break;
  default:
    break;
  }
  
  return;
}

void CycloMap::makeDefaultMap()
{
  mVKeyMaps.clear();
  vector<KeyDest> lV;

  KeyDest lKd("/arduino/fm/note", true);

  for (int lI = 0; lI < 24; ++lI)
    lV.push_back(lKd);

  mVKeyMaps.push_back(lV);

  lV.clear();

  lV.push_back(KeyDest("/arduino/drums/tr909/0", false));
  lV.push_back(KeyDest("/arduino/drums/tr909/1", false));
  lV.push_back(KeyDest("/arduino/drums/tr909/2", false));
  lV.push_back(KeyDest("/arduino/drums/tr909/3", false));
  lV.push_back(KeyDest("/arduino/drums/tr909/4", false));
  lV.push_back(KeyDest("/arduino/drums/tr909/5", false));
  lV.push_back(KeyDest("/arduino/drums/dundunba/0", false));
  lV.push_back(KeyDest("/arduino/drums/dundunba/1", false));
  lV.push_back(KeyDest("/arduino/drums/dundunba/2", false));
  lV.push_back(KeyDest("/arduino/drums/dundunba/3", false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/0", false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/1", false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/2", false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/3", false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/4", false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/5", false));
  lV.push_back(KeyDest("/arduino/drums/tabla/0", false));
  lV.push_back(KeyDest("/arduino/drums/tabla/1", false));
  lV.push_back(KeyDest("/arduino/drums/tabla/2", false));
  lV.push_back(KeyDest("/arduino/drums/tabla/3", false));
  lV.push_back(KeyDest("/arduino/drums/tabla/4", false));
  lV.push_back(KeyDest("/arduino/drums/tabla/5", false));
  lV.push_back(KeyDest("/arduino/drums/tabla/6", false));
  lV.push_back(KeyDest("/arduino/drums/tabla/7", false));

  mVKeyMaps.push_back(lV);

  int majorScale[] = {0,2,4,5,7,9,11};
  int minorScale[] = {0,2,3,5,7,8,10};
  int harmonicMinorScale[] = {0,2,3,5,7,8,11};
  int hungarianMinorScale[] = {0,2,3,6,7,8,11};
  int majorPentatonicScale[] = {0,2,4,7,9};
  int minorPentatonicScale[] = {0,3,5,7,10};
  int diminishedScale[] = {0,2,3,5,6,8,9,11};

  mVScales.push_back(std::vector<int>(majorScale, majorScale + sizeof(majorScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(minorScale, minorScale + sizeof(minorScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(harmonicMinorScale, 
        harmonicMinorScale + sizeof(harmonicMinorScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(hungarianMinorScale, 
        hungarianMinorScale + sizeof(hungarianMinorScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(majorPentatonicScale, 
        majorPentatonicScale + sizeof(majorPentatonicScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(minorPentatonicScale, 
        minorPentatonicScale + sizeof(minorPentatonicScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(diminishedScale, 
        diminishedScale + sizeof(diminishedScale) / sizeof(int) ));

 }

/*
void CycloMap::WriteToStream(ostream &aOs)
{
  aOs << "keymaps" << endl;
  aOs << mVKeyMaps << endl;
  aOs << "scales" << endl;
  aOs << mVScales;
  aOs << "scale" << mIScale << endl;
  aOs << "start" << mIStartNote << endl;
}
*/
