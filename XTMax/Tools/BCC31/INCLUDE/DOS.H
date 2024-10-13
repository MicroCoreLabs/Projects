/*  dos.h

    Defines structs, unions, macros, and functions for dealing
    with MSDOS and the Intel iAPX86 microprocessor family.

    Copyright (c) 1987, 1992 by Borland International
    All Rights Reserved.
*/
#ifndef __DOS_H
#define __DOS_H

#if !defined(___DEFS_H)
#include <_defs.h>
#endif

#if !defined(_RTLDLL)
extern  int _Cdecl  errno;
extern  int _Cdecl  _doserrno;
#else

#ifdef __cplusplus
extern "C" {
#endif
int far * far _Cdecl __getErrno(void);
int far * far _Cdecl __getDOSErrno(void);
#ifdef __cplusplus
}
#endif

#define errno (*__getErrno())
#define _doserrno (*__getDOSErrno())
#endif

#ifndef __DLL__

/* Variables */
extern  int const _Cdecl _8087;
extern  int       _Cdecl _argc;
extern  char    **_Cdecl _argv;
extern  char    **_Cdecl  environ;

extern  unsigned      _Cdecl _psp;
extern  unsigned      _Cdecl _heaplen;
extern  unsigned char _Cdecl _osmajor;
extern  unsigned char _Cdecl _osminor;
extern  unsigned      _Cdecl _stklen;
extern  unsigned      _Cdecl _fpstklen;
extern  unsigned      _Cdecl _version;
extern  unsigned      _Cdecl _osversion;      /* MSC name for _version */

#endif  /* __DLL__*/


#define FA_NORMAL   0x00        /* Normal file, no attributes */
#define FA_RDONLY   0x01        /* Read only attribute */
#define FA_HIDDEN   0x02        /* Hidden file */
#define FA_SYSTEM   0x04        /* System file */
#define FA_LABEL    0x08        /* Volume label */
#define FA_DIREC    0x10        /* Directory */
#define FA_ARCH     0x20        /* Archive */

/* MSC names for file attributes */

#define _A_NORMAL   0x00        /* Normal file, no attributes */
#define _A_RDONLY   0x01        /* Read only attribute */
#define _A_HIDDEN   0x02        /* Hidden file */
#define _A_SYSTEM   0x04        /* System file */
#define _A_VOLID    0x08        /* Volume label */
#define _A_SUBDIR   0x10        /* Directory */
#define _A_ARCH     0x20        /* Archive */

#define NFDS    20          /* Maximum number of fds */

struct  fcb {
    char    fcb_drive;      /* 0 = default, 1 = A, 2 = B */
    char    fcb_name[8];    /* File name */
    char    fcb_ext[3];     /* File extension */
    short   fcb_curblk;     /* Current block number */
    short   fcb_recsize;    /* Logical record size in bytes */
    long    fcb_filsize;    /* File size in bytes */
    short   fcb_date;       /* Date file was last written */
    char    fcb_resv[10];   /* Reserved for DOS */
    char    fcb_currec;     /* Current record in block */
    long    fcb_random;     /* Random record number */
};

struct  xfcb    {
    char        xfcb_flag;  /* Contains 0xff to indicate xfcb */
    char        xfcb_resv[5];/* Reserved for DOS */
    char        xfcb_attr;  /* Search attribute */
    struct  fcb xfcb_fcb;   /* The standard fcb */
};

struct  COUNTRY {
    int co_date;
    char    co_curr[5];
    char    co_thsep[2];
    char    co_desep[2];
    char    co_dtsep[2];
    char    co_tmsep[2];
    char    co_currstyle;
    char    co_digits;
    char    co_time;
    long    co_case;
    char    co_dasep[2];
    char    co_fill[10];
};

#if defined(__MSC) && !defined(__cplusplus)
struct  DOSERROR {
        int     exterror;
        char    class;
        char    action;
        char    locus;
};
#else
struct  DOSERROR {
        int     de_exterror;
        char    de_class;
        char    de_action;
        char    de_locus;
};
#endif  /* __MSC and not C++ */

