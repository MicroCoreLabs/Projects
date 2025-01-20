/* driver.c - MSDOS device driver functions           */
/*                         */
/* Copyright (C) 1994 by Robert Armstrong          */
/* Copyright (C) 2024 by Ted Fried, Matthieu Bucchianeri          */
/*                         */
/* This program is free software; you can redistribute it and/or modify */
/* it under the terms of the GNU General Public License as published by */
/* the Free Software Foundation; either version 2 of the License, or */
/* (at your option) any later version.             */
/*                         */
/* This program is distributed in the hope that it will be useful, but  */
/* WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANT- */
/* ABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General */
/* Public License for more details.             */
/*                         */
/* You should have received a copy of the GNU General Public License */
/* along with this program; if not, visit the website of the Free */
/* Software Foundation, Inc., www.gnu.org.            */


#include <stdio.h>      /* NULL, etc...            */
#include <dos.h>        /* used only for MK_FP !      */
#include "standard.h"   /* definitions for this project     */
#include "sd.h"         /* SD card glue */
#include "diskio.h"     /* SD card library header */
#include "driver.h"     /* MSDOS device driver interface */
#include "cprint.h"     /* Console printing */


#define FORM_FACTOR  8  /* DOS form factor code used for SD */


/* Forward declarations for routines that need it... */
PRIVATE BOOLEAN parse_options (char far *);
PUBLIC void Initialize (rh_init_t far *);
PUBLIC void far SDDriver (rh_t far *);


/* These data structures are exported by the HEADER.ASM module... */
extern devhdr_t header;    /* MSDOS device header for our driver  */
extern bpb_t bpb;          /* BIOS Parameter block "   "   "   */
extern bpbtbl_t bpbtbl;    /* BPB table (one for each drive unit) */

/*   This double word is actually a far pointer to the entry point of   */
/* this module. It's called by the assembly interface whenver DOS needs */
/* driver action.  The second word of the far pointer contains the seg- */
/* ment address, which is actually computed and written by the assembly */
/* code.                      */
PUBLIC WORD c_driver[2] = {(WORD) &SDDriver, 0};

extern unsigned char com_flag;

/* Local data for this module... */
BOOLEAN Debug        = FALSE; /* TRUE to enable debug (verbose) mode */
BOOLEAN InitNeeded   = TRUE;  /* TRUE if we need to (re) initialize  */
WORD  RebootVector[2];  /* previous INT 19H vector contents */
extern DWORD partitionoffset;

BYTE partition_number;

/* fmemcpy */
/*   This function is equivalent to the C RTL _fmemcpy routine. We have */
/* to define it here because BPC is unable to generate inline code for  */
/* _fmemcpy (although it can generate equivalent code for memcpy!).  */
void fmemcpy (void far *dst, void far *src, WORD n)
{
  _asm {
   les   di,dword ptr dst
   mov   dx,word ptr src+2
   mov   si,word ptr src
   mov   cx,n
   push  ds
   mov   ds,dx
   rep   movsb
   pop   ds
  }
}

/* fmemset */
/*    This is the equivalent to _fmemset.  It is here for exactly the   */
/* same reasons as fmemcpy !!!                  */
void fmemset (void far *dst, BYTE c, WORD n)
{
  _asm {
   mov   al,c
   les   di,dword ptr dst
   mov   cx,n
   rep   stosb
  }
}


/* Media Check */
/*   DOS calls this function to determine if the tape in the drive has  */
/* been changed.  The SD hardware can't determine this (like many  */
/* older 360K floppy drives), and so we always return the "Don't Know"  */
/* response.  This works well enough...               */
PUBLIC void MediaCheck (rh_media_check_t far *rh)
{
  if (Debug) cdprintf("SD: media check: unit=%d\n", rh->rh.unit);
  rh->media_status = SDMediaCheck(rh->rh.unit) ? -1 : 0;
  rh->rh.status = DONE;
}


/* Build BPB */
/*   DOS uses this function to build the BIOS parameter block for the   */
/* specified drive.  For diskettes, which support different densities   */
/* and formats, the driver actually has to read the BPB from the boot   */
/* sector on the disk.  */
PUBLIC void BuildBPB (rh_get_bpb_t far *rh)
{
  if (Debug)
      cdprintf("SD: build BPB: unit=%d\n", rh->rh.unit);
  rh->bpb = &bpb;
  rh->rh.status = DONE;
}


