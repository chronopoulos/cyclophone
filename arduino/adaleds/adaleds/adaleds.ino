#include "Adafruit_WS2801.h"
#include "SPI.h" // Comment out this line if using Trinket or Gemma
#ifdef __AVR_ATtiny85__
 #include <avr/power.h>
#endif

//#define PRINT Serial.print
//#define PRINTLN Serial.println
#define PRINT //
#define PRINTLN //


/*

This sketch implements a mini language to tell the ws2801 pixels what to do.

The commands:

updatearray <index>
- sets which color array we are updating.  
- Configure the number of arrays below, watch out, memory is limited!

setpixel <index> <color>
- sets the color of a pixel in the current array (set by updatearray)

showarray <index>
- sends the indicated color array to the pixels.

fadeto <index> <cycles>
- gradually transitions from the current color array to the new color array.
- issue multiple fadeto commands to have them execute sequentially.

*/

const int colorSetCount(5);
const int fadequeuecount(10);


// Choose which 2 pins you will use for output.
// Can be any valid output pins.
// The colors of the wires may be totally different so
// BE SURE TO CHECK YOUR PIXELS TO SEE WHICH WIRES TO USE!
uint8_t dataPin  = 2;    // Yellow wire on Adafruit Pixels
uint8_t clockPin = 3;    // Green wire on Adafruit Pixels

// Don't forget to connect the ground wire to Arduino ground,
// and the +5V wire to a +5V supply

// Set the first variable to the NUMBER of pixels. 25 = 25 pixels in a row
Adafruit_WS2801 strip = Adafruit_WS2801(25, dataPin, clockPin);

// Optional: leave off pin numbers to use hardware SPI
// (pinout is then specific to each board and can't be changed)
//Adafruit_WS2801 strip = Adafruit_WS2801(25);

// For 36mm LED pixels: these pixels internally represent color in a
// different format.  Either of the above constructors can accept an
// optional extra parameter: WS2801_RGB is 'conventional' RGB order
// WS2801_GRB is the GRB order required by the 36mm pixels.  Other
// than this parameter, your code does not need to do anything different;
// the library will handle the format change.  Examples:
//Adafruit_WS2801 strip = Adafruit_WS2801(25, dataPin, clockPin, WS2801_GRB);
//Adafruit_WS2801 strip = Adafruit_WS2801(25, WS2801_GRB);

void setup() {

/*
#if defined(__AVR_ATtiny85__) && (F_CPU == 16000000L)
  clock_prescale_set(clock_div_1); // Enable 16 MHz on Trinket
#endif
*/

  strip.begin();

  // Update LED contents, to start they are all 'off'
  strip.show();
}


/* Helper functions */

// Create a 24 bit color value from R,G,B
uint32_t FromRGB(byte r, byte g, byte b)
{
  uint32_t c;
  c = r;
  c <<= 8;
  c |= g;
  c <<= 8;
  c |= b;
  return c;
}

void ToRGB(uint32_t color, byte &r, byte &g, byte &b)
{
  byte *lC = (byte *)&color;
  r = lC[2];
  g = lC[1];
  b = lC[0];
}

