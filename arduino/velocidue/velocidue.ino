
unsigned long debouncetime = 65000;


class Key
{
public:

  unsigned long pin1time;
  unsigned long pin2time;
  volatile unsigned long keytime;

  char mCDown, mCUp;

  Key(char down, char up) 
  :mCDown(down), mCUp(up), pin1time(0), pin2time(0), keytime(-1)
  {
  }

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

  void PinCheck()
  {
    if (keytime != -1)
    {
      Serial.print(mCDown);
      Serial.println(keytime);
      keytime = -1;
    }
  }
};

Key Keys[24] = { 
  Key('A', 'a'), //  0 
  Key('B', 'b'), //  1 
  Key('C', 'c'), //  2  
  Key('D', 'd'), //  3  
  Key('E', 'e'), //  4  
  Key('F', 'f'), //  5  
  Key('G', 'g'), //  6  
  Key('H', 'h'), //  7  
  Key('I', 'i'), //  8  
  Key('J', 'j'), //  9   
  Key('K', 'k'), //  10  
  Key('L', 'l'), //  11 
  Key('M', 'm'), //  12
  Key('N', 'n'), //  13
  Key('O', 'o'), //  14 
  Key('P', 'p'), //  15 
  Key('Q', 'q'), //  16 
  Key('R', 'r'), //  17 
  Key('S', 's'), //  18 
  Key('T', 't'), //  19 
  Key('U', 'u'), //  20 
  Key('V', 'v'), //  21 
  Key('W', 'w'), //  22  
  Key('X', 'x')  //  23 
 };

void pinChange2() { Keys[0].pinChange1(); }
void pinChange3() { Keys[0].pinChange2(); }

void pinChange4() { Keys[1].pinChange1(); }
void pinChange5() { Keys[1].pinChange2(); }

void pinChange6() { Keys[2].pinChange1(); }
void pinChange7() { Keys[2].pinChange2(); }

void pinChange8() { Keys[3].pinChange1(); }
void pinChange9() { Keys[3].pinChange2(); }

void pinChange10() { Keys[4].pinChange1(); }
void pinChange11() { Keys[4].pinChange2(); }

void pinChange12() { Keys[5].pinChange1(); }
void pinChange13() { Keys[5].pinChange2(); }

void pinChange14() { Keys[6].pinChange1(); }
void pinChange15() { Keys[6].pinChange2(); }

void pinChange16() { Keys[7].pinChange1(); }
void pinChange17() { Keys[7].pinChange2(); }

void pinChange18() { Keys[8].pinChange1(); }
void pinChange19() { Keys[8].pinChange2(); }

void pinChange20() { Keys[9].pinChange1(); }
void pinChange21() { Keys[9].pinChange2(); }

void pinChange22() { Keys[10].pinChange1(); }
void pinChange23() { Keys[10].pinChange2(); }

void pinChange24() { Keys[11].pinChange1(); }
void pinChange25() { Keys[11].pinChange2(); }

void pinChange26() { Keys[12].pinChange1(); }
void pinChange27() { Keys[12].pinChange2(); }

void pinChange28() { Keys[13].pinChange1(); }
void pinChange29() { Keys[13].pinChange2(); }

void pinChange30() { Keys[14].pinChange1(); }
void pinChange31() { Keys[14].pinChange2(); }

void pinChange32() { Keys[15].pinChange1(); }
void pinChange33() { Keys[15].pinChange2(); }

void pinChange34() { Keys[16].pinChange1(); }
void pinChange35() { Keys[16].pinChange2(); }

void pinChange36() { Keys[17].pinChange1(); }
void pinChange37() { Keys[17].pinChange2(); }

void pinChange38() { Keys[18].pinChange1(); }
void pinChange39() { Keys[18].pinChange2(); }

void pinChange40() { Keys[19].pinChange1(); }
void pinChange41() { Keys[19].pinChange2(); }

void pinChange42() { Keys[20].pinChange1(); }
void pinChange43() { Keys[20].pinChange2(); }

