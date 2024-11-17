/* sd.c                        */
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
/*                         */
/*                         */
/*   The functions provided are:             */
/*                         */
/* SDInitialize - establish two way communications with the drive */
/* SDRead       - read one 512 byte logical block from the tape   */
/* SDWrite      - write one 512 byte logical block to the tape */
/* SDMediaCheck - see if card detect has changed */
/*                         */
/*   Normally the SDInitialize routine would be called  */
/* during the DOS device driver initialization, and then the SDRead and */
/*                         */

#include <stdio.h>      /* needed for NULL, etc       */
#include <mem.h>        /* memset, memcopy, etc       */
#include "standard.h"   /* all definitions for this project */
#include "sd.h"         /* device protocol and data defintions */
#include "diskio.h"     /* stuff from sdmm.c module */
#include "driver.h"
#include "cprint.h"

DWORD partition_offset = 0;

/* FatFs refers the members in the FAT structures as byte array instead of
/ structure member because the structure is not binary compatible between
/ different platforms */

#define BS_jmpBoot         0  /* Jump instruction (3) */
#define BS_OEMName         3  /* OEM name (8) */
#define BPB_BytsPerSec     11 /* Sector size [byte] (2) */
#define BPB_SecPerClus     13 /* Cluster size [sector] (1) */
#define BPB_RsvdSecCnt     14 /* Size of reserved area [sector] (2) */
#define BPB_NumFATs        16 /* Number of FAT copies (1) */
#define BPB_RootEntCnt     17 /* Number of root directory entries for FAT12/16 (2) */
#define BPB_TotSec16    19 /* Volume size [sector] (2) */
#define BPB_Media       21 /* Media descriptor (1) */
#define BPB_FATSz16        22 /* FAT size [sector] (2) */
#define BPB_SecPerTrk      24 /* Track size [sector] (2) */
#define BPB_NumHeads    26 /* Number of heads (2) */
#define BPB_HiddSec        28 /* Number of special hidden sectors (4) */
#define BPB_TotSec32    32 /* Volume size [sector] (4) */
#define BS_DrvNum       36 /* Physical drive number (2) */
#define BS_BootSig         38 /* Extended boot signature (1) */
#define BS_VolID        39 /* Volume serial number (4) */
#define BS_VolLab       43 /* Volume label (8) */
#define BS_FilSysType      54 /* File system type (1) */
#define BPB_FATSz32        36 /* FAT size [sector] (4) */
#define BPB_ExtFlags    40 /* Extended flags (2) */
#define BPB_FSVer       42 /* File system version (2) */
#define BPB_RootClus    44 /* Root directory first cluster (4) */
#define BPB_FSInfo         48 /* Offset of FSINFO sector (2) */
#define BPB_BkBootSec      50 /* Offset of backup boot sector (2) */
#define BS_DrvNum32        64 /* Physical drive number (2) */
#define BS_BootSig32    66 /* Extended boot signature (1) */
#define BS_VolID32         67 /* Volume serial number (4) */
#define BS_VolLab32        71 /* Volume label (8) */
#define BS_FilSysType32    82 /* File system type (1) */
#define  FSI_LeadSig       0  /* FSI: Leading signature (4) */
#define  FSI_StrucSig      484   /* FSI: Structure signature (4) */
#define  FSI_Free_Count    488   /* FSI: Number of free clusters (4) */
#define  FSI_Nxt_Free      492   /* FSI: Last allocated cluster (4) */
#define MBR_Table       446   /* MBR: Partition table offset (2) */
#define  SZ_PTE            16 /* MBR: Size of a partition table entry */
#define BS_55AA            510   /* Boot sector signature (2) */


BYTE local_buffer[BLOCKSIZE];

#define LD_WORD(x) *((WORD *)(BYTE *)(x))
#define LD_DWORD(x) *((DWORD *)(BYTE *)(x))

/*-----------------------------------------------------------------------*/
/* Load a sector and check if it is an FAT boot sector                   */
/*-----------------------------------------------------------------------*/

static
BYTE check_fs (BYTE unit,  
   /* 0:FAT boor sector, 1:Valid boor sector but not FAT, */
   /* 2:Not a boot sector, 3:Disk error */
   DWORD sect  /* Sector# (lba) to check if it is an FAT boot record or not */
)
{
   if (disk_read (unit, local_buffer, sect, 1) != RES_OK)
      return 3;
   if (LD_WORD(&local_buffer[BS_55AA]) != 0xAA55) /* Check boot record signature (always placed at offset 510 even if the sector size is >512) */
      return 2;
   if ((LD_DWORD(&local_buffer[BS_FilSysType]) & 0xFFFFFF) == 0x544146)      /* Check "FAT" string */
      return 0;
   if ((LD_DWORD(&local_buffer[BS_FilSysType32]) & 0xFFFFFF) == 0x544146) /* Check "FAT" string */
      return 0;
   return 1;
}


/*-----------------------------------------------------------------------*/
/* Find logical drive and check if the volume is mounted                 */
/*-----------------------------------------------------------------------*/

