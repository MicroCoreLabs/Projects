/*  _null.h

    Definition of NULL.

    Copyright (c) 1987, 1992 by Borland International
    All Rights Reserved.
*/

#ifndef NULL
#  if defined(__TINY__) || defined(__SMALL__) || defined(__MEDIUM__)
#    define NULL    0
#  else
#    define NULL    0L
#  endif
#endif
