/*------------------------------------------------------------------------/
/  Foolproof MMCv3/SDv1/SDv2 (in SPI mode) control module
/-------------------------------------------------------------------------/
/
/  Copyright (C) 2013, ChaN, all right reserved.
/  Copyright (C) 2024, Ted Fried, Matthieu Bucchianeri
/
/ * This software is a free software and there is NO WARRANTY.
/ * No restriction on use. You can use, modify and redistribute it for
/   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
/ * Redistributions of source code must retain the above copyright notice.
/
/-------------------------------------------------------------------------/
  Features and Limitations:

  * No Media Change Detection
    Application program needs to perform f_mount() after media change.

/-------------------------------------------------------------------------*/

#include <conio.h>

#include "diskio.h"     /* Common include file for FatFs and disk I/O layer */
#include "cprint.h"

/*-------------------------------------------------------------------------*/
/* Platform dependent macros and functions needed to be modified           */
/*-------------------------------------------------------------------------*/

WORD DATAPORT=0x280;
WORD CONTROLPORT=0x282;

#if 1
#define TOUTCHR(x)
#define TOUTHEX(x) 
#define TOUTWORD(x) 
#else
#define TOUTCHR(x) toutchr(x)
#define TOUTHEX(x) touthex(x)
#define TOUTWORD(x) toutword(x)

static BYTE toutchr (unsigned char ch)
{
  _DI = _SI = 0;
  _AL = ch;  _AH = 0xE;  _BX = 0;
  asm  INT  0x10;
  return 0; 
}

static BYTE touthex(unsigned char c)
{
  char d = c >> 4;
  toutchr(d > 9 ? d+('A'-10) : d+'0');
  d = c & 0x0F;
  toutchr(d > 9 ? d+('A'-10) : d+'0');
  return 0;
}

static BYTE toutword(WORD x)
{
  touthex(x >> 8);
  touthex(x);
  return 0;
}

#endif

static
void dly_us (UINT n) 
{
   _CX = n;
   loopit:
   _asm {
      loop loopit
   } 
}

#define NOSHIFT

#ifdef NOSHIFT 

DWORD dwordlshift(DWORD d, int n)
{
   int i;
   WORD a = ((WORD *)d)[0];
   WORD b = ((WORD *)d)[1];
   DWORD r;

   for (i=0;i<n;i++)
   {
      b <<= 1;
      b |= (a & 0x8000) ? 1 : 0;
      a <<= 1;
   }
   ((WORD *)r)[0] = a;
   ((WORD *)r)[1] = b;
   return r;
 }

#define DWORDLSHIFT(d,n) dwordlshift(d,n)

DWORD dwordrshift(DWORD d, int n)
{
   int i;
   WORD a = ((WORD *)d)[0];
   WORD b = ((WORD *)d)[1];
   DWORD r;

   for (i=0;i<n;i++)
   {
      a >>= 1;
      a |= (b & 0x1) ? 0x8000 : 0;
      b >>= 1;
   }
   ((WORD *)r)[0] = a;
   ((WORD *)r)[1] = b;
   return r;
}

#define DWORDRSHIFT(d,n) dwordrshift(d,n)

#else

#define DWORDLSHIFT(d,n) ((d) << (n))
#define DWORDRSHIFT(d,n) ((d) >> (n))

#endif

/*--------------------------------------------------------------------------

   Module Private Functions

---------------------------------------------------------------------------*/

