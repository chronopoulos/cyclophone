#include "cyclomap.h"
#include "lo/lo.h"
#include <string.h>
#include <stdlib.h>

// --------------------------------------------------------------------

void BasicMap::OnKeyHit(lo_address aLoAddress, int aIKeyIndex, float aFIntensity)
{
  if (!mBSendHits)
    return;

  aFIntensity *= mFGain * mVMults[aIKeyIndex];
  if (aFIntensity > 1.0)
    aFIntensity = 1.0;

  lo_send(aLoAddress, "keyh", "if", aIKeyIndex, aFIntensity);

  // Track when a key message has been sent.
  if (0 <= aIKeyIndex && aIKeyIndex < mIMaxKeyIndex)
    mBKeySent[aIKeyIndex] = true;
}

void BasicMap::OnContinuous(lo_address aLoAddress, int aIKeyIndex, float aFIntensity)
{
  if (!mBSendContinuous)
    return;

  aFIntensity *= mFGain * mVMults[aIKeyIndex];;
  if (aFIntensity > 1.0)
    aFIntensity = 1.0;

  lo_send(aLoAddress, "keyc", "if", aIKeyIndex, aFIntensity);

  // Track when a key message has been sent.
  if (0 <= aIKeyIndex && aIKeyIndex < mIMaxKeyIndex)
    mBKeySent[aIKeyIndex] = true;
}

void BasicMap::OnKeyEnd(lo_address aLoAddress, int aIKeyIndex)
{
  if (!mBSendEnds)
    return;

  // Only send 'end' messages when there has been a keyhit or continuous message sent.
  if (0 <= aIKeyIndex && aIKeyIndex < mIMaxKeyIndex && mBKeySent[aIKeyIndex] == true)
  {
    lo_send(aLoAddress, "keye", "i", aIKeyIndex);


    cout << "end!" << endl;

    mBKeySent[aIKeyIndex] = false;
  }

}


void BasicMap::OnArduinoCommand(const char *aC, lo_address aLoAddress)
{
  int lINob(0);
  float lF(0.0);
  int len = strlen(aC);
  if (len < 2)
    return;

  // 3 analog knobs, 3 arcade buttons, 1 5-way switch.


  switch (aC[0])
  {
  case '#':
    {
      // Its one of the knobs.
      if (len < 3)
        return;

      // parse the rest of the string as a number.
      lINob = atoi(aC+2);
      lF = lINob;
      lF /= 1023.0;

      int lIKnobIndex = -1;
      switch (aC[1])
      {
         case 'A':
            lIKnobIndex = 0;
            break;
         case 'B':
            lIKnobIndex = 1;
            break;
         case 'C':
            lIKnobIndex = 2;
            break;
         default:
            return;   // invalid.
      }

      lo_send(aLoAddress, "knob", "if", lIKnobIndex, lF);
      break;
    }
  case '$':
    {
      // its the center switch.
      int lIPos = -1;
      switch (aC[1])
      {
      case 'a':
        lIPos = 0;
        break;
      case 'b':
        lIPos = 1;
        break;
      case 'c':
        lIPos = 2;
        break;
      case 'd':
        lIPos = 3;
        break;
      case 'e':
        lIPos = 4;
        break;
      default:
        return;  // invalid.
      }
      lo_send(aLoAddress, "switch", "i", lIPos);
      break;
    }
  case '@':
    {
      int lIButton;
      int lIOn;
      // its a button.
      switch (aC[1])
      {
      case 'a':
        lIButton = 0;
        lIOn = 1;
        break;
      case 'A':
        lIButton = 0;
        lIOn = 0;
        break;
      case 'b':
        lIButton = 1;
        lIOn = 1;
        break;
      case 'B':
        lIButton = 1;
        lIOn = 0;
        break;
      case 'c':
        lIButton = 2;
        lIOn = 1;
        break;
      case 'C':
        lIButton = 2;
        lIOn = 0;
        break;
     default:
        return;
      }
      
      lo_send(aLoAddress, "button", "ii", lIButton, lIOn);
      break;
    }
  default:
    break;
  }
}


// --------------------------------------------------------------------
// PdMap.
// --------------------------------------------------------------------

void PdMap::PrintScale(int aIScale)
{
    cout << "Scale " << aIScale << ": ";
    for (int lI = 0; lI < mVScales[aIScale].size(); ++lI)
    {
      cout << mVScales[aIScale][lI] << " ";
    }

    cout << endl;
}

int CalcNote(int aIKeyIndex, const vector<int> &aVScale)
{
  int length = aVScale.size();
  int floor = aIKeyIndex / length;
  int rem = aIKeyIndex - (length * floor);

  return floor * 12 + aVScale[rem];
}

