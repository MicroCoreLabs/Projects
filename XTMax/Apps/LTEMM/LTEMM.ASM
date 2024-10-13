		PAGE	90,132
		NAME	LTEMM
                include LTEMM.MAC	; macros
                include LTEMM.INC	; structures
;
;************************************************************************
;*							        	*
;*	EMS 4.0 Driver for Lo-tech 2MB EMS Board, rev.01, Mar-14	*
;*							        	*
;*	http://www.lo-tech.co.uk/wiki/2MB-EMS-Board			*
;*	http://www.lo-tech.co.uk/wiki/LTEMM.EXE				*
;*									*
;*	This code is TASM source.					*
;*									*
;*	Based on original works Copyright (c) 1988, Alex Tsourikov.	*
;*	All rights reserved.						*
;*									*
;*	Original source kindly provided subject to the BSD 3-Clause	*
;*	License: http://opensource.org/licenses/BSD-3-Clause		*
;*									*
;*	This software, as modified, is provided subject to the terms 	*
;*	of use at: 							*
;*									*
;*	http://www.lo-tech.co.uk/wiki/lo-tech.co.uk:General_disclaimer	*
;*									*
;*	No charge has been made for this software.			*
;*									*
;************************************************************************

code		SEGMENT
		ASSUME	CS:code

		ORG	0000H

		; DEVICE header block
emmdrv		DW	-1,-1		;Link to next device (none)
		DW	8000H
		DW	OFFSET emmstat
		DW	OFFSET emmint
		DB	'EMMXXXX0'	; required - this is how apps
					; detect EMS driver is present

ptrsav		LABEL	DWORD
parofs		DW	0
parseg		DW	0

;--------------------------------------------------------------------
;	EMM driver work data area
;--------------------------------------------------------------------
emsio		LABEL	WORD
ems_io		DW	260h		;Default EMS i/o port address
emm_flag	db	0		;EMM driver install status
backup_count	DB	0		;mapping data backup count
OSE_flag	DW	0		;OS/E function enable flag
OSE_fast	DW	0		;OS/E fast access flag
access_key_h	DW	0		;OS/E access key high
access_key_l	DW	0		;OS/E access key low
alter_map	LABEL	DWORD
alter_map_off	DW	0
alter_map_seg	DW	0
page_ptr	DW	alloc_page	;allocate page buffer pointer.
page_frame_seg	DW	0E000h		;Default physical page frame address
total_pages	DW	PAGE_MAX	;total logical page count
un_alloc_pages	DW	PAGE_MAX	;unallocate logical page count
handle_count	DW	0		;EMM handle used count
jump_addr	DW	0		;EMM function jump address data area
;
;	physical page status data area
;
map_table	LABEL	phys_page_struct
		DB	SIZE phys_page_struct * PHYS_PAGES DUP (-1)
;
;	handle status flag buffer pointers (handle)
;
alloc_page_count LABEL	BYTE
;
;	allocate page count buffer pointers (handle)
;
handle_flag	equ     $+1
		dw	HANDLE_CNT DUP(0)
;
;	mapping data backup buffer pointers (handle)
;
back_address	LABEL	WORD
		dw	HANDLE_CNT DUP(0)
;
;	allocate pages buffer pointers (handle)
;
page_address	LABEL	WORD
		dw	HANDLE_CNT DUP(0)
;
;	mapping data backup area
;
backup_map	LABEL	WORD
		db	SIZE phys_page_struct * PHYS_PAGES * BACK_MAX DUP(-1)
;
;       backup area status flags
;
backup_flags    LABEL   BYTE
                db      BACK_MAX DUP(0)
;
;	allocate data area
;
alloc_page	LABEL	WORD
		dw	PAGE_MAX DUP(-1)
;
;	logical page kanri data
;	55AAH:not used , 0 - 254:used , FFFFH:bad or non
;
log_page	LABEL	WORD
		dw	PAGE_MAX DUP(-1)
;
;====================================================================
;
;	Define offsets for io data packet
;
iodat		STRUC
	cmdlen	DB	?	;LENGTH OF THIS COMMAND
	unit	DB	?	;SUB UNIT SPECIFIER
	cmd	DB	?	;COMMAND CODE
	status	DW	?	;STATUS
		DB	8 DUP (?)
	media	DB	?	;MEDIA DESCRIPTOR
	trans	DD	?	;TRANSFER ADDRESS
	count	DW	?	;COUNT OF BLOCKS OR CHARACTERS
	start	DW	?	;FIRST BLOCK TO TRANSFER
iodat		ENDS

;
;	Define offsets for io data packet 2
;
iodat2		STRUC
		DB	13 DUP (?)
		DB	?
	brkoff	DW	?	;BREAK ADDRESS (OFFSET)
	brkseg	DW	?	;BREAK ADDRESS (SEGMENT)
iodat2		ENDS

;
; Simplistic Strategy routine for non-multi-Tasking system.
;
;	Currently just saves I/O packet pointers in PTRSAV for
;	later processing by the individual interrupt routines.
;
emmstat		PROC	FAR
		MOV	CS:parofs,BX	;
		MOV	CS:parseg,ES	;
		RET
emmstat		ENDP

;
; Common program for handling the simplistic I/O packet
;	processing scheme in MSDOS
;
emmint		PROC	FAR
		PUSH	AX BX DS
		LDS	BX,CS:ptrsav	;Retrieve pointer to I/O Packet.
		MOV	AL,[BX].cmd	;Retrieve Command type. (1 => 16)
		CMP	AL,10h		;Verify that not more than 16 commands.
		JA	cmderr		;Ah, well, error out.
		OR	AL,AL		;init. command?
		JNZ	emmchk		;check EMS flag.
		JMP	emminit		;EMS Driver initial.
cmderr:
		MOV	AL,3		;Set unknown command error #.
err_exit:				;
		MOV	AH,10000001B	;Set error and done bits.
		JMP	short exit1 	;Quick way out.
;
;	EMM driver install check routine
;
emmchk:
		CMP	CS:emm_flag,1	;EMM install flag on?
		JNZ	err_exit	;no
exit:
		MOV	AH,00000001B	;Set done bit for MSDOS.
exit1:
		LDS	BX,CS:ptrsav	;Retrieve pointer to I/O Packet.
		MOV	[BX].status,AX	;Save operation compete and status.
		POP	DS BX AX
		RET
emmint		ENDP

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;--------------------------------------------------------------------
;	int 67H EMM driver main routine
;--------------------------------------------------------------------
int67		PROC	FAR
		CLI
		SUB	SP,EMMWORK
		PUSH	DS ES BP DI SI DX CX BX
		MOV	BP,SP
		CLD
		PUSH	CS
		POP	DS

		ASSUME	DS:code

		CMP	AH,40H			; function code check
		JC	err84			; FUNCTION 1 - 30 ?
f_max           equ     $+2
		CMP	AH,5EH
		JNC	err84
		PUSH	BX
		MOV	jump_addr,AX
		XCHG	AH,AL
		AND	AL,0BFH
		CBW
		SHL	AX,1
		MOV	BX,AX
		MOV	AX,func_table[BX]
		XCHG	AX,jump_addr
		POP	BX
		JMP	jump_addr		;---- jump to functions -----
noerr:						;normal return point.
		XOR	AH,AH
err_ret:					;error return point.
		POP	BX CX DX SI DI BP ES DS
		ADD	SP,EMMWORK
		IRET
int67		ENDP

;--------------------------------------------------------------------
;	error status set routine
;--------------------------------------------------------------------

;The manager detected a malfunction in the EMM software.
err80:
		MOV	AH,80H
		JMP	err_ret

;The manager detected a malfunction in the expanded memory hardware.
;err81:
;		MOV	AH,81H
;		JMP	err_ret

;The EMM couldn't find the EMM handle your program specified.
err83:
		MOV	AH,83H
		JMP	err_ret

;The function code passed to the EMM is not defined.
err84:
		MOV	AH,84H
		JMP	err_ret

;All EMM handles are being used.
err85:
		MOV	AH,85H
		JMP	err_ret

;The EMM detected a "save" or "restore" page mapping context error.
err86:
		MOV	AH,86H
		JMP	err_ret

;There aren't enough expanded memory pages to satisfy your program's request.
err87:
		MOV	AH,87H
		JMP	err_ret

;There aren't enough unallocated pages to satisfy your program's request.
err88:
		MOV	AH,88H
		JMP	err_ret

;Can't allocate zero (0) pages.
err89:
		MOV	AH,89H
		JMP	err_ret

;The logical page is out of the range of logical pages which are allocated to
;the EMM handle.
err8a:
		MOV	AH,8AH
		JMP	err_ret

;The physical page to which the logical page is mapped is out of the range of
;physical pages.
err8b:
		MOV	AH,8BH
		JMP	err_ret

;The page mapping hardware state save area is full.
err8c:
		MOV	AH,8CH
		JMP	err_ret

;The page mapping hardware state save area already has a state associated with
;the EMM handle.
err8d:
		MOV	AH,8DH
		JMP	err_ret

;The page mapping hardware state save area doesn't have a state associated with
;the EMM handle.
err8e:
		MOV	AH,8EH
		JMP	err_ret

;The subfunction parameter passed to the function isn't defined.
err8f:
		MOV	AH,8FH
		JMP	err_ret

;The attrbute type is undefined.
err90:
		MOV	AH,90H
		JMP	err_ret

;The system configuration does not support non_volatility.
err91:
		MOV	AH,91H
		JMP	err_ret

;The source and destination expanded memory region have the same handle and
;overlap. (move)
err92:
		MOV	AH,92H
		JMP	err_ret

;The length of the specified source or destination expanded memory region
;exceeds the length of the expanded memory region allocated to the specified
;source or destination handle.
err93:
		MOV	AH,93H
		JMP	err_ret

;The conventional memory region and expanded memory region overlap.
err94:
		MOV	AH,94H
		JMP	err_ret

;The offset within the logical page exceeds the length of the logical page.
err95:
		MOV	AH,95H
		JMP	err_ret

;Region length exceeds 1M_byte limit.
err96:
		MOV	AH,96H
		JMP	err_ret

;The source and destination expanded memory region have the same handle and
;overlap. (exchanged)
err97:
		MOV	AH,97H
		JMP	err_ret

;The memory source and destination type are undefined/not supported.
err98:
		MOV	AH,98H
		JMP	err_ret

;Alternate map register serts are supported, but the alternate map register set
;specified is not support.
err9a:
		MOV	AH,9AH
		JMP	err_ret

;Alternate map/DMA register sets are supported. However, all alternate map/DMA
;register sets are currently allocated.
err9b:
		MOV	AH,9BH
		JMP	err_ret

;Alternate map/DMA register sets are not supported, and the alternate map/DMA
;register set specified is not zero.
err9c:
		MOV	AH,9CH
		JMP	err_ret

;Alternate map register serts are supported, but the alternate map register set
;specified is not defined, not allocated, or is the currently allocated map
;register set.
err9d:
		MOV	AH,9DH
		JMP	err_ret

;Dedicated DMA channels are not supported.
err9e:
		MOV	AH,9EH
		JMP	err_ret

;Dedicated DMA channels are not supported. But the DMA channel specified is not
;supported.
err9f:
		MOV	AH,9FH
		JMP	err_ret

;No corresponding handle value could be found for the handle name specified.
erra0:
		MOV	AH,0A0H
		JMP	err_ret

;A handle with this name already exists.
erra1:
		MOV	AH,0A1H
		JMP	err_ret

;An attempt was made to "wrap around" the 1M_byte address space during the
;move/exchange.
erra2:
		MOV	AH,0A2H
		JMP	err_ret

;The contents of the data structure passed to the function have either been
;corrupted or are meaningless.
erra3:
		MOV	AH,0A3H
		JMP	err_ret

;The operating system has denied access to the this function.
erra4:
		MOV	AH,0A4H
		JMP	err_ret

;--------------------------------------------------------------------
;	EMM driver function jump table
;		(40H - 5DH)
;--------------------------------------------------------------------
func_table	LABEL	WORD
		DW	OFFSET noerr
		DW	OFFSET func2
		DW	OFFSET func3
		DW	OFFSET func4
		DW	OFFSET func5
		DW	OFFSET func6
		DW	OFFSET func7
		DW	OFFSET func8
		DW	OFFSET func9
		DW	OFFSET err84
		DW	OFFSET err84
		DW	OFFSET func12
		DW	OFFSET func13
		DW	OFFSET func14
		DW	OFFSET func15
		DW	OFFSET func16
		DW	OFFSET func17
		DW	OFFSET func18
		DW	OFFSET func19
		DW	OFFSET func20
		DW	OFFSET func21
		DW	OFFSET func22
		DW	OFFSET func23
		DW	OFFSET func24
		DW	OFFSET func25
		DW	OFFSET func26
		DW	OFFSET func27
		DW	OFFSET func28
		DW	OFFSET func29
		DW	OFFSET func30

;========================================================================

;--------------------------------------------------------------------
; Set physical page map.
; output
;	CF = 0	: OK
;	CF = 1	: NG
;--------------------------------------------------------------------
set_pages_map	PROC	NEAR
		PUSH	AX CX DX DI
		MOV	DI,OFFSET map_table
		MOV	CX,PHYS_PAGES
set_pages_map2:
		MOV	DX,CS:[DI].phys_page_port
		MOV	AL,CS:[DI].log_page_data
		OUT	DX,AL                   ;mapping physical pages...
		ADD	DI,SIZE phys_page_struct
		LOOP	set_pages_map2
		POP	DI DX CX AX
		RET
