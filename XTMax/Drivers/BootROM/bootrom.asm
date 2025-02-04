;
; BIOS Extension ROM for XTMax SD Card support.
; Copyright (c) 2025 Matthieu Bucchianeri, All rights reserved.
;

bits 16
cpu 8086    ; ensure we remain compatible with 8086


;%define DEBUG
;%define DEBUG_IO
;%define EXTRA_DEBUG


%define FIXED_DISK_0        (0)
%define FIXED_DISK_1        (1)
%define FLOPPY_DISK         (-0x80)

;
; Whether we will emulate the 1st or 2nd disk.
;
%define DISK_NUMBER         FIXED_DISK_0

%define EMULATE_FIXED_DISK  (DISK_NUMBER >= FIXED_DISK_0)

;
; Whether we will use our own bootstrap code.
;
;%define USE_BOOTSTRAP

;
; The properties of our emulated disk.
;
%if EMULATE_FIXED_DISK
%define NUM_CYLINDERS       (1024)
%define NUM_HEADS           (16)
%define SECTORS_PER_TRACK   (63)
; the last cylinder is reserved on fixed disks
%define NUM_SECTORS         (NUM_HEADS * (NUM_CYLINDERS - 1) * SECTORS_PER_TRACK)
%else
%define NUM_HEADS           (2)
%define SECTORS_PER_TRACK   (18)
%define NUM_CYLINDERS       (80)
%define NUM_SECTORS         (NUM_HEADS * NUM_CYLINDERS * SECTORS_PER_TRACK)
%endif

%if NUM_HEADS > 16
%error NUM_HEADS must be 4 bits
%endif
%if EMULATE_FIXED_DISK && SECTORS_PER_TRACK > 63
%error SECTORS_PER_TRACK must be 6 bits
%endif
%if NUM_CYLINDERS > 1024
%error NUM_CYLINDERS must be 10 bits
%endif

%ifndef AS_COM_PROGRAM
;
; BIOS will look for the AA55 signature between C8000-DFFFF in 2KB increments.
; We choose an address in that range.
;
%define ROM_SEGMENT         (0xc000)
org (ROM_SEGMENT << 4 | 0xe000)
dw 0AA55h   ; signature
db 4        ; size in blocks of 512 bytes

%else
;
; Building as a COM file for testing.
;
org 0x100

%endif

entry:
%ifndef AS_COM_PROGRAM
    push es
    push ax
    push dx
    cli
%endif

    mov ax, welcome_msg
    call print_string

;
; Initialize the SD Card.
;
    call init_sd
%ifndef AS_COM_PROGRAM
    jc .skip
%endif

;
; Detecting 80186-compatible so we can use REP INSW/OUTSW.
; Based on https://www.rcollins.org/ftp/source/cpuid/cpuid.asm
;
.cpuid:
    push sp
    pop ax
    cmp ax, sp                      ; if below 80286, these values will differ
    jz .support_string_io           ; nope, 80286 or higher
    mov ax, ds:[0xffff]             ; get original data
    mov word ds:[0xffff], 0xaaaa    ; write signature at test location
    cmp byte ds:[0], 0xaa           ; 8086 will write the 2nd byte at offset 0
    mov ds:[0xffff], ax
    je .test_v20
    jmp .support_string_io          ; we have an 80186/80188
.test_v20:
    push ax                         ; save results
    xor al, al                      ; force ZF
    mov al, 0x40                    ; multiplicand
    mul al                          ; V20 doesn't affect ZF
    pop ax                          ; restore results
    jz .support_string_io           ; we have an V20
    xor dl, dl
    jmp .store_string_io
.support_string_io:
    mov dl, 1
    mov ax, string_io_msg
    call print_string
.store_string_io:
    mov ax, 0x283           ; scratch register 0
    xchg ax, dx
    out dx, al              ; save capability

%ifndef AS_COM_PROGRAM
;
; Install our BIOS INT13h hook into the interrupt vector table.
;
.install_13h_vector:
    mov ax, old_13h_msg
    call print_string

    xor ax, ax              ; INT vector segment
    mov es, ax

    mov ax, es:[0x13*4+2]
    mov dx, 0x284           ; scratch register 1-2
    out dx, ax              ; save segment
    call print_hex
    mov ax, colon
    call print_string
    mov ax, es:[0x13*4]
    mov dx, 0x286           ; scratch register 3-4
    out dx, ax              ; save offset
    call print_hex
    mov ax, newline
    call print_string

    mov ax, new_13h_msg
    call print_string

    mov ax, ROM_SEGMENT
    mov es:[0x13*4+2], ax   ; store segment
    call print_hex
    mov ax, colon
    call print_string
    mov ax, int13h_entry
    mov es:[0x13*4], ax     ; store offset
    call print_hex
    mov ax, newline
    call print_string

