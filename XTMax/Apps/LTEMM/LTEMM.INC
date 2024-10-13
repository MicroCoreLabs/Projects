;*****************************************************************
;*							         *
;*							         *
;*	EMM/EMS driver program for BOCARAM30 Memory board        *
;*							         *
;*							         *
;*****************************************************************
;
;       Структура физической страницы EMS
;
phys_page_struct                STRUC
    Emm_Handle2                 DW      ?       ;дескриптор-владелец страницы
    Phys_page_port		DW	?	;physical page i/o port address
    Phys_Seg_Addr               DW      ?       ;физический сегментный адрес страницы
    Log_Page_Data               DB      ?       ;номер логической страницы,картированной
phys_page_struct                ENDS            ;на эту физическую страницу

handle_page_struct              STRUC
    emm_handle3                 DW      ?
    page_alloc_to_handle        DW      ?
handle_page_struct              ENDS

partial_page_map_struct         STRUC
    mappable_segment_count      DW      ?
    mappable_segment            DW      4 DUP (?)
partial_page_map_struct         ENDS

log_to_phys_map_struct          STRUC
    log_page_number1            DW      ?
    phys_page_number1           DW      ?
log_to_phys_map_struct          ENDS

log_to_seg_map_struct           STRUC
    log_page_number2            DW      ?
    mappable_seg_addr           DW      ?
log_to_seg_map_struct           ENDS

handle_dir_struct               STRUC
    handle_value                DW      ?
    handle_name1                DB      8 DUP (?)
handle_dir_struct               ENDS

map_and_jump_struct             STRUC
    target_address1             DD      ?
    log_phys_map_len            DB      ?
    log_phys_map_ptr            DD      ?
map_and_jump_struct             ENDS

map_and_call_struct             STRUC
    target_address2             DD      ?
    new_page_map_len            DB      ?
    new_page_map_ptr            DD      ?
    old_page_map_len            DB      ?
    old_page_map_ptr            DD      ?
    reserved                    DW      4 DUP (?)
map_and_call_struct             ENDS

move_info_struct                STRUC
    region_lenght               DD      ?
    source_type                 DB      ?
    source_handle1              DW      ?
    source_offset               DW      ?
    source_seg_page             DW      ?
    dest_type                   DB      ?
    dest_handle1                DW      ?
    dest_offset                 DW      ?
    dest_seg_page               DW      ?
move_info_struct               ENDS

mappable_phys_page_struct       STRUC
    phys_page_segment           DW      ?
    phys_page_number2           DW      ?
mappable_phys_page_struct       ENDS

hardware_info_struct            STRUC
    raw_page_size               DW      ?
    alternate_register_sets     DW      ?
    context_save_area_size      DW      ?
    DMA_register_sets           DW      ?
    DMA_channel_operation       DW      ?
hardware_info_struct            ENDS

HANDLE_CNT		EQU	64	;max handle count
PAGE_MAX		EQU	128	;max logical page count
BACK_MAX		EQU	5	;max mapping data backup count
I8042			EQU	60H	;i8042 i/o port address
TIME_OUT		EQU	1000	;
NOT_USE			EQU	0AA55H	;not used logical page code
NON			EQU	0FFFFH	;non or bad logical page code
CR			EQU	0DH	;Carriage Return code
LF			EQU	0AH	;Line Feed code
TAB			EQU	09H	;TAB code
; JJP DIS_EMS		EQU	0	;physical page disable data
DIS_EMS			EQU	0FFH	;physical page disable data (lo-tech cards)
HANDLE_NAME_SIZE	EQU	8	;EMM handle name byte size
UNMAP			EQU	0FFFFH	;unmap code
UNALLOC			EQU	0FFFFH	;unallocate code
PUSH_REG		EQU	8 * 2	;push register size
EMMWORK			EQU	50	;EMM driver work area size
RET_SP			EQU	EMMWORK+PUSH_REG+6+10	;int67 stack size
PHYS_PAGES		EQU	4	;physical page count
RAW_PAGES		EQU	400H	;raw page size (16KB)
CONTEXT_SIZE		EQU	SIZE phys_page_struct * PHYS_PAGES
ALTER_REGS		EQU	0	;alter map register set count
DMA_REGS		EQU	0	;alter DMA register set count
DMA_CHANNEL		EQU	0	;DMA channel number
VOLATILE		EQU	0	;volatile
NON_VOLATILE		EQU	1	;non volatile
F23_RETSP		EQU	10	;
LOG_SIZE		EQU	2	;logical page flag data size
FLAG_SIZE		EQU	2	;handle flag size

