#include "Charliplexing.h"

uint8_t x = 0;
uint8_t y = 0;

void setup()                    // run once, when the sketch starts
{
    LedSign::Init(GRAYSCALE);// | DOUBLEBUFFER);
    Serial.begin(9600);
}

void loop()                     // run over and over again
{ 
  // Append each byte to the delay value integer.
  //0,1,2,3,5,7 seem to be the best differences
  uint8_t value = 0;
  //for each byte in the buffer
  while(Serial.available()){//for(uint8_t avail = Serial.available(); avail--; avail > 0){
    //use it to set the brightness of the current pixel
    value = Serial.read();
    if (value >= '0'){
      value -= '0';
    }
    if (value == 10){
      x = 0;
      y = 0;
    } else {
      LedSign::Set(x,y,value);
      incPixel();
    }
  }
}

void incPixel(){
  x++;
  if (x >= 14){
    x = 0;
    y++;
    if (y >= 9){
      y = 0;
    }
  }
}
