// -----------------------------------------------------
// sketch for knob, selector input.  Maybe some auxilary 
// buttons in the future.
// -----------------------------------------------------

long debounceDelay = 20;

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
      else {
         Serial.print(prefix);
         Serial.println('9');
      }
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

Button Selector[5] = { 
  Button(30, 'S', 'A', 'a'), 
  Button(31, 'S', 'B', 'b'), 
  Button(32, 'S', 'C', 'c'), 
  Button(33, 'S', 'D', 'd'),
  Button(34, 'S', 'E', 'e')
};

void setup()
{
  // start serial port at 115200 bps:
  Serial.begin(115200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  
  for (int i =0; i< sizeof(Selector)/sizeof(Button); ++i)
  {
    Selector[i].InitPin();  
  }
  
}


void loop()
{

  for (int i =0; i< sizeof(Selector)/sizeof(Button); ++i)
  {
    Selector[i].DoButtonStuff();  
  }

  for (int i =0; i< sizeof(Knobs)/sizeof(Knob); ++i)
  {
    Knobs[i].DoKnobStuff();  
  }

}