%if EMULATE_FIXED_DISK
;
; Install our fixed disk parameter table.
; For the 1st disk, it is stored in the interrupt vector table, at vector 41h.
; For the 2nd disk, it is stored in the interrupt vector table, at vector 46h.
;
.install_fixed_disk_parameters_table:
    mov ax, new_fdpt_msg
    call print_string

    mov ax, ROM_SEGMENT
    mov es:[(0x41+DISK_NUMBER*5)*4+2], ax   ; store segment
    call print_hex
    mov ax, colon
    call print_string
    mov ax, fixed_disk_parameters_table
    mov es:[(0x41+DISK_NUMBER*5)*4], ax     ; store offset
    call print_hex
    mov ax, newline
    call print_string

%ifdef USE_BOOTSTRAP
;
; Install our BIOS INT18h hook into the interrupt vector table.
;
.install_18h_vector:
    mov ax, new_18h_msg
    call print_string

    mov ax, ROM_SEGMENT
    mov es:[0x18*4+2], ax   ; store segment
    call print_hex
    mov ax, colon
    call print_string
    mov ax, int18h_entry
    mov es:[0x18*4], ax     ; store offset
    call print_hex
    mov ax, newline
    call print_string
%else

;
; Increment the number of fixed disks in the BIOS Data Area.
;
    mov ax, 0x40            ; BIOS data area
    mov es, ax
    inc byte es:[0x75]      ; HDNUM
%endif
%endif

.skip:
    sti
    pop dx
    pop ax
    pop es
    retf

%else

;
; Execute COM program testing.
;
%include "tests.inc"

;
; DOS exit program.
;
    mov ah, 0x4c
    xor al, al
    int 0x21

%endif

;
; The handler will preserve BP and SI across calls and therefore they can be used as temp.
;
%define TEMP0   bp
%define TEMP1   si
%define TEMP_LO TEMP0
%define TEMP_HI TEMP1

;
; INT 13h entry point.
;
int13h_entry:
%ifdef EXTRA_DEBUG
    call dump_regs
%endif
    push TEMP0
    push TEMP1
    cmp dl, 0x80+DISK_NUMBER    ; is this our drive?
    je .check_function

;
; This is not an operation for the SD Card. Forward to the BIOS INT 13h handler.
;
.forward_to_bios:
%ifdef EXTRA_DEBUG
    push ax
    mov ax, forward_msg
    call print_string
    pop ax
    push ax
    mov al, ah
    xor ah, ah
    call print_hex
    mov ax, newline
    call print_string
    pop ax
%endif
    mov TEMP0, ax               ; save ax
    mov TEMP1, dx               ; save dx
    pushf                       ; setup for iret from INT 13h handler
    push cs                     ; setup for iret from INT 13h handler
    mov ax, .return_from_int13h
    push ax                     ; setup for iret from INT 13h handler
.simulate_int13h:
;
; Simulate INT 13h with the original vector.
;
    pushf                       ; setup for iret below
    mov dx, 0x284               ; scratch register 1-2
%ifndef AS_COM_PROGRAM
    in ax, dx
%else
    mov ax, cs
%endif
    push ax                     ; setup for iret below
    mov dx, 0x286               ; scratch register 3-4
%ifndef AS_COM_PROGRAM
    in ax, dx
%else
    mov ax, fake_int13h_entry
%endif
    push ax                     ; setup for iret below
    mov ax, TEMP0               ; restore ax
    mov dx, TEMP1               ; restore dx
    iret                        ; call the INT 13h handler
.return_from_int13h:
    jmp .return_common

;
; This is an operation for the SD Card. Use our own INT 13h logic.
;
.check_function:
%if EMULATE_FIXED_DISK
    cmp ah, 0x15                ; is valid function?
%else
    cmp ah, 0x16                ; is valid function?
%endif
    jle .prepare_call
    call func_unsupported
    jmp .update_bda
.prepare_call:
.check_function_01_and_15:
    cmp ah, 0x1                 ; is read status?
    je .call_no_update_bda
    cmp ah, 0x15                ; is read size?
    je .call_no_update_bda
    mov TEMP1, .update_bda
    jmp .call
