
long debounceDelay = 20;

int knobPin0 = A0;
int knobVal0 = 0;
int prevKnobVal0 = 0;

int knobPin1 = A1;
int knobVal1 = 0;
int prevKnobVal1 = 0;

int knobPin2 = A2;
int knobVal2 = 0;
int prevKnobVal2 = 0;

class PinChecker
{
public:
  PinChecker(volatile unsigned char *aRegister, char bitindex)
  {
    mRegister = aRegister;
    mask = 0x01;
    mask <<= bitindex;
  }

  volatile unsigned char *mRegister;
  unsigned char mask; 

  inline bool isPinOn() const { return (*mRegister & mask) != 0x00; }
  // inline bool isPinOn() const { return true; }

};


PinChecker PinCheckers[54] = {
  PinChecker(&PINE, 0),
  PinChecker(&PINE, 1),
  PinChecker(&PINE, 4),
  PinChecker(&PINE, 5),
  PinChecker(&PING, 5),
  PinChecker(&PINE, 3),
  PinChecker(&PINH, 3),
  PinChecker(&PINH, 4),
  PinChecker(&PINH, 5),
  PinChecker(&PINH, 6),
  PinChecker(&PINB, 4),
  PinChecker(&PINB, 5),
  PinChecker(&PINB, 6),
  PinChecker(&PINB, 7),
  PinChecker(&PINJ, 1),
  PinChecker(&PINJ, 0),
  PinChecker(&PINH, 1),
  PinChecker(&PINH, 0),
  PinChecker(&PIND, 3),
  PinChecker(&PIND, 2),
  PinChecker(&PIND, 1),
  PinChecker(&PIND, 0),
  PinChecker(&PINA, 0),
  PinChecker(&PINA, 1),
  PinChecker(&PINA, 2),
  PinChecker(&PINA, 3),
  PinChecker(&PINA, 4),
  PinChecker(&PINA, 5),
  PinChecker(&PINA, 6),
  PinChecker(&PINA, 7),
  PinChecker(&PINC, 7),
  PinChecker(&PINC, 6),
  PinChecker(&PINC, 5),
  PinChecker(&PINC, 4),
  PinChecker(&PINC, 3),
  PinChecker(&PINC, 2),
  PinChecker(&PINC, 1),
  PinChecker(&PINC, 0),
  PinChecker(&PIND, 7),
  PinChecker(&PING, 2),
  PinChecker(&PING, 1),
  PinChecker(&PING, 0),
  PinChecker(&PINL, 7),
  PinChecker(&PINL, 6),
  PinChecker(&PINL, 5),
  PinChecker(&PINL, 4),
  PinChecker(&PINL, 3),
  PinChecker(&PINL, 2),
  PinChecker(&PINL, 1),
  PinChecker(&PINL, 0),
  PinChecker(&PINB, 3),
  PinChecker(&PINB, 2),
  PinChecker(&PINB, 1),
  PinChecker(&PINB, 0)
};