//Input a value 0 to 255 to get a color value.
//The colours are a transition r - g -b - back to r
uint32_t Wheel(byte WheelPos)
{
  if (WheelPos < 85) {
   return FromRGB(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if (WheelPos < 170) {
   WheelPos -= 85;
   return FromRGB(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170; 
   return FromRGB(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}

// --------------------------------------------------------------------

const int pixelCount(25);

class ColorSet
{
public:
  ColorSet()
  {
    for (int lI = 0; lI < pixelCount; ++lI)
      csColors[lI] = 0;
  }
  void Show()
  {
      for (int i = 0; i < pixelCount; ++i)
      {
        strip.setPixelColor(i, csColors[i]);
      }
      strip.show();
  }
  
  uint32_t csColors[pixelCount];
};

ColorSet gColorSets[colorSetCount];
// color set we're currently updating using setpixel
int gIUpdatingCs = 0;

// index of the last color array sent to the pixels.
// this should be updated on showarray or at the end of fadeto.  
int gILastColor = 0;

byte interpolate(byte from, byte to, int val, int total)
{
  if (to > from)
    return from + ((to - from) * val) / total;
  else
    return to + ((from-to) * (total - val)) / total;
     
}

// ColorSet mCsFadeWk;
class fade
{
public:
  fade()
  {
    from = to = 0;
    count = 0; 
    counter = 0;
    end = true;
  }
  
  void Init(int aFrom, int aTo, int aCount)
  {
    from  = aFrom;
    to = aTo;
    count = aCount;
    counter = 0;
    end = false;
  }

  void DoFading()
  {
    if (end)
      return;

    ComputeCs(sColorSet);
    
    sColorSet.Show();
    counter++;
    
    if (counter > count)
    {
      gILastColor = to;
      end = true;
    }
        
  }
  
  void ComputeCs(ColorSet &aCs)
  {
    for (int i = 0; i < pixelCount; ++i)
    {
      byte rf,gf,bf,rt,gt,bt;
      ToRGB(gColorSets[from].csColors[i],rf,gf,bf);
      ToRGB(gColorSets[to].csColors[i],rt,gt,bt);
      
      byte r,g,b;
      r = interpolate(rf,rt,counter,count);
      g = interpolate(gf,gt,counter,count);
      b = interpolate(bf,bt,counter,count);
       
      if (i == 0)
      {
        // ToRGB(lcolor,r,g,b);
        PRINT("interp:: r: ");
        PRINT(r);
        PRINT(" g: ");
        PRINT(g);
        PRINT(" b: ");
        PRINTLN(b);
        PRINT(" rf: ");
        PRINTLN(rf);
        PRINT(" rt: ");
        PRINTLN(rt);
        PRINT(" counter: ");
        PRINTLN(counter);
        PRINT(" count: ");
        PRINTLN(count);
        PRINT(" gColorSets[from].csColors[i]: ");
        PRINTLN(String(gColorSets[from].csColors[i], DEC));
        PRINT(" gColorSets[to].csColors[i]: ");
        PRINTLN(String(gColorSets[to].csColors[i], DEC));
      } 
       
      aCs.csColors[i] = FromRGB(r,g,b);
    }
  }
  
private:
  int counter;
  
  int from, to;
  int count;
  bool end;

  // work colorset, shared by all fade objs.
  static ColorSet sColorSet;
};

ColorSet fade::sColorSet;

fade fadequeue[fadequeuecount];
int fadeindex = 0;

void ProcessLine (const String& aSLine)
{
  PRINTLN("ProcessLine");
  // setcolorarray?
  if (aSLine.startsWith("updatearray "))
  {
    int lI = aSLine.substring(12).toInt();
    PRINT("updatearray: ");
    String lSWk(lI, DEC);
    PRINTLN(lSWk);
    // yeah.  Set the colorarray that we're updating.  
    if (lI >= 0 && lI < colorSetCount)
      gIUpdatingCs = lI;
  }
  else if (aSLine.startsWith("showarray "))
  {
    int lI = aSLine.substring(10).toInt();
    PRINT("showarray: ");
    String lSWk(lI, DEC);
    PRINTLN(lSWk);
    // push the indicated color array to the leds.
    if (lI >= 0 && lI < colorSetCount)
    {
      gColorSets[lI].Show();
      gILastColor = lI;
    }
  }
  else if (aSLine.startsWith("setpixel "))
  {
    // within the current array (see "updatearray"), set a pixel's color. 
    PRINT("setpixel: ");
    // should be followed by two ints, separated by a space.
    int lISpace = aSLine.indexOf(" ", 9);
    if (lISpace != -1)
    {
      int lIndex = aSLine.substring(9, lISpace).toInt();
      uint32_t lColor = aSLine.substring(lISpace + 1).toInt();
      
      String lSWk(lIndex, DEC);
      PRINT(lSWk);
      PRINT(" ");
      String lSWk2(lColor, DEC);
      PRINTLN(lSWk2);
      
      // yeah.  Set the colorarray that we're updating.  
      if (lIndex >= 0 && lIndex < pixelCount)
      {
        gColorSets[gIUpdatingCs].csColors[lIndex] = lColor;
      }
    }
    else
      PRINTLN("Space not found!");
  }
  else if (aSLine.startsWith("fadeto "))
  {
    PRINT("fadeto: ");
    
    // should be followed by three ints, separated by a space.
    int lISpace = aSLine.indexOf(" ", 7);
    if (lISpace == -1)
      return;
      
    // from the end of "fade " to the space.
    int lIToIndex = aSLine.substring(7, lISpace).toInt();
      
    // between the first space to the end.
    int lICount = aSLine.substring(lISpace + 1).toInt();
      
    fadequeue[fadeindex].Init(gILastColor, lIToIndex, lICount);
        
    String lSWk2(lIToIndex, DEC);
    PRINT(lSWk2);
    PRINT(" ");
    String lSWk3(lICount, DEC);
    PRINTLN(lSWk3);

    uint32_t lcolor = FromRGB(12,13,145);
    byte r,g,b;
    ToRGB(lcolor,r,g,b);
    PRINT("colortest: r: ");
    PRINT(r);
    PRINT(" g: ");
    PRINT(g);
    PRINT(" b: ");
    PRINTLN(b);
   
  }
}

void loop() {

  Serial.begin(115200);

  String inString;
  
  while (true)
  {
    // Read serial input:
    while (Serial.available() > 0) {
      char inChar = Serial.read();
      inString += inChar;
      
      PRINTLN(inString);
      
      // if you get a newline, print the string,
      // then the string's value:
      if (inChar == '\n') 
      {
        ProcessLine(inString);
        // clear the string for new input:
        inString = "";
      }
    }

    // Do fade stuff, if there's fades happening.
    fadequeue[fadeindex].DoFading();
   
  }
  
  
  
}


