# XTMax Firmware

## Prerequisites

This procedure assumes a modern Windows operating system.

Please follow the instructions to download and [install Teensyduino](https://www.pjrc.com/teensy/td_download.html) (which is two programs: the Arduino IDE and the Teensy board support package).

## Building and deploying

1) Open the Arduino IDE and load the `XTMax.ino` file.

2) Under `Tools` -> `Board` select `Teensy` then `Teensy 4.1`.

3) Under `Tools` -> `Optimize` select `Fastest`.

4) Under `Tools` -> `CPU Speed` select `912 MHz`.

5) Connect your Teensy via USB. **It is recommended that you remove the Teensy from the XTMax or remove the XTMax from the host ISA computer to avoid back-driving from USB.**

6) Under `Sketch` select `Upload`.

7) Put the Teensy and/or XTMax back into the host ISA compute and enjoy!

## Using XTMax and its drivers

See [these instructions](../../Drivers/README.md).