set_pages_map	ENDP
;--------------------------------------------------------------------
; Reset physical page.
; input
;	AL	: physical page no.
;--------------------------------------------------------------------
reset_phys_page	PROC	NEAR
		PUSH	AX CX DX DI
		cbw
		MOV	DI,OFFSET map_table
		MOV	CL,SIZE phys_page_struct
		MUL	CL
		ADD	DI,AX
		MOV	DX,CS:[DI].phys_page_port
		MOV	AL,DIS_EMS
		OUT	DX,AL
		MOV	CS:[DI].emm_handle2,UNMAP
		MOV	CS:[DI].log_page_data,AL;logical page no.
		POP	DI DX CX AX
		RET
reset_phys_page	ENDP
;--------------------------------------------------------------------
; Check mapping data.
; input
;	ES:DI	: pointer to mapping data
; output
;	CF = 0	: OK
;	CF = 1	: NG
;--------------------------------------------------------------------
check_map_data	PROC	NEAR
		PUSH	AX CX SI DI
		MOV	SI,OFFSET map_table
		MOV	CX,PHYS_PAGES
check_map_data3:
		MOV	AX,ES:[DI].phys_page_port
		CMP	AX,CS:[SI].phys_page_port
		jne	check_map_data1
		MOV	AX,ES:[DI].phys_seg_addr
		CMP	AX,CS:[SI].phys_seg_addr
		jne	check_map_data1
		ADD	SI,SIZE phys_page_struct
		ADD	DI,SIZE phys_page_struct
		LOOP	check_map_data3
		CLC
check_map_data2:
		POP	DI SI CX AX
		RET
check_map_data1:
		STC
		JMP	check_map_data2
check_map_data	ENDP
;------ function 1 --------------------------------------------------
; Get status
; output
;	AH	: status
;--------------------------------------------------------------------
;               Same as noerr
;------ function 2 --------------------------------------------------
; Get page frame address
; output
;	AH	: status
;	BX	: page segment address
;--------------------------------------------------------------------
func2:
		STI
		MOV	BX,page_frame_seg	;get EMM physical page segment
f21:						; address.
		MOV	[BP].bx_save,BX
		JMP	noerr			;exit

;------ function 3 --------------------------------------------------
; Get unallocated page count
; output
;	AH	: status
;	BX	: unallocate page
;	DX	: all page
;--------------------------------------------------------------------
func3:						;v0.5....
		MOV	DX,total_pages		;Get total page count
		MOV	BX,un_alloc_pages	;Get unallocated page count
		MOV	[BP].dx_save,DX		;Save all page count
		JMP	f21

;------ function 4 --------------------------------------------------
; Allocate pages
; input
;	BX	: request allocate page
; output
;	AH	: status
;	DX	: EMM handle
;--------------------------------------------------------------------
func4:						;v0.6....
		OR	BX,BX			;request page size 0 ?
		JZ	f49			;yes
;------ function 27 -------------------------------------------------
; Allocate raw pages
; input
;	BX	: num_of_raw_pages_to_alloc
; output
;	AH	: status
;	DX	: raw handle
;--------------------------------------------------------------------
func27:

f41:
		CMP	total_pages,BX		;request total size over ?
		jb	f42			;yes
		CMP	un_alloc_pages,BX	;request unallocate size over ?
		jb	f43			;yes
		XOR	SI,SI
		MOV	CX,HANDLE_CNT
f45:
		CMP	byte ptr [SI].handle_flag,0;not used EMM handle ?
		je	f44
		ADD	SI,FLAG_SIZE		;add handle flag size
		LOOP	f45
		JMP	err85			;error exit
f44:
                MOV     DX,SI
                SHR     DX,1
		MOV	byte ptr [SI].handle_flag,1;handle active flag set
		INC	handle_count		;used EMM handle count up
		SUB	un_alloc_pages,BX	;unallocated page - BX
		MOV	[SI].alloc_page_count,bl;EMM handle used page count set
		MOV	[SI].back_address,0	;backup address clear
		MOV	DI,page_ptr
		MOV	[SI].page_address,DI	;set page buffer pointer
		push	cs
		pop	es
		MOV	SI,OFFSET log_page
		XOR	AX,AX
		MOV	CX,BX
                jcxz    f48
		jmp	short f47
f4a:
		ADD	SI,LOG_SIZE
		INC	AX
f47:
		CMP	WORD PTR [SI],NOT_USE	;unallocated page ?
		JNZ	f4a
		MOV	[SI],DX			;EMM handle set
		STOSW				;logical page no. set
		LOOP	f4a
f48:
		MOV	[BP].dx_save,DX		;return EMM handle
		MOV	page_ptr,DI
		JMP	noerr			;exit
f49:
		JMP	err89			;error exit
f42:
		JMP	err87			;error exit
f43:
		JMP	err88			;error exit

;------ function 5 --------------------------------------------------
; Map handle pages
; input
;	AL	: physical page no.
;	BX	: logical page no. (if BX=FFFFH then unmap)
;	DX	: EMM handle
; output
;	AH	: status
;--------------------------------------------------------------------
func5:						;v0.6....
		CMP	AL,PHYS_PAGES		;physical page no. ok ?
		jnb	f51			;no
		CMP	DX,HANDLE_CNT		;check handle data...
		jnb	f5a
		MOV	SI,DX
		SHL	SI,1
		CMP	byte ptr [SI].handle_flag,0;active handle ?
		je	f5a
		MOV	DI,OFFSET map_table	;get phys_page_struct pointer..
		mov	cl,al
		MOV	AX,SIZE phys_page_struct
		MUL	CL
		ADD	DI,AX
		CMP	BX,UNMAP		;unmap ?
		JZ	f57
		CMP	bl,[SI].alloc_page_count;logical page no. OK ?
		jnb	f53
		SHL	BX,1
		ADD	BX,[SI].page_address
		MOV	AX,[BX]
;               OR      AL,80h
f58:
		CMP	DX,[DI]			;same handle ?
		JNZ	f54
		CMP	AL,[DI].log_page_data	;same page no. ?
		JZ	f56
f54:
		MOV	[DI],DX			;set handle
		MOV	[DI].log_page_data,AL	;set logical page no. data
		MOV	DX,[DI].phys_page_port
		OUT	DX,AL
f56:
		JMP	noerr			;exit
f57:
		xor	al,al
		MOV	DX,bx
		JMP	f58
f51:
		JMP	err8b			;error exit
f53:
		JMP	err8a			;error exit
f5a:
		JMP	err83			;error exit

;------ function 6 --------------------------------------------------
; Deallocate pages
; input
;	DX	: EMM handle
; output
;	AH	: status
;--------------------------------------------------------------------
f63:
		JMP	err86			;error exit
func6:
		push	CS
		pop	ES
		CMP	DX,HANDLE_CNT		;check handle data...
		JNC	f5a
		MOV	BX,DX
		SHL	BX,1
		CMP	byte ptr [BX].handle_flag,0;handle OK ?
		JZ	f5a
		CMP	[BX].back_address,0	;backup used?
		JNZ	f63
		MOV	cl,[BX].alloc_page_count
                xor     ch,ch
		JCXZ	f6c			;page = 0 ?
		add	un_alloc_pages,cx	;add unallocated pages
		MOV	DI,[BX].page_address	;deallocate logical page...
                mov     si,di
		PUSH	BX
f65:
		MOV	BX,[si]
		SHL	BX,1
		MOV	[BX].log_page,NOT_USE
		add	si,2
		LOOP	f65
		POP	BX
		MOV	CX,page_ptr
		SUB	CX,SI
		SHR	CX,1
		JCXZ	f62
		REPZ	MOVSW
f62:
		MOV	cl,[BX].alloc_page_count
                xor     ch,ch
		JCXZ	f68
		MOV	AX,UNALLOC
		REPZ	STOSW
f68:
		XOR	DI,DI			;change page address....
		MOV	SI,[BX].page_address	;get page address.
		MOV	al,[BX].alloc_page_count;get allocated page count.
                xor     ah,ah
		SHL	AX,1
		MOV	CX,handle_count
		JMP	short f66
f6b:
		ADD	DI,FLAG_SIZE
f66:
		CMP	byte ptr [DI].handle_flag,0;active handle ?
		JZ	f6b
		CMP	[DI].page_address,SI	;page_address > SI ?
		JNG	f64
		SUB	[DI].page_address,AX	;page address - AX
f64:
		LOOP	f6b
		SUB	page_ptr,AX		;SUB page pointer
		MOV	CX,PHYS_PAGES		;deallocate physical page...
		XOR	AL,AL
		MOV	SI,OFFSET map_table
f6a:
		CMP	[SI],DX			;same handle no.?
		JNZ	f67
		CALL	reset_phys_page		;reset physical page.
f67:
		INC	AL
		ADD	SI,SIZE phys_page_struct
		LOOP	f6a
f6c:
		MOV	word ptr [BX].alloc_page_count,0
		MOV	[BX].page_address,0	;clear handle page pointer
		MOV	[BX].back_address,0	;clear handle back pointer
                cmp     byte ptr f7_ver,32h
                je      f6e
		MOV	DI,OFFSET handle_name	;clear handle name data...
		MOV	AX,DX
		MOV	CL,3
		SHL	AX,CL
		ADD	DI,AX
		xor	ax,ax
		MOV	CX,HANDLE_NAME_SIZE/2
		REPZ	stosw
f6e:
		OR	DX,DX			;system handle?
		JZ	f6d
		DEC	handle_count		;not use handle count up
		JMP	noerr			;exit
f6d:
		MOV	byte ptr [BX].handle_flag,1
		JMP	noerr			;exit

;------ function 7 --------------------------------------------------
; Get EMS version
; output
;	AH	: status
;	AL	: EMS version number
;--------------------------------------------------------------------
func7:
		STI
f7_ver          equ     $+1
		MOV	AL,40h  		;get version no.
		JMP	noerr

;------ function 8 --------------------------------------------------
; Save page map
; input
;	DX	: EMM handle
; output
;	AH	: status
;--------------------------------------------------------------------
func8:						;v0.6....
		push	CS
		pop	ES
		CMP	DX,HANDLE_CNT		;check handle data
		JNC	f81
		MOV	SI,DX
		SHL	SI,1
		CMP	byte ptr [SI].handle_flag,1;handle OK ?
		JNZ	f81
		CMP	[SI].back_address,0	;backup ?
		JNZ	f82
		MOV	AL,backup_count
		CMP	AL,BACK_MAX
		jb	f83
f84:
		JMP	err8c			;error exit
f83:
		MOV	DI,offset backup_flags	;copy mapping data -> [DI]
                mov     cx,BACK_MAX             ;v1.01
                xor     al,al
                repnz   scasb                   ;Search for free region
                jnz     f84
                dec     di
                mov     byte ptr [di],1         ;Set busy flag
                sub     di,offset backup_flags
                mov     ax,di
                mov     cl,CONTEXT_SIZE
                mul     cl
                add     ax,offset backup_map
                mov     di,ax
		MOV	[SI].back_address,DI
		MOV	SI,OFFSET map_table
		MOV	CX,CONTEXT_SIZE/2
		REPZ	MOVSW
		INC	backup_count
		JMP	noerr
f81:
		JMP	err83
f82:
		JMP	err8d

;------ function 9 --------------------------------------------------
; Restore page map
; input
;	DX	: EMM handle
; output
;	AH	: status
;--------------------------------------------------------------------
func9:
		push	CS
		pop	ES
		CMP	DX,HANDLE_CNT		;check handle data
		JNC	f81
		MOV	BX,DX
		SHL	BX,1
		CMP	byte ptr [BX].handle_flag,1;handle OK ?
		JNZ	f81
		CMP	[BX].back_address,0	;backup ?
		JZ	f92
		MOV	CX,CONTEXT_SIZE/2 	;move mapping data...
		MOV	SI,[BX].back_address
		MOV	DI,OFFSET map_table
		PUSH	DI
		REPZ	MOVSW
		POP	DI
		CALL	set_pages_map		;enable physical pages...
		DEC	backup_count		;backup mapping count DEC
		MOV	ax,[BX].back_address	;v1.01
                sub     ax,offset backup_map
                mov     cl,CONTEXT_SIZE
                div     cl
                add     ax,offset backup_flags
                mov     di,ax
                mov     byte ptr [di],0         ;Set free flag
		MOV	[BX].back_address,0
		JMP	noerr			;exit
f92:
		JMP	err8e

;------ function 10 -------------------------------------------------
; Get page mapping register I/O port array
; input
;	ES:DI	: buffer address point
; output
;	AH	: status
;	AL	: board count
;--------------------------------------------------------------------
;       Not supported on 4.0 : err84
;------ function 11 -------------------------------------------------
; Get logical-to-physical page translation array
; input
;	DX	: EMM handle
;	ES:DI	: buffer address point
; output
;	AH	: status code
;	BX	: number of pages allocated EMM handle.
;--------------------------------------------------------------------
;       Not supported on 4.0 : err84
;------ function 12 -------------------------------------------------
; Get EMM handle count
; output
;	AH	: status
;	BX	: active EMM handles
;--------------------------------------------------------------------
func12:
		STI
		MOV	BX,handle_count
f121:
		MOV	[BP].bx_save,BX
		JMP	noerr			;exit

