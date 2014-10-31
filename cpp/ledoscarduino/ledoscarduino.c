#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <sstream>
#include <lo/lo.h>
#include <fcntl.h>
#include <termios.h>
#include <string.h>

#include <unistd.h>
 


using namespace std;


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

int tty_fd;


// --------------------------------------------------------------------

void  loErrHandler(int num, const char *msg, const char *where)
{
  cout << "lo lib error: " << num << " : " << msg << "\n" << where << endl;
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

      char buf[33];
      sprintf(buf, "%d", index);
      // if (read(STDIN_FILENO,&c,1)>0)  
      write(tty_fd,&buf,strlen(buf));
      write(tty_fd," ", 1);
      
      sprintf(buf, "%d", color);
      write(tty_fd,&buf,strlen(buf));
      write(tty_fd,"\n", 1);

      // send out to serial port.      
      // strip.setPixelColor(index, color);
      // if (read(STDIN_FILENO,&c,1)>0)  write(tty_fd,&c,1);
    }
      
    printf("\n");
    fflush(stdout);

    return 1;
}

void oscloop() {

  cout << "oscledserver started!" << endl;

  lo_server loserver = lo_server_new("8086", loErrHandler);
  // lo_method lomethod1 = lo_server_add_method (loserver, 0, 0, generic_handler, 0);
  lo_method lomethod2 = lo_server_add_method (loserver, "led", 0, led_handler, 0);

  while (true)
  {
    lo_server_recv(loserver);
  }
}

int main(int argc,char** argv)
{
  // serial port stuff.
  struct termios tio;
  struct termios stdio;
  struct termios old_stdio;

  unsigned char c='D';

  /*
  // code to 'take over' std input and output.

  tcgetattr(STDOUT_FILENO,&old_stdio);

  printf("Please start with %s /dev/ttyS1 (for example)\n",argv[0]);
  memset(&stdio,0,sizeof(stdio));
  stdio.c_iflag=0;
  stdio.c_oflag=0;
  stdio.c_cflag=0;
  stdio.c_lflag=0;
  stdio.c_cc[VMIN]=1;
  stdio.c_cc[VTIME]=0;
  tcsetattr(STDOUT_FILENO,TCSANOW,&stdio);
  tcsetattr(STDOUT_FILENO,TCSAFLUSH,&stdio);
  fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK);       // make the reads non-blocking
  */

  memset(&tio,0,sizeof(tio));
  tio.c_iflag=0;
  tio.c_oflag=0;
  tio.c_cflag=CS8|CREAD|CLOCAL;           // 8n1, see termios.h for more information
  tio.c_lflag=0;
  tio.c_cc[VMIN]=1;
  tio.c_cc[VTIME]=5;

  tty_fd=open(argv[1], O_RDWR | O_NONBLOCK);      
  cfsetospeed(&tio,B115200);            // 115200 baud
  cfsetispeed(&tio,B115200);            // 115200 baud

  tcsetattr(tty_fd,TCSANOW,&tio);

  oscloop();

  /*
  printf("hit 'q' to x-it");
  while (c!='q')
  {
      // if new data is available on the serial port, print it out
      if (read(tty_fd,&c,1)>0)
        write(STDOUT_FILENO,&c,1);              
      // if new data is available on the console, send it to the serial port
      // if (read(STDIN_FILENO,&c,1)>0)  write(tty_fd,&c,1);
      // printf("blah");
  }
  */

  close(tty_fd);
  // tcsetattr(STDOUT_FILENO,TCSANOW,&old_stdio);


  return EXIT_SUCCESS;
}