/*
void initPinCheckers()
{
	PinCheckers[0] = new PinChecker(&PINE, 0);
	PinCheckers[1] = new PinChecker(&PINE, 1);
	PinCheckers[2] = new PinChecker(&PINE, 4);
	PinCheckers[3] = new PinChecker(&PINE, 5);
	PinCheckers[4] = new PinChecker(&PING, 5);
	PinCheckers[5] = new PinChecker(&PINE, 3);
	PinCheckers[6] = new PinChecker(&PINH, 3);
	PinCheckers[7] = new PinChecker(&PINH, 4);
	PinCheckers[8] = new PinChecker(&PINH, 5);
	PinCheckers[9] = new PinChecker(&PINH, 6);
	PinCheckers[10] = new PinChecker(&PINB, 4);
	PinCheckers[11] = new PinChecker(&PINB, 5);
	PinCheckers[12] = new PinChecker(&PINB, 6);
	PinCheckers[13] = new PinChecker(&PINB, 7);
	PinCheckers[14] = new PinChecker(&PINJ, 1);
	PinCheckers[15] = new PinChecker(&PINJ, 0);
	PinCheckers[16] = new PinChecker(&PINH, 1);
	PinCheckers[17] = new PinChecker(&PINH, 0);
	PinCheckers[18] = new PinChecker(&PIND, 3);
	PinCheckers[19] = new PinChecker(&PIND, 2);
	PinCheckers[20] = new PinChecker(&PIND, 1);
	PinCheckers[21] = new PinChecker(&PIND, 0);
	PinCheckers[22] = new PinChecker(&PINA, 0);
	PinCheckers[23] = new PinChecker(&PINA, 1);
	PinCheckers[24] = new PinChecker(&PINA, 2);
	PinCheckers[25] = new PinChecker(&PINA, 3);
	PinCheckers[26] = new PinChecker(&PINA, 4);
	PinCheckers[27] = new PinChecker(&PINA, 5);
	PinCheckers[28] = new PinChecker(&PINA, 6);
	PinCheckers[29] = new PinChecker(&PINA, 7);
	PinCheckers[30] = new PinChecker(&PINC, 7);
	PinCheckers[31] = new PinChecker(&PINC, 6);
	PinCheckers[32] = new PinChecker(&PINC, 5);
	PinCheckers[33] = new PinChecker(&PINC, 4);
	PinCheckers[34] = new PinChecker(&PINC, 3);
	PinCheckers[35] = new PinChecker(&PINC, 2);
	PinCheckers[36] = new PinChecker(&PINC, 1);
	PinCheckers[37] = new PinChecker(&PINC, 0);
	PinCheckers[38] = new PinChecker(&PIND, 7);
	PinCheckers[39] = new PinChecker(&PING, 2);
	PinCheckers[40] = new PinChecker(&PING, 1);
	PinCheckers[41] = new PinChecker(&PING, 0);
	PinCheckers[42] = new PinChecker(&PINL, 7);
	PinCheckers[43] = new PinChecker(&PINL, 6);
	PinCheckers[44] = new PinChecker(&PINL, 5);
	PinCheckers[45] = new PinChecker(&PINL, 4);
	PinCheckers[46] = new PinChecker(&PINL, 3);
	PinCheckers[47] = new PinChecker(&PINL, 2);
	PinCheckers[48] = new PinChecker(&PINL, 1);
	PinCheckers[49] = new PinChecker(&PINL, 0);
	PinCheckers[50] = new PinChecker(&PINB, 3);
	PinCheckers[51] = new PinChecker(&PINB, 2);
	PinCheckers[52] = new PinChecker(&PINB, 1);
	PinCheckers[53] = new PinChecker(&PINB, 0);
};
*/


PinChecker& getPinChecker(int pin)
{
  if (pin < 0 || pin > 53)
  {
    Serial.print("pin out of range: ");
    Serial.println(pin);

    // return pc 0 if out of range, so the prog doesn't have to do null checks.
    return PinCheckers[0];  
  }
 
  return PinCheckers[pin];
}


class Button
{
  public:
    Button(int pin1, int pin2, char aprefix, char aup, char adown)
    :buttonPin1(pin1), 
     pc1(getPinChecker(pin1)),
     buttonPin2(pin2), 
     pc2(getPinChecker(pin2)),
    prefix(aprefix), up(aup), down(adown)
    {
     prevState1 = -1;
     lastDebounceTime1 = 0;
     prevState2 = -1;
     lastDebounceTime2 = 0;
    }  

  bool HasRegister(volatile unsigned char *aRegister) const 
  {
    return (aRegister == pc1.mRegister) || (aRegister == pc2.mRegister);
  }

  char up, down, prefix;
  const int buttonPin1;
  const int buttonPin2;
  PinChecker &pc1;
  PinChecker &pc2;
  int prevState1;
  int prevState2;
  long lastDebounceTime1;
  long lastDebounceTime2;
  unsigned long time1;

  void InitPin()
  {
    pinMode(buttonPin1, INPUT);   // digital sensor is on digital pin 1
    pinMode(buttonPin2, INPUT);   // digital sensor is on digital pin 2
    digitalWrite(buttonPin1, HIGH);
    digitalWrite(buttonPin2, HIGH);
  }