void PdMap::OnKeyHit(lo_address aLoAddress, int aIKeyIndex, float aFIntensity)
{
  aFIntensity *= mFGain;
  if (aFIntensity > 1.0)
    aFIntensity = 1.0;

  if (mVKeyMaps[mIKeyMap][aIKeyIndex].mBSendNote)
  {
    int lINote = CalcNote(aIKeyIndex, mVScales[mIScale]);
    lINote += mIStartNote;

    // cout << "sending: key " << aIKeyIndex << " note " << lINote << " intensity " << aFIntensity << endl;
    lo_send(aLoAddress, 
      mVKeyMaps[mIKeyMap][aIKeyIndex].mSName.c_str(), "if", lINote, aFIntensity);
  }
  else
  {
    // cout << "sending: key " << aIKeyIndex << " intensity " << aFIntensity << endl;
    lo_send(aLoAddress, 
      mVKeyMaps[mIKeyMap][aIKeyIndex].mSName.c_str(), "f", aFIntensity);
  }
}

void PdMap::OnContinuous(lo_address aLoAddress, int aIKeyIndex, float aFIntensity)
{
  return;


  aFIntensity *= mFGain;
  if (aFIntensity > 1.0)
    aFIntensity = 1.0;

  if (mVKeyMaps[mIKeyMap][aIKeyIndex].mBSendNote)
  {
    int lINote = CalcNote(aIKeyIndex, mVScales[mIScale]);
    lINote += mIStartNote;

    // cout << "sending: key " << aIKeyIndex << " note " << lINote << " intensity " << aFIntensity << endl;
    lo_send(aLoAddress, 
      mVKeyMaps[mIKeyMap][aIKeyIndex].mSName.c_str(), "if", lINote, aFIntensity);
  }
  else
  {
    lo_send(aLoAddress, 
      mVKeyMaps[mIKeyMap][aIKeyIndex].mSName.c_str(), "f", aFIntensity);
  }
}

void PdMap::OnArduinoCommand(const char *aC, lo_address aLoAddress)
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
    lF /= 1023.0;

    switch (aC[1])
    {
       case 'A':
          lo_send(aLoAddress, "/arduino/delay/time", "f", lF); 
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
    PrintScale(mIScale);
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

void PdMap::makeDefaultMap()
{
  mVKeyMaps.clear();
  vector<KeyDest> lV;

  KeyDest lKd("/arduino/fm/note", true, true, false);

  for (int lI = 0; lI < 24; ++lI)
    lV.push_back(lKd);

  mVKeyMaps.push_back(lV);

  lV.clear();

  lV.push_back(KeyDest("/arduino/drums/tr909/0",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tr909/1",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tr909/2",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tr909/3",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tr909/4",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tr909/5",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/dundunba/0",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/dundunba/1",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/dundunba/2",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/dundunba/3",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/0",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/1",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/2",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/3",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/4",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/rx21Latin/5",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tabla/0",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tabla/1",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tabla/2",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tabla/3",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tabla/4",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tabla/5",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tabla/6",false, true, false));
  lV.push_back(KeyDest("/arduino/drums/tabla/7",false, true, false));

  mVKeyMaps.push_back(lV);

  int chromaticScale[] = {0,1,2,3,4,5,6,7,8,9,10,11};
  int majorScale[] = {0,2,4,5,7,9,11};
  int minorScale[] = {0,2,3,5,7,8,10};
  int harmonicMinorScale[] = {0,2,3,5,7,8,11};
  int hungarianMinorScale[] = {0,2,3,6,7,8,11};
  int majorPentatonicScale[] = {0,2,4,7,9};
  int minorPentatonicScale[] = {0,3,5,7,10};
  int diminishedScale[] = {0,2,3,5,6,8,9,11};

  mVScales.push_back(std::vector<int>(chromaticScale, chromaticScale + sizeof(chromaticScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(majorScale, majorScale + sizeof(majorScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(hungarianMinorScale, 
        hungarianMinorScale + sizeof(hungarianMinorScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(majorPentatonicScale, 
        majorPentatonicScale + sizeof(majorPentatonicScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(harmonicMinorScale, 
        harmonicMinorScale + sizeof(harmonicMinorScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(minorPentatonicScale, 
        minorPentatonicScale + sizeof(minorPentatonicScale) / sizeof(int) ));
  mVScales.push_back(std::vector<int>(diminishedScale, 
        diminishedScale + sizeof(diminishedScale) / sizeof(int) ));

  // mVScales.push_back(std::vector<int>(minorScale, minorScale + sizeof(minorScale) / sizeof(int) ));

 }

