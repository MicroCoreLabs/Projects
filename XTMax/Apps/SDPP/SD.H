/* sd.h - SD card driver glue */

#ifndef _SD_H
#define _SD_H

#include "integer.h"
#include "driver.h"

#define BLOCKSIZE 512

extern DWORD partition_offset;

/* SDInitialize - establish two way communications with the drive */
BOOLEAN SDInitialize (BYTE unit, BYTE partno, bpb_t *bpb);
/* SDRead - read one 512 byte logical block from the tape */
int SDRead (WORD, DWORD, BYTE far *, WORD count);
/* SDWrite - write one 512 byte logical block to the tape */
int SDWrite (WORD, DWORD, BYTE far *, WORD count);
/* SDMediaCheck - check if media changed */
BOOLEAN SDMediaCheck (BYTE unit);

#endif
