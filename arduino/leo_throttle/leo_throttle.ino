// -----------------------------------------------------
// sketch for knob, selector input.  Maybe some auxilary 
// buttons in the future.
// -----------------------------------------------------

long debounceDelay = 20;
long knobCadence = 30;

class Knob
{
public:
  Knob(char aid, int apin)
  :pin(apin), id(aid), val(0), prevVal(0)
  {}
    
  int pin;
  char id;
  int val;
  int prevVal;

  void DoKnobStuff()
  {  
    val = analogRead(pin);
    if (abs(val-prevVal) > 2) 
    {
      Serial.print('#');      // knob prefix
      Serial.print(id);       // knob id
      Serial.println(val);    // knob value
      prevVal = val;
    }
  }
};

class Button
{
  public:
    Button(int pin, char aprefix, char aup, char adown)
    :buttonPin(pin), prefix(aprefix), up(aup), down(adown)
    {
     prevState = -1;
     lastDebounceTime = 0;
    }  

  char up, down, prefix;
  const int buttonPin;
  int prevState;
  long lastDebounceTime;

  void InitPin()
  {
    pinMode(buttonPin, INPUT);   // digital sensor is on digital pin 2
    digitalWrite(buttonPin, HIGH);
  }

  void DoButtonStuff()
  {  
    int buttonState = digitalRead(buttonPin);
  
    if (buttonState != prevState) 
    {
      if ((millis()-lastDebounceTime) > debounceDelay)
      {
        if (buttonState == HIGH) 
        {
         Serial.print(prefix);
         Serial.println(up);
        }
        else {
         Serial.print(prefix);
         Serial.println(down);
        }
      }
      /*
      else {
         Serial.print(prefix);
         Serial.println('9');
      }
      */
      lastDebounceTime = millis();
      prevState = buttonState;
    }
  }
};

Knob Knobs[3] = {
  Knob('A', A0),
  Knob('B', A1),
  Knob('C', A2)
};

// $ prefix denotes selector knob.
// @ prefix denotes arcade buttons.
Button TheButtons[8] = { 
  Button(2, '$', 'A', 'a'), 
  Button(3, '$', 'B', 'b'), 
  Button(4, '$', 'C', 'c'), 
  Button(5, '$', 'D', 'd'),
  Button(6, '$', 'E', 'e'),
  Button(8, '@', 'A', 'a'),
  Button(9, '@', 'B', 'b'),
  Button(10, '@', 'C', 'c')
};

long lastTransmission = 0;
long now;
int nKnobs = sizeof(Knobs)/sizeof(Knob);
int i; // iterable

void setup()
{
  // start serial port at 115200 bps:
  Serial.begin(115200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  
  for (int i =0; i< sizeof(TheButtons)/sizeof(Button); ++i)
  {
    TheButtons[i].InitPin();  
  }
  
}


void loop()
{

  for (i =0; i< sizeof(TheButtons)/sizeof(Button); ++i)
  {
    TheButtons[i].DoButtonStuff();
  }

  now = millis();
  if (now-lastTransmission>knobCadence)
  {
    for (i=0; i<nKnobs; ++i)
    {
      Knobs[i].DoKnobStuff();
    }
    lastTransmission = now;
  }

}