/* MMC/SD command (SPI mode) */
#define CMD0   (0)         /* GO_IDLE_STATE */
#define CMD1   (1)         /* SEND_OP_COND */
#define  ACMD41   (0x80+41)   /* SEND_OP_COND (SDC) */
#define CMD8   (8)         /* SEND_IF_COND */
#define CMD9   (9)         /* SEND_CSD */
#define CMD10  (10)     /* SEND_CID */
#define CMD12  (12)     /* STOP_TRANSMISSION */
#define CMD13  (13)     /* SEND_STATUS */
#define ACMD13 (0x80+13)   /* SD_STATUS (SDC) */
#define CMD16  (16)     /* SET_BLOCKLEN */
#define CMD17  (17)     /* READ_SINGLE_BLOCK */
#define CMD18  (18)     /* READ_MULTIPLE_BLOCK */
#define CMD23  (23)     /* SET_BLOCK_COUNT */
#define  ACMD23   (0x80+23)   /* SET_WR_BLK_ERASE_COUNT (SDC) */
#define CMD24  (24)     /* WRITE_BLOCK */
#define CMD25  (25)     /* WRITE_MULTIPLE_BLOCK */
#define CMD32  (32)     /* ERASE_ER_BLK_START */
#define CMD33  (33)     /* ERASE_ER_BLK_END */
#define CMD38  (38)     /* ERASE */
#define CMD55  (55)     /* APP_CMD */
#define CMD58  (58)     /* READ_OCR */


static
DSTATUS Stat = STA_NOINIT; /* Disk status */

static
BYTE CardType;       /* b0:MMC, b1:SDv1, b2:SDv2, b3:Block addressing */



/*-----------------------------------------------------------------------*/
/* Transmit bytes to the card (bitbanging)                               */
/*-----------------------------------------------------------------------*/

static
void xmit_mmc (
   const BYTE DOSFAR * buff, /* Data to be sent */
   UINT bc                  /* Number of bytes to send */
)
{
   // NOTE: Callers always use buffer sizes multiple of two.
   bc >>= 1;

#ifndef USE186
   _asm {
      mov   cx,bc
      mov   dx,DATAPORT
      push  ds
      lds   si,dword ptr buff
   }
   repeat:
   _asm {
      lodsw
      out   dx, ax
      loop  repeat
      pop   ds
   }
#else
   _asm {
      mov   cx,bc
      mov   dx,DATAPORT
      push  ds
      lds   si,dword ptr buff
      rep   outsw
      pop   ds
   }
#endif
}



/*-----------------------------------------------------------------------*/
/* Receive bytes from the card (bitbanging)                              */
/*-----------------------------------------------------------------------*/

static
void rcvr_mmc (
   BYTE DOSFAR *buff, /* Pointer to read buffer */
   UINT bc            /* Number of bytes to receive */
)
{
   // NOTE: Callers always use buffer sizes multiple of two.
   bc >>= 1;

#ifndef USE186
   _asm {
      mov   cx,bc
      mov   dx,DATAPORT
      push  es
      les   di,dword ptr buff
   }
   repeat:
   _asm {
      in    ax, dx
      stosw
      loop  repeat
      pop   es
   }
#else
   _asm {
      mov   cx,bc
      mov   dx,DATAPORT
      push  es
      les   di,dword ptr buff
      rep   insw
      pop   es
   }
#endif
}

/*-----------------------------------------------------------------------*/
/* Wait for card ready                                                   */
/*-----------------------------------------------------------------------*/

static
int wait_ready (void)   /* 1:OK, 0:Timeout */
{
   BYTE d;
   UINT tmr;


   for (tmr = 5000; tmr; tmr--) {   /* Wait for ready in timeout of 500ms */
      d = inp(DATAPORT);
      if (d == 0xFF) break;
      dly_us(100);
   }

   return tmr ? 1 : 0;
}



/*-----------------------------------------------------------------------*/
/* Deselect the card and release SPI bus                                 */
/*-----------------------------------------------------------------------*/

static
void deselect (void)
{
   outp(CONTROLPORT, 1); // CS high
}



/*-----------------------------------------------------------------------*/
/* Select the card and wait for ready                                    */
/*-----------------------------------------------------------------------*/

static
int select (void) /* 1:OK, 0:Timeout */
{
   BYTE d;

   outp(CONTROLPORT, 0); // CS low

   if (wait_ready()) return 1;   /* OK */
   deselect();
   return 0;         /* Failed */
}