  void DoButtonStuff()
  {  
    int buttonState1 = pc1.isPinOn();
  
    if (buttonState1 != prevState1) 
    {
      if ((millis()-lastDebounceTime1) > debounceDelay)
      {
        if (buttonState1 == LOW) 
        {
         time1 = micros();
         //Serial.print(prefix);
         //Serial.println(up);
        }
        else {
         //Serial.print(prefix);
         //Serial.println(down);
        }
      }
      else {
         //Serial.print(prefix);
         //Serial.println("9A");
      }
      lastDebounceTime1 = millis();
      prevState1 = buttonState1;
    }

    int buttonState2 = pc2.isPinOn();
    if (buttonState2 != prevState2) 
    {
      if ((millis()-lastDebounceTime2) > debounceDelay)
      {
        if (buttonState2 == LOW) 
        {
          unsigned long time2 = micros();
          Serial.print(prefix);
          Serial.print(up);
          Serial.print(" ");
          Serial.println(time2 - time1);
        }
        else 
        {
          //Serial.print(prefix);
          //Serial.println(down);
        }
      }
      else 
      {
        Serial.print(prefix);
        Serial.println("9B");
      }
      lastDebounceTime2 = millis();
      prevState2 = buttonState2;
    }
  }
};

Button Buttons[24] = { 
  Button(26, 51, 'K', 'A', 'a'), //  0
  Button(27, 52, 'K', 'B', 'b'), //  1
  Button(2, 29, 'K', 'C', 'c'),  //  2
  Button(3, 30, 'K', 'D', 'd'),  //  3
  Button(4, 31, 'K', 'E', 'e'),  //  4
  Button(5, 32, 'K', 'F', 'f'),  //  5
  Button(6, 33, 'K', 'G', 'g'),  //  6
  Button(7, 34, 'K', 'H', 'h'),  //  7
  Button(8, 35, 'K', 'I', 'i'),  //  8
  Button(9, 36, 'K', 'J', 'j'),  //  9
  Button(10, 37, 'K', 'K', 'k'), //  10
  Button(11, 38, 'K', 'L', 'l'), //  11 
  Button(12, 39, 'K', 'M', 'm'), //  12 
  Button(13, 40, 'K', 'N', 'n'), //  13 
  Button(14, 41, 'K', 'O', 'o'), //  14
  Button(15, 42, 'K', 'P', 'p'), //  15
  Button(16, 43, 'K', 'Q', 'q'), //  16
  Button(17, 44, 'K', 'R', 'r'), //  17
  Button(18, 45, 'K', 'S', 's'), //  18
  Button(19, 46, 'K', 'T', 't'), //  19
  Button(20, 47, 'K', 'U', 'u'), //  20
  Button(21, 48, 'K', 'V', 'v'), //  21
  Button(22, 49, 'K', 'W', 'w'), //  22
  Button(24, 50, 'K', 'X', 'x')  //  23
};  

int InitPinButtonArray(unsigned int *aButtonArray, volatile unsigned char *aRegister)
{
  int count = 0;

  for (int i =0; i< sizeof(Buttons)/sizeof(Button); ++i)
  {
    if (Buttons[i].HasRegister(aRegister))
    {
      aButtonArray[count] = (unsigned int)&(Buttons[i]);
      ++count;
    }
    if (count > 8)
    {
      Serial.println("pinbuttonarray count exceeded!!");
      count = 8;
      break;
    }
  }

  // terminate the array with zero.
  aButtonArray[count] = 0;
  
  return count;
}


/*
int InitPinButtonArray(Button **aButtonArray)
{
  //  aButtonArray[0] = 0;

  // Array[0] = 0;
  return 0;
}

int InitPinButtonArray(Button **aButtonArray, volatile unsigned char *aRegister)
{
  int count = 0;

  for (int i =0; i< sizeof(Buttons)/sizeof(Button); ++i)
  {
    if (Buttons[i].HasRegister(aRegister))
    {
      aButtonArray[count] = &(Buttons[i]);
      ++count;
    }
    if (count > 8)
    {
      Serial.println("pinbuttonarray count exceeded!!");
      count = 8;
      break;
    }
  }

  // terminate the array with zero.
  aButtonArray[count] = 0;
  
  return count;
}
*/

// all buttons with pins in register A.  (22 - 29)
Button *AButtons[9];
Button *BButtons[9];
Button *CButtons[9];
Button *DButtons[9];
Button *EButtons[9];
Button *FButtons[9];
Button *GButtons[9];
Button *HButtons[9];
Button *JButtons[9];
Button *LButtons[9];


/*
Button Selector[0] = { 
  Button(30, 'S', 'A', 'a'), 
  Button(31, 'S', 'B', 'b'), 
  Button(32, 'S', 'C', 'c'), 
  Button(33, 'S', 'D', 'd'),
  Button(34, 'S', 'E', 'e') 
};
*/