.call_no_update_bda:
    mov TEMP1, .return
.call:
    push TEMP1                  ; setup for ret from the handler
    push bx
    mov bl, ah
    xor bh, bh
    shl bl, 1
    mov TEMP1, bx
    pop bx
    jmp [cs:TEMP1+func_table]
.update_bda:
    push es
    mov TEMP1, 0x40             ; BIOS data area
    mov es, TEMP1
    mov es:[0x74], ah           ; store HDSTAT
    pop es
.return:
%ifdef DEBUG
    push ax
    mov ax, status_msg
    call print_string
    pop ax
    push ax
    xchg ah, al
    pushf
    xor ah, ah
    popf
    call print_hex
    mov ax, newline
    call print_string
    pop ax
%endif

;
; Propagate the Carry Flag to the caller.
; MS-DOS hooks INT13h and will not perform a proper INT call, but instead a far call.
; Therefore, we handle the flags like we would for a far call.
;
.return_common:
    mov TEMP0, sp
    mov TEMP1, [TEMP0+8]        ; grab the flags for iret
    pushf
    and TEMP1, 0xfffe           ; clear carry
    popf
    adc TEMP1, 0                ; propagate carry
    push TEMP1
    popf
    pop TEMP1
    pop TEMP0
%ifdef EXTRA_DEBUG
    call dump_regs
%endif
    retf 2                      ; return and discard flags on the stack

;
; INT 13h function table
;
func_table:
    dw  func_10_is_ready            ; reset
    dw  func_01_read_status
    dw  func_02_read_sector
    dw  func_03_write_sector
    dw  func_04_verify_sector
    dw  func_unsupported            ; format_cyl
    dw  func_unsupported            ; format_bad_trk
    dw  func_unsupported            ; format_drv
    dw  func_08_read_params
    dw  func_10_is_ready            ; init_params
    dw  func_unsupported            ; read_sector_long
    dw  func_unsupported            ; write_sector_long
    dw  func_0c_seek_cyl
    dw  func_10_is_ready            ; reset_alt
    dw  func_unsupported            ; read_sector_buf
    dw  func_unsupported            ; write_sector_buf
    dw  func_10_is_ready
    dw  func_10_is_ready            ; recalibrate
    dw  func_unsupported            ; diagnostics
    dw  func_unsupported            ; diagnostics
    dw  func_10_is_ready            ; diagnostics
    dw  func_15_read_size
%if !EMULATE_FIXED_DISK
    dw  func_10_is_ready            ; detect_change
%endif

func_unsupported:
%ifdef DEBUG
    call debug_handler
%endif
    push ax
    mov ax, unsupported_msg
    call print_string
    pop ax
    push ax
    mov al, ah
    xor ah, ah
    call print_hex
    mov ax, newline
    call print_string
    pop ax
    jmp error_invalid_parameter

;
; Fixed Disk Parameters Table
;
fixed_disk_parameters_table:
    dw  NUM_CYLINDERS                   ; cylinders
    db  NUM_HEADS                       ; heads
    db  0, 0                            ; reserved
    dw  0xffff                          ; starting cylinder for write compensation
    db  0                               ; reserved
    db  0xc0 | ((NUM_HEADS > 8) * 0x8)  ; control byte (disable retries, >8 heads)
    db  0, 0, 0                         ; reserved
    dw  0                               ; landing zone
    db  SECTORS_PER_TRACK               ; sectors per track
    db  0                               ; reserved

;
; Function 01h: Read Disk Status
; in:  AH = 01h
;      DL = drive number (80h or 81h)
; out: AH = status
;      CF = 0 (success), 1 (error)
;
func_01_read_status:
%ifdef DEBUG
    call debug_handler
%endif
    push es
    mov TEMP0, 0x40         ; BIOS data area
    mov es, TEMP0
    xor ah, ah
    xchg ah, es:[0x74]      ; load then clear HDSTAT
    test ah, ah
    jz .end
    stc
.end:
    pop es
    ret

;
; Function 02h: Read Disk Sectors
; in:  AH = 02h
;      AL = number of sectors to read
;      CH = cylinder number (low 8 bits)
;      CL = bits 7-6: cylinder number (high 2 bits)
;           bits 5-0: sector number
;      DH = head number
;      DL = drive number (80h or 81h)
;      ES:BX = destination buffer
; out: AH = status
;      CF = 0 (success), 1 (error)
;
func_02_read_sector:
%ifdef DEBUG
    call debug_handler
