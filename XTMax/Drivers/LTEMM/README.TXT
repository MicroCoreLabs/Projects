*************************************************************************
*							        	*
*	EMS 4.0 Driver for Lo-tech 2MB EMS Board, rev.01, Mar-14	*
*							        	*
*	http://www.lo-tech.co.uk/wiki/2MB-EMS-Board			*
*	http://www.lo-tech.co.uk/wiki/LTEMM.EXE				*
*									*
*	This code is TASM source.					*
*									*
*	Based on original works Copyright (c) 1988, Alex Tsourikov.	*
*	All rights reserved.						*
*									*
*	Original source kindly provided subject to the BSD 3-Clause	*
*	License: http://opensource.org/licenses/BSD-3-Clause		*
*									*
*	This software, as modified, is provided subject to the terms 	*
*	of use at: 							*
*									*
*	http://www.lo-tech.co.uk/wiki/lo-tech.co.uk:General_disclaimer	*
*									*
*	No charge has been made for this software.			*
*									*
*************************************************************************

Syntax:    DEVICE=LTEMM.EXE [/switches]
 /p:nnnn - Page frame address (E000)
 /i:nnn  - EMS i/o port base address (260)
 /h:nnn  - Maximal number of handles (64)
 /d:nn   - Depth of contest saves (5)
 /f:nnn  - First page number (0)
 /n      - Bypass memory test
 /x      - Perform long memory test
 /3      - Use only EMS 3.2 functions
 /q      - Quiet mode

Defaults in parentheses. This driver has been tested under MS-DOS 6.22.


