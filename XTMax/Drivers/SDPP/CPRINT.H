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

#ifndef _CPRINT_H
#define _CPRINT_H
void outchr (char ch);
void outstr (char *p);
void outdec (int val);
void outhex (unsigned val, int ndigits);
void outcrlf (void);
void cdprintf (char near *msg, ...);
#endif