%endif
    test al, al
    jz error_invalid_parameter
    push ax
    xor ah, ah
    mov TEMP_HI, ax
    push bx
    call compute_lba
    mov TEMP_LO, ax         ; save lba
    add ax, TEMP_HI         ; check the upper boundary
    mov TEMP_HI, bx         ; save lba
    adc bx, 0               ; carry
    call is_lba_valid
    pop bx
    pop ax
    jc error_sector_not_found
    ; TODO: (robustness) check buffer boundaries
.setup:
    push bx
    push cx
    push dx
    push di
    push ax
    mov cx, ax              ; number of sectors to read
    xor ch, ch
    mov di, bx              ; setup use of stosw
.assert_cs:
    mov dx, 0x282           ; chip select port
    mov al, 0               ; assert chip select
    out dx, al
.cmd17:
    push cx
    ; TODO: (opt) use CMD18 for multiple blocks
%ifdef DEBUG_IO
    mov ax, send_cmd17_msg
    call print_string
%endif
    mov ax, TEMP_LO         ; restore lba
    mov bx, TEMP_HI         ; restore lba
    mov cl, 0x51            ; CMD17
    call send_sd_read_write_cmd
    jc .error
%ifdef DEBUG_IO
    mov ax, wait_msg
    call print_string
%endif
    mov dx, 0x280           ; data port
    mov cx, 1000            ; timeout
    jmp .receive_token_no_delay
.receive_token:
    call delay_100us
.receive_token_no_delay:
    in al, dx
    cmp al, 0xfe
    loopne .receive_token
    jne .error
%ifdef DEBUG_IO
    mov ax, sd_token_msg
    call print_string
%endif
    mov cx, 256             ; block size (in words)
    push dx
    mov dx, 0x283           ; scratch register 0
    in al, dx
    pop dx
    test al, al             ; supports insw?
    cld
    jz .receive_block
.receive_block_fast:
cpu 186
    rep insw
cpu 8086
    jmp .receive_crc
.receive_block:
    in ax, dx
    stosw
    loop .receive_block
.receive_crc:
    in ax, dx               ; discard CRC
    add TEMP_LO, 1          ; next block
    adc TEMP_HI, 0          ; carry
    pop cx                  ; number of sectors left to read
    loop .cmd17
.success:
.deassert_cs1:
    mov dx, 0x282           ; chip select port
    mov al, 1               ; deassert chip select
    out dx, al
.return1:
    pop ax
    pop di
    pop dx
    pop cx
    pop bx
    jmp succeeded
.error:
.deassert_cs2:
    mov dx, 0x282           ; chip select port
    mov al, 1               ; deassert chip select
    out dx, al
.return2:
    pop cx                  ; number of sectors not read successfully
    pop ax
    sub al, cl              ; number of sectors read successfully
    pop di
    pop dx
    pop cx
    pop bx
    jmp error_drive_not_ready

;
; Function 03h: Write Disk Sectors
; in:  AH = 03h
;      AL = number of sectors to write
;      CH = cylinder number (low 8 bits)
;      CL = bits 7-6: cylinder number (high 2 bits)
;           bits 5-0: sector number
;      DH = head number
;      DL = drive number (80h or 81h)
;      ES:BX = source buffer
; out: AH = status
;      CF = 0 (success), 1 (error)
;
func_03_write_sector:
%ifdef DEBUG
    call debug_handler
%endif
    test al, al
    jz error_invalid_parameter
    push ax
    xor ah, ah
    mov TEMP_HI, ax
    push bx
    call compute_lba
    mov TEMP_LO, ax         ; save lba
    add ax, TEMP_HI         ; check the upper boundary
    mov TEMP_HI, bx         ; save lba
    adc bx, 0               ; carry
    call is_lba_valid
    pop bx
    pop ax
    jc error_sector_not_found
    ; TODO: (robustness) check buffer boundaries
.setup:
    push ds
    push bx
    push cx
    push dx
    push di
    push ax
    mov cx, ax              ; number of sectors to write
    xor ch, ch
    mov di, bx              ; destination address
    mov ax, es
    mov ds, ax
.assert_cs:
    mov dx, 0x282           ; chip select port
    mov al, 0               ; assert chip select
    out dx, al
.cmd24:
    push cx
    ; TODO: (opt) use CMD25 for multiple blocks