/* Get Parameters */
/*   This routine implements the Get Parameters subfunction of the DOS  */
/* Generic IOCTL call. It gets a pointer to the device paramters block, */
/* which it then fills in.  We do NOT create the track/sector map that  */
/* is defined by recent DOS manuals to be at the end of the block - it  */
/* never seems to be used...                 */
PUBLIC void GetParameters (device_params_t far *dp)
{
  dp->form_factor = FORM_FACTOR;  dp->attributes = 0;  dp->media_type = 0;
  dp->cylinders = bpb.total_sectors / (bpb.track_size * bpb.head_count);
  fmemcpy(&(dp->bpb), &bpb, sizeof(bpb_t));
}

/* dos_error */
/*   This routine will translate a SD error code into an appropriate  */
/* DOS error code.  This driver never retries on any error condition.   */
/* For actual tape read/write errors it's pointless because the drive   */
/* will have already tried several times before reporting the failure.  */
/* All the other errors (e.g. write lock, communications failures, etc) */
/* are not likely to succeed without user intervention, so we go thru   */
/* the usual DOS "Abort, Retry or Ignore" dialog. Communications errors */
/* are a special situation.  In these cases we also set global flag to  */
/* force a controller initialization before the next operation.      */
int dos_error (int status)
{
  switch (status) {
    case RES_OK:     return 0;
    case RES_WRPRT:  return WRITE_PROTECT;
    case RES_NOTRDY: InitNeeded= TRUE; return NOT_READY;
    case RES_ERROR:  InitNeeded= TRUE; return BAD_SECTOR;
    case RES_PARERR: return CRC_ERROR;

    default:
    cdprintf("SD: unknown drive error - status = 0x%2x\n", status);
        return GENERAL_FAILURE;
  }
}


/* drive_init */
/*   This routine should be called before every I/O function.  If the   */
/* last I/O operation resulted in a protocol error, then this routine   */
/* will re-initialize the drive and the communications.  If the drive   */
/* still won't talk to us, then it will set a general failure code in   */
/* the request header and return FALSE.               */
BOOLEAN drive_init (rh_t far *rh)
{
  if (!InitNeeded)  return TRUE;
  if (!SDInitialize(rh->unit, partition_number, &bpb)) {
    if (Debug)  cdprintf("SD: drive failed to initialize\n");
    rh->status = DONE | ERROR | GENERAL_FAILURE;
    return FALSE;
  }
  InitNeeded = FALSE;
  if (Debug) cdprintf("SD: drive initialized\n");
  return TRUE;
}


/* Read Data */
PUBLIC void ReadBlock (rh_io_t far *rh)
{
  DWORD lbn;
  WORD count;  int status;  BYTE far *dta;
  WORD sendct;
  if (Debug)
    cdprintf("SD: read block: unit=%d, start=%d, count=%d, dta=%4x:%4x\n",
      rh->rh.unit, rh->start, rh->count, FP_SEG(rh->dta), FP_OFF(rh->dta));
  if (!drive_init ((rh_t far *) rh))  return;
  count = rh->count,  lbn = rh->start,  dta = rh->dta;
  lbn = (rh->start == 0xFFFF) ? rh->longstart : rh->start;
  while (count > 0) {
      sendct = (count > 16) ? 16 : count;
      status = SDRead(rh->rh.unit, lbn, dta, sendct);
      if (status != RES_OK)  {
   if (Debug) cdprintf("SD: read error - status=%d\n", status);
   fmemset(dta, 0, BLOCKSIZE);
   rh->rh.status = DONE | ERROR | dos_error(status);
   return;
      }
    lbn += sendct;
    count -= sendct;
    dta += (sendct*BLOCKSIZE);
  }
  rh->rh.status = DONE;
}


