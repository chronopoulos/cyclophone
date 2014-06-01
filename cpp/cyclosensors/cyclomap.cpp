#include "cyclomap.h"

int CalcNote(int aIKeyIndex, const vector<int> &aVScale)
{
  int length = aVScale.size();
  int floor = aIKeyIndex / length;
  int rem = aIKeyIndex - (length * floor);

  return aIKeyIndex * 12 + aVScale[rem];
}

void CycloMap::makeDefaultMap()
{
  mVKeyMaps.clear();
  map<int,KeyDest> lM;

  lM[0] = KeyDest("/arduino/drums/tr909/0", false);
  lM[1] = KeyDest("/arduino/drums/tr909/1", false);
  lM[2] = KeyDest("/arduino/drums/tr909/2", false);
  lM[3] = KeyDest("/arduino/drums/tr909/3", false);
  lM[5] = KeyDest("/arduino/drums/tr909/4", false);
  lM[6] = KeyDest("/arduino/drums/tr909/5", false);
  lM[7] = KeyDest("/arduino/drums/dundunba/0", false);
  lM[8] = KeyDest("/arduino/drums/dundunba/1", false);
  lM[9] = KeyDest("/arduino/drums/dundunba/2", false);
  lM[10] = KeyDest("/arduino/drums/dundunba/3", false);
  lM[11] = KeyDest("/arduino/drums/rx21Latin/0", false);
  lM[12] = KeyDest("/arduino/drums/rx21Latin/1", false);
  lM[13] = KeyDest("/arduino/drums/rx21Latin/2", false);
  lM[14] = KeyDest("/arduino/drums/rx21Latin/3", false);
  lM[15] = KeyDest("/arduino/drums/rx21Latin/4", false);
  lM[16] = KeyDest("/arduino/drums/rx21Latin/5", false);
  lM[17] = KeyDest("/arduino/drums/tabla/0", false);
  lM[18] = KeyDest("/arduino/drums/tabla/1", false);
  lM[19] = KeyDest("/arduino/drums/tabla/2", false);
  lM[20] = KeyDest("/arduino/drums/tabla/3", false);
  lM[21] = KeyDest("/arduino/drums/tabla/4", false);
  lM[22] = KeyDest("/arduino/drums/tabla/5", false);
  lM[23] = KeyDest("/arduino/drums/tabla/6", false);
  lM[24] = KeyDest("/arduino/drums/tabla/7", false);

  mVKeyMaps.push_back(lM);

  lM.clear();

  KeyDest lKd("/arduino/fm/note", true);

  for (int lI = 0; lI < 24; ++lI)
    lM[lI] = lKd;

  mVKeyMaps.push_back(lM);

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