%ifdef DEBUG_IO
    mov ax, send_cmd24_msg
    call print_string
%endif
    mov ax, TEMP_LO         ; restore lba
    mov bx, TEMP_HI         ; restore lba
    mov cl, 0x58            ; CMD24
    call send_sd_read_write_cmd
    jc .error
    mov dx, 0x280           ; data port
    mov al, 0xfe            ; send token
    out dx, al
    mov cx, 256             ; block size (in words)
    xchg di, si             ; save si (aka TEMP1)
    push dx
    mov dx, 0x283           ; scratch register 0
    in al, dx
    pop dx
    test al, al             ; supports outsw?
    cld
    jz .send_block
.send_block_fast:
cpu 186
    rep outsw
cpu 8086
    jmp .end_send_block
.send_block:
    lodsw
    out dx, ax
    loop .send_block
.end_send_block:
    xchg si, di             ; restore si (aka TEMP1)
%ifdef DEBUG_IO
    mov ax, wait_msg
    call print_string
%endif
    mov cx, 2500            ; timeout
    jmp .receive_status_no_delay
.receive_status:
    call delay_100us
.receive_status_no_delay:
    in al, dx
    cmp al, 0xff
    loope .receive_status
%ifdef DEBUG_IO
    push ax
    mov ax, sd_status_msg
    call print_string
    pop ax
    push ax
    xor ah, ah
    call print_hex
    mov ax, newline
    call print_string
    pop ax
%endif
    and al, 0x1F
    cmp al, 0x5
    jne .error
%ifdef DEBUG_IO
    mov ax, wait_msg
    call print_string
%endif
    mov cx, 2500            ; timeout
    jmp .receive_finish_no_delay
.receive_finish:
    call delay_100us
.receive_finish_no_delay:
    in al, dx
    test al, al
    loope .receive_finish
    jz .error
%ifdef DEBUG_IO
    mov ax, sd_idle_msg
    call print_string
%endif
    add TEMP_LO, 1          ; next block
    adc TEMP_HI, 0          ; carry
    pop cx                  ; number of sectors left to write
    loop .cmd24
.success:
.deassert_cs1:
    mov dx, 0x282           ; chip select port
    mov al, 1               ; deassert chip select
    out dx, al
.return1:
    pop ax
    pop di
    pop dx
    pop cx
    pop bx
    pop ds
    jmp succeeded
.error:
.deassert_cs2:
    mov dx, 0x282           ; chip select port
    mov al, 1               ; deassert chip select
    out dx, al
.return2:
    pop cx                  ; number of sectors not written successfully
    pop ax
    sub al, cl              ; number of sectors written successfully
    pop di
    pop dx
    pop cx
    pop bx
    pop ds
    jmp error_drive_not_ready

;
; Function 04h: Verify Disk Sectors
; in:  AH = 04h
;      AL = number of sectors to verify
;      CH = cylinder number (low 8 bits)
;      CL = bits 7-6: cylinder number (high 2 bits)
;           bits 5-0: sector number
;      DH = head number
;      DL = drive number (80h or 81h)
; out: AH = status
;      CF = 0 (success), 1 (error)
;
func_04_verify_sector:
%ifdef DEBUG
    call debug_handler
%endif
    test al, al
    jz error_invalid_parameter
    push ax
    xor ah, ah
    mov TEMP0, ax
    push bx
    call compute_lba
    add ax, TEMP0           ; check the upper boundary
    adc bx, 0               ; carry
    call is_lba_valid
    pop bx
    pop ax
    jc error_sector_not_found
    jmp succeeded

;
; Function 08h: Read Drive Parameters
; in:  AH = 08h
;      DL = drive number (80h or 81h)
; out: AH = status
;      AL = 0
;      CH = maximum usable cylinder number (low 8 bits)
;      CL = bits 7-6: maximum usable cylinder number  (high 2 bits)
;           bits 5-0: maximum usable sector number
;      DH = maximum usable head number
;      DL = number of drives
;      ES:DI = address of disk parameters table (floppies only)
;      CF = 0 (success), 1 (error)
;
func_08_read_params:
%ifdef DEBUG
    call debug_handler
%endif
    mov dh, (NUM_HEADS - 1)

    push es
    mov ax, 0x40            ; BIOS data area
    mov es, ax
    mov dl, es:[0x75]       ; HDNUM
    pop es
%ifndef USE_BOOTSTRAP
    inc dl                  ; we never added ourselves
