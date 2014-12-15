/*

Copyright (c) 2012, 2013 RedBearLab

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

#include <SPI.h>
#include <boards.h>
#include <RBL_nRF8001.h>
#include "Boards.h"

#define PROTOCOL_MAJOR_VERSION   0x00 //
#define PROTOCOL_MINOR_VERSION   0x00 //
#define PROTOCOL_BUGFIX_VERSION  0x02 // bugfix

int PIN_SWITCH = 4;
int PIN_LED = 2;

int ON = 1;
int OFF = 0;

static byte buf_len = 0;
int MAX_BUF_LEN = 20;

void setup()
{
  Serial.begin(57600);
  Serial.println("BLE Arduino Slave");
  
  pinMode(PIN_SWITCH, INPUT);
  pinMode(PIN_LED, OUTPUT);
  
  digitalWrite(PIN_LED, OFF);
  digitalWrite(PIN_SWITCH, OFF);
  
  // Default pins set to 9 and 8 for REQN and RDYN
  // Set your REQN and RDYN here before ble_begin() if you need
  //ble_set_pins(3, 2);
  
  // Set your BLE Shield name here, max. length 10
  ble_set_name("Rover 5");
  
  // Init. and start BLE library.
  ble_begin();
}

void ble_write_string(byte *bytes, uint8_t len)
{
  if (buf_len + len > MAX_BUF_LEN)
  {
    for (int j = 0; j < 15000; j++) 
    {
      ble_do_events();
    }
    buf_len = 0;
  }
  
  for (int j = 0; j < len; j++)
  {
    ble_write(bytes[j]);
    buf_len++;
  }
    
  if (buf_len == MAX_BUF_LEN)
  {
    for (int j = 0; j < 15000; j++) 
    {
      ble_do_events();
    }
    buf_len = 0;
  }  
}

void process_ble() 
{
  while(ble_available())
  {
    byte cmd;
    cmd = ble_read();
    Serial.print("BLE command recieved: " + cmd);
    Serial.write(cmd);
    
    switch (cmd)
    {
      // Set pin value
      case 'P': 
      {
         byte pin = ble_read();
         byte state = ble_read();
         
         Serial.println("---");
         Serial.print("Changing pin ");
         Serial.write(pin);
         Serial.print(" to ");
         Serial.write(state);
         Serial.println("");
         Serial.println("---");
         
         digitalWrite(pin-'0', state-'0');
         break; 
      }
      case 'V': // query protocol version
        {
          byte buf[] = {'V', PROTOCOL_MAJOR_VERSION, PROTOCOL_MINOR_VERSION, PROTOCOL_BUGFIX_VERSION};
          ble_write_string(buf, 4);
        }
        break;
    }
  } 
  
  ble_do_events();
  buf_len = 0;
}

int timeout = 0;
boolean pin4State = false;

void process_inputs() 
{
  if(digitalRead(PIN_SWITCH) == LOW && timeout == 0) {
    pin4State = true;
    byte buf[] = {'R', '0' + PIN_SWITCH, '0' + 1};
    ble_write_string(buf, 3);
    timeout = 5000;
  } 
  else if (digitalRead(PIN_SWITCH) == HIGH && pin4State == true && timeout == 0) 
  {
    pin4State = false;
    byte buf[] = {'R', '0' + PIN_SWITCH, '0'};
    ble_write_string(buf, 3);
  }
  
  if(timeout > 0) 
  {
    timeout = timeout - 1;  
  }
}

void loop()
{
  process_ble();
  process_inputs(); 
}