/* Write Data */
/* Write Data with Verification */
PUBLIC void WriteBlock (rh_io_t far *rh, BOOLEAN verify)
{
  DWORD lbn;
  WORD count;  int status;  BYTE far *dta;
  WORD sendct;
  if (Debug)
    cdprintf("SD: write block: unit=%d, start=%d, count=%d, dta=%4x:%4x\n",
      rh->rh.unit, rh->start, rh->count, FP_SEG(rh->dta), FP_OFF(rh->dta));
  if (!drive_init ((rh_t far *) rh))  return;
  count = rh->count,  dta = rh->dta;
  lbn = (rh->start == 0xFFFF) ? rh->longstart : rh->start;
  while (count > 0) {
    sendct = (count > 16) ? 16 : count;
    status = SDWrite(rh->rh.unit, lbn, dta, sendct);
    if (status != RES_OK)  {
      if (Debug) cdprintf("SD: write error - status=%d\n", status);
      rh->rh.status = DONE | ERROR | dos_error(status);
      return;
    }
    lbn += sendct;
    count -= sendct;
    dta += (sendct*BLOCKSIZE);
  }
  rh->rh.status = DONE;
}


/* Generic IOCTL */
/*   The generic IOCTL functions are used by DOS programs to determine  */
/* the device geometry, and especially by the FORMAT program to init-   */
/* ialize new media.  The DOS format program requires us to implement   */
/* these three generic IOCTL functions:               */

PUBLIC void GenericIOCTL (rh_generic_ioctl_t far *rh)
{
  if (Debug)
    cdprintf("SD: generic IOCTL: unit=%d, major=0x%2x, minor=0x%2x, data=%4x:%4x\n",
    rh->rh.unit, rh->major, rh->minor, FP_SEG(rh->packet), FP_OFF(rh->packet));

  if (rh->major == DISK_DEVICE)
    switch (rh->minor) {
      case GET_PARAMETERS:  GetParameters ((device_params_t far *) rh->packet);
             rh->rh.status = DONE;
             return;
      case GET_ACCESS:      ((access_flag_t far *) (rh->packet))->allowed = 1;
             rh->rh.status = DONE;
             return;
      case GET_MEDIA_ID:
      case SET_MEDIA_ID:
      case SET_ACCESS:
      case SET_PARAMETERS:
      case FORMAT_TRACK:
             rh->rh.status = DONE;
             return;
      default: ;
    }
  cdprintf("SD: unimplemented IOCTL - unit=%d, major=0x%2x, minor=0x%2x\n",
     rh->rh.unit, rh->major, rh->minor);
  rh->rh.status = DONE | ERROR | UNKNOWN_COMMAND;
}


/* Generic IOCTL Query */
/*   DOS programs can use this function to determine which generic   */
/* IOCTL functions a device supports.  The query IOCTL driver call will */
/* succeed for any function the driver supports, and fail for others.   */
/* Nothing actually happens - just a test for success or failure. */
PUBLIC void IOCTLQuery (rh_generic_ioctl_t far *rh)
{
  if (Debug)
    cdprintf("SD: generic IOCTL query: unit=%d, major=0x%2x, minor=0x%2x\n",
    rh->rh.unit, rh->major, rh->minor);
  if (rh->major == DISK_DEVICE)
    switch (rh->minor) {
      case GET_ACCESS:
      case SET_ACCESS:
      case SET_MEDIA_ID:
      case GET_PARAMETERS:
      case SET_PARAMETERS:
      case FORMAT_TRACK:   rh->rh.status = DONE;
            return;
      default:
            break;
    }
  rh->rh.status = DONE | ERROR | UNKNOWN_COMMAND;
}


