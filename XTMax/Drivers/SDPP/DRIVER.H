/* driver.h - MSDOS commands for a device driver....        */
/*                         */
/* Copyright (C) 1994 by Robert Armstrong          */
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

#ifndef _DRIVER_H
#define _DRIVER_H


/*  NOTE: B implies block device, C implies a character device.      */
/*        n.n+ implies DOS version n.n or later only!       */
#define INITIALIZATION  0  /* (BC)     initialize driver */
#define MEDIA_CHECK  1  /* (B)      query media changed  */
#define GET_BPB      2  /* (B)      BIOS parameter block */
#define IOCTL_INPUT  3  /* (BC)     read IO control data */
#define INPUT     4  /* (BC)     read data      */
#define ND_INPUT  5  /* (C)      non-destructive input   */
#define INPUT_STATUS 6  /* (C)      query data available */
#define INPUT_FLUSH  7  /* (C)      flush input buffers  */
#define OUTPUT    8  /* (BC)     write data     */
#define OUTPUT_VERIFY   9  /* (BC)     write data with verify  */
#define OUTPUT_STATUS   10 /* (C)      query output busy */
#define OUTPUT_FLUSH 11 /* (C)      flush output buffers */
#define IOCTL_OUTPUT 12 /* (BC)     write IO control data   */
#define DEVICE_OPEN  13 /* (BC) (3.0+) device is to be opened  */
#define DEVICE_CLOSE 14 /* (BC) (3.0+)    "   "   "  " closed  */
#define REMOVABLE_MEDIA 15 /* (B)  (3.0+) query removable media   */
#define OUTPUT_BUSY  16 /* (C)  (3.0+) output data until busy  */
#define GENERIC_IOCTL   19 /* (B)  (3.2+)          */
#define GET_LOGICAL  23 /* (BC) (3.2+)          */
#define SET_LOGICAL  24 /* (BC) (3.2+)          */
#define IOCTL_QUERY  25 /* (BC) (5.0+)          */

/* Flag bits for the request header status word...       */
#define ERROR     0x8000   /* indicates any error condition */
#define BUSY      0x0200   /* prevents further operations      */
#define DONE      0x0100   /* set on request completion     */

/* Error codes that may be returned by a device driver...      */
#define WRITE_PROTECT   0x00  /* diskette is write protected      */
#define UNKNOWN_UNIT 0x01  /* unit number does not exist    */
#define NOT_READY 0x02  /* device is not ready        */
#define UNKNOWN_COMMAND 0x03  /* unknown command code       */
#define CRC_ERROR 0x04  /* data check (CRC) error     */
#define HDR_LEN_ERROR   0x05  /* bad request header length     */
#define SEEK_ERROR   0x06  /* seek failure            */
#define UNKNOWN_MEDIA   0x07  /* unknown media (e.g. wrong density)  */
#define BAD_SECTOR   0x08  /* sector not found        */
#define NO_PAPER  0x09  /* printer out of paper       */
#define WRITE_FAULT  0x0A  /* write failure        */
#define READ_FAULT   0x0B  /* read failure            */
#define GENERAL_FAILURE 0x0C  /* general failure         */
#define MEDIA_CHANGED   0x0F  /* invalid diskette change    */

/* Values associated with function 19 - Generic IOCTL...    */
#define SERIAL_DEVICE   0x01  /* device category: any serial device  */
#define CONSOLE_DEVICE  0x03  /*   "      "     : console (display)  */
#define PARALLEL_DEVICE 0x05  /*   "      "     : parallel printer   */
#define DISK_DEVICE  0x08  /*   "      "     : any disk (block)   */
#define SET_PARAMETERS  0x40  /* disk device: set device parameters  */
#define GET_PARAMETERS  0x60  /*   "    "   : get    "     "    " */
#define WRITE_TRACK  0x41  /*   "    "   : write one track     */
#define READ_TRACK   0x61  /*   "    "   : read   "    "    */ 
#define FORMAT_TRACK 0x42  /*   "    "   : format "    "    */
#define VERIFY_TRACK 0x62  /*   "    "   : verify "    "    */
#define SET_MEDIA_ID 0x46  /*   "    "   : set media id byte   */
#define GET_MEDIA_ID 0x66  /*   "    "   : get   "    "   " */
#define SENSE_MEDIA  0x68  /*   "    "   : sense media type */
#define SET_ACCESS   0x67  /*   "    "   : set access allowed flag   */
#define GET_ACCESS   0x47  /*   "    "   : get   "        "    "  */

