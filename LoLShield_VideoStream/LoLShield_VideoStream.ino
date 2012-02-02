/*
 Super-simple LoL Shield "breathe" fading test
 Written by Thilo Fromm <kontakt@thilo-fromm.de>.

 Writen for the LoL Shield, designed by Jimmie Rodgers:
 http://jimmieprodgers.com/kits/lolshield/

 This is free software; you can redistribute it and/or
 modify it under the terms of the GNU Version 3 General Public
 License as published by the Free Software Foundation; 
 or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

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
  for(uint8_t avail = Serial.available(); avail--; avail > 0){
    //use it to set the brightness of the current pixel
    value = Serial.read();
    if (value >= '0'){
      value -= '0';
    }
    LedSign::Set(x,y,value);
    incPixel();
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