/* SDDriver */
/*   This procedure is called by the DRIVER.ASM interface module when   */
/* MSDOS calls the driver INTERRUPT routine, and the C code is expected */
/* to define it.  Note that the STRATEGY call is handled completely  */
/* inside DRIVER.ASM and the address of the request header block is  */
/* passed to the C interrupt routine as a parameter.        */
PUBLIC void far SDDriver (rh_t far *rh)
{
/*
  if (Debug)
    cdprintf("SD: request at %4x:%4x, command=%d, length=%d\n",
      FP_SEG(rh), FP_OFF(rh), rh->command, rh->length);
*/
  switch (rh->command) {
    case INITIALIZATION:  Initialize   ((rh_init_t far *) rh);    break;
    case MEDIA_CHECK:     MediaCheck   ((rh_media_check_t far *) rh);   break;
    case GET_BPB:   BuildBPB     ((rh_get_bpb_t far *) rh); break;
    case INPUT:        ReadBlock    ((rh_io_t far *) rh);      break;
    case OUTPUT:    WriteBlock   ((rh_io_t far *) rh, FALSE);  break;
    case OUTPUT_VERIFY:   WriteBlock   ((rh_io_t far *) rh, TRUE);   break;
    case GENERIC_IOCTL:   GenericIOCTL ((rh_generic_ioctl_t far *) rh); break;
    case IOCTL_QUERY:     IOCTLQuery   ((rh_generic_ioctl_t far *) rh); break;

    case GET_LOGICAL:
    case SET_LOGICAL:     rh->status = DONE;          break;

    default:
      cdprintf("SD: unimplemented driver request - command=%d, length=%d\n",
         rh->command, rh->length);
      rh->status = DONE | ERROR | UNKNOWN_COMMAND;
  }
}


PUBLIC void Shutdown (void)
{
  long i;
  cdprintf("SD: Shutdown\n");
  for (i=0; i <100000; ++i);
  /* SDClose(); */
  JMPVECTOR(RebootVector);
}


/*   WARNING!!  WARNING!!  WARNING!!  WARNING!!  WARNING!!  WARNING!!   */
/*                         */
/*   All code following this point in the file is discarded after the   */
/* driver initialization.  Make absolutely sure that no routine above   */
/* this line calls any routine below it!!          */
/*                         */
/*   WARNING!!  WARNING!!  WARNING!!  WARNING!!  WARNING!!  WARNING!!   */


/* Driver Initialization */
/*   DOS calls this function immediately after the driver is loaded and */
/* expects it to perform whatever initialization is required.  Since */
/* this function can never be called again, it's customary to discard   */
/* the memory allocated to this routine and any others that are used */
/* only at initialization.  This allows us to economize a little on the */
/* amount of memory used.                 */
/*                         */
/*   This routine's basic function is to initialize the serial port, go */
/* and make contact with the SD card, and then return a table of BPBs to   */
/* DOS.  If we can't communicate with the drive, then the entire driver */
/* is unloaded from memory.                  */
PUBLIC void Initialize (rh_init_t far *rh)
{
  WORD brkadr, reboot[2];  int status, i;

  /* The version number is sneakily stored in the device header! */
  cdprintf("SD Card driver V%c.%c for XTMax (%s)\n     based on SD pport device driver (C) 2014 by Dan Marks\n     based on TU58 by Robert Armstrong\n",
    header.name[6], header.name[7],
#ifdef USE186
    "80186+"
#else
    "8086"
#endif
    );

  /* Parse the options from the CONFIG.SYS file, if any... */
  if (!parse_options((char far *) rh->bpbtbl)) {
    cdprintf("SD: bad options in CONFIG.SYS\n");
    goto unload2;
  }

  /*   Calculate the size of this driver by using the address of this   */
  /* routine.  Note that C will return an offset for &Initialize which  */
  /* is relative to the _TEXT segment. We have to adjust this by adding */
  /* the offset from DGROUP.  See HEADER.ASM for a memory layout. */
  brkadr = ((WORD) &Initialize) + ((_CS - _DS) << 4);
  rh->brkadr = MK_FP(_DS, brkadr);
  if (Debug)
    cdprintf("SD: CS=%4x, DS=%4x, SS=%4x, SP=%4x, break=%4x\n",
     _CS, _DS, _SS, _SP, brkadr);

/* Try to make contact with the drive... */
  if (Debug) cdprintf("SD: initializing drive\n");
  if (!SDInitialize(rh->rh.unit, partition_number, &bpb)) {
    cdprintf("SD: drive not connected or not powered\n");
    goto unload1;
  }
  cdprintf("SD: rh = %4x:%4x\n", FP_SEG(rh), FP_OFF(rh));

  reboot[0] = ((WORD) &reboot) + ((_CS - _DS) << 4);
  reboot[1] = _CS;
  GETVECTOR(0x19, RebootVector);
  SETVECTOR(0x19, reboot);
  if (Debug)
    cdprintf("SD: reboot vector = %4x:%4x, old vector = %4x, %4x\n",
    reboot[1], reboot[0], RebootVector[1], RebootVector[0]);

  /* All is well.  Tell DOS how many units and the BPBs... */
  cdprintf("SD initialized on DOS drive %c\n",
    rh->drive+'A');
  rh->nunits = 1;  rh->bpbtbl = &bpbtbl;
  rh->rh.status = DONE;

  if (Debug)
  {   
      cdprintf("SD: BPB data:\n");
      cdprintf("Sector Size: %d   ", bpb.sector_size);
      cdprintf("Allocation unit: %d\n", bpb.allocation_unit);
      cdprintf("Reserved sectors: %d  ", bpb.reserved_sectors);
      cdprintf("Fat Count: %d\n", bpb.fat_count);
      cdprintf("Directory size: %d  ", bpb.directory_size);
      cdprintf("Total sectors: %d\n", bpb.total_sectors);
      cdprintf("Media descriptor: %x  ", bpb.media_descriptor);
      cdprintf("Fat sectors: %d\n", bpb.fat_sectors);
      cdprintf("Track size: %d  ", bpb.track_size);
      cdprintf("Head count: %d\n", bpb.head_count);
      cdprintf("Hidden sectors: %d  ", bpb.hidden_sectors);
      cdprintf("Sector Ct 32 hex: %L\n", bpb.sector_count);
      cdprintf("Partition offset: %L\n", partition_offset);
   }
  return;

  /*   We get here if there are any errors in initialization.  In that  */
  /* case we can unload this driver completely from memory by setting   */
  /* (1) the break address to the starting address, (2) the number of   */
  /* units to 0, and (3) the error flag.           */
unload1:
  { };
unload2:
  rh->brkadr = MK_FP(_DS, 0);  rh->nunits = 0;  rh->rh.status = ERROR;
}