static
int find_volume ( 
   BYTE unit,
   BYTE partno,
   bpb_t *bpb
)
{
   BYTE fmt;
   DSTATUS stat;
   WORD secsize;
   DWORD bsect;

   stat = disk_status(unit);
   if (!(stat & STA_NOINIT)) {      /* and the physical drive is kept initialized */
         return 0;                  /* The file system object is valid */
   }

   /* The file system object is not valid. */
   /* Following code attempts to mount the volume. (analyze BPB and initialize the fs object) */

   stat = disk_initialize(unit);    /* Initialize the physical drive */
   if (stat & STA_NOINIT)           /* Check if the initialization succeeded */
      return -1;                    /* Failed to initialize due to no medium or hard error */
   
   /* Find an FAT partition on the drive. Supports only generic partitioning, FDISK and SFD. */
   bsect = 0;
   fmt = check_fs(unit, bsect);             /* Load sector 0 and check if it is an FAT boot sector as SFD */
   if (fmt == 1 || (!fmt && (partno))) { /* Not an FAT boot sector or forced partition number */
      UINT i;         
      DWORD br[4];

      for (i = 0; i < 4; i++) {        /* Get partition offset */
         BYTE *pt = &local_buffer[MBR_Table + i * SZ_PTE];
         br[i] = pt[4] ? LD_DWORD(&pt[8]) : 0;
      }
      i = partno;                /* Partition number: 0:auto, 1-4:forced */
      if (i) i--;
      do {                       /* Find an FAT volume */
         bsect = br[i];
         fmt = bsect ? check_fs(unit, bsect) : 2; /* Check the partition */
      } while (!partno && fmt && ++i < 4);
   }
   if (fmt == 3) return -2;      /* An error occured in the disk I/O layer */
   if (fmt) return -3;           /* No FAT volume is found */

   /* An FAT volume is found. Following code initializes the file system object */

   secsize = LD_WORD(local_buffer + BPB_BytsPerSec);
   if (secsize != BLOCKSIZE)
      return -3;

   bpb->sector_size = BLOCKSIZE;
   bpb->allocation_unit = local_buffer[BPB_SecPerClus];     /* Number of sectors per cluster */
   bpb->reserved_sectors = LD_WORD(local_buffer+BPB_RsvdSecCnt);  /* Number of reserved sectors */
   if (!bpb->reserved_sectors) return -3;                   /* (Must not be 0) */
   bpb->fat_count = local_buffer[BPB_NumFATs];              /* Number of FAT copies */
   if (bpb->fat_count == 0)
      bpb->fat_count = 2;
   bpb->directory_size = LD_WORD(local_buffer+BPB_RootEntCnt);   
   bpb->total_sectors = LD_WORD(local_buffer+BPB_TotSec16);
   if (!bpb->total_sectors) 
      bpb->sector_count = LD_DWORD(local_buffer+BPB_TotSec32);
   else
      bpb->sector_count = bpb->total_sectors;
   bpb->media_descriptor = local_buffer[BPB_Media];
   bpb->fat_sectors = LD_WORD(local_buffer+BPB_FATSz16);             /* Number of sectors per FAT */
   bpb->track_size = LD_WORD(local_buffer+BPB_SecPerTrk);     /* Number of sectors per cluster */
   bpb->head_count = LD_WORD(local_buffer+BPB_NumHeads);     /* Number of sectors per cluster */
   bpb->hidden_sectors = 1;

   partition_offset = bsect;
   return 0;
}


/* SDInitialize */
PUBLIC BOOLEAN SDInitialize (BYTE unit, BYTE partno, bpb_t *bpb)
{
  if (find_volume(unit,partno,bpb) < 0)
      return FALSE;
  return TRUE;
}

/* SDMediaCheck */
PUBLIC BOOLEAN SDMediaCheck (BYTE unit)
{
  return (disk_result(unit) == RES_OK) ? FALSE : TRUE;
}

/* SDRead */
/*  IMPORTANT!  Blocks are always 512 bytes!  Never more, never less.   */
/*                         */
/* INPUTS:                       */
/* unit  - selects tape drive 0 (left) or 1 (right)      */
/* lbn   - logical block number to be read [0..511]      */
/* buffer   - address of 512 bytes to receive the data read    */
/*                         */
/* RETURNS: operation status as reported by the TU58     */
/*                         */
PUBLIC int SDRead (WORD unit, DWORD lbn, BYTE far *buffer, WORD count)
{
  return disk_read (unit, buffer, lbn + partition_offset, count);
}


/* SDWrite */
/*  IMPORTANT!  Blocks are always 512 bytes!  Never more, never less.   */
/*                         */
/* INPUTS:                       */
/* unit  - selects tape drive 0 (left) or 1 (right)      */
/* lbn   - logical block number to be read [0..511]      */
/* buffer   - address of 512 bytes containing the data to write   */
/* verify   - TRUE to ask the TU58 for a verification pass     */
/*                         */
/* RETURNS: operation status as reported by the TU58     */
/*                         */
PUBLIC int SDWrite (WORD unit, DWORD lbn, BYTE far *buffer, WORD count)
{
  return disk_write (unit, buffer, lbn + partition_offset, count);
}