struct _devhdr {        /* Device header structure... */
  struct _devhdr far *next;      /*  address of the next device   */
  WORD attribute;       /*  device attribute word  */
  void (near *strtgy) (void);    /*  strategy routine address  */
  void (near *intrpt) (void);    /*  interrupt   "      "   */
  BYTE name[8];            /*  device name (blank filled!)  */
};
typedef struct _devhdr devhdr_t;

struct _bpb {        /* BIOS Parameter block structure...   */
  WORD sector_size;     /*  sector size, in bytes     */
  BYTE allocation_unit;    /*  allocation unit size      */
  WORD reserved_sectors;   /*  number of reserved (boot) sectors  */
  BYTE fat_count;    /*  number of FATs on disk    */
  WORD directory_size;     /*  root directory size, in files   */
  WORD total_sectors;      /*  device size, in sectors      */
  BYTE media_descriptor;   /*  media descriptor code from the BIOS   */
  WORD fat_sectors;     /*  number of sectors per FAT    */
  WORD track_size;      /*  track size, in sectors    */
  WORD head_count;      /*  number of heads        */
  LONG hidden_sectors;     /*  offset of this hard disk partition */
  /*   The following device size is used only for disks > 32Mb. In that */
  /* case, the total_sectors field should be zero!       */
  LONG sector_count;    /*  device size, in sectors      */
};
typedef struct _bpb bpb_t;

struct _rhfixed {    /* Fixed preamble for every request... */
  BYTE length;       /*  length of the header, in bytes  */
  BYTE unit;         /*  physical unit number requested  */
  BYTE command;         /*  device driver command code      */
  WORD status;       /*  status returned by the driver   */
  BYTE reserved[8];     /*  reserved (unused) bytes      */
};
typedef struct _rhfixed rh_t;

/*   NOTE: count is in _bytes_ for character type device drivers, and   */
/* in _sectors_ for block type drivers!!           */

typedef near * (bpbtbl_t[]);
struct _rh_init {    /* INITIALIZATION(0)       */
  rh_t        rh;    /*  fixed portion of the header     */
  BYTE        nunits;      /*  number of units supported by driver   */
  BYTE   far *brkadr;      /*  break address (memory used)     */
  bpbtbl_t far *bpbtbl;    /*  pointer to array of BPBs     */
  BYTE        drive;    /*  first available drive number */
};
typedef struct _rh_init rh_init_t;

struct _rh_media_check {   /* MEDIA_CHECK(1)       */
  rh_t     rh;       /*  fixed portion of the request */
  BYTE     media_type;     /*  media descriptor byte from BIOS */
  BYTE     media_status;   /*  new media status flags    */
  BYTE far *volume_id;     /*  pointer to volume ID string     */
};
typedef struct _rh_media_check rh_media_check_t;

struct _rh_get_bpb {    /* GET_BPB(2)           */
  rh_t       rh;     /*  fixed portion of the request */
  BYTE       media_type;   /*  media descriptor byte from BIOS */
  BYTE  far *dta;    /*  address for data transfer    */
  bpb_t far *bpb;    /*  pointer to the BPB        */
};
typedef struct _rh_get_bpb rh_get_bpb_t;

