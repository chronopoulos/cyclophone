#include "Adafruit_WS2801.h"
#include "SPI.h" // Comment out this line if using Trinket or Gemma
#ifdef __AVR_ATtiny85__
 #include <avr/power.h>
#endif

/*****************************************************************************
Example sketch for driving Adafruit WS2801 pixels!


  Designed specifically to work with the Adafruit RGB Pixels!
  12mm Bullet shape ----> https://www.adafruit.com/products/322
  12mm Flat shape   ----> https://www.adafruit.com/products/738
  36mm Square shape ----> https://www.adafruit.com/products/683

  These pixels use SPI to transmit the color data, and have built in
  high speed PWM drivers for 24 bit color per pixel
  2 pins are required to interface

  Adafruit invests time and resources providing this open source code, 
  please support Adafruit and open-source hardware by purchasing 
  products from Adafruit!

  Written by Limor Fried/Ladyada for Adafruit Industries.  
  BSD license, all text above must be included in any redistribution

*****************************************************************************/

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
uint32_t Color(byte r, byte g, byte b)
{
  uint32_t c;
  c = r;
  c <<= 8;
  c |= g;
  c <<= 8;
  c |= b;
  return c;
}

//Input a value 0 to 255 to get a color value.
//The colours are a transition r - g -b - back to r
uint32_t Wheel(byte WheelPos)
{
  if (WheelPos < 85) {
   return Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if (WheelPos < 170) {
   WheelPos -= 85;
   return Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170; 
   return Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}

/* patterns */

void rainbow(uint8_t wait) {
  int i, j;
   
  for (j=0; j < 256; j++) {     // 3 cycles of all 256 colors in the wheel
    for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, Wheel( (i + j) % 255));
    }  
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

// Slightly different, this one makes the rainbow wheel equally distributed 
// along the chain
void rainbowCycle(uint8_t wait) {
  int i, j;
  
  for (j=0; j < 256 * 5; j++) {     // 5 cycles of all 25 colors in the wheel
    for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 96-color wheel
      // (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 96 is to make the wheel cycle around
      strip.setPixelColor(i, Wheel( ((i * 256 / strip.numPixels()) + j) % 256) );
    }  
    strip.show();   // write all the pixels out
    delay(wait);
  }
}

// fill the dots one after the other with said color
// good for testing purposes
void colorWipe(uint32_t c, uint8_t wait) {
  int i;
  
  for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i, c);
      strip.show();
      delay(wait);
  }
}

// --------------------------------------------------------------------

/*
void  loErrHandler(int num, const char *msg, const char *where)
{
  cout << "lo lib error: " << num << " : " << msg << "\n" << where << endl;
}

// catch any incoming messages and display them. returning 1 means that the
// message has not been fully handled and the server should try other methods 
int generic_handler(const char *path, const char *types, lo_arg ** argv,
                    int argc, void *data, void *user_data)
{
    int i;

    printf("path: %s\n", path);
    for (i = 0; i < argc; i++) {
        printf("arg %d '%c' ", i, types[i]);
        lo_arg_pp((lo_type)types[i], argv[i]);
        printf("\n");
    }
    printf("\n");
    fflush(stdout);

    return 1;
}

// set individual LED colors.  
int led_handler(const char *path, const char *types, lo_arg ** argv,
                    int argc, void *data, void *user_data)
{
    int i;

    printf("path: %s\n", path);
    
    if (argc % 2 != 0)
    {
      printf ("Invalid arg count for 'led' msg - must be even!\n");
      return 1;
    }

    int index;
    uint32_t color;


    for (i = 0; i < argc; i+=2) 
    {
      if (types[i] == LO_INT32)
        index = argv[i]->i;
      else if (types[i] == LO_FLOAT)
        index = (int)argv[i]->f;
      else
      {
        printf("invalid type for 'index'");
        break;
      }
     
      int j = i + 1; 
      if (types[j] == LO_INT32)
        color = argv[j]->i;
      else if (types[j] == LO_FLOAT)
        color = (int)argv[j]->f;
      else
      {
        printf("invalid type for 'color'");
        break;
      }
      
      strip.setPixelColor(index, color);
    }
      
    strip.show();
    printf("\n");
    fflush(stdout);

    return 1;
}
*/