%endif

%if EMULATE_FIXED_DISK
    ; the last cylinder is reserved on fixed disks
    mov ch, ((NUM_CYLINDERS - 2) & 0xff)
    mov cl, (((NUM_CYLINDERS - 2) & 0x300) >> 2) | SECTORS_PER_TRACK

%else
    mov ch, ((NUM_CYLINDERS - 1) & 0xff)
    mov cl, (((NUM_CYLINDERS - 1) & 0x300) >> 2) | SECTORS_PER_TRACK

    ; diskette drive parameters table, it is stored in the interrupt vector table, at vector 1Eh.
    xor ax, ax              ; INT vector segment
    mov es, ax
    mov ax, es:[0x1e*4]     ; offset
    mov di, ax
    mov ax, es:[0x1e*4+2]   ; segment
    mov es, ax
    mov bx, 0x4             ; 1.44 MB
%endif

    xor ax, ax
    clc
.exit:
    ret

;
; Function 0Ch: Seek to Cylinder
; in:  AH = 0Ch
;      CH = cylinder number (low 8 bits)
;      CL = bits 7-6: cylinder number (high 2 bits)
;           bits 5-0: sector number
;      DH = head number
;      DL = drive number (80h or 81h)
; out: AH = status
;      CF = 0 (success), 1 (error)
;
func_0c_seek_cyl:
%ifdef DEBUG
    call debug_handler
%endif
    push ax
    push bx
    call compute_lba
    call is_lba_valid
    pop bx
    pop ax
    jc error_sector_not_found
    jmp succeeded

;
; Function 10h: Test for Drive Ready
; in:  AH = 10h
;      DL = drive number (80h or 81h)
; out: AH = error code
;      CF = 0 (success), 1 (error)
;
func_10_is_ready:
%ifdef DEBUG
    call debug_handler
%endif
    jmp succeeded

;
; Function 15h: Read Disk Size
; in:  AH = 15h
;      DL = drive number (80h or 81h)
; out: AH = 00h (no drive present)
;           03h (drive present)
;      CX:DX = number of 512-byte sectors
;      CF = 0 (success), 1 (error)
;
func_15_read_size:
%ifdef DEBUG
    call debug_handler
%endif
%if EMULATE_FIXED_DISK
    mov ah, 0x3             ; drive present
    call get_max_lba
    xchg cx, dx
%else
    mov ah, 0x1             ; diskette drive present
%endif
    clc
    ret

;
; Common error handling
;
error_drive_not_ready:
    mov ah, 0xaa
    stc
    ret

error_invalid_parameter:
    mov ah, 0x1
    stc
    ret

error_sector_not_found:
    mov ah, 0x4
    stc
    ret

succeeded:
    xor ah, ah
    clc
    ret

%ifdef USE_BOOTSTRAP
;
; INT 18h entry point.
;
int18h_entry:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov cx, 256
    mov di, 0x7c00
    rep stosw
    mov ax, 0x201           ; read 1 sector
    mov dx, 0x80+DISK_NUMBER
    mov cx, 1               ; sector 1
    mov bx, 0x7c00
    int 0x13
    cmp word [0x7c00+510], 0xaa55
    jne .no_boot
    mov ax, boot_msg
    call print_string
    jmp 0:0x7c00
.no_boot:
    mov ax, no_boot_msg
    call print_string
    sti
.loop:
    hlt
    jmp .loop
%endif

;
; Disk utilities
;

;
; Compute LBA address based on CHS address
; in:  CH = cylinder number (low 8 bits)
;      CL = bits 7-6: cylinder number (high 2 bits)
;           bits 5-0: sector number
;      DH = head number
; out: BX:AX = LBA address
;      FL = <TRASH>
;
compute_lba:
    xor ax, ax
    xor bx, bx
    push dx
    push cx
    push dx
%if EMULATE_FIXED_DISK
    mov al, cl
    and al, 0xc0
    shl ax, 1
    shl ax, 1
%endif
    mov al, ch          ; cylinder
    mov cx, NUM_HEADS
    mul cx              ; cylinder * hpc
    pop dx
    mov cl, dh
    xor ch, ch
    add ax, cx          ; cylinder * hpc + head
    mov cl, SECTORS_PER_TRACK
    mul cx              ; (cylinder * hpc + head) * spt
    pop cx
    push cx
    xor ch, ch
%if EMULATE_FIXED_DISK
    and cl, 0x3f