struct  dfree   {
    unsigned df_avail;
    unsigned df_total;
    unsigned df_bsec;
    unsigned df_sclus;
};

struct diskfree_t {
    unsigned total_clusters;
    unsigned avail_clusters;
    unsigned sectors_per_cluster;
    unsigned bytes_per_sector;
};

struct  fatinfo {
    char     fi_sclus;
    char     fi_fatid;
    unsigned fi_nclus;
    int      fi_bysec;
};

struct  devhdr  {
    long        dh_next;        /* Next device pointer */
    short       dh_attr;        /* Attributes */
    unsigned short  dh_strat;   /* Driver strategy routine */
    unsigned short  dh_inter;   /* Driver interrupt routine */
    char        dh_name[8];     /* Device name */
};

struct  time    {
    unsigned char   ti_min;     /* Minutes */
    unsigned char   ti_hour;    /* Hours */
    unsigned char   ti_hund;    /* Hundredths of seconds */
    unsigned char   ti_sec;     /* Seconds */
};

struct dostime_t {
    unsigned char hour;         /* Hours */
    unsigned char minute;       /* Minutes */
    unsigned char second;       /* Seconds */
    unsigned char hsecond;      /* Hundredths of seconds */
};

struct  date    {
    int     da_year;        /* Year - 1980 */
    char        da_day;     /* Day of the month */
    char        da_mon;     /* Month (1 = Jan) */
};

struct dosdate_t {
    unsigned char day;      /* 1-31 */
    unsigned char month;    /* 1-12 */
    unsigned int  year;     /* 1980 - 2099 */
    unsigned char dayofweek;/* 0 - 6 (0=Sunday) */
};

#ifndef _REG_DEFS
#define _REG_DEFS

struct WORDREGS {
    unsigned int    ax, bx, cx, dx, si, di, cflag, flags;
};

struct BYTEREGS {
    unsigned char   al, ah, bl, bh, cl, ch, dl, dh;
};

union   REGS    {
    struct  WORDREGS x;
    struct  BYTEREGS h;
};

struct  SREGS   {
    unsigned int    es;
    unsigned int    cs;
    unsigned int    ss;
    unsigned int    ds;
};

struct  REGPACK {
    unsigned    r_ax, r_bx, r_cx, r_dx;
    unsigned    r_bp, r_si, r_di, r_ds, r_es, r_flags;
};

#endif  /* _REG_DEFS */

typedef struct {
    char    ds_drive;          /* do not change    */
    char    ds_pattern [13];   /*  these fields,       */
    char    ds_reserved [7];   /*   Microsoft reserved */
    char    ds_attrib;
    short   ds_time;
    short   ds_date;
    long    ds_size;
    char    ds_nameZ [13];     /* result of the search, asciiz */
}   dosSearchInfo;  /* used with DOS functions 4E, 4F   */


#ifndef _FFBLK_DEF
#define _FFBLK_DEF
struct  ffblk   {
    char        ff_reserved[21];
    char        ff_attrib;
    unsigned    ff_ftime;
    unsigned    ff_fdate;
    long        ff_fsize;
    char        ff_name[13];
};
#endif  /* _FFBLK_DEF */

/* The MSC find_t structure corresponds exactly to the ffblk structure */
struct find_t {
    char     reserved[21];      /* Microsoft reserved - do not change */
    char     attrib;            /* attribute byte for matched file */
    unsigned wr_time;           /* time of last write to file */
    unsigned wr_date;           /* date of last write to file */
    long     size;              /* size of file */
    char     name[13];          /* asciiz name of matched file */
};

#ifdef __MSC
#define _find_t find_t
#endif

/* axret values for _hardresume() */

#define _HARDERR_IGNORE 0   /* ignore error */
#define _HARDERR_RETRY  1   /* retry the operation */
#define _HARDERR_ABORT  2   /* abort program */
#define _HARDERR_FAIL   3   /* fail the operation */