void pinChange44() { Keys[21].pinChange1(); }
void pinChange45() { Keys[21].pinChange2(); }

void pinChange46() { Keys[22].pinChange1(); }
void pinChange47() { Keys[22].pinChange2(); }

void pinChange48() { Keys[23].pinChange1(); }
void pinChange49() { Keys[23].pinChange2(); }

void pinChange50() { Keys[24].pinChange1(); }
void pinChange51() { Keys[25].pinChange2(); }

void InitPin(int pin)
{
    pinMode(pin, INPUT);   // digital sensor is on digital pin 1
    digitalWrite (pin, HIGH);  // internal pull-up resistor
}

void setup ()
{
  // Init pins.  
  int i;
  for (i = 2; i <= 50; ++i)
  {
    InitPin(i);
  }

  // attach interrupt handlers
  attachInterrupt (2, pinChange2, FALLING);  
  attachInterrupt (3, pinChange3, FALLING);  
  attachInterrupt (4, pinChange4, FALLING);  
  attachInterrupt (5, pinChange5, FALLING);  
  attachInterrupt (6, pinChange6, FALLING);  
  attachInterrupt (7, pinChange7, FALLING);  
  attachInterrupt (8, pinChange8, FALLING);  
  attachInterrupt (9, pinChange9, FALLING);  
  attachInterrupt (10, pinChange10, FALLING);  
  attachInterrupt (11, pinChange11, FALLING);  
  attachInterrupt (12, pinChange12, FALLING);  
  attachInterrupt (13, pinChange13, FALLING);  
  attachInterrupt (14, pinChange14, FALLING);  
  attachInterrupt (15, pinChange15, FALLING);  
  attachInterrupt (16, pinChange16, FALLING);  
  attachInterrupt (17, pinChange17, FALLING);  
  attachInterrupt (18, pinChange18, FALLING);  
  attachInterrupt (19, pinChange19, FALLING);  
  attachInterrupt (20, pinChange20, FALLING);  
  attachInterrupt (21, pinChange21, FALLING);  
  attachInterrupt (22, pinChange22, FALLING);  
  attachInterrupt (23, pinChange23, FALLING);  
  attachInterrupt (24, pinChange24, FALLING);  
  attachInterrupt (25, pinChange25, FALLING);  
  attachInterrupt (26, pinChange26, FALLING);  
  attachInterrupt (27, pinChange27, FALLING);  
  attachInterrupt (28, pinChange28, FALLING);  
  attachInterrupt (29, pinChange29, FALLING);  
  attachInterrupt (30, pinChange30, FALLING);  
  attachInterrupt (31, pinChange31, FALLING);  
  attachInterrupt (32, pinChange32, FALLING);  
  attachInterrupt (33, pinChange33, FALLING);  
  attachInterrupt (34, pinChange34, FALLING);  
  attachInterrupt (35, pinChange35, FALLING);  
  attachInterrupt (36, pinChange36, FALLING);  
  attachInterrupt (37, pinChange37, FALLING);  
  attachInterrupt (38, pinChange38, FALLING);  
  attachInterrupt (39, pinChange39, FALLING);  
  attachInterrupt (40, pinChange40, FALLING);  
  attachInterrupt (41, pinChange41, FALLING);  
  attachInterrupt (42, pinChange42, FALLING);  
  attachInterrupt (43, pinChange43, FALLING);  
  attachInterrupt (44, pinChange44, FALLING);  
  attachInterrupt (45, pinChange45, FALLING);  
  attachInterrupt (46, pinChange46, FALLING);  
  attachInterrupt (47, pinChange47, FALLING);  
  attachInterrupt (48, pinChange48, FALLING);  
  attachInterrupt (49, pinChange49, FALLING);  
  attachInterrupt (50, pinChange50, FALLING);  

  Serial.begin(115200);
}  // end of setup

void loop ()
{
  for (int i = 0; i < 24; ++i)
    Keys[i].PinCheck();
} 