;------ function 13 -------------------------------------------------
; Get EMM handle pages
; input
;	DX	: EMM handle
; output
;	AH	: status
;	BX	: pages EMM handle
;--------------------------------------------------------------------
func13:						;v0.6....
		STI
		CMP	DX,HANDLE_CNT		;check handle data
		jnb	f131
		MOV	SI,DX
		SHL	SI,1
		CMP	byte ptr [SI].handle_flag,1;handle OK ?
		jne	f131
		MOV	bl,[SI].alloc_page_count
                xor     bh,bh
		jmp	f121			;exit
f131:
		JMP	err83			;error exit
;------ function 14 -------------------------------------------------
; Get all EMM handle pages
; input
;	ES:DI	: buffer address point
; output
;	AH	: status
;	BX	: number of active EMM handles
;--------------------------------------------------------------------
func14:
		STI
		XOR	SI,SI
		MOV	CX,HANDLE_CNT
		XOR	BX,BX
		XOR	DX,DX
f142:
		CMP	byte ptr [SI].handle_flag,0
		JZ	f141
		MOV	AX,DX
		STOSW
		MOV	al,[SI].alloc_page_count;v0.5
                xor     ah,ah
		STOSW
		INC	BX
f141:
		INC	DX
		ADD	SI,FLAG_SIZE
		LOOP	f142
		JMP	f121

;------ function 15 -------------------------------------------------
; Get/set page map
; input
;	AL	: request subfunction no.
;	ES:DI	: mapping registers buffer address point
; output
;	AH	: status
;--------------------------------------------------------------------
func15:
                cbw
		dec	ax
		js	get_page_map		; 0
		jz	set_page_map		; 1
		dec	ax
		jz	get_set_page_map	; 2
		dec	ax
		jz	get_size_page_map	; 3
		jmp	err84			;error exit

;--------------------------------------------------------------------
; Get page map.
; input
;	ES:DI	: dest_page_map
; output
;	AH	: status
;--------------------------------------------------------------------
get_page_map:
		MOV	SI,OFFSET map_table
		MOV	CX,CONTEXT_SIZE/2
		REPZ	MOVSW
		JMP	noerr			;exit

;--------------------------------------------------------------------
; Set page map.
; input
;	DS:SI	: source_page_map
; output
;	AH	: status
;--------------------------------------------------------------------
set_page_map:
		MOV	AX,[BP].ds_save
		MOV	DS,AX
		MOV	CX,CONTEXT_SIZE/2
		MOV	AX,SS
		MOV	ES,AX
		LEA	DI,[BP].f15_map_data	;save map data.
		REPZ	MOVSW
set_page_map3:
		LEA	DI,[BP].f15_map_data
		CALL	check_map_data		;check map data (ES:DI)
		JC	set_page_map2
		MOV	AX,ES
		MOV	DS,AX
		MOV	SI,DI
                push    cs
		pop	es
		MOV	DI,OFFSET map_table
		MOV	CX,CONTEXT_SIZE/2
		REPZ	MOVSW
		CALL	set_pages_map		;mapping physical pages.
		JMP	noerr			;exit
set_page_map2:
		JMP	erra3			;error exit

;--------------------------------------------------------------------
; Get & set page map.
; input
;	DS:SI	: source_page_map
;	ES:DI	: dest_page_map
; output
;	AH	: status
;--------------------------------------------------------------------
get_set_page_map:
		PUSH	DI DS ES
		MOV	AX,[BP].ds_save
		MOV	DS,AX
		MOV	AX,SS
		MOV	ES,AX
		LEA	DI,[BP].f15_map_data
		MOV	CX,CONTEXT_SIZE/2
		REPZ	MOVSW
		POP	ES DS DI
		MOV	SI,OFFSET map_table	;move current map data...
		MOV	CX,CONTEXT_SIZE/2
		REPZ	MOVSW
		MOV	AX,SS
		MOV	ES,AX
		JMP	set_page_map3

;--------------------------------------------------------------------
; Get size of page map save array.
; output
;	AH	: status
;	AL	: size_of_array
;--------------------------------------------------------------------
get_size_page_map:
		MOV	AL,CONTEXT_SIZE		;map data size set.
		JMP	noerr
;
;       This is end of EMS 3 function set
;
;------ function 16 -------------------------------------------------
; Get/set partial page map
;--------------------------------------------------------------------
func16:
                cbw
		dec	ax
		js	get_partial_map		; 0
		jz	set_partial_map		; 1
		dec	ax
		jz	get_size_partial_map	; 2
		jmp	err84			;error exit
;--------------------------------------------------------------------
; Get size of partial page map save array
; input
;	BX	: number of pages in the partial array
; output
;	AH	: status
;	AL	: size_of_partial_save_array
;--------------------------------------------------------------------
get_size_partial_map:
		OR	BX,BX			;BX = 0?
		JZ	get_size_partial_map1
		CMP	BX,PHYS_PAGES		;BX > physical page count?
		JG	get_size_partial_map2
		MOV	AX,SIZE phys_page_struct;get size of partial map array.
		MUL	BL
		ADD	AX,2
		JMP	noerr			;exit
get_size_partial_map1:
		JMP	err8f			;error exit
get_size_partial_map2:
		JMP	err8b			;error exit

;--------------------------------------------------------------------
; Get partial page map
; input
;	DS:SI	: partial_page_map
;	ES:DI	: dest_array
; output
;	AH	: status
;--------------------------------------------------------------------
get_partial_map:
		MOV	AX,[BP].ds_save
		MOV	DS,AX
		LODSW
		CMP	AX,PHYS_PAGES
		JG	get_partial_map1	;rel. 0.2
		MOV	CX,AX
		JCXZ	get_partial_map5	;page count = 0?
		STOSW
get_partial_map4:
		LODSW
		PUSH	CX
		MOV	BX,OFFSET map_table
		MOV	CX,PHYS_PAGES
get_partial_map3:
		CMP	AX,CS:[BX].phys_seg_addr
		JZ	get_partial_map2
		ADD	BX,SIZE phys_page_struct
		LOOP	get_partial_map3
		POP	CX
		JMP	err8b			;error exit
get_partial_map2:
		PUSH	SI DS
		PUSH	CS
		POP	DS
		MOV	SI,BX
		MOV	CX,SIZE phys_page_struct
		REPZ	MOVSB
		POP	DS SI CX
		LOOP	get_partial_map4
get_partial_map5:
		JMP	noerr			;exit
get_partial_map1:
		JMP	erra4			;error exit

;--------------------------------------------------------------------
; Set partial page map
; input
;	DS:SI	: source_array
; output
;	AH	: status
;--------------------------------------------------------------------
set_partial_map:
		MOV	AX,[BP].ds_save
		MOV	DS,AX
		LODSW
		MOV	[BP].f16_map_len,AX	;save page map data length.
		MOV	CX,SIZE phys_page_struct
		MUL	CL
		MOV	CX,AX
		JCXZ	set_partial_map1
		MOV	AX,SS			;save page map data...
		MOV	ES,AX
		LEA	DI,[BP].f16_map_data
		REPZ	MOVSB
		LEA	SI,[BP].f16_map_data	;set page map data...
		MOV	AX,ES
		MOV	DS,AX
		MOV	AX,CS
		MOV	ES,AX
		MOV	CX,[BP].f16_map_len	;get page map data length.
set_partial_map4:
		MOV	AX,[SI].phys_seg_addr
		CALL	change_seg_page		;change segment -> phys_page_no
		JC	set_partial_map3
		MOV	DI,OFFSET map_table
		PUSH	CX
		MOV	CX,SIZE phys_page_struct
		MUL	CL
		ADD	DI,AX
		REPZ	MOVSB
		POP	CX
		LOOP	set_partial_map4
		CALL	set_pages_map		;mapping physical pages.
set_partial_map1:
		JMP	noerr			;exit
set_partial_map3:
		JMP	err8b			;error exit

;------ function 17 -------------------------------------------------
; Map/unmap multiple handle pages
;--------------------------------------------------------------------
func17:
		STI
		OR	AL,AL
		JZ	log_phys_map
		CMP	AL,1
		JZ	log_phys_map
		JMP	err84			;error exit

;--------------------------------------------------------------------
; Logical page/physical page/segment method
; input
;	AL	: physical page/segment selector
;	DX	: EMM handle
;	CX	: logical to physical map length
;	DS:SI	: pointer to logical to physical/segment map array
; output
;	AH	: status
;--------------------------------------------------------------------
log_phys_map:
		MOV	[BP].f17_ax_save,AX
		MOV	AX,[BP].ds_save
		MOV	DS,AX
		CALL	check_handle		;check handle data.
		JC	log_phys_map2
		CMP	CX,PHYS_PAGES
		ja	log_phys_map1
		JCXZ	log_phys_map9
		MOV	[BP].f17_map_len,CX	;save page map data length.
		MOV	AX,SS
		MOV	ES,AX
		LEA	DI,[BP].f17_map_data	;save page map data.
		SHL	CX,1
		REPZ	MOVSW
		MOV	AX,SS
		MOV	DS,AX
		LEA	SI,[BP].f17_map_data	;set page map data pointer.
		MOV	CX,[BP].f17_map_len	;get page map data length.
log_phys_map7:
		mov	bx,[si].log_page_number1;get logical page no.
		cmp	bx,UNMAP		;unmapping?
		je	log_phys_map6
		call	check_log_page		;check logical page no.
		jc	log_phys_map3		;error?
		mov	bx,ax			;set EMM logical page no.
log_phys_map6:
		mov	ax,[bp].f17_ax_save
		or	al,al			;subfunction 0?
		jnz	log_phys_map8
		mov	ax,[si].phys_page_number1;get physical page no.
		cmp	ax,PHYS_PAGES		;check physical page no.
		jb	log_phys_map4
log_phys_map1:
		jmp	err8b
log_phys_map8:
		mov	ax,[si].mappable_seg_addr;get mappable seg_address.
		call	change_seg_page		;change segment -> phys_page_no
		jc	log_phys_map1
log_phys_map4:
		cmp	bx,UNMAP		;unmapping?
		jz	log_phys_mapa
		call	set_phys_page		;set physical page
		jmp	short log_phys_map5
log_phys_mapa:
		call	reset_phys_page		;reset physical page
log_phys_map5:
		add	si,SIZE log_to_phys_map_struct;
		loop	log_phys_map7
log_phys_map9:
		jmp	noerr			;exit
log_phys_map2:
		jmp	err83
log_phys_map3:
		jmp	err8a

;------ function 18 ------------------------------------------------------
; Reallocate pages
; input
;	DX	: EMM handle
;	BX	: reallocation count
; output
;	AH	: status
;	BX	: number of pages allocated to handle after reallocation
;-------------------------------------------------------------------------
f182:
		JMP	err87
f181:
		MOV	word ptr [BP].bx_save,0
		JMP	err83
func18:
		push	CS
		pop	ES
		CMP	DX,HANDLE_CNT		;check handle data...
		jnb	f181
		MOV	SI,DX
		SHL	SI,1
		CMP	byte ptr [SI].handle_flag,0
		je	f181
		CMP	total_pages,BX		;request total size over ?
		JC	f182			;yes
		MOV	al,[SI].alloc_page_count;get page size to handle
                xor     ah,ah
		OR	BX,BX			;reallocate count = 0?
		JNZ	f184
		MOV	CX,AX
		JCXZ	f18a			;CX = 0 case?
		MOV	DI,[SI].page_address	;BX = 0 case...
		add	un_alloc_pages,ax	;add unallocated pages
		PUSH	BX
f185:
		MOV	BX,[DI]
		SHL	BX,1
		MOV	[BX].log_page,NOT_USE	;unallocate logical page
		add	di,2
		LOOP	f185
		POP	BX
		JMP	short f18l
f184:
		CMP	AX,BX			;check reallocation/allocated
		JNZ	f18c			;pages.
f18a:
		JMP	noerr			;same size case.
f18c:
		JNC	f183			;BX < allocated count?
		JMP	f186
f183:
		MOV	CX,AX			;BX < allocated pages case...
		SUB	CX,BX
		MOV	DI,[SI].page_address	;BX = 0 case...
		MOV	AX,BX
		SHL	AX,1
		ADD	DI,AX
		add	un_alloc_pages,cx	;add unallocated pages
		PUSH	BX
f18b:
		MOV	BX,[DI]
		SHL	BX,1
		MOV	[BX].log_page,NOT_USE	;unallocate logical page
		add	di,2
		LOOP	f18b
		POP	BX
f18l:
		MOV	CX,page_ptr		;clear & sort page buffer...
		MOV	AX,BX
		SHL	AX,1
		ADD	AX,[SI].page_address
		SUB	CX,AX
		PUSH	SI
		MOV	DI,[SI].page_address
		MOV	AX,BX
		SHL	AX,1
		ADD	DI,AX
		MOV	al,[SI].alloc_page_count
                xor     ah,ah
		MOV	SI,[SI].page_address
		SHL	AX,1
		ADD	SI,AX
		SHR	CX,1
		JCXZ	f18e
		REPZ	MOVSW
f18e:
		MOV	CX,page_ptr
		SUB	CX,DI
		SHR	CX,1
		JCXZ	f18f
		MOV	AX,UNALLOC
		REPZ	STOSW
f18f:
		POP	SI
		MOV	al,[SI].alloc_page_count
                xor     ah,ah
		MOV	[SI].alloc_page_count,bl;set EMM handle used page count
		XOR	DI,DI			;change other handle page add-
		SUB	AX,BX			;ress....
		SHL	AX,1
		MOV	BX,[SI].page_address
		MOV	CX,handle_count
		JMP	short f18j
f18k:
		ADD	DI,FLAG_SIZE
