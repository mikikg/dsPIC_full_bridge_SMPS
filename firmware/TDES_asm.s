;/*****************************************************************************
; *
; * Tripple Data Encryption Standard (TDES) Encrypt/Decrypt Routines
; *   168 bit key, 64 bit data block
; *   For more information see, AN1044
; *
; *****************************************************************************
; * FileName:		TDES_asm.s
; * Dependencies:	DES_asm.s
; * Processor:		PIC24F, PIC24H, dsPIC30F, or dsPIC33F
; * Compiler:		MPLAB ASM30 2.03 or later
; * Linker:			MPLAB LINK30 2.03 or later
; * Company:		Microchip Technology Incorporated
; *
; * Software License Agreement
; *
; * The software supplied herewith by Microchip Technology Incorporated
; * (the ?Company?) for its PICmicro® Microcontroller is intended and
; * supplied to you, the Company?s customer, for use solely and
; * exclusively on Microchip PICmicro Microcontroller products. The
; * software is owned by the Company and/or its supplier, and is
; * protected under applicable copyright laws. All rights are reserved.
; * Any use in violation of the foregoing restrictions may subject the
; * user to criminal sanctions under applicable laws, as well as to
; * civil liability for the breach of the terms and conditions of this
; * license.
; *
; * Microchip Technology Inc. (?Microchip?) licenses this software to 
; * you solely for use with Microchip products.  The software is owned 
; * by Microchip and is protected under applicable copyright laws.  
; * All rights reserved.
; *
; * You may not export or re-export Software, technical data, direct 
; * products thereof or any other items which would violate any applicable
; * export control laws and regulations including, but not limited to, 
; * those of the United States or United Kingdom.  You agree that it is
; * your responsibility to obtain copies of and to familiarize yourself
; * fully with these laws and regulations to avoid violation.
; *
; * SOFTWARE IS PROVIDED ?AS IS.?  MICROCHIP EXPRESSLY DISCLAIM ANY 
; * WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT 
; * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
; * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL MICROCHIP
; * BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES,
; * LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF PROCUREMENT
; * OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS BY THIRD PARTIES
; * (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF), ANY CLAIMS FOR 
; * INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS. 
; *
; * Author				Date        Comment
; *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; * David Flowers		08/08/2006	Original release
; * Howard Schlunder	05/13/2010	Updated to support PIC24FxxxKAxxx parts and 
; *									devices with EDS memory.
; *****************************************************************************/
.equ VALID_ID,0
    .ifdecl __dsPIC33E
        .include "p33exxxx.inc"
    .endif

    .ifdecl __dsPIC33F
	    .include "p33fxxxx.inc"
    .endif

    .ifdecl __dsPIC30F
	    .include "p30fxxxx.inc"
    .endif

    .ifdecl __PIC24E
        .include "p24exxxx.inc"
    .endif

    .ifdecl __PIC24H
	    .include "p24hxxxx.inc"
    .endif

    .ifdecl __PIC24F
	    .include "p24fxxxx.inc"
    .endif

    .ifdecl __PIC24FK
	    .include "p24fxxxx.inc"
    .endif

.if VALID_ID <> 1
	.error "Processor ID not specified in generic include files.  New ASM30 assembler needs to be downloaded?"
.endif

.ifdecl __HAS_EDS
	.equ	PSVPAG,DSRPAG	
.endif

.global _initTDES
.global _TDES

.bss
_SubkeyPointer: .space 2
W14_save_var: .space 2

.text

_initTDES:
	push PSVPAG
.ifndecl __HAS_EDS
	push CORCON
.endif
; Save the Working registers that you are using by uncommenting the push and pop calls for the register
	push W0
	push W1
	push W2
	push W3
	push W4
	push W5
	push W6
	push W7
	push W8
	push W9
	push W10
	push W11
	push W12
	push W13
	mov W14,W14_save_var
;	push W14
;	push W15

	;save off the called pointer to where the subkeys will reside
	mov WREG,_subKeyBlock
	call _calcSubKeys

	mov _subKeyBlock,WREG
	add #0x80,W0
	mov WREG,_subKeyBlock

	mov _Key+8,WREG
	mov WREG,_Key
	mov _Key+10,WREG
	mov WREG,_Key+2
	mov _Key+12,WREG
	mov WREG,_Key+4
	mov _Key+14,WREG
	mov WREG,_Key+6
	call _calcSubKeys

	mov _subKeyBlock,WREG
	add #0x80,W0
	mov WREG,_subKeyBlock

	mov _Key+16,WREG
	mov WREG,_Key
	mov _Key+18,WREG
	mov WREG,_Key+2
	mov _Key+20,WREG
	mov WREG,_Key+4
	mov _Key+22,WREG
	mov WREG,_Key+6
	call _calcSubKeys

; Save the Working registers that you are using by uncommenting the push and pop calls for the register
;	pop W15
;	pop W14
	mov W14_save_var,W14
	pop W13
	pop W12
	pop W11
	pop W10
	pop W9
	pop W8
	pop W7
	pop W6
	pop W5
	pop W4
	pop W3
	pop W2
	pop W1
	pop W0
.ifndecl __HAS_EDS
	pop CORCON
.endif
	pop PSVPAG
	
	return

_TDES:
	push PSVPAG
.ifndecl __HAS_EDS
	push CORCON
.endif
; Save the Working registers that you are using by uncommenting the push and pop calls for the register
	push W0
	push W1
	push W2
	push W3
	push W4
	push W5
	push W6
	push W7
	push W8
	push W9
	push W10
	push W11
	push W12
	push W13
	push W14
	push W15

	mov WREG,_SubkeyPointer
	; 1 = EDE mode, 0 = DED mode
	btss _mode,#0x0
	add #0x178,W0
	mov WREG,_subKeyBlock
	call _des
	;if it was encrypt then now do a decryption and visa versa
	btg _mode,#0x0
	mov _SubkeyPointer,WREG
	add #0xF8,W0
	btsc _mode,#0x0
	sub #0x78,W0
	mov WREG,_subKeyBlock
	call _des
	;if it was encrypt then now do a decryption and visa versa
	btg _mode,#0x0
	mov _SubkeyPointer,WREG
	add #0x100,W0
	btss _mode,#0x0
	sub #0x88,W0
	mov WREG,_subKeyBlock
	call _des

; Save the Working registers that you are using by uncommenting the push and pop calls for the register
	pop W15
	pop W14
	pop W13
	pop W12
	pop W11
	pop W10
	pop W9
	pop W8
	pop W7
	pop W6
	pop W5
	pop W4
	pop W3
	pop W2
	pop W1
	pop W0
.ifndecl __HAS_EDS
	pop CORCON
.endif
	pop PSVPAG
	return

.end