void setup()
{
  // set up pin button arrays.
  InitPinButtonArray((unsigned int*)AButtons, &PINA);
  InitPinButtonArray((unsigned int*)BButtons, &PINB);
  InitPinButtonArray((unsigned int*)CButtons, &PINC);
  InitPinButtonArray((unsigned int*)DButtons, &PIND);
  InitPinButtonArray((unsigned int*)EButtons, &PINE);
  InitPinButtonArray((unsigned int*)FButtons, &PINF);
  InitPinButtonArray((unsigned int*)GButtons, &PING);
  InitPinButtonArray((unsigned int*)HButtons, &PINH);
  InitPinButtonArray((unsigned int*)JButtons, &PINJ);
  InitPinButtonArray((unsigned int*)LButtons, &PINL);
  
  // start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  
  for (int i =0; i< sizeof(Buttons)/sizeof(Button); ++i)
  {
    Buttons[i].InitPin();  
  }

  /*
  for (int i =0; i< sizeof(Selector)/sizeof(Button); ++i)
  {
    Selector[i].InitPin();  
  }
  */
  
}

int count = 0;
unsigned long time1 = 0;
unsigned char oldpina, oldpinb, oldpinc, oldpind, oldpine;
unsigned char oldpinf, oldping, oldpinh, oldpinj, oldpinl;

inline void checkbuttons( volatile unsigned char &aRegister, 
                          unsigned char &aOld, 
                          unsigned int* aButtonArray)
{
  if (aOld != aRegister)
    aOld = aRegister; 
}

void loop()
{

  // if 10000 loops, print the time.
  if (count > 10000)
  {
    unsigned long time2 = micros();
    Serial.print("time: ");
    Serial.println(time2 - time1);
    time1 = time2;
    count = 0;
  }  
  
  ++count;
  
  // is this as fast as the non-inline function code? 
  checkbuttons(PINA, oldpina, (unsigned int*)AButtons);
  checkbuttons(PINB, oldpinb, (unsigned int*)BButtons);
  checkbuttons(PINC, oldpinc, (unsigned int*)CButtons);
  checkbuttons(PIND, oldpind, (unsigned int*)DButtons);
  checkbuttons(PINE, oldpine, (unsigned int*)EButtons);
  checkbuttons(PINF, oldpinf, (unsigned int*)FButtons);
  checkbuttons(PING, oldping, (unsigned int*)GButtons);
  checkbuttons(PINH, oldpinh, (unsigned int*)HButtons);
  checkbuttons(PINJ, oldpinj, (unsigned int*)JButtons);
  checkbuttons(PINL, oldpinl, (unsigned int*)LButtons);

/* 
  // takes 167750 for 10000 loops, or 16.7 microseconds.
  if (oldpina != PINA)
    oldpina = PINA;
  if (oldpinb != PINB)
    oldpinb != PINB;
  if (oldpinc != PINC)
    oldpinc != PINC;
  if (oldpind != PIND)
    oldpind != PIND;
  if (oldpine != PINE)
    oldpine != PINE;
  if (oldpinf != PINF)
    oldpinf != PINF;
  if (oldping != PING)
    oldping != PING;
  if (oldpinh != PINH)
    oldpinh != PINH;
  if (oldpinj != PINJ)
    oldpinj != PINJ;
  if (oldpinl != PINL)
    oldpinl != PINL;
*/
  /*
  // takes 3671324 per 10000 loops, or 367 microseconds.
  for (int i =0; i< sizeof(Buttons)/sizeof(Button); ++i)
  {
    Buttons[i].DoButtonStuff();  
  }
  
  */
  
  
/*
  for (int i =0; i< sizeof(Selector)/sizeof(Button); ++i)
  {
    Selector[i].DoButtonStuff();  
  }
*/
/*
  knobVal0 = analogRead(knobPin0);
  if (abs(knobVal0-prevKnobVal0) > 2) {
    Serial.print('A');
    Serial.println(knobVal0);
    prevKnobVal0 = knobVal0;
  }
  
  knobVal1 = analogRead(knobPin1);
  if (abs(knobVal1-prevKnobVal1) > 2) {
    Serial.print('B');
    Serial.println(knobVal1);
    prevKnobVal1 = knobVal1;
  }
  knobVal2 = analogRead(knobPin2);
  if (abs(knobVal2-prevKnobVal2) > 2) {
    Serial.print('C');
    Serial.println(knobVal2);
    prevKnobVal2 = knobVal2;
  }

*/  
  
}
