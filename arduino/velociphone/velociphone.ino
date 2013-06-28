

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

class Button
{
  public:
    Button(int pin1, int pin2, char aprefix, char aup, char adown)
    :buttonPin1(pin1), buttonPin2(pin2), 
    prefix(aprefix), up(aup), down(adown)
    {
     prevState1 = -1;
     lastDebounceTime1 = 0;
     prevState2 = -1;
     lastDebounceTime2 = 0;
    }  

  char up, down, prefix;
  const int buttonPin1;
  const int buttonPin2;
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
    int buttonState1 = digitalRead(buttonPin1);
  
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

    int buttonState2 = digitalRead(buttonPin2);
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
        else {
         //Serial.print(prefix);
         //Serial.println(down);
        }
      }
      else {
         Serial.print(prefix);
         Serial.println("9B");
      }
      lastDebounceTime2 = millis();
      prevState2 = buttonState2;
    }
  }
};

Button Buttons[24] = { 
  /*
  Button(2, 3, 'K', 'C', 'c'), 
  Button(3, 4, 'K', 'D', 'd'), 
  Button(5, 6, 'K', 'E', 'e'), 
  Button(7, 8, 'K', 'F', 'f'), 
  Button(9, 10, 'K', 'G', 'g'), 
  Button(11, 12, 'K', 'H', 'h:'), 
  */

  Button(26, 51, 'K', 'A', 'a'), 
  Button(27, 52, 'K', 'B', 'b'), 
  Button(2, 29, 'K', 'C', 'c'), 
  Button(3, 30, 'K', 'D', 'd'),
  Button(4, 31, 'K', 'E', 'e'),
  Button(5, 32, 'K', 'F', 'f'),
  Button(6, 33, 'K', 'G', 'g'),
  Button(7, 34, 'K', 'H', 'h'),
  Button(8, 35, 'K', 'I', 'i'),
  Button(9, 36, 'K', 'J', 'j'),
  Button(10, 37, 'K', 'K', 'k'),
  Button(11, 38, 'K', 'L', 'l'), 
  Button(12, 39, 'K', 'M', 'm'), 
  Button(13, 40, 'K', 'N', 'n'), 
  Button(14, 41, 'K', 'O', 'o'),
  Button(15, 42, 'K', 'P', 'p'),
  Button(16, 43, 'K', 'Q', 'q'),
  Button(17, 44, 'K', 'R', 'r'),
  Button(18, 45, 'K', 'S', 's'),
  Button(19, 46, 'K', 'T', 't'),
  Button(20, 47, 'K', 'U', 'u'),
  Button(21, 48, 'K', 'V', 'v'),
  Button(22, 49, 'K', 'W', 'w'),
  Button(24, 50, 'K', 'X', 'x')
};

Button Selector[0] = { 
/*  Button(30, 'S', 'A', 'a'), 
  Button(31, 'S', 'B', 'b'), 
  Button(32, 'S', 'C', 'c'), 
  Button(33, 'S', 'D', 'd'),
  Button(34, 'S', 'E', 'e') */
};

void setup()
{
  // start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  
  for (int i =0; i< sizeof(Buttons)/sizeof(Button); ++i)
  {
    Buttons[i].InitPin();  
  }
  

  for (int i =0; i< sizeof(Selector)/sizeof(Button); ++i)
  {
    Selector[i].InitPin();  
  }

  
}

int count = 0;
unsigned long time1 = 0;
unsigned char oldpina, oldpinb, oldpinc, oldpind, oldpine;
unsigned char oldpinf, oldping, oldpinh, oldpinj, oldpinl;

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

  // takes 3671324 per 10000 loops, or 367 microseconds.
  for (int i =0; i< sizeof(Buttons)/sizeof(Button); ++i)
  {
    Buttons[i].DoButtonStuff();  
  }
  
  
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