/*-----------------------------------------------------------------------*/
/* Receive a data packet from the card                                   */
/*-----------------------------------------------------------------------*/

static
int rcvr_datablock ( /* 1:OK, 0:Failed */
   BYTE DOSFAR *buff,       /* Data buffer to store received data */
   UINT btr                 /* Byte count */
)
{
   BYTE d;
   UINT tmr;


   for (tmr = 1000; tmr; tmr--) {   /* Wait for data packet in timeout of 100ms */
      d = inp(DATAPORT);
      if (d != 0xFF) break;
      dly_us(100);
   }
   if (d != 0xFE) {
    return 0;      /* If not valid data token, return with error */
   }

   rcvr_mmc(buff, btr);       /* Receive the data block into buffer */
   (void)inp(DATAPORT); (void)inp(DATAPORT); /* Discard CRC */

   return 1;                  /* Return with success */
}



/*-----------------------------------------------------------------------*/
/* Send a data packet to the card                                        */
/*-----------------------------------------------------------------------*/

static
int xmit_datablock ( /* 1:OK, 0:Failed */
   const BYTE DOSFAR *buff, /* 512 byte data block to be transmitted */
   BYTE token               /* Data/Stop token */
)
{
   BYTE d;


   if (!wait_ready()) return 0;

   d = token;
   outp(DATAPORT, d);          /* Xmit a token */
   if (token != 0xFD) {    /* Is it data token? */
      xmit_mmc(buff, 512); /* Xmit the 512 byte data block to MMC */
      (void)inp(DATAPORT); (void)inp(DATAPORT); /* Xmit dummy CRC (0xFF,0xFF) */
      d = inp(DATAPORT);;         /* Receive data response */
      if ((d & 0x1F) != 0x05) /* If not accepted, return with error */
      {
         return 0;
      }
   }

   return 1;
}



/*-----------------------------------------------------------------------*/
/* Send a command packet to the card                                     */
/*-----------------------------------------------------------------------*/

static
BYTE send_cmd (      /* Returns command response (bit7==1:Send failed)*/
   BYTE cmd,      /* Command byte */
   DWORD arg      /* Argument */
)
{
   BYTE n, d, buf[6];

   
   if (cmd & 0x80) { /* ACMD<n> is the command sequense of CMD55-CMD<n> */
      cmd &= 0x7F;
      n = send_cmd(CMD55, 0);
      if (n > 1) return n;
   }

   /* Select the card and wait for ready except to stop multiple block read */
   if (cmd != CMD12) {
      deselect();
      if (!select()) return 0xFF;
   }

   /* Send a command packet */
   buf[0] = 0x40 | cmd;       /* Start + Command index */
 #ifdef NOSHIFT
   buf[1] = ((BYTE *)&arg)[3];      /* Argument[31..24] */
   buf[2] = ((BYTE *)&arg)[2];      /* Argument[23..16] */
   buf[3] = ((BYTE *)&arg)[1];      /* Argument[15..8] */
   buf[4] = ((BYTE *)&arg)[0];      /* Argument[7..0] */
 #else
   buf[1] = (BYTE)(arg >> 24);      /* Argument[31..24] */
   buf[2] = (BYTE)(arg >> 16);      /* Argument[23..16] */
   buf[3] = (BYTE)(arg >> 8);    /* Argument[15..8] */
   buf[4] = (BYTE)arg;           /* Argument[7..0] */
 #endif
   n = 0x01;                  /* Dummy CRC + Stop */
   if (cmd == CMD0) n = 0x95;    /* (valid CRC for CMD0(0)) */
   if (cmd == CMD8) n = 0x87;    /* (valid CRC for CMD8(0x1AA)) */
   buf[5] = n;
   TOUTCHR('L');
   TOUTHEX(buf[0]);
   TOUTHEX(buf[1]);
   TOUTHEX(buf[2]);
   TOUTHEX(buf[3]);
   TOUTHEX(buf[4]);
   TOUTHEX(buf[5]);
   xmit_mmc(buf, 6);

   /* Receive command response */
   if (cmd == CMD12) (void)inp(DATAPORT);  /* Skip a stuff byte when stop reading */
   n = 10;                       /* Wait for a valid response in timeout of 10 attempts */
   do
   {
      d = inp(DATAPORT);
   }
   while ((d & 0x80) && (--n));
      TOUTCHR('P');
      TOUTHEX(d);
   return d;         /* Return with the response value */
}



