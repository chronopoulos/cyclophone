const byte LED = 13;
const byte BUTTON1 = 2;
const byte BUTTON2 = 3;

unsigned long pin1time = 0;
unsigned long pin2time = 0;
volatile unsigned long keytime = -1;

unsigned long debouncetime = 20000;

// Interrupt Service Routine (ISR)
void pinChange1 ()
{
  unsigned long newtime = micros();
  if (newtime - pin1time > debouncetime)
     pin1time = newtime;
  
}  // end of pinChange

void pinChange2 ()
{
  unsigned long newtime = micros();
  if (newtime - pin2time > debouncetime && pin1time != 0)
  {
     pin2time = newtime;
     keytime = pin2time - pin1time;
     pin1time = 0;
  }
}  // end of pinChange

void setup ()
{
  pinMode (LED, OUTPUT);  // so we can update the LED
  pinMode(BUTTON1, INPUT);   // digital sensor is on digital pin 1
  digitalWrite (BUTTON1, HIGH);  // internal pull-up resistor
  pinMode(BUTTON2, INPUT);   // digital sensor is on digital pin 1
  digitalWrite (BUTTON2, HIGH);  // internal pull-up resistor
  attachInterrupt (0, pinChange1, FALLING);  // attach interrupt handler
  attachInterrupt (1, pinChange2, FALLING);  // attach interrupt handler
  Serial.begin(230400);
}  // end of setup

void loop ()
{
  if (keytime != -1)
  {
    Serial.println(keytime);
    keytime = -1;
  }
} 