#define SEEK_CUR    1
#define SEEK_END    2
#define SEEK_SET    0

#ifdef __cplusplus
extern "C" {
#endif

#if !defined( _Windows )
int         _Cdecl absread( int __drive, int __nsects, long __lsect,
                            void _FAR *__buffer );
int         _Cdecl abswrite( int __drive, int __nsects, long __lsect,
                             void _FAR *__buffer );
int         _Cdecl allocmem( unsigned __size, unsigned _FAR *__segp );
#endif

int         _CType _FARFUNC bdos( int __dosfun, unsigned __dosdx, unsigned __dosal );
int         _CType bdosptr( int __dosfun, void _FAR *__argument,
                unsigned __dosal );
struct COUNTRY _FAR *_Cdecl country( int __xcode, struct COUNTRY _FAR *__cp);
void        _Cdecl ctrlbrk( int _Cdecl( *handler )( void ));

#if !defined( _Windows )
void        _CType delay( unsigned __milliseconds );
#endif

void        _Cdecl _FARFUNC disable( void );
int         _Cdecl _FARFUNC dosexterr( struct DOSERROR _FAR *__eblkp );
long        _Cdecl _FARFUNC dostounix( struct date _FAR *__d, struct time _FAR *__t );

unsigned    _Cdecl _dos_allocmem( unsigned __size, unsigned _FAR *__segp );
unsigned    _Cdecl _dos_close ( int __fd );
unsigned    _Cdecl _dos_commit( int __fd );
unsigned    _Cdecl _dos_creat( const char _FAR *__pathP, unsigned __attr,
                int _FAR *__fd );
unsigned    _Cdecl _dos_creatnew( const char _FAR *__pathP, unsigned __attr,
                   int _FAR *__fd );
unsigned    _Cdecl _dos_findfirst( const char _FAR *__path,
                  unsigned __attrib,
                  struct find_t _FAR *__finfo );
unsigned    _Cdecl _dos_findnext( struct find_t _FAR *__finfo );
unsigned    _Cdecl _dos_freemem( unsigned __segx );
void        _Cdecl _dos_getdate( struct dosdate_t _FAR *__datep );
unsigned    _Cdecl _dos_getdiskfree( unsigned __drive,
                      struct diskfree_t _FAR *__dtable);
void        _Cdecl _dos_getdrive( unsigned _FAR *__drive );
unsigned    _Cdecl _dos_getfileattr( const char _FAR *__filename,
                      unsigned _FAR *__attrib );
unsigned    _Cdecl _dos_getftime( int __fd, unsigned _FAR *__date,
                   unsigned _FAR *__time );
void        _Cdecl _dos_gettime( struct dostime_t _FAR *__timep );
void        _Cdecl _dos_keep(unsigned char __status, unsigned __size);
unsigned    _Cdecl _dos_open( const char _FAR *__pathP, unsigned __oflag,
                   int _FAR *__fd );
unsigned    _Cdecl _dos_read( int __fd, void far *__buf, unsigned __len,
                   unsigned _FAR *__nread );
unsigned    _Cdecl _dos_setblock( unsigned __size, unsigned __segx,
                   unsigned _FAR *__maxp );
unsigned    _Cdecl _dos_setdate( struct dosdate_t _FAR *__datep );
void        _Cdecl _dos_setdrive( unsigned __drive, unsigned _FAR *__ndrives );
unsigned    _Cdecl _dos_setfileattr( const char _FAR *__filename,
                      unsigned _FAR __attrib);
unsigned    _Cdecl _dos_setftime( int __fd, unsigned __date, unsigned __time );
unsigned    _Cdecl _dos_settime( struct dostime_t _FAR *__timep );
unsigned    _Cdecl _dos_write( int __fd, const void far *__buf, unsigned __len,
                unsigned _FAR *__nread );

void        __emit__( unsigned char __byte, ...);
void        _Cdecl _FARFUNC enable( void );

#if !defined( _Windows )
int         _Cdecl freemem( unsigned __segx );
#endif

int         _Cdecl getcbrk( void );
void        _CType getdate( struct date _FAR *__datep );
void        _Cdecl getdfree( unsigned char __drive,
                 struct dfree _FAR *__dtable );
int         _Cdecl _getdrive( void );
void        _Cdecl getfat( unsigned char __drive,
               struct fatinfo _FAR *__dtable );
void        _Cdecl getfatd( struct fatinfo _FAR *__dtable );
unsigned    _Cdecl getpsp( void );
int         _Cdecl getswitchar( void );
void        _CType gettime( struct time _FAR *__timep );
int         _Cdecl getverify( void );

#if !defined( _Windows )
#ifdef __cplusplus
void        _Cdecl _harderr( void _Cdecl (far *__fptr)( unsigned __deverr,
                             unsigned __doserr, unsigned far *__hdr) );
#else
void        _Cdecl _harderr( void _Cdecl (far *__fptr)( ) );
#endif
void        _Cdecl _hardresume( int __axret );
void        _Cdecl _hardretn( int __retn );

#ifdef __cplusplus
void        _CType harderr( int _Cdecl( *__handler )( int __errval, int __ax,
                            int __bp, int __si) );
#else
void        _CType harderr( int _Cdecl( *__handler )( ) );
#endif
void        _CType hardresume( int __axret );
void        _CType hardretn( int __retn );
#endif

#ifndef _PORT_DEFS
unsigned        _Cdecl inport ( unsigned __portid );
unsigned char   _Cdecl inportb( unsigned __portid );
unsigned        _Cdecl inpw   ( unsigned __portid );
int             _Cdecl inp    ( unsigned __portid );
#endif

int         _Cdecl int86( int __intno,
                          union REGS _FAR *__inregs,
                          union REGS _FAR *__outregs );
int         _Cdecl int86x( int __intno,
                           union REGS _FAR *__inregs,
                           union REGS _FAR *__outregs,
                           struct SREGS _FAR *__segregs );
int         _Cdecl intdos( union REGS _FAR *__inregs,
                           union REGS _FAR *__outregs );
int         _Cdecl intdosx( union REGS _FAR *__inregs,
                                     union REGS _FAR *__outregs,
                                     struct SREGS _FAR *__segregs );
void        _Cdecl intr( int __intno, struct REGPACK _FAR *__preg );

#if !defined( _Windows )
void        _Cdecl keep( unsigned char __status, unsigned __size );
void        _Cdecl nosound( void );
#endif

#ifndef _PORT_DEFS
void        _Cdecl outport ( unsigned __portid, unsigned __value );
void        _Cdecl outportb( unsigned __portid, unsigned char __value );
unsigned    _Cdecl outpw   ( unsigned __portid, unsigned __value );
int         _Cdecl outp    ( unsigned __portid, int __value );
#endif

char _FAR * _Cdecl parsfnm( const char _FAR *__cmdline,
                       struct fcb _FAR *__fcb, int __opt );
int         _Cdecl peek( unsigned __segment, unsigned __offset );
char        _Cdecl peekb( unsigned __segment, unsigned __offset );
void        _Cdecl poke( unsigned __segment, unsigned __offset, int __value);
void        _Cdecl pokeb( unsigned __segment,
                          unsigned __offset, char __value );

#if !defined( _Windows )
int         _Cdecl randbrd( struct fcb _FAR *__fcb, int __rcnt );
int         _Cdecl randbwr( struct fcb _FAR *__fcb, int __rcnt );
#endif

void        _Cdecl segread( struct SREGS _FAR *__segp );

#if !defined( _Windows )
int         _Cdecl setblock( unsigned __segx, unsigned __newsize );
#endif

int         _Cdecl setcbrk( int __cbrkvalue );
void        _Cdecl setdate( struct date _FAR *__datep );
void        _Cdecl setswitchar( char __ch );
void        _Cdecl settime( struct time _FAR *__timep );
void        _Cdecl setverify( int __value );

#if !defined( _Windows )
void        _Cdecl sleep( unsigned __seconds );
void        _Cdecl sound( unsigned __frequency );
#endif

void        _Cdecl _FARFUNC unixtodos( long __time, struct date _FAR *__d,
                              struct time _FAR *__t );
int         _CType unlink( const char _FAR *__path );

    /* These are in-line functions.  These prototypes just clean up
       some syntax checks and code generation.
     */

void        _Cdecl          __cli__( void );
void        _Cdecl          __sti__( void );
void        _Cdecl          __int__( int __interruptnum );

#define disable( ) __emit__( (char )( 0xfa ) )
#define _disable( ) __emit__( (char )( 0xfa ) ) /* MSC name */
#define enable( )  __emit__( (char )( 0xfb ) )
#define _enable( )  __emit__( (char )( 0xfb ) ) /* MSC name */

#define geninterrupt( i ) __int__( i )      /* Interrupt instruction */

#ifndef _PORT_DEFS
#define _PORT_DEFS

unsigned char   _Cdecl    __inportb__ ( unsigned __portid );
unsigned        _Cdecl    __inportw__ ( unsigned __portid );
unsigned char   _Cdecl    __outportb__( unsigned __portid, unsigned char __value );
unsigned        _Cdecl    __outportw__( unsigned __portid, unsigned __value );

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

#if !__STDC__

extern  unsigned    _Cdecl  _ovrbuffer;
int cdecl far _OvrInitEms( unsigned __emsHandle, unsigned __emsFirst,
                           unsigned __emsPages );
int cdecl far _OvrInitExt( unsigned long __extStart,
                           unsigned long __extLength );

char far *cdecl getdta( void );
void      cdecl setdta( char far *__dta );

#define MK_FP( seg,ofs )( (void _seg * )( seg ) +( void near * )( ofs ))
#define FP_SEG( fp )( (unsigned )( void _seg * )( void far * )( fp ))
#define FP_OFF( fp )( (unsigned )( fp ))

#ifdef __cplusplus
void        _Cdecl _chain_intr ( void interrupt (far *__target)( ... ));
void interrupt( far * _Cdecl _dos_getvect( unsigned __interruptno ))( ... );
void interrupt( far * _CType getvect( int __interruptno ))( ... );
void        _Cdecl _dos_setvect( unsigned __interruptno,
                                 void interrupt( far *__isr )( ... ));
void        _CType setvect( int __interruptno,
                            void interrupt( far *__isr )( ... ));
int  inline _Cdecl peek( unsigned __segment, unsigned __offset )
                  { return( *( (int  far* )MK_FP( __segment, __offset )) ); }
char inline _Cdecl peekb( unsigned __segment, unsigned __offset )
                  { return( *( (char far* )MK_FP( __segment, __offset )) ); }
void inline _Cdecl poke( unsigned __segment, unsigned __offset, int __value )
               {( *( (int  far* )MK_FP( __segment, __offset )) = __value ); }
void inline _Cdecl pokeb( unsigned __segment, unsigned __offset, char __value )
               {( *( (char far* )MK_FP( __segment, __offset )) = __value ); }
#else
void        _Cdecl _chain_intr ( void interrupt (far *__target)( ));
void interrupt( far * _Cdecl _dos_getvect( unsigned __interruptno ))( );
void interrupt( far * _CType getvect( int __interruptno ))( );
void        _Cdecl _dos_setvect( unsigned __interruptno,
                void interrupt( far *__isr )( ));
void        _CType setvect( int __interruptno,
                void interrupt( far *__isr )( ) );
#define peek( a,b )( *( (int  far* )MK_FP( (a ),( b )) ))
#define peekb( a,b )( *( (char far* )MK_FP( (a ),( b )) ))
#define poke( a,b,c )( *( (int  far* )MK_FP( (a ),( b )) ) =( int )( c ))
#define pokeb( a,b,c )( *( (char far* )MK_FP( (a ),( b )) ) =( char )( c ))
#endif  /* __cplusplus */

#endif  /* !__STDC__ */


#ifdef __cplusplus
}
#endif

#endif  /* __DOS_H */

