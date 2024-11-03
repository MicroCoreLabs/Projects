/* cprint.c                      */
/*                         */
/*   This file contains simple ASCII output routines.  These are used   */
/* by the device driver for debugging, and to issue informational */
/* messages (e.g. while loading).  In general the C run time library    */
/* functions probably aren't safe for use withing the context of a   */
/* device driver and should be avoided.               */
/*                         */
/*   All these routines do their output thru the routine outchr, which  */
/* is defined in DRIVER.ASM.  It calls the BIOS INT 10 "dumb TTY" */
/* output function directly and does not use MSDOS at all.     */
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

#include <stdio.h>      /* NULL, etc...            */
#include <dos.h>        /* used only for MK_FP !      */
#include <stdarg.h>     /* needed for variable argument lists  */

/* outchr - print a single ASCII character */
void outchr (char ch)
{
  _DI = _SI = 0;
  _AL = ch;  _AH = 0xE;  _BX = 0;
  asm  INT  0x10;
}


/* outstr - print an ASCIZ string */
void outstr (char *p)
{
  while (*p != '\0')
    outchr (*p++);
}

/* outdec - print a signed decimal integer */
void outdec (int val)
{
  if (val < 0)
    {outchr('-');  val = -val;}
  if (val > 9)
    {outdec( val/10 );  val %= 10;}
  outchr('0' + val);
}

/* outhex - print a n digit hex number with leading zeros */
void outhex (unsigned val, int ndigits)
{
  if (ndigits > 1)
    outhex (val >> 4, ndigits-1);
  val &= 0xf;
  if (val > 9)
    outchr('A'+val-10);
  else
    outchr('0'+val);
}

/* outhex - print a n digit hex number with leading zeros */
void outlhex (unsigned long lval)
{
  int i;
  for (i=3;i>=0;i--)
     outhex(((unsigned char *)&lval)[i],2);
}


/* outcrlf - print a carriage return, line feed pair */
void outcrlf (void)
{
  outchr ('\r');  outchr ('\n');
}

/* cprintf */
/*   This routine provides a simple emulation for the printf() function */
/* using the "safe" console output routines.  Only a few escape seq- */
/* uences are allowed: %d, %x and %s.  A width modifier (e.g. %2x) is   */
/* recognized only for %x, and then may only be a single decimal digit. */
void cdprintf (char near *msg, ...)
{
  va_list ap;  char *str;  int size, ival;  unsigned uval; unsigned long luval;
  va_start (ap, msg);

  while (*msg != '\0') {
/*outhex((unsigned) msg, 4);  outchr('=');  outhex(*msg, 2);  outchr(' ');*/
    if (*msg == '%') {
      ++msg;  size = 0;
      if ((*msg >= '0')  &&  (*msg <= '9'))
   {size = *msg - '0';  ++msg;}
      if (*msg == 'c') {
        ival = va_arg(ap, int);  outchr(ival&0xff);  ++msg;
      } else if (*msg == 'd') {
   ival = va_arg(ap, int);  outdec (ival);   ++msg;
      } else if (*msg == 'x') {
   uval = va_arg(ap, unsigned); ++msg;
        outhex (uval,  (size > 0) ? size : 4);
      } else if (*msg == 'L') {
   luval = va_arg(ap, unsigned long); ++msg;
        outlhex (luval);
      } else if (*msg == 's') {
        str = va_arg(ap, char *);  outstr (str);  ++msg;
      }
    } else if (*msg == '\n') {
      outchr('\r');  outchr('\n');  ++msg;
    } else {
      outchr(*msg);  ++msg;
    }
  }

  va_end (ap);
}