const int pixelCount(25);

class ColorSet
{
public:
  ColorSet()
  {
    for (int lI = 0; lI < pixelCount; ++lI)
      csColors[lI] = 0;
  }
  uint32_t csColors[pixelCount];
};

const int colorSetCount(10);

ColorSet colorSets[colorSetCount];
int gIUpdatingCs = 0;

class fade
{
public:
  fade()
  {
    from = to = 0;
    count = 0; 
    end = true;
  }
  int from, to;
  int count;
  bool end;
};

fade fadequeue[pixelCount];
int fadeindex = 0;

void ProcessLine (const String& aSLine)
{
  Serial.print("ProcessLine");
  // setcolorarray?
  if (aSLine.startsWith("setcolorarray "))
  {
    int lI = aSLine.substring(14).toInt();
    Serial.print("setcolorarray: ");
    String lSWk(lI, DEC);
    Serial.println(lSWk);
    // yeah.  Set the colorarray that we're updating.  
    if (lI >= 0 && lI < colorSetCount)
      gIUpdatingCs = lI;
  }
  else if (aSLine.startsWith("setcolor "))
  {
    int lI = aSLine.substring(9).toInt();
    Serial.print("setcolor: ");
    String lSWk(lI, DEC);
    Serial.println(lSWk);
    // yeah.  Set the colorarray that we're updating.  
    if (lI >= 0 && lI < colorSetCount)
    {
      for (int i = 0; i < pixelCount; ++i)
      {
        strip.setPixelColor(i, colorSets[lI].csColors[i]);
      }
      strip.show();
    }
  }
  else if (aSLine.startsWith("set "))
  {
    Serial.print("set: ");
    // should be followed by two ints, separated by a space.
    int lISpace = aSLine.indexOf(" ", 4);
    if (lISpace != -1)
    {
      int lIndex = aSLine.substring(4, lISpace - 1).toInt();
      uint32_t lColor = aSLine.substring(lISpace + 1).toInt();
      
      String lSWk(lIndex, DEC);
      Serial.print(lSWk);
      Serial.print(" ");
      String lSWk2(lColor, DEC);
      Serial.println(lSWk2);
      
      // yeah.  Set the colorarray that we're updating.  
      if (lIndex >= 0 && lIndex < pixelCount)
      {
        colorSets[gIUpdatingCs].csColors[lIndex] = lColor;
      }
    }
    else
      Serial.println("Space not found!");
  }
}

/*
-- make an array of colors, but don't actually send them to
-- the leds yet.
setcolorarray <index>
<index> <color>
...
end

-- send an array of colors to the leds.
-- stops any fades that are in progress.
setcolor <index>

-- add a fade to the action queue.
addfade <index1> <index2> <time>

-- reset the action queue.
reset
*/

void loop() {

  Serial.begin(115200);

  String inString;
  
  while (true)
  {
    // Read serial input:
    while (Serial.available() > 0) {
      char inChar = Serial.read();
      inString += inChar;
      
      Serial.println(inString);
      
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
    
  }
  
  
  
}

// -----------------------------------------------------------------------
// junkyard
// -----------------------------------------------------------------------


  // Some example procedures showing how to display to the pixels
  /*
  colorWipe(Color(255, 0, 0), 50);
  colorWipe(Color(0, 255, 0), 50);
  colorWipe(Color(0, 0, 255), 50);
  rainbow(20);
  rainbowCycle(20);
  */

    // colorWipe(Color(255, 0, 0), 50);
    // int index = Serial.parseInt();
    // int color = Serial.parseInt();
    // hope this does range checking!
    // strip.setPixelColor(index, color);
    
    /*
    // char lC = Serial.read();
    int lC = Serial.parseInt();
    
    if (lC != 0)
    {
      Serial.print("I received: ");
      Serial.println(lC, DEC);
      int index = lC % 25;
      strip.setPixelColor(index, Color(lC, lC, lC));
      strip.show();
    }
    */