f18j:
		CMP	byte ptr [DI].handle_flag,0;active handle ?
		JZ	f18k
		CMP	[DI].page_address,BX	;page_address > BX ?
		JNG	f18m
		SUB	[DI].page_address,AX	;page_address - AX
f18m:
		LOOP	f18k
		SUB	page_ptr,AX		;page_ptr - AX
		CMP	[SI].alloc_page_count,0	;allocate page count = 0 ?
		JNZ	f18o
		MOV	[SI].page_address,0	;clear page buffer pointer
f18o:
		JMP	noerr			;exit.
f187:
		MOV	al,[SI].alloc_page_count
                xor     ah,ah
		MOV	[BP].bx_save,AX
		JMP	err88			;error exit
f186:
		MOV	CX,BX			;BX > allocated pages case...
		SUB	CX,AX
		cmp	un_alloc_pages,cx	;request unallocate size over ?
		jb	f187			;no
		PUSH	SI			;move page buffer...
		MOV	DI,page_ptr
		CMP	[SI].page_address,0	;not poniter address?
		JNZ	f18p
		MOV	[SI].page_address,DI	;set page pointer
		JMP	short f18q
f18p:
		DEC	DI
		MOV	AX,CX
		SHL	AX,1
		ADD	DI,AX
		MOV	al,[SI].alloc_page_count
                xor     ah,ah
		SHL	AX,1
		ADD	AX,[SI].page_address
		PUSH	CX
		MOV	CX,page_ptr
		SUB	CX,AX
		MOV	SI,page_ptr
		DEC	SI
		STD
		JCXZ	f18g
		REPZ	MOVSB
f18g:
		POP	CX
f18q:
		SHL	CX,1
		ADD	page_ptr,CX		;pointer add
		POP	SI
		CLD
		MOV	DI,[SI].page_address	;allocate add pages...
		MOV	al,[SI].alloc_page_count
                xor     ah,ah
		MOV	CX,BX
		SUB	CX,AX
		SHL	AX,1
		ADD	DI,AX
		PUSH	SI
		MOV	SI,OFFSET log_page
		XOR	AX,AX
		sub	un_alloc_pages,cx
		JMP	short f188
f189:
		ADD	SI,LOG_SIZE
		INC	AX
f188:
		CMP	WORD PTR [SI],UNMAP	;logical page end?
		JZ	f18d
		CMP	WORD PTR [SI],NOT_USE	;unallocated page ?
		JNZ	f189
		MOV	WORD PTR [SI],DX
		STOSW
		LOOP	f189
		POP	SI
		MOV	al,[SI].alloc_page_count
                xor     ah,ah
		MOV	[SI].alloc_page_count,bl;set EMM handle used page count
		XOR	DI,DI			;change other handle page add-
		XCHG	AX,BX			;ress....
		SUB	AX,BX
		SHL	AX,1
		MOV	BX,[SI].page_address
		MOV	CX,handle_count
		JMP	short f18h
f18i:
		ADD	DI,FLAG_SIZE
f18h:
		CMP	byte ptr [DI].handle_flag,0
		JZ	f18i
		CMP	[DI].page_address,BX
		JNG	f18n
		ADD	[DI].page_address,AX
f18n:
		LOOP	f18i
		JMP	noerr			;exit
f18d:
		POP	SI
		JMP	err80			;error exit
;------ function 19 -------------------------------------------------
; Get/set handle attribute
;--------------------------------------------------------------------
func19:
		sti
                cbw
		dec	ax
		js	get_handle_attr		; 0
		jz	set_handle_attr		; 1
		dec	ax
		jz	get_attr_cap		; 2
		jmp	err84			;error exit
;--------------------------------------------------------------------
; Get handle attribute
; input
;	DX	: EMM handle
; output
;	AH	: status
;	AL	: handle attribute
;--------------------------------------------------------------------
get_handle_attr:
		CALL	check_handle		;check handle data
		JC	get_handle_attr1
		MOV	AL,VOLATILE		;handle attribute set
		JMP	noerr			;exit
get_handle_attr1:
		JMP	err83			;error exit
;--------------------------------------------------------------------
; Set handle attribute
; input
;	DX	: EMM handle
;	BL	: new handle attribute
; output
;	AH	: status
;--------------------------------------------------------------------
set_handle_attr:
		JMP	err91			;error exit
;--------------------------------------------------------------------
; Get attribute capability
; output
;	AH	: status
;	AL	: attribute capability
;--------------------------------------------------------------------
get_attr_cap:
		mov	al,VOLATILE		;set attribute capability
		jmp	noerr			;exit
;------ function 20 -------------------------------------------------
; Get/set handle name
;--------------------------------------------------------------------
func20:
		dec	al
		js	get_handle_name		; 0
		jz	set_handle_name		; 1
		jmp	err84			;error exit
;--------------------------------------------------------------------
; Get handle name
; input
;	DX	: EMM handle
;	ES:DI	: pointer to handle name array
; output
;	AH	: status
;--------------------------------------------------------------------
get_handle_name:
		CALL	check_handle		;check handle data
		JC	get_handle_name1
		MOV	SI,OFFSET handle_name
		MOV	AX,DX
		MOV	CL,3
		SHL	AX,CL
		ADD	SI,AX
		MOV	CX,HANDLE_NAME_SIZE/2
		REPZ	MOVSW
		JMP	noerr			;exit
get_handle_name1:
		JMP	err83			;error exit
;--------------------------------------------------------------------
; Set handle name
; input
;	DX	: EMM handle
;	DS:SI	: pointer to handle name
; output
;	AH	: status
;--------------------------------------------------------------------
set_handle_name:
		call	check_handle		;check handle data
		jc	get_handle_name1
		push	cs
		pop	es
		mov	ax,[bp].ds_save
		mov	ds,ax
		mov	cx,HANDLE_CNT		;check handle name...
		mov	di,offset handle_name
		mov	bx,offset handle_flag
set_handle_name2:
		cmp	byte ptr [bx],0         ;active handle ?
		je	set_handle_name3
		push	cx si
		mov	cx,HANDLE_NAME_SIZE/2
		repz	cmpsw                   ;compare handle name...
		pop	si cx
		je	set_handle_name4	;found same handle name ?
set_handle_name3:
		add	bx,2
		loop	set_handle_name2
		mov	di,offset handle_name	;set handle name...
		mov	cl,3
		shl	dx,cl
		add	di,dx
		mov	cx,HANDLE_NAME_SIZE/2
		rep	movsw
		jmp	noerr			;exit
set_handle_name4:
		jmp	erra1			;error exit
;------ function 21 -------------------------------------------------
; Get handle directory
;--------------------------------------------------------------------
func21:
		dec	al
		js	get_handle_dir		; 0
		JZ	search_for_name		; 1
		dec	al
		JZ	get_total_handle	; 2
		JMP	err84			;error exit
;--------------------------------------------------------------------
; Get handle directory
; input
;	ES:DI	: pointer to handle_dir
; output
;	AH	: status
;	AL	: number of entries in the handle_dir array
;--------------------------------------------------------------------
get_handle_dir:
		MOV	CX,HANDLE_CNT
		MOV	SI,OFFSET handle_name
		XOR	DX,DX
		XOR	BL,BL
get_handle_dir1:
		CALL	check_handle		;check handle data
		JC	get_handle_dir2
		MOV	AX,DX			;set EMM handle.
		STOSW
		PUSH	CX SI			;set handle name...
		MOV	CX,HANDLE_NAME_SIZE/2
		REPZ	MOVSW
		POP	SI CX
		INC	BL			;inc handle count.
get_handle_dir2:
		ADD	SI,HANDLE_NAME_SIZE
		INC	DX
		LOOP	get_handle_dir1
		MOV	AL,BL
		JMP	noerr			;exit
;--------------------------------------------------------------------
; Search for named handle
; input
;	DS:SI	: search handle_name pointer
; output
;	AH	: status
;	DX	: EMM handle
;--------------------------------------------------------------------
search_for_name:
		push	CS
		pop	ES
		MOV	CX,HANDLE_CNT
		MOV	DI,OFFSET handle_name
		MOV	AX,[BP].ds_save
		MOV	DS,AX
		XOR	DX,DX
search_for_name1:
		PUSH	CX SI di
		MOV	CX,HANDLE_NAME_SIZE/2
		repz	cmpsw
		POP	di SI CX
		JZ	search_for_name2
                add     di,HANDLE_NAME_SIZE
		inc	dx
		loop	search_for_name1
		jmp	erra0
search_for_name2:
		mov	cx,HANDLE_NAME_SIZE/2
		xor	ax,ax
		repz	scasw
		jnz	search_for_name3
		jmp	erra1			;error exit
search_for_name3:
		push	cx
		pop	ds
		mov	[bp].dx_save,dx
		jmp	noerr			;exit
;--------------------------------------------------------------------
; Get total handle
; output
;	AH	: status
;	BX	: total_handles
;--------------------------------------------------------------------
get_total_handle:
		MOV	BX,HANDLE_CNT		;set max handle count.
		MOV	[BP].bx_save,BX
		JMP	noerr			;exit
;------ function 22 -------------------------------------------------
; Alter page map & jump.
; input
;	AL	: physical page number/segment selector
;	DX	: EMM handle
;	DS:SI	: pointer to map_and_jump structure
; output
;	AH	: status
;--------------------------------------------------------------------
f224:
		JMP	err8a
func22:
		STI
		cmp	AL,0
		je	f220
		cmp	AL,1
		je	f220
		JMP	err8f
f220:
		MOV	[BP].f22_ax_save,AX
		CALL	check_handle		;check handle data.
		JC	f221
		MOV	AX,[BP].ds_save		;copy calling parameters...
		MOV	DS,AX
		LES	BX,[SI].target_address1
		MOV	AX,ES
		MOV	[BP].f22_target_off,BX	;offset
		MOV	[BP].f22_target_seg,AX	;segment
		MOV	CL,[SI].log_phys_map_len;get mapping data length.
		XOR	CH,CH
		MOV	[BP].f22_map_len,CX	;length
		JCXZ	f22a
		LES	BX,[SI].log_phys_map_ptr;get log_phys_map_ptr.
		LEA	DI,[BP].f22_map_data	;copy log_phys_map data...
		SHL	CX,1
f228:
		MOV	AX,ES:[BX]
		MOV	SS:[DI],AX
		add	DI,2
		add	BX,2
		LOOP	f228
f22a:
		MOV	AX,SS
		MOV	DS,AX
		MOV	CX,[BP].f22_map_len	;length
		JCXZ	f222
		LEA	DI,[BP].f22_map_data	;get mapping data pointer.
f223:
		MOV	BX,[DI].log_page_number1;get logical page no.
		CMP	BX,UNMAP		;unmapping?
		JZ	f22b
		CALL	check_log_page		;check logical page no.
		JC	f224
		MOV	BX,AX			;set EMM logical page no.
f22b:
		MOV	AX,[BP].f22_ax_save	;get phys_page_no/seg_selector.
		OR	AL,AL			;sub_function 0?
		JNZ	f229
		MOV	AX,[DI].phys_page_number1;get physical page no.
		CMP	AX,PHYS_PAGES
		jb	f225
f22c:
		jmp	err8b
f229:
		MOV	AX,[DI].mappable_seg_addr;get mappable segment.
		CALL	change_seg_page		;change segment -> phys_page_no.
		JC	f22c
f225:
		CMP	BX,UNMAP		;unmapping?
		JZ	f227
		CALL	set_phys_page		;set physical page
		jmp	short f226
f221:
		JMP	err83
f227:
		CALL	reset_phys_page		;reset physical page
f226:
		ADD	DI,SIZE log_to_phys_map_struct;
		LOOP	f223
f222:
		MOV	AX,[BP].f22_target_seg	;get target address.
		MOV	[BP].ret_segment,AX	;set FAR:JUMP segment.
		MOV	AX,[BP].f22_target_off	;get target address.
		MOV	[BP].ret_offset,AX	;set FAR:JUMP offset.
		JMP	noerr			;exit
;------ function 23 -------------------------------------------------
; Alter page map & call
;--------------------------------------------------------------------
func23:
		STI
		or	al,al
		je	f2300
		cmp	al,1
		je	f2300
		cmp	al,2
		je	get_page_map_stack
		jmp	err84
;--------------------------------------------------------------------
; Get page map stack space size
; output
;	AH	: status
;	BX	: stack space required
;--------------------------------------------------------------------
get_page_map_stack:
		MOV	BX,RET_SP		;set stack space...
		MOV	[BP].bx_save,BX
		JMP	noerr			;exit
;--------------------------------------------------------------------
; Alter page map & call
; input
;	AL	: physical page number/segment selector
;	DX	: EMM handle
;	DS:SI	: pointer to map_and_call structure
; output
;	AH	: status
;	AL	: number of entries in the handle_dir array
;--------------------------------------------------------------------
f2300:
		MOV	[BP].f23_ax_save,AX
		CALL	check_handle		;check handle data
		JC	f221
		MOV	AX,[BP].ds_save
		MOV	DS,AX
		LES	BX,[SI].target_address2	;get FAR:CALL target_addr.
		MOV	[BP].f23_target_off,BX	;set offset.
		MOV	AX,ES			;get segment
		MOV	[BP].f23_target_seg,AX	;set segment.
		MOV	CL,[SI].new_page_map_len;get new_page_map_len.
		XOR	CH,CH
		MOV	[BP].f23_new_map_len,CX
		LES	BX,[SI].new_page_map_ptr;get new_page_map_ptr.
		JCXZ	f2303
		LEA	DI,[BP].f23_new_map_data;
		SHL	CX,1
