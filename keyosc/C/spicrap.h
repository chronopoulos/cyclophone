#ifndef spicrap_h
#define spicrap_h

enum SPIThing8
{
  RD_MODE,
  WR_MODE,                 
  RD_LSB_FIRST,           
  WR_LSB_FIRST,          
  RD_BITS_PER_WORD,     
  WR_BITS_PER_WORD    
};

typedef enum SPIThing8 SPIThing8;

enum SPIThing32
{
  RD_MAX_SPEED_HZ,    
  WR_MAX_SPEED_HZ   
};

typedef enum SPIThing32 SPIThing32;

unsigned int GetSPICrap8(SPIThing8 aSpit);
unsigned int GetSPICrap32(SPIThing32 aSpit);


#endif