%endif
    dec cx              ; sector - 1
    add ax, cx          ; (cylinder * hpc + head) * spt + (sector - 1)
    adc dx, 0           ; carry
    mov bx, dx
    pop cx
    pop dx
    ret

;
; Check if an LBA address is within the drive
; in:  BX:AX = LBA address
; out: CF = 0 (success), 1 (error)
;      FL = <TRASH>
;
is_lba_valid:
    push cx
    push dx
    call get_max_lba
    cmp bx, dx          ; check highest word
    jb .success
    ja .error
    cmp ax, cx          ; check lowest word
    jb .success
.error:
    stc
    pop dx
    pop cx
    ret
.success:
    clc
    pop dx
    pop cx
    ret

;
; Retrieve maximum LBA address for the drive
; out: DX:CX = maximum LBA address
;
get_max_lba:
    mov dx, (NUM_SECTORS >> 16)
    mov cx, (NUM_SECTORS & 0xFFFF)
    ret

;
; I/O utilities
;

;
; Initialize the SD Card.
; out: CF = 0 (success), 1 (error)
;      FL = <TRASH>
;
init_sd:
    push ax
    push ds
    push bx
    push cx
    push dx
    push si
%ifndef AS_COM_PROGRAM
    mov ax, ROM_SEGMENT
    mov ds, ax
%endif
    mov dx, 0x282           ; chip select port
    mov al, 1               ; deassert chip select
    out dx, al
    xor cx, cx
    mov dx, 1000            ; microseconds
    mov ah, 0x86            ; wait
    int 0x15
    mov dx, 0x280           ; data port
    mov al, 0xff
    mov cx, 80              ; send 80 clock cycles
.synchronize:
    out dx, al
    loop .synchronize
.assert_cs:
    mov dx, 0x282           ; chip select port
    mov al, 0               ; assert chip select
    out dx, al
.cmd0:
%ifdef DEBUG_IO
    mov ax, send_cmd0_msg
    call print_string
%endif
    mov si, cmd0
    mov cx, 1               ; response is 1 byte
    mov ah, 1               ; expect idle state
    call send_sd_init_cmd
    jc .exit
.cmd8:
%ifdef DEBUG_IO
    mov ax, send_cmd8_msg
    call print_string
%endif
    mov si, cmd8
    mov cx, 5               ; response is 5 bytes
    mov ah, 1               ; expect idle state
    call send_sd_init_cmd
    jc .exit
.acmd41:
    mov bx, 100             ; retries
.retry_acmd41:
%ifdef DEBUG_IO
    mov ax, send_acmd41_msg
    call print_string
%endif
    mov si, cmd55
    mov cx, 1               ; response is 1 byte
    mov ah, 1               ; expect idle state
    call send_sd_init_cmd
    ; TODO: (older cards) on error, try CMD1
    mov si, acmd41
    mov cx, 1               ; response is 1 byte
    mov ah, 0               ; expect ready state
    call send_sd_init_cmd
    jnc .exit
    pushf
    xor cx, cx
    mov dx, 1000            ; microseconds
    mov ah, 0x86            ; wait
    int 0x15
    popf
    dec bx
    jnz .retry_acmd41
    ; TODO: (older cards) send CMD16 to set block size
.exit:
    pop si
    pop dx
    pop cx
    pop bx
    pop ds
    jc .error
.success:
    mov ax, init_ok_msg
    call print_string
    pop ax
    ret
.error:
    mov ax, init_error_msg
    call print_string
    pop ax
    ret

;
; Send an initialization command to the SD card
; in:  DS:SI = command buffer
;      CX = response size (in bytes)
;      AH = expected highest status
; out: AX = <TRASH>
;      CX = <TRASH>
;      DX = <TRASH>
;      SI = <TRASH>
;      CF = 0 (success), 1 (error)
;      FL = <TRASH>
;
send_sd_init_cmd:
    mov dx, 0x280           ; data port
.settle_before:
    mov al, 0xff
    out dx, al
.send_cmd:
    push cx
    mov cx, 6               ; command size
    cld
.send_byte:
    lodsb
    out dx, al
    loop .send_byte
    mov cx, 8               ; retries
.receive_r1:
    in al, dx
    cmp al, 0xff
    loope .receive_r1
    pop cx
    cmp al, ah
    jbe .receive_payload
    stc
    jmp .settle_after
.receive_payload:
    clc
.receive_byte:
    in al, dx
    loop .receive_byte