/*--------------------------------------------------------------------------

   Public Functions

---------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------*/
/* Get Disk Status                                                       */
/*-----------------------------------------------------------------------*/

DSTATUS disk_status (
   BYTE drv       /* Drive number (always 0) */
)
{
   if (drv) return STA_NOINIT;
   return Stat;
}

DRESULT disk_result (
   BYTE drv       /* Drive number (always 0) */
)
{
   if (drv) return RES_NOTRDY;
   return RES_OK;
}


/*-----------------------------------------------------------------------*/
/* Initialize Disk Drive                                                 */
/*-----------------------------------------------------------------------*/

DSTATUS disk_initialize (
   BYTE drv    /* Physical drive nmuber (0) */
)
{
   BYTE n, ty, cmd, buf[4];
   UINT tmr;
   DSTATUS s;

   if (drv) return RES_NOTRDY;

   ty = 0;
   for (n = 5; n; n--) {
      outp(CONTROLPORT, 1); // CS high
      dly_us(10000);       /* 10ms. time for SD card to power up */
      for (tmr = 10; tmr; tmr--) outp(DATAPORT, 0xFF); /* Apply 80 dummy clocks and the card gets ready to receive command */
      if (send_cmd(CMD0, 0) == 1) {       /* Enter Idle state */
         if (send_cmd(CMD8, 0x1AA) == 1) {   /* SDv2? */
            rcvr_mmc(buf, 4);                   /* Get trailing return value of R7 resp */
            if (buf[2] == 0x01 && buf[3] == 0xAA) {      /* The card can work at vdd range of 2.7-3.6V */
               for (tmr = 1000; tmr; tmr--) {         /* Wait for leaving idle state (ACMD41 with HCS bit) */
                  if (send_cmd(ACMD41, 1UL << 30) == 0) break;
                  dly_us(1000);
               }
               if (tmr && send_cmd(CMD58, 0) == 0) {  /* Check CCS bit in the OCR */
                  rcvr_mmc(buf, 4);
                  ty = (buf[0] & 0x40) ? CT_SD2 | CT_BLOCK : CT_SD2; /* SDv2 */
               }
            }
         } else {                   /* SDv1 or MMCv3 */
            if (send_cmd(ACMD41, 0) <= 1)    {
               ty = CT_SD1; cmd = ACMD41; /* SDv1 */
            } else {
               ty = CT_MMC; cmd = CMD1;   /* MMCv3 */
            }
            for (tmr = 1000; tmr; tmr--) {         /* Wait for leaving idle state */
               if (send_cmd(cmd, 0) == 0) break;
               dly_us(1000);
            }
            if (!tmr || send_cmd(CMD16, 512) != 0) /* Set R/W block length to 512 */
               ty = 0;
         }
         break;
      }
   }
   CardType = ty;
   s = ty ? 0 : STA_NOINIT;
   Stat = s;

   deselect();

   return s;
}



/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */
/*-----------------------------------------------------------------------*/

