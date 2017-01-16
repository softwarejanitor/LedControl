require("SPI");

dofile("sd:/LedControl.nut");

/*
 Now we need a LedControl to work with.
 SPI bus number on Esquilo
 ***** Please set the number of devices you have *****
 But the maximum default of 8 MAX72XX wil also work.
 */
local lc = LedControl(0, 1);

/* we always wait a bit between updates of the display */
local delaytime = 500;

/*
 This time we have more than one device.
 But all of them have to be initialized
 individually.
 */

// we have already set the number of devices when we created the LedControl
local devices = lc.getDeviceCount();
// we have to init all devices in a loop
local address;
for (address = 0; address < devices; address++) {
    /*The MAX72XX is in power-saving mode on startup*/
    lc.shutdown(address, false);
    /* Set the brightness to a medium values */
    lc.setIntensity(address, 8);
    /* and clear the display */
    lc.clearDisplay(address);
}

local row;
local col;
while (1) {
  // we have to init all devices in a loop
  for (row = 0; row < 8; row++) {
    for(col = 0; col < 8; col++) {
      for (address = 0; address < devices; address++) {
        delay(delaytime);
        lc.setLed(address, row, col, true);
        delay(delaytime);
        lc.setLed(address, row, col, false);
      }
    }
  }
}