f2302:
		MOV	AX,ES:[BX]
		MOV	SS:[DI],AX
		add	DI,2
		add	BX,2
		LOOP	f2302
f2303:
		MOV	CL,[SI].old_page_map_len;get old_page_map_len.
		XOR	CH,CH
		MOV	[BP].f23_old_map_len,CX
		LES	BX,[SI].old_page_map_ptr;get old_page_map_ptr.
		JCXZ	f2305
		LEA	DI,[BP].f23_old_map_data;
		SHL	CX,1
f2304:
		MOV	AX,ES:[BX]
		MOV	SS:[DI],AX
		add	DI,2
		add	BX,2
		LOOP	f2304
f2305:
		MOV	CX,[BP].f23_new_map_len	;get new_page_map_len.
		JCXZ	f2307			;mapping page length = 0?
		MOV	AX,SS
		MOV	DS,AX
		LEA	SI,[BP].f23_new_map_data;get new_page_map_ptr.
f2306:
		MOV	BX,[SI].log_page_number2;get logical page no.
		CMP	BX,UNMAP		;unmapping?
		JZ	f2313
		CALL	check_log_page
		JC	f2309
		MOV	BX,AX
f2313:
		MOV	AX,[BP].f23_ax_save
		OR	AL,AL			;sub_function 0?
		JZ	f2310
		MOV	AX,[SI].mappable_seg_addr;
		CALL	change_seg_page		;change segment -> phys_page_no.
		JC	f2314
f2310:
		MOV	AX,[SI].phys_page_number1;get physical page no.
		CMP	AX,PHYS_PAGES
		jnb	f2314
f2311:
		CMP	BX,UNMAP		;unmapping?
		JZ	f2312
		CALL	set_phys_page		;set physical page
		jmp	short f2308
f2309:
		JMP	err8a
f2314:
		JMP	err8b
f2312:
		CALL	reset_phys_page		;reset physical page
f2308:
		ADD	SI,SIZE log_to_seg_map_struct;
		LOOP	f2306
f2307:
		MOV	BX,OFFSET f2350		;get FAR:CALL return_addr
		MOV	[BP].f23_retoff,BX	;set offset.
		MOV	AX,CS
		MOV	[BP].f23_retseg,AX	;set segment.
		MOV	AX,[BP].ret_flag	;get flags.
		MOV	[BP].f23_flag,AX	;set flags.
		MOV	AH,0
		POP	BX CX DX SI DI BP ES DS
		IRET				;FAR:CALL to target

;
; far call return point
;
f2350:
		PUSHF				;push flags.
		POP	AX			;pop flags.
		CLI
		SUB	SP,F23_RETSP
		PUSH	DS ES BP DI SI DX CX BX
		MOV	BP,SP
		MOV	[BP].ret_flag,AX	;set return_flags.
		MOV	CX,[BP].f23_old_map_len	;get old_page_map_len.
		JCXZ	f2351			;mapping page length = 0?
		MOV	AX,SS
		MOV	DS,AX
		LEA	SI,[BP].f23_old_map_data;get old_page_map_ptr.
f2352:
		MOV	BX,[SI].log_page_number2;get logical page no.
		CMP	BX,UNMAP		;unmapping?
		JZ	f2359
		CALL	check_log_page
		JC	f2309
		MOV	BX,AX
f2359:
		MOV	AX,[BP].f23_ax_save
		OR	AL,AL
		JZ	f2354
		MOV	AX,[SI].mappable_seg_addr
		CALL	change_seg_page		;change segment -> phys_page_no.
		jc	f2314
f2354:
		MOV	AX,[SI].phys_page_number1;get physical page no.
		CMP	AX,PHYS_PAGES
		jnb	f2314
		CMP	BX,UNMAP		;unmapping?
		JZ	f2357
		CALL	set_phys_page		;set physical page
		jmp	short f2353
f2357:
		CALL	reset_phys_page		;reset physical page
f2353:
		ADD	SI,SIZE log_to_seg_map_struct
		LOOP	f2352
f2351:
		JMP	noerr

;------ Function  24 (57h) -------------------------------------------
; Move Memory Region

; This subfunction copies a region of memory in the following memory
; source/destination combinations:
;
;          o   conventional memory to conventional memory
;          o   conventional memory to expanded memory
;          o   expanded memory to conventional memory
;          o   expanded memory to expanded memory
;
;       AL      : Operation (0)
;       DS:SI   : pointer to move_info
;       AH      : Return code
;--------------------------------------------------------------------
func24:
                or      al,al
                je      f2400
                cmp     al,1
                je      f2400
                jmp     err84                   ;
f2400:
                mov     [bp].f24_al_save,al
                mov     ax,[bp].ds_save
                mov     ds,ax
                mov     ax,[si].source_offset   ;
                mov     [bp].source_off,ax
                mov     al,[si].source_type
                mov     [bp].source_type1,al
                or      al,al
                je      f2401
                mov     ax,[si].source_seg_page ; = EMS
                mov     [bp].source_page,ax
                mov     ax,cs:Page_Frame_Seg
                mov     [bp].source_seg,ax
                mov     ax,[si].source_handle1
                mov     [bp].source_handle2,ax
                jmp     short f2402
f2401:
                mov     ax,[si].source_seg_page ; = RAM
                mov     [bp].source_seg,ax
f2402:
                mov     ax,[si].dest_offset     ;
                mov     [bp].dest_off,ax
                mov     al,[si].dest_type
                mov     [bp].dest_type1,al
                or      al,al
                je      f2403
                mov     ax,[si].dest_seg_page   ; = EMS
                mov     [bp].dest_page,ax
                mov     ax,cs:Page_Frame_Seg
                add     ax,400H
                mov     [bp].dest_seg,ax
                mov     ax,[si].dest_handle1
                mov     [bp].dest_handle2,ax
                jmp     short f2404
f2403:
                mov     ax,[si].dest_seg_page   ; = RAM
                mov     [bp].dest_seg,ax
f2404:
                les     di,[si].region_lenght   ;
                mov     [bp].region_low,di
                mov     ax,es
                mov     [bp].region_high,ax
                cmp     ax,10h                  ;
                jb      f2405
                jne     f2407
                or      di,di
                jnz     f2407

f2405:
                cmp     [si].source_type,0
                jne     f2408                   ; = RAM
                FarPtrAddress [bp].source_seg,[bp].source_off
                cmp     dx,10h                  ;...
                jnb     f2411
f2409:
                Save32  [bp].source_ea_high,[bp].source_ea_low;
                Add32   [bp].region_high,[bp].region_low
                Sub32   0,1                     ;
                cmp     dx,10h                  ;
                jb      f2410
                jg      f2411
                or      ax,ax
                jz      f2410
f2411:
                jmp     errA2
f2413:
                jmp     err8A
f2414:
                jmp     err95
f2410a:
                jmp     err93
f2412:
                jmp     err83
f2407:
                jmp     err96
f2418:
                jmp     errA2
f2408:
                mov     dx,[bp].source_handle2  ; = EMS
                call    check_handle            ;
                jc      f2412
                mov     bx,[bp].source_page
                call    check_log_page          ;
                jc      f2413
                mov     di,dx
                mov     ax,[bp].source_off
                cmp     ax,4000h
                jnb     f2414
                xor     dx,dx
                Add32   [bp].region_high,[bp].region_low
                Sub32   0,1
                Shl32   2
                add     bx,dx
                mov     dx,di
                call    check_log_page          ;
                jc      f2410a
f2410:
                cmp     [si].dest_type,0
                jne     f2415                   ; = RAM
                FarPtrAddress [bp].dest_seg,[bp].dest_off
                cmp     dx,10h                  ;.
                jnb     f2418
                Save32  [bp].dest_ea_high, [bp].dest_ea_low
                Add32   [bp].region_high,[bp].region_low
                Sub32   0,1                     ;
                cmp     dx,10h                  ;
                jb      f2417
                jmp     short f2418
f2419:
                jmp     err83
f2420:
                jmp     err8A
f2421:
                jmp     err95                   ;
f2417a:
                jmp     err93                   ;
f2415:
                mov     dx,[bp].dest_handle2    ; = EMS
                call    check_handle            ;
                jc      f2419
                mov     bx,[bp].dest_page
                call    check_log_page          ;
                jc      f2420
                mov     di,dx
                mov     ax,[bp].dest_off
                cmp     ax,4000h
                jnb     f2421
                xor     dx,dx
                Add32   [bp].region_high, [bp].region_low
                Sub32   0,1
                Shl32   2
                add     bx,dx
                mov     dx,di
                call    check_log_page          ;
                jc      f2417a

f2417:
                mov     [bp].direct_move,0
                mov     al,[si].source_type
                cmp     al,[si].dest_type       ;
                jne     f2423
f2422:
                cmp     al,1
                je      f2424
                FLoad32 [bp].source_ea_low
                mov     bx,[bp].dest_ea_low     ; = RAM
                mov     cx,[bp].dest_ea_high
                jmp     short f2430
f2424:
                mov     ax,[bp].source_handle2  ; = EMS
                cmp     ax,[bp].dest_handle2
                jne     f2423
                mov     dx,[bp].dest_page
                xor     ax,ax
                Shr32   2
                Add32   0,[bp].dest_off
                mov     bx,ax
                mov     cx,dx
                mov     dx,[bp].source_page
                xor     ax,ax
                Shr32   2
                Add32   0,[bp].source_off
f2430:
                cmp     dx,cx                   ;DX:AX = , CX:BX =
                jne     f2425
                cmp     ax,bx
f2425:
                jae     f2426
                xchg    bx,ax
                xchg    cx,dx
                cmp     [bp].f24_al_save,1
                je      f2426
                or      [bp].direct_move,1      ;
f2426:
                sub     ax,bx
                sbb     dx,cx
                cmp     dx,[bp].region_high
                jne     f2427
                cmp     ax,[bp].region_low
f2427:
                jae     f2423
                cmp     [bp].f24_al_save,1
                je      f2428                   ;
                or      [bp].direct_move,2      ;
f2423:
                mov     [bp].zero_low,0
                test    [bp].direct_move,1
                jnz     f2429
                cld
                jmp     f2435
f2428:
                jmp     err97

f2429:
                std
                cmp     [si].dest_type,1        ; = EMS ?
                je      f2432

                FLoad32 [bp].dest_ea_low
                Add32   [bp].region_high,[bp].region_low
                Sub32   0,1
                mov     bx,ax
                and     bx,000Fh
                mov     [bp].dest_off,bx
                Shr32   4
                mov     [bp].dest_seg,ax
                jmp     short f2433
f2432:                                          ; EMS...
                FLoad32 [bp].region_low
                Add32   0,[bp].dest_off
                Sub32   0,1
                mov     bx,ax
                and     bx,3FFFh
                mov     [bp].dest_off,bx
                Shl32   2
                mov     bx,[bp].dest_page
                add     bx,dx
                mov     [bp].dest_page,bx
                mov     dx,[bp].dest_handle2
                call    check_log_page
                mov     bx,ax
                mov     al,1
                call    set_phys_page
f2433:
                cmp     [si].source_type,1      ; = EMS ?
                je      f2434
                                                ;...
                FLoad32 [bp].source_ea_low
                Add32   [bp].region_high,[bp].region_low
                Sub32   0,1
                mov     bx,ax
                and     bx,000Fh
                mov     [bp].source_off,bx
                Shr32   4
                mov     [bp].source_seg,ax
                jmp     short f2435
f2434:                                          ; EMS...
                FLoad32 [bp].region_low
                Add32   0,[bp].source_off
                Sub32   0,1
                mov     bx,ax
                and     bx,3FFFh
                mov     [bp].source_off,bx
                Shl32   2
                add     [bp].source_page,dx
                mov     dx,[bp].source_handle2
                call    check_log_page
                mov     bx,ax
                xor     al,al
                call    set_phys_page


f2435:
                mov     al,[si].source_type     ;
                or      al,[si].dest_type       ;
                jz      f2436
                mov     cx,SIZE phys_page_struct
                mov     si,offset map_table
                mov     di,offset f24_data
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                rep     movsw
                or      [bp].direct_move,4

f2436:
                mov     ax,[bp].region_low
                or      ax,[bp].region_high
                jnz     f2438
                test    [bp].direct_move,4      ;
                jz      f2439
                mov     cx,SIZE phys_page_struct
                mov     si,offset f24_data
                mov     di,offset map_table
f2440:
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                rep     movsw
                call    set_pages_map
f2439:
                test    [bp].direct_move,2      ; F24 !!!
                jnz     f2441
                jmp     noerr
f2441:
                jmp     err92


f2438:
                cmp     [bp].source_type1,1
                je      f2442

                FarPtrAddress [bp].source_seg,[bp].source_off
                test    [bp].direct_move,1
                jnz     f2443
                Add32   [bp].zero_low,0         ;
                mov     bx,ax
                and     bx,000Fh
                mov     [bp].source_off,bx
                Shr32   4
                mov     [bp].source_seg,ax
                jmp     short f2444
f2443:
                Sub32   0,[bp].zero_low         ;
                mov     bx,ax
                or      bx,0FFF0h
                mov     [bp].source_off,bx
                Sub32   0,bx
                Shr32   4
                mov     [bp].source_seg,ax
                jmp     short f2444
f2442:
                mov     ax,[bp].source_off      ; EMS...
                test    [bp].direct_move,1
                jnz     f2445
                add     ax,[bp].zero_low        ;...
                cmp     ax,4000h
                jb      f2446
                inc     [bp].source_page
                mov     [bp].source_off,0
                jmp     short f2446