.settle_after:
    mov al, 0xff
    out dx, al
    ret

cmd0        db  0x40, 0x00, 0x00, 0x00, 0x00, 0x95
cmd8        db  0x48, 0x00, 0x00, 0x01, 0xAA, 0x87
cmd55       db  0x77, 0x00, 0x00, 0x00, 0x00, 0x01
acmd41      db  0x69, 0x40, 0x00, 0x00, 0x00, 0x01

;
; Send a read or write command to the SD card
; in:  CL = command
;      BX:AX = LBA address
; out: AX = <TRASH>
;      BX = <TRASH>
;      CX = <TRASH>
;      DX = <TRASH>
;      CF = 0 (success), 1 (error)
;      FL = <TRASH>
;
send_sd_read_write_cmd:
    mov dx, 0x280           ; data port
    push ax
.settle_before:
    mov al, 0xff
    out dx, al
.send_cmd:
    mov al, cl              ; command byte
    out dx, al
    mov al, bh              ; address byte 1
    out dx, al
    mov al, bl              ; address byte 2
    out dx, al
    pop ax
    xchg al, ah             ; address byte 3
    out dx, al
    xchg al, ah             ; address byte 4
    out dx, al
    mov al, 0x1             ; crc (dummy)
    out dx, al
    mov cx, 8               ; retries
.receive_r1:
    in al, dx
    cmp al, 0xff
    loope .receive_r1
    test al, al
    jz .exit
    stc
.exit:
    ret

;
; General utilities
;

;
; Wait 100 microseconds.
; out: AX = <TRASH>
;      FL = <TRASH>
delay_100us:
    push cx
    push dx
    xor cx, cx
    mov dx, 100             ; microseconds
    mov ah, 0x86            ; wait
    int 0x15
    pop dx
    pop cx
    ret

%include "utils.inc"

%ifdef DEBUG
debug_handler:
    push ax
    mov ax, handler_msg
    call print_string
    pop ax
    push ax
    mov al, ah
    xor ah, ah
    call print_hex
    mov ax, newline
    call print_string
    pop ax
    ret
%endif

;
; Strings
;

welcome_msg     db 'BootROM for XTMax v1.0', 0xD, 0xA
                db 'Copyright (c) 2025 Matthieu Bucchianeri', 0xD, 0xA, 0
string_io_msg   db 'CPU supports INS/OUTS instructions', 0xD, 0xA, 0
old_13h_msg     db 'Old INT13h Vector = ', 0
new_13h_msg     db 'New INT13h Vector = ', 0
new_fdpt_msg    db 'New Fixed Disk Parameter Table = ', 0
init_ok_msg     db 'SD Card initialized successfully', 0xD, 0xA, 0
init_error_msg  db 'SD Card failed to initialize', 0xD, 0xA, 0
unsupported_msg db 'Unsupported INT13h Function ', 0
%ifdef USE_BOOTSTRAP
new_18h_msg     db 'New INT18h Vector = ', 0
boot_msg        db 'Booting from SD Card...', 0xD, 0xA, 0
no_boot_msg     db 'Not bootable', 0xD, 0xA, 0
%endif
colon           db ':', 0
space           db ' ', 0
newline         db 0xD, 0xA, 0

%ifdef DEBUG
handler_msg     db 'INT13h Function ', 0
status_msg      db 'Return with ', 0

%ifdef DEBUG_IO
send_cmd0_msg   db 'Sending CMD0', 0xD, 0xA, 0
send_cmd8_msg   db 'Sending CMD8', 0xD, 0xA, 0
send_cmd17_msg  db 'Sending CMD17', 0xD, 0xA, 0
send_cmd24_msg  db 'Sending CMD24', 0xD, 0xA, 0
send_acmd41_msg db 'Sending ACMD41', 0xD, 0xA, 0
wait_msg        db 'Waiting for SD Card', 0xD, 0xA, 0
sd_token_msg    db 'Received token', 0xD, 0xA, 0
sd_status_msg   db 'Received status ', 0
sd_idle_msg     db 'Received idle', 0xD, 0xA, 0
%endif

%ifdef EXTRA_DEBUG
forward_msg     db 'Forward to BIOS INT13h handler ', 0
%endif
%endif

%ifndef AS_COM_PROGRAM
;
; Pad to 2KB. We will try to keep our ROM under that size.
;
times 2047-($-$$) db 0
db 0    ; will be used to complete the checksum.
%endif
