SD card driver for XTMax

This driver is based on SDPP cloned from https://github.com/nilseuropa/sdpp.

The original driver is made available under the GNU General Public License version 2.  It incorporates
modified code from ELM Chan Fat FS (http://elm-chan.org/fsw/ff/00index_e.html).

Usage:

In your config.sys file

DEVICE=SD.SYS /d /p=<partition #>

Loads and installs the SD card driver.

/d = debugging mode (displays copious debugging messsages)
/p = partition number (1-4) to partition in MBR to use.  Default: first available.

For best results, format your SD card with a FAT16 partition which is less than 32 MB in size.
NOTE:  Many versions of DOS don't know how to handle FAT32, and many can't have FAT16 with a 
partition size greater than 32 MB.  Therefore, if you want to play with this, make your parition on
the card FAT16 and less than 32 MB.  This assures the best compatibility.  You can have multiple copies of the 
driver loaded if there are multiple partitions on your SD card you want to use simultaneously.