f2445:
                sub     ax,[bp].zero_low        ;...
                jnc     f2446
                dec     [bp].source_page
                mov     [bp].source_off,3FFFh
f2446:
                mov     dx,[bp].source_handle2
                mov     bx,[bp].source_page
                call    check_log_page
                mov     bx,ax
                xor     al,al
                call    set_phys_page


f2444:
                test    [bp].dest_type1,1
                jnz     f2447

                FarPtrAddress [bp].dest_seg,[bp].dest_off
                test    [bp].direct_move,1
                jnz     f2448
                Add32   0,[bp].zero_low         ;
                mov     bx,ax
                and     bx,000Fh
                mov     [bp].dest_off,bx
                Shr32   4
                mov     [bp].dest_seg,ax
                jmp     short f2449
f2448:
                Sub32   0,[bp].zero_low         ;...
                mov     bx,ax
                or      bx,0FFF0h
                mov     [bp].dest_off,bx
                Sub32   0,bx
                Shr32   4
                mov     [bp].dest_seg,ax
                jmp     short f2449
f2447:
                mov     ax,[bp].dest_off        ; EMS...
                test    [bp].direct_move,1
                jnz     f2450
                add     ax,[bp].zero_low        ;...
                cmp     ax,4000h
                jb      f2451
                inc     [bp].dest_page
                mov     [bp].dest_off,0
                jmp     short f2451
f2450:
                sub     ax,[bp].zero_low        ;...
                jnc     f2451
                dec     [bp].dest_page
                mov     [bp].dest_off,3FFFh
f2451:
                mov     dx,[bp].dest_handle2
                mov     bx,[bp].dest_page
                call    check_log_page
                mov     bx,ax
                mov     al,1
                call    set_phys_page
f2449:
                mov     bl,[bp].dest_type1     ;MAXLEN (dest)...
                mov     ax,[bp].dest_off
                call    maxlen
                push    ax
                mov     bl,[bp].source_type1   ;MAXLEN (source)...
                mov     ax,[bp].source_off
                call    maxlen
                pop     bx
                mov     cx,ax
                FLoad32 [bp].region_low
                cmp     cx,bx                  ;
                jb      f2452
                mov     cx,bx
f2452:
                or      dx,dx
                jnz     f2453
                cmp     cx,ax
                jb      f2453
                mov     cx,ax


f2453:
                mov     [bp].zero_low,cx
                mov     ax,[bp].source_seg
                mov     ds,ax
                mov     ax,[bp].dest_seg
                mov     es,ax
                mov     si,[bp].source_off
                mov     di,[bp].dest_off

                cmp     [bp].f24_al_save,1
                je      f2454
                rep     movsb                   ;
f2455:
                FLoad32 [bp].region_low
                Sub32   0,[bp].zero_low
                Save32  [bp].region_high,[bp].region_low
                jmp     f2436
f2454:
                Exbyte                          ;...
                loop    f2454
                jmp     f2455
;------ function 25 -------------------------------------------------
; Get mappable physical address array
;--------------------------------------------------------------------
func25:
		STI
		DEC	AL
		js	get_map_phys_addr	; 0
		JZ	get_map_phys_ent	; 1
		JMP	err84			;error exit
;--------------------------------------------------------------------
; Get mappable physical address array
; input
;	ES:DI	: mappable_phys_page
; output
;	AH	: status
;	CX	: number of entries in the mappable_phys_page
;--------------------------------------------------------------------
get_map_phys_addr:
		MOV	AX,[BP].es_save
		MOV	ES,AX
		MOV	CX,PHYS_PAGES
		MOV	SI,OFFSET map_table
		XOR	DX,DX
get_map_phys_addr1:
		MOV	AX,[SI].phys_seg_addr
		STOSW
		MOV	AX,DX
		STOSW
		INC	DX
		ADD	SI,SIZE phys_page_struct
		LOOP	get_map_phys_addr1
;--------------------------------------------------------------------
; Get mappable physcal address array entries
; output
;	AH	: status
;	CX	: number of entries in the mappable_phys_page
;--------------------------------------------------------------------
get_map_phys_ent:
get_map_phys_addr2:
		MOV	CX,PHYS_PAGES
		MOV	[BP].cx_save,CX		;set segment addr entrie
		JMP	noerr			;exit

;------ function 26 -------------------------------------------------
; Get expanded memory hardware infomation
;--------------------------------------------------------------------
func26:
		STI
		DEC	AL
		js	get_hardware_config	; 0
		JZ	get_unalloc_raw_page	; 1
		JMP	err84			;error exit
;--------------------------------------------------------------------
; Get hardware configration array
; input
;	ES:DI	: hardware_info
; output
;	AH	: status
;--------------------------------------------------------------------
get_hardware_config:
		CMP	OSE_flag,0		;OS/E flag enable?
		jne	get_hardware_config1
		MOV	AX,[BP].es_save
		MOV	ES,AX
		MOV	AX,RAW_PAGES
		STOSW
		MOV	AX,ALTER_REGS
		STOSW
		MOV	AX,CONTEXT_SIZE
		STOSW
		MOV	AX,DMA_REGS
		STOSW
		MOV	AX,DMA_CHANNEL
		STOSW
		JMP	noerr			;exit
get_hardware_config1:
		JMP	erra4			;error exit
;--------------------------------------------------------------------
; Get unallocated raw page count
; output
;	AH	: status
;	BX	: unallocated raw pages
;	DX	: total raw pages
;--------------------------------------------------------------------
get_unalloc_raw_page:
		JMP	func3			;goto function 3
;------ function 28 -------------------------------------------------
; Alternate map register set
;--------------------------------------------------------------------
f280:
		JMP	erra4			;error exit
func28:
		STI
		CMP	OSE_flag,0		;OS/E flag enable?
		jne	f280
                cbw
		dec	ax
		js	get_alter_map_reg	; 0
		JZ	set_alter_map_reg	; 1
		dec	ax
		jz	get_alter_map_size	; 2
		dec	ax
		jz	alloc_alter_map_reg	; 3
		dec	ax
		jz	dealloc_alter_map_reg	; 4
		dec	ax
		jz	alloc_DMA_reg		; 5
		dec	ax
		jz	enable_DMA_alter_reg	; 6
		dec	ax
		jz	disable_DMA_alter_reg	; 7
		dec	ax
		jz	dealloc_DMA_reg		; 8
		jmp	err84			;error exit
;--------------------------------------------------------------------
; Get alternate map save array size
; output
;	AH	: status
;	DX	: size_of_array
;--------------------------------------------------------------------
get_alter_map_size:
		MOV	DX,CONTEXT_SIZE
		MOV	[BP].dx_save,DX
		JMP	noerr			;exit
;--------------------------------------------------------------------
; Allocate alternate map register set
; output
;	AH	: status
;	BL	: alternate map register set number
;--------------------------------------------------------------------
alloc_alter_map_reg:
;--------------------------------------------------------------------
; Allocate DMA register set
; output
;	AH	: status
;	BL	: DMA register set number
;--------------------------------------------------------------------
alloc_DMA_reg:
		xor	bx,bx
		MOV	[BP].bx_save,BX
		JMP	noerr			;exit
;--------------------------------------------------------------------
; Deallocate alternate map register set
; input
;	BL	: alternate map register set number
; output
;	AH	: status
;--------------------------------------------------------------------
dealloc_alter_map_reg:
;--------------------------------------------------------------------
; Enable DMA on alternate map register set
; input
;	BL	: DMA register set number
;	DL	: DMA channel number
; output
;	AH	: status
;--------------------------------------------------------------------
enable_DMA_alter_reg:
;--------------------------------------------------------------------
; Disable DMA on alternate map register set
; input
;	BL	: alternate register set number
; output
;	AH	: status
;--------------------------------------------------------------------
disable_DMA_alter_reg:
;--------------------------------------------------------------------
; Deallocate DMA register set
; input
;	BL	: DMA register set number
; output
;	AH	: status
;--------------------------------------------------------------------
dealloc_DMA_reg:
		OR	BL,BL
		jnz	dealloc_alter_map_reg1
		JMP	noerr
dealloc_alter_map_reg1:
		JMP	err9c
;--------------------------------------------------------------------
; Get alternate map register set
; output
;	AH	: status
;	BL	: current active alternate map register set number
;	ES:DI	: pointer to a map register context save area
;--------------------------------------------------------------------
get_alter_map_reg:
		MOV	DI,alter_map_off
		MOV	AX,alter_map_seg
		MOV	ES,AX
		OR	AX,DI
		JZ	get_alter_map_reg1
		MOV	SI,OFFSET map_table
		PUSH	CS
		POP	DS
		MOV	CX,CONTEXT_SIZE/2
		REPZ	MOVSW
get_alter_map_reg1:
		MOV	DI,CS:alter_map_off
		MOV	AX,CS:alter_map_seg
		MOV	[BP].di_save,DI
		MOV	[BP].es_save,AX
		MOV	BX,[BP].bx_save
		xor	bl,bl
		MOV	[BP].bx_save,BX
		JMP	noerr
;--------------------------------------------------------------------
; Set alternate map register set
; input
;	BL	: new alternate map register set number
;	ES:DI	: pointer to a map register context restore area
; output
;	AH	: status
;--------------------------------------------------------------------
set_alter_map_reg:
		cli
		or	bl,bl
		jnz	set_alter_map_reg1
		mov	alter_map_off,di
		mov	ax,es
		mov	alter_map_seg,ax
		or	ax,di
		jz	set_alter_map_reg2
		push	es
		pop	ds
		mov	si,di
		mov	cx,CONTEXT_SIZE/2
		mov	ax,ss
		mov	es,ax
		lea	di,[bp].f28_map_data
		rep	movsw
		lea	di,[bp].f28_map_data
		call	check_map_data
		jc	set_alter_map_reg3
		mov	si,di
		push	es
		pop	ds
		mov	cx,CONTEXT_SIZE/2
		mov	di,offset map_table
		push	cs
		pop	es
		rep	movsw
                call    set_pages_map
set_alter_map_reg2:
		jmp	noerr
set_alter_map_reg1:
		jmp	err9c
set_alter_map_reg3:
		jmp	erra3
;------ function 29 -------------------------------------------------
; Prepare expanded memory hardware for warm boot
;--------------------------------------------------------------------
func29:
		MOV	AX,CS
		MOV	ES,AX
		MOV	DS,AX
		MOV	DI,OFFSET map_table	;disable physical pages...
		MOV	CX,PHYS_PAGES
f291:
		MOV	[DI].emm_handle2,UNMAP
		MOV	[DI].log_page_data,0
		ADD	DI,SIZE phys_page_struct
		loop	f291
		call	set_pages_map
		MOV	DI,OFFSET alloc_page_count;clear all...
		mov	cx,HANDLE_CNT*3
                xor     ax,ax
		rep	stosw
		MOV	DI,OFFSET handle_name	;clear handles...
		MOV	CX,HANDLE_CNT*4
		REPZ	STOSW
		MOV	di,OFFSET backup_flags	;v1.01
                mov     cx,CONTEXT_SIZE/2
		rep	stosw
		MOV	DI,OFFSET alloc_page	;clear logical page buffer...
		MOV	CX,PAGE_MAX*2
		dec	ax                      ; set to -1
		REPZ	STOSW
		MOV	byte ptr handle_flag,1  ;set system handle flag...
		MOV	handle_count,1		;set active handle count
		MOV	backup_count,0		;set backup map count
		MOV	AX,total_pages
		MOV	un_alloc_pages,AX	;set unallocate page count
		MOV	AX,OFFSET alloc_page	;set page buffer pointer
		MOV	page_ptr,AX
		JMP	noerr			;exit
;------ function 30 -------------------------------------------------
; Enable/disable OS/E function set functions
; input
;	BX,CX	: alternate register set number
; output
;	AH	: status
;	BX,CX	: alternate register set number
;--------------------------------------------------------------------
func30:
		sti
		dec	al
		js	enable_OSE_func		; 0
		jz	disable_OSE_func	; 1
		dec	al
		jz	return_access_key	; 2
		jmp	err84			;error exit

;--------------------------------------------------------------------
; Enable OS/E function set
; input
;	BX,CX	: access_key
; output
;	AH	: status
;	BX,CX	: access_key
;--------------------------------------------------------------------
enable_OSE_func:
		CMP	OSE_fast,0		;OS/E fast access flag enable?
		JZ	enable_OSE_func1
		CMP	access_key_h,BX		;compare access key high
		JNZ	enable_OSE_func2
		CMP	access_key_l,CX		;compare access key low
		jnz	enable_OSE_func2
enable_OSE_func1:
		MOV	OSE_flag,0		;enable OS/E function
		MOV	OSE_fast,0FFFFH		;set OS/E fast access flag
		MOV	BX,access_key_h
		MOV	[BP].bx_save,BX
		MOV	CX,access_key_l
		MOV	[BP].cx_save,CX
		JMP	noerr
enable_OSE_func2:
		JMP	erra4
;--------------------------------------------------------------------
; Disable OS/E function set
; input
;	BX,CX	: access_key
; output
;	AH	: status
;	BX,CX	: access_key
;--------------------------------------------------------------------
disable_OSE_func:
		CMP	OSE_fast,0		;OS/E fast access flag enable?
		JZ	disable_OSE_func1
		CMP	access_key_h,BX		;compare access key high
		JNZ	enable_OSE_func2
		CMP	access_key_l,CX		;compare access key low
		jnz	enable_OSE_func2
