
SD card driver for parallel port

I wrote this to simplify data transfer between my IBM PC and my laptop, because my laptop does
not have a 360k floppy drive but does have an SD card slot.

WARNING:  I take **no responsibility** for any damage to your computer, parallel port, or SD
card, or any data.  You use this driver at your own risk.   It is highly recommended you use
an expendable parallel port card with your expendable SD card, and your expendable data.
It is recommended that you use a level converter IC with between your 5 volt parallel port
outputs and the SD card 3.3 volt inputs.  This project is intended as a fun hack for hobbyists
and enthusiasts and not for serious work.

This driver is made available under the GNU General Public License version 2.  It incorporates
modified code from ELM Chan Fat FS (http://elm-chan.org/fsw/ff/00index_e.html).

Usage:

In your config.sys file

DEVICE=SD.SYS /d /k /p=<partition #> /b=<port base index>

Loads and installs the SD card driver.

/d = debugging mode (displays copious debugging messsages)
/k = use card detect signal to inform dos that card is attached
/p = partition number (1-4) to partition in MBR to use.  Default: first available.
/b = port base index of parallel port, one of
     1=0x3BC, 2=0x378, 3=0x278, 4=0x3E8, 5=0x2E8
     Default: 0x378

For best results, format your SD card with a FAT16 partition which is less than 32 MB in size.
NOTE:  Many versions of DOS don't know how to handle FAT32, and many can't have FAT16 with a 
partition size greater than 32 MB.  Therefore, if you want to play with this, make your parition on
the card FAT16 and less than 32 MB.  This assures the best compatibility.  You can have multiple copies of the 
driver loaded if there are multiple partitions on your SD card you want to use simultaneously.
     
I have used Adafruit's microSD adapter
 (http://www.adafruit.com/products/254?gclid=CLH7l4iEkrwCFQPNOgod7BkAQA)
if you want a relatively simple way to interface your PC parallel port to 
the SD card.  The adapter provides the 3.3 volts needed to power the SD card, as well
as a the level shifting between the 5 volt parallel port output and the 3.3 volt input.
If you directly connect a 5 volt output to a 3.3 volt input, you risk latching up the
3.3 volt input and damaging the card or computer from exceesive current.
Some have used series resistors instead of the level converters, but I found this
to not be that reliable and still may have this problem.  Also, some SD cards MISO/DO
outputs are unable to drive a TTL input of some parallel ports, so you may need to add
a buffer between the two as well.  I have found quite a bit of variability in the drive
current required for the inputs of various parallel ports.

The driver uses the very slow serial peripheral interface (SPI) mode of the SD card.  The
speed, which depends on your PC speed, could be as slow as 10 kilobytes/second.  This is 
not a replacement for your hard drive.  Your parallel port should be configured for standard
mode (not bidirectional) if applicable.

The connections between the parallel port and the SD card are as follows:

Parallel port          SD card

PIN 25 signal GND      GND (Vss)
+3.3V                  Vdd (power)
PIN 2 signal D0        CMD / MOSI / DI (SPI data in)
PIN 3 signal D1        SCLK / CLK (SPI clock)
PIN 4 signal D2        DAT3 / CS (SPI chip select)
PIN 13 signal SELECT   DAT0 / MISO / DO (SPI data out)
PIN 11 signal BUSY     Card detect (if you SD card slot has one)

For similar setups, look up parallel port to JTAG adapters which are used for in circuit
programming and debugging.

Good luck and be careful!

