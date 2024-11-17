/*  conio.h

    Direct MSDOS console input/output.

    Copyright (c) 1987, 1992 by Borland International
    All Rights Reserved.
*/

#if !defined(__CONIO_H)
#define __CONIO_H

#if !defined(___DEFS_H)
#include <_defs.h>
#endif

#if !defined(_Windows)

#define _NOCURSOR      0
#define _SOLIDCURSOR   1
#define _NORMALCURSOR  2

struct text_info {
    unsigned char winleft;
    unsigned char wintop;
    unsigned char winright;
    unsigned char winbottom;
    unsigned char attribute;
    unsigned char normattr;
    unsigned char currmode;
    unsigned char screenheight;
    unsigned char screenwidth;
    unsigned char curx;
    unsigned char cury;
};

enum text_modes { LASTMODE=-1, BW40=0, C40, BW80, C80, MONO=7, C4350=64 };

#if !defined(__COLORS)
#define __COLORS

enum COLORS {
    BLACK,          /* dark colors */
    BLUE,
    GREEN,
    CYAN,
    RED,
    MAGENTA,
    BROWN,
    LIGHTGRAY,
    DARKGRAY,       /* light colors */
    LIGHTBLUE,
    LIGHTGREEN,
    LIGHTCYAN,
    LIGHTRED,
    LIGHTMAGENTA,
    YELLOW,
    WHITE
};
#endif

#define BLINK       128 /* blink bit */

extern   int _Cdecl directvideo;
extern   int _Cdecl _wscroll;

#endif   /* !_Windows */

#ifdef __cplusplus
extern "C" {
#endif

void        _Cdecl clreol( void );
void        _Cdecl clrscr( void );
void        _Cdecl gotoxy( int __x, int __y );
int         _Cdecl wherex( void );
int         _Cdecl wherey( void );
int         _Cdecl getch( void );
int         _Cdecl getche( void );
int         _Cdecl kbhit( void );
int         _Cdecl putch( int __c );

#ifndef _PORT_DEFS
unsigned char   _Cdecl inportb( unsigned __portid );
unsigned        _Cdecl inport ( unsigned __portid );
int             _Cdecl inp( unsigned __portid );
unsigned        _Cdecl inpw( unsigned __portid );
void            _Cdecl outportb( unsigned __portid, unsigned char __value );
void            _Cdecl outport ( unsigned __portid, unsigned __value );
int             _Cdecl outp( unsigned __portid, int __value );
unsigned        _Cdecl outpw( unsigned __portid, unsigned __value );
#endif  /* !_PORT_DEFS */

#if !defined(_Windows)

void        _Cdecl delline( void );
int         _Cdecl gettext( int __left, int __top,
                            int __right, int __bottom,
                            void *__destin);
void        _Cdecl gettextinfo (struct text_info *__r );
void        _Cdecl highvideo( void );
void        _Cdecl insline( void );
void        _Cdecl lowvideo( void );
int         _Cdecl movetext( int __left, int __top,
                             int __right, int __bottom,
                             int __destleft, int __desttop );
void        _Cdecl normvideo( void );
int         _Cdecl puttext( int __left, int __top,
                            int __right, int __bottom,
                            void *__source );
void        _Cdecl textattr( int __newattr );
void        _Cdecl textbackground( int __newcolor );
void        _Cdecl textcolor( int __newcolor );
void        _Cdecl textmode( int __newmode );
void        _Cdecl window( int __left, int __top, int __right, int __bottom);

void        _Cdecl _setcursortype( int __cur_t );
char * _Cdecl cgets( char *__str );
int         _Cdecl cprintf( const char *__format, ... );
int         _Cdecl cputs( const char *__str );
int         _Cdecl cscanf( const char *__format, ... );
char * _Cdecl getpass( const char *__prompt );
int         _Cdecl ungetch( int __ch );

#endif  /* !_Windows */

#ifndef _PORT_DEFS
#define _PORT_DEFS

    /* These are in-line functions.  These prototypes just clean up
       some syntax checks and code generation.
     */
unsigned char   _Cdecl  __inportb__ (unsigned __portid);
unsigned        _Cdecl  __inportw__ (unsigned __portid);
unsigned char   _Cdecl  __outportb__(unsigned __portid, unsigned char __value);
unsigned        _Cdecl  __outportw__(unsigned __portid, unsigned __value);

#define inportb(__portid)           __inportb__(__portid)
#define outportb(__portid, __value) ((void) __outportb__(__portid, __value))
#define inport(__portid)            __inportw__(__portid)
#define outport(__portid, __value)  ((void) __outportw__(__portid, __value))

/* MSC-compatible macros for port I/O */
#define inp(__portid)               __inportb__ (__portid)
#define outp(__portid, __value)     __outportb__(__portid, (unsigned char)__value)
#define inpw(__portid)              __inportw__ (__portid)
#define outpw(__portid, __value)    __outportw__(__portid, __value)

#endif  /* _PORT_DEFS */

#ifdef __cplusplus
}
#endif


#endif  /* __CONIO_H */