DRESULT disk_read (
   BYTE drv,            /* Physical drive nmuber (0) */
   BYTE DOSFAR *buff,   /* Pointer to the data buffer to store read data */
   DWORD sector,        /* Start sector number (LBA) */
   UINT count           /* Sector count (1..128) */
)
{
   DRESULT dr = disk_result(drv);
   if (dr != RES_OK) return dr;
   
   if (!(CardType & CT_BLOCK)) sector = DWORDLSHIFT(sector,9);   /* Convert LBA to byte address if needed */

   if (count == 1) { /* Single block read */
      if ((send_cmd(CMD17, sector) == 0)  /* READ_SINGLE_BLOCK */
         && rcvr_datablock(buff, 512))
         count = 0;
   }
   else {            /* Multiple block read */
      if (send_cmd(CMD18, sector) == 0) { /* READ_MULTIPLE_BLOCK */
         do {
            if (!rcvr_datablock(buff, 512)) break;
            buff += 512;
         } while (--count);
         send_cmd(CMD12, 0);           /* STOP_TRANSMISSION */
      }
   }
   deselect();

   return count ? RES_ERROR : RES_OK;
}



/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */
/*-----------------------------------------------------------------------*/

DRESULT disk_write (
   BYTE drv,                /* Physical drive nmuber (0) */
   const BYTE DOSFAR *buff, /* Pointer to the data to be written */
   DWORD sector,            /* Start sector number (LBA) */
   UINT count               /* Sector count (1..128) */
)
{
   DRESULT dr = disk_result(drv);
   if (dr != RES_OK) return dr;

   if (!(CardType & CT_BLOCK)) sector = DWORDLSHIFT(sector,9);   /* Convert LBA to byte address if needed */
   
   if (count == 1) { /* Single block write */
      if ((send_cmd(CMD24, sector) == 0)  /* WRITE_BLOCK */
         && xmit_datablock(buff, 0xFE))
         count = 0;
   }
   else {            /* Multiple block write */
      if (CardType & CT_SDC) send_cmd(ACMD23, count); 
      if (send_cmd(CMD25, sector) == 0) { /* WRITE_MULTIPLE_BLOCK */
         do {
            if (!xmit_datablock(buff, 0xFC)) break;
            buff += 512;
         } while (--count);
         if (!xmit_datablock(0, 0xFD)) /* STOP_TRAN token */
            count = 1;
         if (!wait_ready()) count = 1;   /* Wait for card to write */
      }
   }
   deselect();

   return count ? RES_ERROR : RES_OK;
}


/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/

DRESULT disk_ioctl (
   BYTE drv,             /* Physical drive nmuber (0) */
   BYTE ctrl,            /* Control code */
   void DOSFAR *buff     /* Buffer to send/receive control data */
)
{
   DRESULT res;
   BYTE n, csd[16];
   DWORD cs;
   DRESULT dr = disk_result(drv);
   if (dr != RES_OK) return dr;

   res = RES_ERROR;
   switch (ctrl) {
      case CTRL_SYNC :     /* Make sure that no pending write process */
         if (select()) res = RES_OK;
         break;

      case GET_SECTOR_COUNT : /* Get number of sectors on the disk (DWORD) */
         if ((send_cmd(CMD9, 0) == 0) && rcvr_datablock(csd, 16)) {
            if ((csd[0] >> 6) == 1) {  /* SDC ver 2.00 */
               cs = csd[9] + ((WORD)csd[8] << 8) + ((DWORD)(csd[7] & 63) << 16) + 1;
               *(DWORD DOSFAR *)buff = DWORDLSHIFT(cs,10);
            } else {             /* SDC ver 1.XX or MMC */
               n = (csd[5] & 15) + ((csd[10] & 128) >> 7) + ((csd[9] & 3) << 1) + 2;
               cs = (csd[8] >> 6) + ((WORD)csd[7] << 2) + ((WORD)(csd[6] & 3) << 10) + 1;
               *(DWORD DOSFAR *)buff = DWORDLSHIFT(cs,n-9);
            }
            res = RES_OK;
         }
         break;

      case GET_BLOCK_SIZE :   /* Get erase block size in unit of sector (DWORD) */
         *(DWORD DOSFAR *)buff = 128;
         res = RES_OK;
         break;

      default:
         res = RES_PARERR;
   }

   deselect();

   return res;
}