disable_OSE_func1:
		MOV	OSE_flag,0FFFFH		;disable OS/E function
		MOV	OSE_fast,0FFFFH		;set OS/E fast access flag
		MOV	BX,access_key_h
		MOV	[BP].bx_save,BX
		MOV	CX,access_key_l
		MOV	[BP].cx_save,CX
		JMP	noerr
;--------------------------------------------------------------------
; Return access key
; input
;	BX,CX	: access_key
; output
;	AH	: status
;--------------------------------------------------------------------
return_access_key:
		CMP	OSE_flag,0		;OS/E flag enable?
		jnz	enable_OSE_func2
		CMP	access_key_h,BX		;compare access key high
		jnz	enable_OSE_func2
		CMP	access_key_l,CX		;compare access key low
		jnz	enable_OSE_func2
		MOV	OSE_flag,0		;enable OS/E function
		MOV	OSE_fast,0		;reset OS/E fast access flag
		XOR	AX,AX
		MOV	ES,AX
		MOV	AX,ES:[46CH]
		ADD	BX,AX			;make access key...
		MOV	access_key_h,BX
		ADC	AX,ES:[46EH]
		ADD	CX,AX
		MOV	access_key_l,CX
		JMP	noerr
;.........................................................................
;--------------------------------------------------------------------
; \82\EB\E7\A8᫥\AD\A8\A5 \AC\A0\AAᨬ\A0\AB쭮 \A2\AE\A7\AC\AE\A6\AD\AE\A9 \A4\AB\A8\AD\EB \A1\AB\AE筮\A9 \AF\A5\E0\A5\E1뫪\A8
; \A2室
;       BL      : ⨯ \AF\A0\AC\EF\E2\A8 (0=RAM,1=EMS)
;       AX      : ᬥ饭\A8e \A1\AB\AE\AA\A0
; \A2\EB室
;       AX      : \A4\AB\A8\AD\A0 \AF\A5\E0\A5\E1뫪\A8
;--------------------------------------------------------------------
maxlen          PROC    NEAR
                or      bl,bl
                jnz     max1
                test    [bp].direct_move,1      ;\A4\AB\EF ᮢ\AC\A5\E1⨬\AE\A9 \AF\A0\AC\EF\E2\A8...
                jnz     max2
                neg     ax
                jmp     short max3
max2:
                inc     ax
max3:
                or      ax,ax
                jnz     max4
                dec     ax
                ret
max1:
                test    [bp].direct_move,1      ;\A4\AB\EF EMS...
                jnz     max5
                sub     ax,4000h
                neg     ax
                ret
max5:
                inc     ax
max4:
                ret
maxlen          ENDP

;--------------------------------------------------------------------
; Check logical page no.
; input
;	BX	: logical page number in handle
;	DX	: EMM handle
; output
;	AX	: logical page number in EMM
;	CF = 0	: OK
;	CF = 1	: NG
;--------------------------------------------------------------------
check_log_page 	PROC	NEAR
		PUSH	CX SI
		MOV	SI,DX
		SHL	SI,1
		CMP	bl,CS:[SI].alloc_page_count
		jnb	check_log_page2
		MOV	SI,CS:[SI].page_address
		MOV	AX,BX
		SHL	AX,1
		ADD	SI,AX
		MOV	AX,CS:[SI]		;get logical no. in EMM
		CLC
check_log_page1:
		POP	SI CX
		RET
check_log_page2:
		STC
		JMP	short check_log_page1
check_log_page 	ENDP
;--------------------------------------------------------------------
; Check EMM handle no.
; input
;	DX	: EMM handle
; output
;	CF = 0	: OK
;	CF = 1	: NG
;--------------------------------------------------------------------
check_handle 	PROC	NEAR
		PUSH	DI
		CMP	DX,HANDLE_CNT
		jnb	check_handle1
		MOV	DI,DX
		SHL	DI,1
		cmp	byte ptr CS:[DI].handle_flag,0	;active handle ?
		JZ	check_handle1
		CLC
check_handle2:
		POP	DI
		RET
check_handle1:
		STC
                jmp     check_handle2
check_handle 	ENDP
;--------------------------------------------------------------------
; Set physical page.
; input
;	AL	: physical page no.
;	BX	: logical page no. in EMM (if BX=FFFFH then unmap)
;	DX	: EMM handle
;--------------------------------------------------------------------
set_phys_page	PROC	NEAR
		PUSH	AX CX DX DI
		cbw
		MOV	DI,OFFSET map_table
		MOV	CL,SIZE phys_page_struct
		MUL	CL
		ADD	DI,AX
		PUSH	DX
		MOV	DX,CS:[DI].phys_page_port
		MOV	AX,BX
; JJP           OR      AL,80h
		OUT	DX,AL
		POP	DX
		MOV	CS:[DI].emm_handle2,DX	;handle
		MOV	CS:[DI].log_page_data,AL;logical page no.
		POP	DI DX CX AX
		RET
set_phys_page	ENDP
;--------------------------------------------------------------------
; Change mappable segment address to physical page number.
; input
;	AX	: mappable segment address
; output
;	AX	: physical page number
;--------------------------------------------------------------------
change_seg_page	PROC	NEAR
		PUSH	BX CX DI
		XOR	BX,BX
		MOV	DI,OFFSET map_table
		MOV	CX,PHYS_PAGES
		CLC				;reset CF
change_seg_page2:
		CMP	AX,CS:[DI].phys_seg_addr
		JZ	change_seg_page1
		ADD	DI,SIZE phys_page_struct
		INC	BX
		LOOP	change_seg_page2
		STC				;set CF
change_seg_page1:
		MOV	AX,BX
		POP	DI CX BX
		RET
change_seg_page	ENDP

;
;               EMS 4.0 Data
;
                ALIGN   2
;
;	handle name buffer
;
handle_name	LABEL	BYTE
		DB	HANDLE_NAME_SIZE * HANDLE_CNT DUP (0)
;
;       f24 Save area
;
f24_data        DB      SIZE phys_page_struct * 2 dup (0)
;
;--------------------------------------------------------------------
; EMM driver initilize program
;--------------------------------------------------------------------
emminit:
		PUSH	CX DX SI DI ES BP       ;Store registers...
		PUSH	CS
		POP	DS
		XOR	AX,AX
		MOV	ES,AX
		MOV	SI,19CH
		MOV	WORD PTR ES:[SI],OFFSET int67;set int67 offset.
		MOV	ES:[SI+2],CS		;set int67 segment.
		CALL	getprm			;get parameters
                test    sysflg,1
                jz      emminit1
                call    set32
emminit1:
		MOV	SI,OFFSET start_msg	;display start messege.
		CALL	strdsp
		CALL	ckemsio			;check EMS i/o port
		jc	errems			;error ?
		CALL	ramchk			;check EMS memory
		jc	errems			;error ?
		CALL	instmsg			;display install message.
		XOR	AX,AX
		MOV	ES,AX
		MOV	AX,ES:[46CH]
		ADD	BX,AX			;make access key...
		MOV	access_key_h,BX
		ADC	AX,ES:[46EH]
		ADD	BX,AX
		MOV	access_key_l,BX
		XOR	DI,DI			;set system handle...
		PUSH	CS
		POP	ES
		MOV	byte ptr es:[DI].handle_flag,1;set system handle active.
		INC	es:handle_count		;handle count up
		MOV	AX,OFFSET emminit	;make 4.0 break address...
                test    sysflg,1
                jz      emminit2
		MOV	AX,OFFSET func16	;make 3.2 break address...
emminit2:
		ADD	AX,0FH
		MOV	CL,4
		SHR	AX,CL
		MOV	CX,AX
		MOV	AX,CS
		ADD	AX,CX
		MOV	emm_flag,1		;set EMM install flag.
		LDS	BX,ptrsav
		MOV	[BX].brkoff,0		;break address offset set.
		MOV	[BX].brkseg,AX		;break address segment set.
		JMP	short emmint1
errems:
		MOV	SI,OFFSET notinst	;display error message
		CALL	strdsp
		MOV	emm_flag,0		;reset EMM install flag.
		PUSH	CS
		POP	ES
		MOV	DI,OFFSET func_table
		MOV	AX,OFFSET err80
		MOV	CX,30
		REPZ	STOSW
		LDS	BX,ptrsav
		MOV	AX,OFFSET func2		;set break address offset.
		MOV	[BX].brkoff,AX		;set break address offset.
		MOV	[BX].brkseg,CS		;set break address segment.
emmint1:
		POP	BP ES DI SI DX CX	;Restore registers...
		JMP	exit			;exit initial program.
;--------------------------------------------------------------------
; Get CONFIG.SYS parameters.
;--------------------------------------------------------------------
getprm		PROC	NEAR
		PUSH	DS
		LES	BX,ptrsav
		MOV	DI,ES:[BX].count
		MOV	AX,ES:[BX].start
		MOV	ES,AX
		XOR	CL,CL
getpr2:
		MOV	AL,ES:[DI]
		CMP	AL,CR
		JZ	getpr4
		CMP	AL,'/'		;set page frame address?
                jne     getpr5
                inc     di
		MOV	AL,ES:[DI]
                OR      AL,20h          ;tolower
		CMP	AL,'p'		;set page frame address?
		JNZ	getpr3
		INC	DI
		MOV	AL,ES:[DI]
		CMP	AL,':'
		JNZ	getpr5
		INC	DI
		CALL	ascbin2		;change data ascii -> binary.
		JNC	getpr8		;error ?
		JMP	getpr5
getpr8:
		MOV	page_frame_seg,AX
		JMP	getpr5
getpr3:
		CMP	AL,'i'		;set EMS i/o port address?
		JNZ	getpr6
		INC	DI
		MOV	AL,ES:[DI]
		CMP	AL,':'
		JNZ	getpr5
		INC	DI
		CALL	ascbin2		;change data ascii -> binary.
		MOV	emsio,AX
		JMP	getpr5
getpr6:
		CMP	AL,'f'		;set EMS i/o port address?
		JNZ	getpr7
		INC	DI
		MOV	AL,ES:[DI]
		CMP	AL,':'
		JNZ	getpr5
		INC	DI
		CALL	ascbin1		;change data ascii -> binary.
		MOV	pageofs,al
		JMP	getpr5
getpr7:
		CMP	AL,'q'		;set quiet mode
		JNZ	getpr1
		OR	CL,4
		JMP	getpr5
getpr1:
		CMP	AL,'n'		;set notest mode
		JNZ	getpr10
		OR	CL,8
		JMP	getpr5
getpr10:
		CMP	AL,'x'		;set extended memory test
		JNZ	getpr9
		OR	CL,2
		JMP	getpr5
getpr9:
		CMP	AL,'3'		;set 3.2 mode
		JNZ	getpr5
		OR	CL,1
getpr5:
		INC	DI
		JMP	getpr2
getpr4:
		MOV	sysflg,CL	;set system option flag.
		POP	DS
		RET
getprm		ENDP
;--------------------------------------------------------------------
; Display EMM install opening message.
;--------------------------------------------------------------------
instmsg		PROC	NEAR
		PUSH	AX BX CX DI
		PUSH	CS
		POP	ES
		MOV	AX,page_frame_seg
		MOV	DI,OFFSET segadr
		CALL	hbinasc
		MOV	AX,total_pages
		MOV	DI,OFFSET total_pg
		CALL	dbinasc
		MOV	AX,emsio
		MOV	DI,OFFSET pioadr
		CALL	hbinasc
		MOV	AX,total_pages
                mov     cl,4
                shl     ax,cl                   ; Multiply to 16
		MOV	DI,OFFSET totmem
		CALL	dbinasc
		MOV	SI,OFFSET install_msg
		CALL	strdsp
		POP	DI CX BX AX
		RET
instmsg		ENDP
;--------------------------------------------------------------------
; Check EMS i/o port.
; output
; for lo-tech EMS board, we cannot read from the page registers
; hence we just return OK anyway.
;	cf = 0 : OK
;	cf = 1 : NG
;--------------------------------------------------------------------
ckemsio		PROC	NEAR
		MOV	DX,CS:EMSIO
; JJP		IN	AL,DX
; JJP		CMP	AL,255			;check TRS flag
; JJP		JE	ckems3
ckems4:
		CLC				;reset CF
		RET
ckems3:
		MOV	SI,OFFSET hard_w_err	;display hardware error messege.
		CALL	strdsp
		STC				;set CF
		RET
ckemsio		ENDP
;--------------------------------------------------------------------
; Check expanded memory.
; output
;	cf = 0 : OK
;	cf = 1 : NG
;--------------------------------------------------------------------
ramchk		PROC	NEAR
		PUSH	AX BX CX DX BP
		PUSH	CS
		POP	DS
		MOV	DI,OFFSET map_table
		MOV	CX,PHYS_PAGES
		MOV	BX,emsio
		MOV	SI,page_frame_seg
ramch14:
		MOV	[DI].phys_page_port,BX
		MOV	[DI].log_page_data,0
		MOV	[DI].phys_seg_addr,SI
		ADD	DI,SIZE phys_page_struct
		ADD	SI,0400H
		MOV	DX,BX			;disable physical pages ---
		MOV	AL,DIS_EMS
		OUT	DX,AL