/* iseol - return TRUE if ch is any end of line character */
PRIVATE BOOLEAN iseol (char ch)
{  return ch=='\0' || ch=='\r' || ch=='\n';  }

/* spanwhite - skip any white space characters in the string */
PRIVATE char far *spanwhite (char far *p)
{  while (*p==' ' || *p=='\t') ++p;  return p;  }

/* option_value */
/*   This routine will parse the "=nnn" part of an option.  It should   */
/* be called with a text pointer to what we expect to be the '=' char-  */
/* acter.  If all is well, it will return the binary value of the arg-  */
/* ument and a pointer to the first non-numeric character.  If there is */
/* a syntax error, then it will return NULL.          */
PRIVATE char far *option_value (char far *p, WORD *v)
{
  BOOLEAN null = TRUE;
  if (*p++ != '=')  return NULL;
  for (*v=0;  *p>='0' && *p<='9';  ++p)
    *v = (*v * 10) + (*p - '0'),  null = FALSE;
  return null ? NULL : p;
}

/* parse_options */
/*   This routine will parse our line from CONFIG.SYS and extract the   */
/* driver options from it.  The routine returns TRUE if it parsed the   */
/* line successfully, and FALSE if there are any problems.  The pointer */
/* to CONFIG.SYS that DOS gives us actually points at the first char-   */
/* acter after "DEVICE=", so we have to first skip over our own file */
/* name by searching for a blank.  All the option values are stored in  */
/* global variables (e.g. DrivePort, DriveBaud, etc).          */
PRIVATE BOOLEAN parse_options (char far *p)
{
  WORD temp;
  while (*p!=' ' && *p!='\t' && !iseol(*p))  ++p;
  p = spanwhite(p);
  while (!iseol(*p)) {
    p = spanwhite(p);
    if (*p++ != '/')  return FALSE;
    switch (*p++) {
      case 'd', 'D':
        Debug = TRUE;
   break;
      case 'p', 'P':
        if ((p=option_value(p,&temp)) == NULL)  return FALSE;
        if ((temp < 1) || (temp > 4))
            cdprintf("SD: Invalid partition number %x\n",temp);
        else
            partition_number = temp;
   break; 
      default:
        return FALSE;
    }
    p = spanwhite(p);
  }
  return TRUE;
}


