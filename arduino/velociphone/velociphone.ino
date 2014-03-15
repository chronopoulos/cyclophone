// ----------------------------------------------------------
// velociphone sketch.  
//  this sketch is for the velocity sensitive cyclophone
//  this is the first iteration using the arduino mega.
//  ultimately we abandoned this approach and went with the
//  'velocidue' sketch instead.
// ----------------------------------------------------------

//  to do:
// - save time by only using a button once in a button array
// - compare with mask for register checks. 

unsigned long debounceDelay = 40000;

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

PinChecker& getPinChecker(int pin)
{
  if (pin < 0 || pin > 53)
  {
    //Serial.print("pin out of range: ");
    //Serial.println(pin);

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
     prevState1 = false;
     prevState2 = false;
     lasttime1 = 0;
     lasttime2 = 0;
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
  unsigned long lasttime1;
  unsigned long lasttime2;
  bool prevState1;
  bool prevState2;

  void InitPin()
  {
    pinMode(buttonPin1, INPUT);   // digital sensor is on digital pin 1
    pinMode(buttonPin2, INPUT);   // digital sensor is on digital pin 2
    digitalWrite(buttonPin1, HIGH);
    digitalWrite(buttonPin2, HIGH);
  }

  void DoButtonStuff(unsigned long newtime)
  {  
    // Serial.println("DoButtonStuff");
    
    bool buttonState1 = !pc1.isPinOn();
    if (buttonState1 != prevState1) 
    {
      if (buttonState1 && newtime - lasttime1 > debounceDelay)
      {
        //Serial.print("1:");
        //Serial.println(newtime - lasttime);
        lasttime1 = newtime;
      }
      prevState1 = buttonState1;
    }
    
    bool buttonState2 = !pc2.isPinOn();
    if (buttonState2 != prevState2) 
    {
      if (buttonState2 && newtime - lasttime2 > debounceDelay)
      {
        //Serial.print("2:");
        //Serial.print(down);
        //Serial.write(down);
        //Serial.println((newtime - lasttime) / 10000);
        Serial.println(newtime - lasttime1);
        /*
        if (newtime - lasttime == 0)
        {
          // turn on pin 13 - the LED.
          digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
        }
        */

        lasttime2 = newtime;
      }
      prevState2 = buttonState2;
    }
  }
};

Button Buttons[23] = { 
//  Button(26, 51, 'K', 'A', 'a'), //  0
//  Button(27, 52, 'K', 'B', 'b'), //  1
  Button(26, 27, 'K', 'A', 'a'), //  0
  Button(51, 52, 'K', 'B', 'b'), //  1
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
//  Button(13, 40, 'K', 'N', 'n'), //  13 
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
      //Serial.println("pinbuttonarray count exceeded!!");
      count = 8;
      break;
    }
  }

  // terminate the array with zero.
  aButtonArray[count] = 0;
  
  return count;
}

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
  
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);   // turn the LED off.
  // start serial port at 9600 bps:
  //Serial.begin(9600);  // 372, 380
  //Serial.begin(115200);
  Serial.begin(230400);
  /*
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  */
  
  for (int i =0; i< sizeof(Buttons)/sizeof(Button); ++i)
  {
    Buttons[i].InitPin();  
  }
 
  // digitalWrite(13, LOW);   // turn the LED off.
}

inline void checkbuttons( unsigned int* aButtonArray)
{
  unsigned long newtime = micros(); 

  while (*aButtonArray != 0)
  {
    ((Button*)*aButtonArray)->DoButtonStuff(newtime);
    ++aButtonArray;
  }
}

int count = 0;
int oldcount = 0;
unsigned char oldpina, oldpinb, oldpinc, oldpind, oldpine;
unsigned char oldpinf, oldping, oldpinh, oldpinj, oldpinl;

unsigned long last10000 = 0;
unsigned long maxcycle = 0;
unsigned long lastcycle = 0;


void loop()
{
  /*
  unsigned long newtime = micros();
  if (maxcycle < newtime - lastcycle)
    maxcycle = newtime - lastcycle;

  lastcycle = newtime;

  // if 10000 loops, print the time.
  if (count > 10000)
  {
    //Serial.print("avg time: ");
    //Serial.println((newtime - last10000) / 10000);
    //Serial.print("max time: ");
    unsigned short lS = maxcycle;
    Serial.write((uint8_t*)&lS, 2);
    last10000 = newtime;
    count = 0;
    maxcycle = 0;
  }  
  
  ++count;
  */
  
  if (oldpina != PINA)
  {
    oldpina = PINA;
    checkbuttons((unsigned int*)AButtons);
  }
  if (oldpinb != PINB)
  {
    oldpinb = PINB;
    checkbuttons((unsigned int*)BButtons);
  }
  if (oldpinc != PINC)
  {
    oldpinc = PINC;
    checkbuttons((unsigned int*)CButtons);
  }
  if (oldpind != PIND)
  {
    oldpind = PIND;
    checkbuttons((unsigned int*)DButtons);
  }
  if (oldpine != PINE)
  {
    oldpine = PINE;
    checkbuttons((unsigned int*)EButtons);
  }
  if (oldpinf != PINF)
  {
    oldpinf = PINF;
    checkbuttons((unsigned int*)FButtons);
  }
  if (oldping != PING)
  {
    oldping = PING;
    checkbuttons((unsigned int*)GButtons);
  }
  if (oldpinh != PINH)
  {
    oldpinh = PINH;
    checkbuttons((unsigned int*)HButtons);
  }
  if (oldpinj != PINJ)
  {
    oldpinj = PINJ;
    checkbuttons((unsigned int*)JButtons);
  }
  if (oldpinl != PINL)
  {
    oldpinl = PINL;
    checkbuttons((unsigned int*)LButtons);
  }


  // takes 167750 for 10000 loops, or 16.7 microseiconds.
  // 172780
  /*
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
  
  // 140328
  /*
  if (oldpina != PINA & 0xFEFE)
    oldpina = PINA & 0xFEFE;
  if (oldpinb != PINB & 0xFEFE)
    oldpinb = PINB & 0xFEFE;
  if (oldpinc != PINC & 0xFEFE)
    oldpinc = PINC & 0xFEFE;
  if (oldpind != PIND & 0xFEFE)
    oldpind = PIND & 0xFEFE;
  if (oldpine != PINE & 0xFEFE)
    oldpine = PINE & 0xFEFE;
  if (oldpinf != PINF & 0xFEFE)
    oldpinf = PINF & 0xFEFE;
  if (oldping != PING & 0xFEFE)
    oldping = PING & 0xFEFE;
  if (oldpinh != PINH & 0xFEFE)
    oldpinh = PINH & 0xFEFE;
  if (oldpinj != PINJ & 0xFEFE)
    oldpinj = PINJ & 0xFEFE;
  if (oldpinl != PINL & 0xFEFE)
    oldpinl = PINL & 0xFEFE;
    */

/*
  // takes 3671324 per 10000 loops, or 367 microseconds.
  for (int i =0; i< sizeof(Buttons)/sizeof(Button); ++i)
  {
    Buttons[i].DoButtonStuff();  
  }
  
  */
 
}