; JJP		ADD	BX,4000h
		INC	BX			; lo-tech cards registers are sequential from base address
		LOOP	ramch14
		MOV	SI,OFFSET pagemsg	;display page test msg..
		CALL	strdsp
		IN	AL,I8042+1		;logical page test...
		OR	AL,4			;system memory parity disable
                and     al,0feh
		OUT	I8042+1,AL
		MOV	DI,OFFSET log_page
		MOV	DX,emsio
		MOV	AL,pageofs		;get EMS logical page start no.
                xor     ah,ah
		MOV	CX,PAGE_MAX
                sub     cx,ax
                jng     ramch16
                mov     ah,al
		XOR	BX,BX
ramch9:
		PUSH	CX
                MOV     AL,AH
; JJP           OR      AL,80h
		OUT	DX,AL
		CALL	imgchk			; checks the page is RAM
		jc	ramch17
                test    byte ptr sysflg,8       ;supress memory test
                jne     ramch2
                call    testkb			; check if user press ESC
                jnc     ramch6
                or      byte ptr sysflg,8       ;supress memory test
                jmp     short ramch2
ramch6:
                test    byte ptr sysflg,2       ;long memory test
                jne     ramch3
		CALL	pagetst
                jmp     short ramch4
ramch3:
		CALL	spagetst
ramch4:
		jc	ramch8
ramch2:
		MOV	[DI],NOT_USE
		INC	BX
ramch17:
		ADD	DI,LOG_SIZE
ramch8:
		POP	CX
		INC	AH
		LOOP	ramch9
ramch16:
		MOV	total_pages,BX
		MOV	un_alloc_pages,BX
		MOV	AL,DIS_EMS
		OUT	DX,AL
		IN	AL,I8042+1		;enable system memory parity..
		AND	AL,0FBH
		or	AL,1
		OUT	I8042+1,AL
		CMP	total_pages,0		;total page zero?
		JNZ	ramch7
		MOV	SI,OFFSET nopage_err	;error message display
		CALL	strdsp
		STC				;set CF
		JMP	ramch5
ramch7:
		CLC
ramch5:
		POP	BP DX CX BX AX
		RET
ramchk		ENDP
;--------------------------------------------------------------------
; check memory size (1024 KByte)
;--------------------------------------------------------------------
imgchk		PROC	NEAR
		CLD
		PUSH	AX CX SI DI DS
		PUSH	CS			;set ES <- CS..
		POP	ES
                test    ah,3
                jnz     imgchk2
		IN	AL,I8042+1
		or	AL,2
		OUT	I8042+1,AL
imgchk2:
		MOV	AL,AH
                CBW
		MOV	DI,OFFSET tstpage
		CALL	dbinasc			;change binary -> ascii.
		MOV	SI,OFFSET tstpage	;display message..
		CALL	strdsp
		IN	AL,I8042+1
		and	AL,0fdh
		OUT	I8042+1,AL
		MOV	AX,page_frame_seg
		MOV	ES,AX
		MOV	ax,chkchr
                mov     es:[0],ax
                cmp     es:[0],ax
                jne     imgch1
		xor	ax,ax
                mov     es:[0],ax
		CLC
		jmp	imgch3
imgch1:
		STC
imgch3:
		POP	DS DI SI CX AX
		RET
imgchk		ENDP
;--------------------------------------------------------------------
; check logical page memory.
; input
;	AX	: logical page no.
;--------------------------------------------------------------------
pagetst		PROC	NEAR
		CLD				;reset DF
		PUSH	AX BX CX DX DI
		MOV	AX,page_frame_seg	;set page frame address -> ES...
		MOV	ES,AX
		MOV	AX,chkchr
		XOR	DI,DI
		MOV	CX,2000h
		REP	STOSW
		XOR	DI,DI
		MOV	CX,2000h		;check pattan data...
		REPZ	SCASW
		JZ	pagets1
pagets2:
		STC
		JMP	pagets5
pagets1:
		XOR	AX,AX			;clear expand memory...
		XOR	DI,DI
		MOV	CX,2000h
		REP	STOSW
		CLC
pagets5:
		POP	DI DX CX BX AX
		RET
pagetst		ENDP
;--------------------------------------------------------------------
spagetst	proc	near
		cld				;reset DF
		push	ax bx cx di ds
		mov	ax,page_frame_seg	;set page frame address -> ES...
		mov	es,ax
		mov	ds,ax
		xor	ax,ax
		xor	di,di
		mov	cx,2000h
		rep	stosw                   ;Fill area with zeros
                mov     bx,00ffh
;       Pass 1
		xor	di,di
		mov	cx,4000h
spagets3:
                mov     al,[di]
                cmp     al,bh
                jne     spagets2
                mov     [di],bl
                inc     di
                loop    spagets3
;       Pass 2
		xor	di,di
		mov	cx,4000h
                xchg    bl,bh
spagets4:
                mov     al,[di]
                cmp     al,bh
                jne     spagets2
                mov     [di],bl
                inc     di
                loop    spagets4
;       Pass 3
		mov	di,4000h
                dec     di
                xchg    bl,bh
spagets6:
                mov     al,[di]
                cmp     al,bh
                jne     spagets2
                mov     [di],bl
                dec     di
                jns     spagets6
;       Pass 4
		mov	di,4000h
                dec     di
                xchg    bl,bh
spagets7:
                mov     al,[di]
                cmp     al,bh
                jne     spagets2
                mov     [di],bl
                dec     di
                jns     spagets7
		clc
spagets5:
		pop	ds di cx bx ax
		ret
spagets2:
		stc
		jmp	spagets5
spagetst 	endp
;--------------------------------------------------------------------
; Change data BYNARY -> ASCII (DEC)
; input
;	AX	: binary data
; output
;	ES:DI	: ascii data (DEC)
;--------------------------------------------------------------------
dbinasc:
		PUSH	AX BX CX DX SI
		MOV	SI,DI
		MOV	CX,4
		MOV	BX,1000
		XOR	DX,DX
dbinas1:
		DIV	BX
		OR	AL,AL
		JNZ	dbinas2
		CMP	CL,4
		JZ	dbinas4
		CMP	BYTE PTR [SI],' '
		JNZ	dbinas2
dbinas4:
		MOV	AL,' '
		CMP	CL,1
		JNZ	dbinas3
		XOR	AL,AL
dbinas2:
		ADD	AL,'0'
dbinas3:
		MOV	SI,DI
		STOSB
		PUSH	DX
		XOR	DX,DX
		MOV	AX,BX
		MOV	BX,10
		DIV	BX
		MOV	BX,AX
		POP	AX
		LOOP	dbinas1
		POP	SI DX CX BX AX
		DEC	DI
		RET
;--------------------------------------------------------------------
; Change data BYNARY -> ASCII (HEX)
; input
;	AX	: binary data
; output
;	ES:DI	: ascii data (HEX)
;--------------------------------------------------------------------
hbinasc:
		PUSH	AX BX CX DX SI
		MOV	SI,DI
		MOV	CX,4
		MOV	BX,1000H
		XOR	DX,DX
hbinas1:
		DIV	BX
		CMP	AL,10
		JC	hbinas2
		ADD	AL,7
hbinas2:
		ADD	AL,'0'
hbinas3:
		MOV	SI,DI
		STOSB
		PUSH	DX
		XOR	DX,DX
		MOV	AX,BX
		MOV	BX,10H
		DIV	BX
		MOV	BX,AX
		POP	AX
		LOOP	hbinas1
		POP	SI DX CX BX AX
		DEC	DI
		RET
;--------------------------------------------------------------------
; Change data ASCII (DEC) -> BINARY
; input
;	ES:DI = ascii data address (DEC)
; output
;	AX = binary data
;--------------------------------------------------------------------
ascbin1:
		PUSH	BX CX DX
		XOR	DL,DL
		MOV	CX,4
		XOR	BX,BX
ascbin11:
		MOV	AL,ES:[DI]
		CMP	AL,' '
		JZ	ascbin13
		CMP	AL,TAB
		JNZ	ascbin14
ascbin13:
		OR	DL,DL
		JNZ	ascbin12
		INC	DI
		JMP	ascbin11
ascbin12:
		OR	DL,DL
		JNZ	ascbin16
		STC
		JMP	ascbin15
ascbin14:
		CMP	AL,'0'
		JC	ascbin12
		CMP	AL,':'
		JNC	ascbin12
		MOV	DL,1
		SUB	AL,'0'
		XOR	AH,AH
		XCHG	BX,AX
		PUSH	DX
		MOV	DX,10
		MUL	DX
		ADD	BX,AX
		POP	DX
		INC	DI
		LOOP	ascbin11
ascbin16:
		MOV	AX,BX
		CLC
ascbin15:
		POP	DX CX BX
		RET
;--------------------------------------------------------------------
; Change data ASCII (HEX) -> BINARY
; input
;	ES:DI = ascii data address (HEX)
; output
;	AX = binary data
;--------------------------------------------------------------------
ascbin2:
		PUSH	BX CX DX
		XOR	DL,DL
		MOV	CX,4
		XOR	BX,BX
ascbin21:
		MOV	AL,ES:[DI]
		CMP	AL,' '
		JZ	ascbin23
		CMP	AL,TAB
		JNZ	ascbin24
ascbin23:
		OR	DL,DL
		JNZ	ascbin22
		INC	DI
		JMP	ascbin21
ascbin22:
		OR	DL,DL
		JNZ	ascbin27
		STC
		JMP	ascbin25
ascbin24:
		CMP	AL,'0'
		JC	ascbin22
		CMP	AL,':'
		JC	ascbin26
		CMP	AL,'A'
		JC	ascbin22
		CMP	AL,'G'
		JNC	ascbin22
		SUB	AL,7
ascbin26:
		MOV	DL,1
		SUB	AL,'0'
		XOR	AH,AH
		XCHG	BX,AX
		PUSH	DX
		MOV	DX,10H
		MUL	DX
		ADD	BX,AX
		POP	DX
		INC	DI
		LOOP	ascbin21
ascbin27:
		MOV	AX,BX
		CLC
ascbin25:
		POP	DX CX BX
		RET
;--------------------------------------------------------------------
; STRINGS DISPLAY SUB
; input
;	DS:SI	: strings datas
;--------------------------------------------------------------------
strdsp:
                test    byte ptr cs:sysflg,4    ;supress output
                jnz     strdsp1                 ;when in quet mode
		PUSH	AX DX ES
		PUSH	CS
		POP	ES
		MOV	DX,SI
		MOV	AH,9
		INT	21H			;bdos call
		POP	ES DX AX
strdsp1:
		RET
;
;               Set EMS 3 mode
;
set32:
                mov     byte ptr msg_ver,'3'
                mov     byte ptr msg_ver+2,'2'
                mov     byte ptr f7_ver,32h
                mov     byte ptr f_max,4fh
                ret
;
;               Test ESC from keyboard
;
testkb:
                push    ax
                mov     ah,1
                int     16h
                jz      testkb1
                xor     ah,ah
                int     16h
                cmp     al,27
                jne     testkb1
                stc
                jmp     short testkb2
testkb1:
                clc
testkb2:
                pop     ax
                ret
;____________________________________________________________________
;
;               This is "EXE" part of this driver
;
;____________________________________________________________________
info:
                push    cs
                pop     ds
		mov	si, offset start_msg	; Display title & version
                call    strdsp
                mov     si, offset info_msg     ; Display switches
                call    strdsp
                mov     ax,4c00h                ;Exit to DOS
                int     21h
;____________________________________________________________________

;--------------------------------------------------------------------
;	EMM driver initial routine work data area
;--------------------------------------------------------------------
start_msg       db      CR,LF
                DB	'LTEMM: Lo-tech EMM Driver '
msg_ver         db      'r01'
		DB	CR,LF,'$'
install_msg	label   byte
page_msg	DB	'Page frame specification: Frame Segment at '
segadr		DB	'0000',CR,LF
total_pg	DB	'0000 pages found on EMS board at '
pioadr		DB	'0000',CR,LF
                db      'Installation completed - '
totmem          db      '0000K RAM Available.',CR,LF,LF,'$'
hard_w_err	DB	'No EMS board found.',CR,LF,'$'
nopage_err	DB	'No EMS memory found.',CR,LF,'$'
notinst		DB	'Installation failed - No EMS available.',CR,LF,LF,'$'
pagemsg		DB	'0000 Pages testing, Esc bypass test',CR,'$'
tstpage		DB	'0000',CR,'$'
info_msg        db       CR,LF
		db      'Expanded Memory Manager for the Lo-tech 2MB EMS board.',CR,LF
		db	 CR,LF
		db	'Based on original works Copyright (c) 1988, Alex Tsourikov.',CR,LF
		db	'All rights reserved.',CR,LF
                db       CR,LF
                db      'http://www.lo-tech.co.uk/wiki/2MB-EMS-Board',CR,LF
                db      'Syntax:    DEVICE=LTEMM.EXE [/switches]',CR,LF
                db       CR,LF
                db      '  /p:nnnn - Page frame address(E000)',CR,LF
                db      '  /i:nnn  - EMS i/o port base address(260)',CR,LF
                db      '  /h:nnn  - Maximal number of handles(64)',CR,LF
                db      '  /d:nn   - Depth of contest saves(5)',CR,LF
;               db      '  /f:nnn  - First page number(0)',CR,LF
                db      '  /n      - Bypass memory test',CR,LF
                db      '  /x      - Perform long memory test',CR,LF
                db      '  /3      - Use only EMS 3.2 functions',CR,LF
                db      '  /q      - Quiet mode',CR,LF
                db       CR,LF
                db      'Defaults in parentheses.',CR,LF,'$'
pageofs		DB	0		;logical page no. offset data
sysflg		DB	0		;system option flag
chkchr		DW	55AAH
code		ENDS
		END     INFO