struct _rh_ioctl {      /* IOCTL_INPUT(3), IOCTL_OUTPUT(12) */
  rh_t      rh;         /*  fixed portion of the request */
  BYTE      media_type;    /*  media descriptor byte from BIOS */
  BYTE far *dta;     /*  address for data transfer    */
  WORD      count;      /*  transfer count (bytes or sectors)  */
  WORD      start;      /*  starting sector number    */
};
typedef struct _rh_ioctl rh_ioctl_t;

struct _rh_io {         /* INPUT(4),OUTPUT(8),OUTPUT_VERIFY(9) */
  rh_t      rh;         /*  fixed portion of the request */
  BYTE      media_type;    /*  media descriptor byte from BIOS */
  BYTE far *dta;     /*  address for data transfer    */
  WORD      count;      /*  transfer count (bytes or sectors)  */
  WORD      start;      /*  starting sector number    */
  BYTE far *volume_id;     /*  address of volume ID string     */
  DWORD     longstart;   /* long start for lba */
};
typedef struct _rh_io rh_io_t;

struct _rh_ndinput {    /* ND_INPUT(5)          */
  rh_t rh;        /*  fixed portion of the request */
  BYTE ch;        /*  next input character (returned) */
};
typedef struct _rh_ndinput rh_ndinput_t;

/* INPUT_STATUS(6)      has only a request header...        */
/* INPUT_FLUSH(7)        "   "   "    "      "   ...        */
/* OUTPUT_STATUS(10)     "   "   "    "      "   ...        */
/* OUTPUT_FLUSH(11)      "   "   "    "      "   ...        */
/* DEVICE_OPEN(13)       "   "   "    "      "   ...        */
/* DEVICE_CLOSE(14)      "   "   "    "      "   ...        */
/* REMOVABLE_MEDIA(15)   "   "   "    "      "   ...        */

struct _rh_output_busy {   /* OUTPUT_BUSY(16)         */
  rh_t      rh;         /*  fixed portion of the request */
  BYTE      media_type;    /*  media descriptor byte from BIOS */
  BYTE far *dta;     /*  address for data transfer    */
  WORD      count;      /*  transfer count (bytes or sectors)  */
};
typedef struct _rh_output_busy rh_output_busy_t;

struct _rh_generic_ioctl { /* GENERIC_IOCTL(19), IOCTL_QUERY(25)  */
  rh_t      rh;         /*  fixed portion of the request */
  BYTE      major, minor;  /*  function code - major and minor */
  WORD      si, di;     /*  caller's SI and DI registers */
  BYTE far *packet;     /*  address of IOCTL data packet */
};
typedef struct _rh_generic_ioctl rh_generic_ioctl_t;

struct _rh_logical {    /* GET_LOGICAL(23), SET_LOGICAL(24) */
  rh_t rh;        /*  fixed portion of the request */
  BYTE io;        /*  unit code or last device     */
  BYTE command;         /*  command code        */
  WORD status;       /*  resulting status       */
  LONG reserved;     /*  reserved (unused)         */
};
typedef struct _rh_logical rh_logical_t;

struct _device_params {    /* Generic IOCTL, Get/Set Parameters   */
  BYTE  special;     /*  special functions and flags     */
  BYTE  form_factor;    /*  device (not media!) form factor */
  WORD  attributes;     /*  physical drive attributes    */
  WORD  cylinders;      /*  number of cylinders       */
  BYTE  media_type;     /*  media type (not the media id!)  */
  bpb_t bpb;         /*  the entire BIOS parameter block!   */
  WORD  layout[];    /*  track layout map       */
};
typedef struct _device_params device_params_t;

struct _access_flag   { /* Generic IOCTL Get/Set access allowed   */
  BYTE  special;     /*  special functions and flags     */
  BYTE  allowed;     /*  non-zero if access is allowed   */
};
typedef struct _access_flag access_flag_t;

struct _media_type {    /* Generic IOCTL Get media type     */
  BYTE default_media;      /*  1 for default media type     */
  BYTE form_factor;     /*  media (not device!) form factor */
};
typedef struct _media_type media_type_t;

#endif