;
;       function 15 struct
;
f15_struct                      STRUC
                                DW      8 DUP (?)
    f15_map_data                DB      CONTEXT_SIZE DUP (?)
f15_struct                      ENDS

;
;       function 16 struct
;
f16_struct                      STRUC
                                DW      8 DUP (?)
    f16_map_len                 DW      ?
    f16_map_data                DB      CONTEXT_SIZE DUP (?)
f16_struct                      ENDS

;
;       function 17 struct
;
f17_struct                      STRUC
                                DW      8 DUP (?)
    f17_ax_save                 DW      ?
    f17_map_len                 DW      ?
    f17_map_data                DB      PHYS_PAGES * 4 DUP (?)
f17_struct                      ENDS

;
;       function 22 struct
;
f22_struct                      STRUC
                                DW      8 DUP (?)
    f22_ax_save                 DW      ?
    f22_target_off              DW      ?
    f22_target_seg              DW      ?
    f22_map_len                 DW      ?
    f22_map_data                DB      PHYS_PAGES * 4 DUP (?)
f22_struct                      ENDS

;
;       function 23 struct
;
f23_struct                      STRUC
                                DW      8 DUP (?)
    f23_target_off              DW      ?
    f23_target_seg              DW      ?
    f23_flag                    DW      ?
    f23_retoff                  DW      ?
    f23_retseg                  DW      ?
    f23_ax_save                 DW      ?
    f23_new_map_len             DW      ?
    f23_new_map_data            DB      PHYS_PAGES * 4 DUP (?)
    f23_old_map_len             DW      ?
    f23_old_map_data            DB      PHYS_PAGES * 4 DUP (?)
f23_struct                      ENDS

;
;       function 24 struct
;
f24_struct                      STRUC
                                DW      8 DUP (?)
    region_low                  DW      ?
    region_high                 DW      ?
    source_off                  DW      ?
    source_seg                  DW      ?
    source_page                 DW      ?
    source_ea_low               DW      ?
    source_ea_high              DW      ?
    source_handle2              DW      ?
    dest_off                    DW      ?
    dest_seg                    DW      ?
    dest_page                   DW      ?
    dest_ea_low                 DW      ?
    dest_ea_high                DW      ?
    dest_handle2                DW      ?
    f24_al_save                 DB      ?
    direct_move                 DB      ?
    source_type1                db      ?
    dest_type1                  db      ?
    zero_low                    DW      ?
f24_struct                      ENDS

;
;       function 28 struct
;
f28_struct                      STRUC
                                DW      8 DUP (?)
    f28_map_data                DB      CONTEXT_SIZE DUP (?)
f28_struct                      ENDS

;
;       register back area struct
;
retreg          STRUC
    bx_save     DW      ?                       ;BX save area
    cx_save     DW      ?                       ;CX save area
    dx_save     DW      ?                       ;DX save area
    si_save     DW      ?                       ;SI save area
    di_save     DW      ?                       ;DI save area
    bp_save     DW      ?                       ;BP save area
    es_save     DW      ?                       ;ES save area
    ds_save     DW      ?                       ;DS save area
retreg          ENDS

;
;       return address struct
;
ret_struct      STRUC
                DW      8 DUP (?)
                DB      EMMWORK DUP (?)
    ret_offset  DW      ?                       ;return offset address
    ret_segment DW      ?                       ;return segment address
    ret_flag    DW      ?                       ;return flags
ret_struct      ENDS
