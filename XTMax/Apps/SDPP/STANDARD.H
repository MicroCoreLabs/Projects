/* standard.h - standard, project wide, declarations        */
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


/* Datatypes of a known size ... */
typedef unsigned char   BYTE; /*  8 bits, unsigned       */
typedef unsigned short  WORD; /* 16  "       "        */
#ifndef DEFINEDLONG
#define DEFINEDLONG
typedef unsigned long   LONG; /* 32  "       "        */
#endif


/* The BOOLEAN type and associated constants ... */
typedef unsigned char   BOOLEAN;/* any TRUE/FALSE result    */
#define FALSE     (0)   /*  logical falsity        */
#define TRUE      (~FALSE)/*  if it's not FALSE, it's ...      */


/*   This magic declaration modifier will make the symbol defined be */
/* invisible to the linker.  For example, "PRIVATE int foo;" or even */
/* "PRIVATE void fred () { ...}".  This is used extensively to restrict */
/* the scope of a global declaration to the current module.    */
#define PRIVATE      static   /* this works for most compilers!   */


/*   And this magic declaration modifier guarantees that the symbol so  */
/* defined will be visible to other modules.  It is the opposite of  */
/* "PRIVATE".  In C this is the default condition anyway, so this macro */
/* mostly serves as documentation.              */
#define PUBLIC       /* this is the way things are anyway   */


/* Extract the high and low bytes of a 16 bit value... */
#define HIGH(x)      (((x) >> 8) & 0xFF)
#define LOW(x)    ((x) & 0xFF)

/* Test a value for odd/even... */
#define ODD(x)    (((x) & 1) != 0)


/*   These macros provide access to specific 8088 family hardware ins-  */
/* tructions. From a performance viewpoint, it is highly desirable that */
/* these macros not be implemented by subroutine calls, but rather that */
/* they expand directly to inline assembler instructions.      */

#ifdef __TURBOC__
/*   These macros turn the interrupt system on and off.  They should */
/* generate the STI (0xFB) and CLI (0xFA) instructions...      */
#define INT_ON    asm sti
#define INT_OFF      asm cli

/*   These macros read and write a bytes from an I/O port.  They should */
/* generate the 0xE5 (IN AL,DX) or 0xEE (OUT DX,AL) instructions...  */
#define INBYTE(p,v)  { _DX = (p);  asm IN AL,DX;  v = _AL; }
#define OUTBYTE(p,v) { _DX = (p);  _AL = (v);  asm OUT DX,AL; }

/*   These macros will set or clear specific bit(s) in an I/O port.  */
/* They work by first reading the port, seting or clearing the bit(s),  */
/* and then writing the port.  Needless to say, they can only be used   */
/* on ports that can safely be both read and written!       */
#define IOSETBIT(p,m)   { _DX = (p);  _BL = (m);  \
           asm IN AL,DX;  asm OR  AL,BL;  asm OUT DX,AL; }
#define IOCLRBIT(p,m)   { _DX = (p);  _BL = ~(m);  \
           asm IN AL,DX;  asm AND AL,BL;  asm OUT DX,AL; }

/*   These macros use the DOS INT 21H functions to get and set the   */
/* contents of interrupt vectors.  They are used to save and restore */
/* the serial port interrupt service routine...          */
#define GETVECTOR(v,a)  { _AL = (v);  _AH = 0x35;  asm INT 0x21;  \
           asm MOV WORD PTR a, BX;  asm MOV WORD PTR a+2, ES; }
#define SETVECTOR(v,a)  { _AL = (v);  _AH = 0x25;  asm PUSH DS;  \
           asm LDS DX, DWORD PTR a;  \
           asm INT 0x21;  asm POP DS; }
#define JMPVECTOR(a) { asm JMP DWORD PTR a; }


/* Compute dst += src with end-around carry, just like the TU58 does... */
#define ADC(dst,src) { asm MOV AX, dst;  asm ADD AX, src;  \
           asm ADC AX, 0;    asm MOV dst, AX; }

#endif   /* ifdef __TURBOC__ */


/* Debugging output routines... */
void outchr (char);
void outstr (char *);
void outdec (int);
void outhex (unsigned, int);
void outcrlf (void);
void cprintf (char near *, ...);
