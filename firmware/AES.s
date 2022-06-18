;/*****************************************************************************
; *
; * Advanced Encryption Standard (AES) Encrypt/Decrypt Routines
; *   128 bit key, 128 bit data block
; *   For more information see, AN1044
; *
; *****************************************************************************
; * FileName:		AES.s
; * Dependencies:	None
; * Processor:		PIC24F, PIC24H, dsPIC30F, or dsPIC33F
; * Compiler:		MPLAB ASM30 3.23 or later
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
; * Howard Schlunder	07/11/2006	Original release
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

.text
STable:		;S-Box substitution table.  Used by AESEncrypt() and AESDecrypt.
.byte	0x63,0x7C,0x77,0x7B,0xF2,0x6B,0x6F,0xC5,0x30,0x01,0x67,0x2B,0xFE,0xD7,0xAB,0x76
.byte	0xCA,0x82,0xC9,0x7D,0xFA,0x59,0x47,0xF0,0xAD,0xD4,0xA2,0xAF,0x9C,0xA4,0x72,0xC0
.byte	0xB7,0xFD,0x93,0x26,0x36,0x3F,0xF7,0xCC,0x34,0xA5,0xE5,0xF1,0x71,0xD8,0x31,0x15
.byte	0x04,0xC7,0x23,0xC3,0x18,0x96,0x05,0x9A,0x07,0x12,0x80,0xE2,0xEB,0x27,0xB2,0x75
.byte	0x09,0x83,0x2C,0x1A,0x1B,0x6E,0x5A,0xA0,0x52,0x3B,0xD6,0xB3,0x29,0xE3,0x2F,0x84
.byte	0x53,0xD1,0x00,0xED,0x20,0xFC,0xB1,0x5B,0x6A,0xCB,0xBE,0x39,0x4A,0x4C,0x58,0xCF
.byte	0xD0,0xEF,0xAA,0xFB,0x43,0x4D,0x33,0x85,0x45,0xF9,0x02,0x7F,0x50,0x3C,0x9F,0xA8
.byte	0x51,0xA3,0x40,0x8F,0x92,0x9D,0x38,0xF5,0xBC,0xB6,0xDA,0x21,0x10,0xFF,0xF3,0xD2
.byte	0xCD,0x0C,0x13,0xEC,0x5F,0x97,0x44,0x17,0xC4,0xA7,0x7E,0x3D,0x64,0x5D,0x19,0x73
.byte	0x60,0x81,0x4F,0xDC,0x22,0x2A,0x90,0x88,0x46,0xEE,0xB8,0x14,0xDE,0x5E,0x0B,0xDB
.byte	0xE0,0x32,0x3A,0x0A,0x49,0x06,0x24,0x5C,0xC2,0xD3,0xAC,0x62,0x91,0x95,0xE4,0x79
.byte	0xE7,0xC8,0x37,0x6D,0x8D,0xD5,0x4E,0xA9,0x6C,0x56,0xF4,0xEA,0x65,0x7A,0xAE,0x08
.byte	0xBA,0x78,0x25,0x2E,0x1C,0xA6,0xB4,0xC6,0xE8,0xDD,0x74,0x1F,0x4B,0xBD,0x8B,0x8A
.byte	0x70,0x3E,0xB5,0x66,0x48,0x03,0xF6,0x0E,0x61,0x35,0x57,0xB9,0x86,0xC1,0x1D,0x9E
.byte	0xE1,0xF8,0x98,0x11,0x69,0xD9,0x8E,0x94,0x9B,0x1E,0x87,0xE9,0xCE,0x55,0x28,0xDF
.byte	0x8C,0xA1,0x89,0x0D,0xBF,0xE6,0x42,0x68,0x41,0x99,0x2D,0x0F,0xB0,0x54,0xBB,0x16

SiTable:	;Inverse S-Box substitution table. Used by AESDecrypt() only.
.byte	0x52,0x09,0x6A,0xD5,0x30,0x36,0xA5,0x38,0xBF,0x40,0xA3,0x9E,0x81,0xF3,0xD7,0xFB
.byte	0x7C,0xE3,0x39,0x82,0x9B,0x2F,0xFF,0x87,0x34,0x8E,0x43,0x44,0xC4,0xDE,0xE9,0xCB
.byte	0x54,0x7B,0x94,0x32,0xA6,0xC2,0x23,0x3D,0xEE,0x4C,0x95,0x0B,0x42,0xFA,0xC3,0x4E
.byte	0x08,0x2E,0xA1,0x66,0x28,0xD9,0x24,0xB2,0x76,0x5B,0xA2,0x49,0x6D,0x8B,0xD1,0x25
.byte	0x72,0xF8,0xF6,0x64,0x86,0x68,0x98,0x16,0xD4,0xA4,0x5C,0xCC,0x5D,0x65,0xB6,0x92
.byte	0x6C,0x70,0x48,0x50,0xFD,0xED,0xB9,0xDA,0x5E,0x15,0x46,0x57,0xA7,0x8D,0x9D,0x84
.byte	0x90,0xD8,0xAB,0x00,0x8C,0xBC,0xD3,0x0A,0xF7,0xE4,0x58,0x05,0xB8,0xB3,0x45,0x06
.byte	0xD0,0x2C,0x1E,0x8F,0xCA,0x3F,0x0F,0x02,0xC1,0xAF,0xBD,0x03,0x01,0x13,0x8A,0x6B
.byte	0x3A,0x91,0x11,0x41,0x4F,0x67,0xDC,0xEA,0x97,0xF2,0xCF,0xCE,0xF0,0xB4,0xE6,0x73
.byte	0x96,0xAC,0x74,0x22,0xE7,0xAD,0x35,0x85,0xE2,0xF9,0x37,0xE8,0x1C,0x75,0xDF,0x6E
.byte	0x47,0xF1,0x1A,0x71,0x1D,0x29,0xC5,0x89,0x6F,0xB7,0x62,0x0E,0xAA,0x18,0xBE,0x1B
.byte	0xFC,0x56,0x3E,0x4B,0xC6,0xD2,0x79,0x20,0x9A,0xDB,0xC0,0xFE,0x78,0xCD,0x5A,0xF4
.byte	0x1F,0xDD,0xA8,0x33,0x88,0x07,0xC7,0x31,0xB1,0x12,0x10,0x59,0x27,0x80,0xEC,0x5F
.byte	0x60,0x51,0x7F,0xA9,0x19,0xB5,0x4A,0x0D,0x2D,0xE5,0x7A,0x9F,0x93,0xC9,0x9C,0xEF
.byte	0xA0,0xE0,0x3B,0x4D,0xAE,0x2A,0xF5,0xB0,0xC8,0xEB,0xBB,0x3C,0x83,0x53,0x99,0x61
.byte	0x17,0x2B,0x04,0x7E,0xBA,0x77,0xD6,0x26,0xE1,0x69,0x14,0x63,0x55,0x21,0x0C,0x7D


.text
;***************************************************************************
; Function: void AESEncrypt(int *DataBlock, int *EncryptKey)
;
; Input: *DataBlock: Pointer to 16 bytes to encrypt.  Must point to an even 
;					 address.
;		 *EncryptKey: Pointer to 16 byte encryption key.  Must point to an 
;					  even address.
;
; Output: *DataBlock 16 byte array filled with encrypted contents
;
; Side Effects: Contents of W0:W7 are destroyed
;
; Memory Requirements: 36 bytes + 4 byte return address on stack.  2 less for
;			devices with EDS support.
;
; Performance: 2808 instruction cycles, including call and return. 3 less for 
;			devices with EDS support.
;
; Overview: Sixteen data bytes @ W0 are encrypted using 16 byte key @ W1.  
;			The data bytes are updated in place while the key is unmodified.
;***************************************************************************
	.global _AESEncrypt
_AESEncrypt:
.ifndecl	__HAS_EDS
	push	CORCONL
.endif
	push	PSVPAG
	push.d	W8
	push.d	W10
	push.d	W12

	;Store the encryption key on the stack
	mov		W15, W2
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]

	;Note: Commenting the mov instruction and uncommenting the sub 
	;      instruction will cause the *EncryptKey input to be translated to 
	;	   the final decryption key when the function returns.  This 
    ;	   might be useful in some applications.
	mov		W2, W1
;	sub		#16, W1

	;roundCounter = 10, rcon = 1
	mov		#10, W2	; roundCounter
	mov		#1, W3	; rcon
	push.d	W2

	;Enable Program Space Visibility of S-table
.ifndecl	__HAS_EDS
	bset.b	CORCONL, #PSV
.endif
	mov		#psvpage(STable), W2
	mov		W2, PSVPAG

	;Key addition
	;Key addition already takes place at EncodeKeyAddition.  However, there is a 6 
	;instruction cycle performance penalty total if you jump to EncodeKeyAddition instead 
	;of wasting 33 bytes of program memory repeating it.
;	bra		EncodeKeyAddition
	mov.d	[W0], W2
	xor		W2, [W1++], [W0++]
	xor		W3, [W1++], [W0++]
	mov.d	[W0], W2
	xor		W2, [W1++], [W0++]
	xor		W3, [W1++], [W0++]
	mov.d	[W0], W2
	xor		W2, [W1++], [W0++]
	xor		W3, [W1++], [W0++]
	mov.d	[W0], W2
	xor		W2, [W1++], [W0++]
	xor		W3, [W1++], [W0++]

	; Reset block and key pointers to beginning
	sub		#16, W0
	sub		#16, W1

	;
	;Enter roundCounter Loop
	;
EncodeRoundLoop:
	;Do S-table subsitution
	mov		#psvoffset(STable), W2
	clr		W3
	
	mov.b	[W0], W3			;Byte 0
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 1
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 2
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 3
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 4
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 5
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 6
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 7
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 8
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 9
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 10
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 11
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 12
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 13
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 14
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 15
	mov.b	[W3+W2], [W0++]
		

	;Encode row shift
	;Given this byte order:     0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
	;This byte order is needed: 0  5  10 15 4  9  14 3  8  13 2  7  12 1  6  11

	mov.b	[W0+1-16], W9
	mov.b	[W0+2-16], W5
	mov.b	[W0+3-16], W2
	mov.b	[W0+5-16], W3
	mov.b	[W0+6-16], W4
	mov.b	[W0+7-16], W13
	mov.b	[W0+9-16], W6
	mov.b	[W0+10-16], W7
	mov.b	[W0+11-16], W8
	mov.b	[W0+13-16], W12
	mov.b	[W0+14-16], W10
	mov.b	[W0+15-16], W11

	mov.b	W8, [W0+15-16]
	mov.b	W4, [W0+14-16]
	mov.b	W9, [W0+13-16]
	mov.b	W13, [W0+11-16]
	mov.b	W5, [W0+10-16]
	mov.b	W12, [W0+9-16]
	mov.b	W2, [W0+7-16]
	mov.b	W10, [W0+6-16]
	mov.b	W6, [W0+5-16]
	mov.b	W11, [W0+3-16]
	mov.b	W7, [W0+2-16]
	mov.b	W3, [W0+1-16]

	;Check to see if we are on the last round.  The last round does not need
	;to have the columns mixed
	;Note: We decrement roundCounter here and test for Zero instead of 1. 
	mov		W15, W7
	sub		#4, W7
	dec		[W7], [W7]
	bra		Z, EncKeySchedule

	;Restore the block pointer to the beginning
	sub		#16, W0

	;Prepare for future Xtime() operations
	mov		#0x001B, W5		

	;Mix columns
	;Address of block is in W0, let's use it
	;for(i=0;i<16;i+=4)
	;i=0
	mov.b	[W0++], W2		;aux1 = block[i+0]^block[i+1];
	xor.b	W2, [W0], W11
	mov.b	[W0++], W3		;aux2 = block[i+1]^block[i+2];
	xor.b	W3, [W0], W12
	mov.b	[W0++], W4		;aux3 = block[i+2]^block[i+3];
	xor.b	W4, [W0--], W13
	xor.b	W11, W13, W10	;aux  = aux1^aux3;
	sl		W11, W11		;aux1 = xtime(aux1);
	btsc	W11, #8			
	xor.b	W11, W5, W11
	sl		W12, W12		;aux2 = xtime(aux2);
	btsc	W12, #8			
	xor.b	W12, W5, W12
	sl		W13, W13		;aux3 = xtime(aux3);
	btsc	W13, #8			
	xor.b	W13, W5, W13
	xor.b	W4, W10, [W0]	;block[i+2]= aux^aux3^block[i+2];
	xor.b	W13, [W0], [W0--]
	xor.b	W3, W10, [W0]	;block[i+1]= aux^aux2^block[i+1];
	xor.b	W12, [W0], [W0--]
	xor.b	W2, W10, [W0]	;block[i+0]= aux^aux1^block[i+0];
	xor.b	W11, [W0], [W0]
	xor.b	W10, [W0++], W4	;block[i+3]= block[i+0]^block[i+1]^block[i+2]^aux;
	xor.b	W4, [W0++], W4
	xor.b	W4, [W0++], [W0++]

	;i=4
	mov.b	[W0++], W2		;aux1 = block[i+0]^block[i+1];
	xor.b	W2, [W0], W11
	mov.b	[W0++], W3		;aux2 = block[i+1]^block[i+2];
	xor.b	W3, [W0], W12
	mov.b	[W0++], W4		;aux3 = block[i+2]^block[i+3];
	xor.b	W4, [W0--], W13
	xor.b	W11, W13, W10	;aux  = aux1^aux3;
	sl		W11, W11		;aux1 = xtime(aux1);
	btsc	W11, #8			
	xor.b	W11, W5, W11
	sl		W12, W12		;aux2 = xtime(aux2);
	btsc	W12, #8			
	xor.b	W12, W5, W12
	sl		W13, W13		;aux3 = xtime(aux3);
	btsc	W13, #8			
	xor.b	W13, W5, W13
	xor.b	W4, W10, [W0]	;block[i+2]= aux^aux3^block[i+2];
	xor.b	W13, [W0], [W0--]
	xor.b	W3, W10, [W0]	;block[i+1]= aux^aux2^block[i+1];
	xor.b	W12, [W0], [W0--]
	xor.b	W2, W10, [W0]	;block[i+0]= aux^aux1^block[i+0];
	xor.b	W11, [W0], [W0]
	xor.b	W10, [W0++], W4	;block[i+3]= block[i+0]^block[i+1]^block[i+2]^aux;
	xor.b	W4, [W0++], W4
	xor.b	W4, [W0++], [W0++]

	;i=8
	mov.b	[W0++], W2		;aux1 = block[i+0]^block[i+1];
	xor.b	W2, [W0], W11
	mov.b	[W0++], W3		;aux2 = block[i+1]^block[i+2];
	xor.b	W3, [W0], W12
	mov.b	[W0++], W4		;aux3 = block[i+2]^block[i+3];
	xor.b	W4, [W0--], W13
	xor.b	W11, W13, W10	;aux  = aux1^aux3;
	sl		W11, W11		;aux1 = xtime(aux1);
	btsc	W11, #8			
	xor.b	W11, W5, W11
	sl		W12, W12		;aux2 = xtime(aux2);
	btsc	W12, #8			
	xor.b	W12, W5, W12
	sl		W13, W13		;aux3 = xtime(aux3);
	btsc	W13, #8			
	xor.b	W13, W5, W13
	xor.b	W4, W10, [W0]	;block[i+2]= aux^aux3^block[i+2];
	xor.b	W13, [W0], [W0--]
	xor.b	W3, W10, [W0]	;block[i+1]= aux^aux2^block[i+1];
	xor.b	W12, [W0], [W0--]
	xor.b	W2, W10, [W0]	;block[i+0]= aux^aux1^block[i+0];
	xor.b	W11, [W0], [W0]
	xor.b	W10, [W0++], W4	;block[i+3]= block[i+0]^block[i+1]^block[i+2]^aux;
	xor.b	W4, [W0++], W4
	xor.b	W4, [W0++], [W0++]

	;i=12
	mov.b	[W0++], W2		;aux1 = block[i+0]^block[i+1];
	xor.b	W2, [W0], W11
	mov.b	[W0++], W3		;aux2 = block[i+1]^block[i+2];
	xor.b	W3, [W0], W12
	mov.b	[W0++], W4		;aux3 = block[i+2]^block[i+3];
	xor.b	W4, [W0--], W13
	xor.b	W11, W13, W10	;aux  = aux1^aux3;
	sl		W11, W11		;aux1 = xtime(aux1);
	btsc	W11, #8			
	xor.b	W11, W5, W11
	sl		W12, W12		;aux2 = xtime(aux2);
	btsc	W12, #8			
	xor.b	W12, W5, W12
	sl		W13, W13		;aux3 = xtime(aux3);
	btsc	W13, #8			
	xor.b	W13, W5, W13
	xor.b	W4, W10, [W0]	;block[i+2]= aux^aux3^block[i+2];
	xor.b	W13, [W0], [W0--]
	xor.b	W3, W10, [W0]	;block[i+1]= aux^aux2^block[i+1];
	xor.b	W12, [W0], [W0--]
	xor.b	W2, W10, [W0]	;block[i+0]= aux^aux1^block[i+0];
	xor.b	W11, [W0], [W0]
	xor.b	W10, [W0++], W4	;block[i+3]= block[i+0]^block[i+1]^block[i+2]^aux;
	xor.b	W4, [W0++], W4
	xor.b	W4, [W0++], [W0++]

	;i is 16

EncKeySchedule:
	;Encode key schedule
	mov		#psvoffset(STable), W10
	clr		W12
	dec2	W15, W6				;[W6] is rcon

	;Column 1
	mov.b	[W1+13], W12		;key[0]^=STable[key[13]];
	mov.b	[W10+W12], W12
	xor.b	W12, [W6], W12		;key[0]^=rcon;
	xor.b	W12, [W1], [W1++]
	mov.b	[W1+13], W12		;key[1]^=STable[key[14]];
	mov.b	[W10+W12], W12
	xor.b	W12, [W1], [W1++]
	mov.b	[W1+13], W12		;key[2]^=STable[key[15]];
	mov.b	[W10+W12], W12
	xor.b	W12, [W1], [W1++]
	mov.b	[W1+13-4], W12		;key[3]^=STable[key[12]];
	mov.b	[W10+W12], W12
	xor.b	W12, [W1], [W1++]

	sl		[W6], [W6]			;rcon = xtime(rcon);
	mov		#0x011B, W5			;   constant 0x011B is used instead of 0x1B because it 
	btsc	[W6], #8			;   conveniently causes the high byte to be 0x00
	xor		W5, [W6], [W6]

	;Column 2
	mov		[W1-4], W2			;key[4]^=key[0]; key[5]^=key[1];
	xor		W2, [W1], [W1++]
	mov		[W1-4], W2			;key[6]^=key[2]; key[7]^=key[3];
	xor		W2, [W1], [W1++]

	;Column 3
	mov		[W1-4], W2			;key[8]^=key[4]; key[9]^=key[5];
	xor		W2, [W1], [W1++]
	mov		[W1-4], W2			;key[10]^=key[6]; key[11]^=key[7];
	xor		W2, [W1], [W1++]

	;Column 4
	mov		[W1-4], W2			;key[12]^=key[8]; key[13]^=key[9];
	xor		W2, [W1], [W1++]
	mov		[W1-4], W2			;key[14]^=key[10]; key[15]^=key[11];
	xor		W2, [W1], [W1++]


	;Add key to block
EncodeKeyAddition:
	mov.d	[--W1], W2
	xor		W3, [--W0], [W0]
	xor		W2, [--W0], [W0]
	mov.d	[--W1], W2
	xor		W3, [--W0], [W0]
	xor		W2, [--W0], [W0]
	mov.d	[--W1], W2
	xor		W3, [--W0], [W0]
	xor		W2, [--W0], [W0]
	mov.d	[--W1], W2
	xor		W3, [--W0], [W0]
	xor		W2, [--W0], [W0]


	;Process roundCounter loop
	;Note: roundCounter has already been decremented
;	mov		roundCounter
	mov		[W7], W2
	add		#0, W2
	bra		NZ, EncodeRoundLoop

	;Pop the roundCounter, rcon, and decryption key off the stack
	sub		#20, W15
	
	pop.d	W12
	pop.d	W10
	pop.d	W8
	pop		PSVPAG
.ifndecl	__HAS_EDS
	pop		CORCONL
.endif
	return




;***************************************************************************
; Function: void AESDecrypt(int *DataBlock, int *DecryptKey)
;
; Input: *DataBlock: Pointer to 16 bytes to decrypt.  Must point to an even 
;					 address.
;		 *DecryptKey: Pointer to 16 byte decryption key.  Must point to an 
;					  even address.
;
; Output: *DataBlock: 16 byte array filled with decrypted contents
;
; Side Effects: Contents of W0:W7 are destroyed
;
; Memory Requirements: 36 bytes + 4 byte return address on stack.  2 less 
;			for devices with EDS support.
;
; Performance: 4490 instruction cycles, including call and return.  3 less 
;			for devices with EDS support.
;
; Overview: Sixteen data bytes @ W0 are decrypted using 16 byte key @ W1.  
;			The data bytes are updated in place while the key is unmodified.
;***************************************************************************
	.global _AESDecrypt
_AESDecrypt:
.ifndecl	__HAS_EDS
	push	CORCONL
.endif
	push	PSVPAG
	push.d	W8
	push.d	W10
	push.d	W12

	;Store the decryption key on the stack
	mov		W15, W2
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]
	push	[W1++]

	;Note: Commenting the mov instruction and uncommenting the sub 
	;      instruction will cause the *DecryptKey input to be translated to 
	;	   the original encryption key when the function returns.  This 
    ;	   might be useful in some applications.
	mov		W2, W1
;	sub		#16, W1

	;roundCounter = 10, rcon = 0x36
	mov		#10, W2	; roundCounter
	push	W2
	mov		#0x36, W13	; W13 = rcon = 0x36

	;Enable Program Space Visibility of S-table
.ifndecl	__HAS_EDS
	bset.b	CORCONL, #PSV
.endif
	mov		#psvpage(STable), W2
	mov		W2, PSVPAG


	;Key addition
	;Key addition already takes place at DecodeKeyAddition.  However, there is a 6 
	;instruction cycle performance penalty total if you jump to DecodeKeyAddition instead 
	;of wasting 33 bytes of program memory repeating it.
;	bra		DecodeKeyAddition
	mov.d	[W0], W2
	xor		W2, [W1++], [W0++]
	xor		W3, [W1++], [W0++]
	mov.d	[W0], W2
	xor		W2, [W1++], [W0++]
	xor		W3, [W1++], [W0++]
	mov.d	[W0], W2
	xor		W2, [W1++], [W0++]
	xor		W3, [W1++], [W0++]
	mov.d	[W0], W2
	xor		W2, [W1++], [W0++]
	xor		W3, [W1++], [W0++]

	; Reset block and key pointers to beginning
	sub		#16, W0
	sub		#16, W1

	;The first looop iteration does not do inverse column mixing, so let's jump into the 
	;middle of the loop
	bra		DecodeSSubstitute

	;
	;Enter roundCounter Loop
	;
DecodeRoundLoop:
	;
	;Inverse mix column
	;
	clr		W4
	mov		#0x011B, W6		;Set up W6 for doing future Xtime() operations.  Constant 0x011B 
							;is used instead of 0x1B because it conveniently causes the high 
							;byte to be 0x00


	;for(i=0;i<16;i+=4)
	;i=0
	mov.b	[W0++], W4		;W4=block[i+0x00]
	mov.b	W4, W5			;temp0=block[i+0x00]
	mov.b	W4, W3			;temp3=block[i+0x00]
	sl		W4, W4			;W4=x1[block[i+0x00]]
	btsc	W4, #8			
	xor		W4, W6, W4
	mov		W4, W7			;W7=x1[block[i+0x00]]
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x1[block[i+0x00]]
	sl		W4, W2			;temp2=x2[block[i+0x00]]
	btsc	W2, #8			
	xor		W2, W6, W2
	xor.b	W5, W2, W5		;temp0=block[i+0x00]^x1[block[i+0x00]]^x2[block[i+0x00]]
	sl		W2, W4			;W4=x3[block[i+0x00]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]

	mov.b	[W0++], W4		;W4=block[i+0x01]
	mov.b	W4, W8			;temp1=block[i+0x01]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]
	sl		W4, W4			;W4=x1[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]
	sl		W4, W4			;W4=x2[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]
	sl		W4, W4			;W4=x3[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]

	mov.b	[W0++], W4		;W4=block[i+0x02]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]
	sl		W4, W4			;W4=x1[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]
	sl		W4, W4			;W4=x2[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]^x2[block[i+0x02]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]^x2[block[i+0x02]]
	sl		W4, W4			;W4=x3[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]

	mov.b	[W0++], W4		;W4=block[i+0x03]
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]
	sl		W4, W4			;W4=x1[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]^x1[block[i+0x03]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]^x2[block[i+0x02]]^x1[block[i+0x03]]
	sl		W4, W4			;W4=x2[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]^x2[block[i+0x03]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]^x2[block[i+0x03]]
	sl		W4, W4			;W4=x3[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]^x3[block[i+0x03]]

	xor.b	W5, W3, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]^x2[block[i+0x02]]^temp3
	xor.b	W8, W3, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]^x2[block[i+0x03]]^temp3
	xor.b	W2, W3, W2		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]^x3[block[i+0x03]]^temp3

	xor.b	W3, W7, W3		;temp3=temp3^x2[block[i+0x03]]^x1[block[i+0x03]]^x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]

	mov.b	W5, [W0-4]		;block[i+0]=temp0;
	mov.b	W8, [W0-3]		;block[i+1]=temp1;
	mov.b	W2, [W0-2]		;block[i+2]=temp2;
	mov.b	W3, [W0-1]		;block[i+3]=temp3;


	;i=4
	mov.b	[W0++], W4		;W4=block[i+0x00]
	mov.b	W4, W5			;temp0=block[i+0x00]
	mov.b	W4, W3			;temp3=block[i+0x00]
	sl		W4, W4			;W4=x1[block[i+0x00]]
	btsc	W4, #8			
	xor		W4, W6, W4
	mov		W4, W7			;W7=x1[block[i+0x00]]
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x1[block[i+0x00]]
	sl		W4, W2			;temp2=x2[block[i+0x00]]
	btsc	W2, #8			
	xor		W2, W6, W2
	xor.b	W5, W2, W5		;temp0=block[i+0x00]^x1[block[i+0x00]]^x2[block[i+0x00]]
	sl		W2, W4			;W4=x3[block[i+0x00]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]

	mov.b	[W0++], W4		;W4=block[i+0x01]
	mov.b	W4, W8			;temp1=block[i+0x01]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]
	sl		W4, W4			;W4=x1[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]
	sl		W4, W4			;W4=x2[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]
	sl		W4, W4			;W4=x3[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]

	mov.b	[W0++], W4		;W4=block[i+0x02]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]
	sl		W4, W4			;W4=x1[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]
	sl		W4, W4			;W4=x2[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]^x2[block[i+0x02]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]^x2[block[i+0x02]]
	sl		W4, W4			;W4=x3[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]

	mov.b	[W0++], W4		;W4=block[i+0x03]
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]
	sl		W4, W4			;W4=x1[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]^x1[block[i+0x03]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]^x2[block[i+0x02]]^x1[block[i+0x03]]
	sl		W4, W4			;W4=x2[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]^x2[block[i+0x03]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]^x2[block[i+0x03]]
	sl		W4, W4			;W4=x3[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]^x3[block[i+0x03]]

	xor.b	W5, W3, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]^x2[block[i+0x02]]^temp3
	xor.b	W8, W3, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]^x2[block[i+0x03]]^temp3
	xor.b	W2, W3, W2		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]^x3[block[i+0x03]]^temp3

	xor.b	W3, W7, W3		;temp3=temp3^x2[block[i+0x03]]^x1[block[i+0x03]]^x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]

	mov.b	W5, [W0-4]		;block[i+0]=temp0;
	mov.b	W8, [W0-3]		;block[i+1]=temp1;
	mov.b	W2, [W0-2]		;block[i+2]=temp2;
	mov.b	W3, [W0-1]		;block[i+3]=temp3;
	
	
	;i=8
	mov.b	[W0++], W4		;W4=block[i+0x00]
	mov.b	W4, W5			;temp0=block[i+0x00]
	mov.b	W4, W3			;temp3=block[i+0x00]
	sl		W4, W4			;W4=x1[block[i+0x00]]
	btsc	W4, #8			
	xor		W4, W6, W4
	mov		W4, W7			;W7=x1[block[i+0x00]]
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x1[block[i+0x00]]
	sl		W4, W2			;temp2=x2[block[i+0x00]]
	btsc	W2, #8			
	xor		W2, W6, W2
	xor.b	W5, W2, W5		;temp0=block[i+0x00]^x1[block[i+0x00]]^x2[block[i+0x00]]
	sl		W2, W4			;W4=x3[block[i+0x00]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]

	mov.b	[W0++], W4		;W4=block[i+0x01]
	mov.b	W4, W8			;temp1=block[i+0x01]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]
	sl		W4, W4			;W4=x1[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]
	sl		W4, W4			;W4=x2[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]
	sl		W4, W4			;W4=x3[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]

	mov.b	[W0++], W4		;W4=block[i+0x02]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]
	sl		W4, W4			;W4=x1[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]
	sl		W4, W4			;W4=x2[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]^x2[block[i+0x02]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]^x2[block[i+0x02]]
	sl		W4, W4			;W4=x3[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]

	mov.b	[W0++], W4		;W4=block[i+0x03]
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]
	sl		W4, W4			;W4=x1[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]^x1[block[i+0x03]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]^x2[block[i+0x02]]^x1[block[i+0x03]]
	sl		W4, W4			;W4=x2[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]^x2[block[i+0x03]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]^x2[block[i+0x03]]
	sl		W4, W4			;W4=x3[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]^x3[block[i+0x03]]

	xor.b	W5, W3, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]^x2[block[i+0x02]]^temp3
	xor.b	W8, W3, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]^x2[block[i+0x03]]^temp3
	xor.b	W2, W3, W2		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]^x3[block[i+0x03]]^temp3

	xor.b	W3, W7, W3		;temp3=temp3^x2[block[i+0x03]]^x1[block[i+0x03]]^x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]

	mov.b	W5, [W0-4]		;block[i+0]=temp0;
	mov.b	W8, [W0-3]		;block[i+1]=temp1;
	mov.b	W2, [W0-2]		;block[i+2]=temp2;
	mov.b	W3, [W0-1]		;block[i+3]=temp3;


	;i=12
	mov.b	[W0++], W4		;W4=block[i+0x00]
	mov.b	W4, W5			;temp0=block[i+0x00]
	mov.b	W4, W3			;temp3=block[i+0x00]
	sl		W4, W4			;W4=x1[block[i+0x00]]
	btsc	W4, #8			
	xor		W4, W6, W4
	mov		W4, W7			;W7=x1[block[i+0x00]]
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x1[block[i+0x00]]
	sl		W4, W2			;temp2=x2[block[i+0x00]]
	btsc	W2, #8			
	xor		W2, W6, W2
	xor.b	W5, W2, W5		;temp0=block[i+0x00]^x1[block[i+0x00]]^x2[block[i+0x00]]
	sl		W2, W4			;W4=x3[block[i+0x00]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]

	mov.b	[W0++], W4		;W4=block[i+0x01]
	mov.b	W4, W8			;temp1=block[i+0x01]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]
	sl		W4, W4			;W4=x1[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]
	sl		W4, W4			;W4=x2[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]
	sl		W4, W4			;W4=x3[block[i+0x01]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]

	mov.b	[W0++], W4		;W4=block[i+0x02]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]
	sl		W4, W4			;W4=x1[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]
	sl		W4, W4			;W4=x2[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W5, W4, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]^x2[block[i+0x02]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]^x2[block[i+0x02]]
	sl		W4, W4			;W4=x3[block[i+0x02]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]

	mov.b	[W0++], W4		;W4=block[i+0x03]
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]
	sl		W4, W4			;W4=x1[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]^x1[block[i+0x03]]
	xor.b	W2, W4, W2		;temp2=x2[block[i+0x00]]^block[i+0x02]^x1[block[i+0x02]]^x2[block[i+0x02]]^x1[block[i+0x03]]
	sl		W4, W4			;W4=x2[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W7, W4, W7		;W7=x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]^x2[block[i+0x03]]
	xor.b	W8, W4, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]^x2[block[i+0x03]]
	sl		W4, W4			;W4=x3[block[i+0x03]]
	btsc	W4, #8			
	xor		W4, W6, W4
	xor.b	W3, W4, W3		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]^x3[block[i+0x03]]

	xor.b	W5, W3, W5		;temp0=block[i+0x00]^x2[block[i+0x00]]^x1[block[i+0x00]]^x1[block[i+0x01]]^x2[block[i+0x02]]^temp3
	xor.b	W8, W3, W8		;temp1=block[i+0x01]^x1[block[i+0x01]]^x2[block[i+0x01]]^x1[block[i+0x02]]^x2[block[i+0x03]]^temp3
	xor.b	W2, W3, W2		;temp3=block[i+0x00]^x3[block[i+0x00]]^block[i+0x01]^x3[block[i+0x01]]^block[i+0x02]^x3[block[i+0x02]]^block[i+0x03]^x3[block[i+0x03]]^temp3

	xor.b	W3, W7, W3		;temp3=temp3^x2[block[i+0x03]]^x1[block[i+0x03]]^x1[block[i+0x00]]^x2[block[i+0x01]]^block[i+0x03]

	mov.b	W5, [W0-4]		;block[i+0]=temp0;
	mov.b	W8, [W0-3]		;block[i+1]=temp1;
	mov.b	W2, [W0-2]		;block[i+2]=temp2;
	mov.b	W3, [W0-1]		;block[i+3]=temp3;

	;i is 16
	;Restore W0 to beginning of data block
	sub		#16, W0

DecodeSSubstitute:
	;
	;Inverse S-table subsitution (uses Si-table)
	;
	mov		#psvoffset(SiTable), W2
	clr		W3

	mov.b	[W0], W3			;Byte 0
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 1
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 2
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 3
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 4
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 5
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 6
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 7
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 8
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 9
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 10
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 11
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 12
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 13
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 14
	mov.b	[W3+W2], [W0++]
	mov.b	[W0], W3			;Byte 15
	mov.b	[W3+W2], [W0++]


	;Data block pointer is forward 16

	;
	;Decode shift row
	;
	;Given this byte order:     0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
	;This byte order is needed: 0  13 10 7  4  1  14 11 8  5  2  15 12 9  6  3
	push	W1
	mov.b	[W0+1-16], W9
	mov.b	[W0+2-16], W1
	mov.b	[W0+3-16], W2
	mov.b	[W0+5-16], W3
	mov.b	[W0+6-16], W4
	mov.b	[W0+7-16], W5
	mov.b	[W0+9-16], W6
	mov.b	[W0+10-16], W7
	mov.b	[W0+11-16], W8
	mov.b	[W0+13-16], W12
	mov.b	[W0+14-16], W10
	mov.b	[W0+15-16], W11

	mov.b	W2, [W0+15-16]
	mov.b	W4, [W0+14-16]
	mov.b	W6, [W0+13-16]
	mov.b	W11, [W0+11-16]
	mov.b	W1, [W0+10-16]
	mov.b	W3, [W0+9-16]
	mov.b	W8, [W0+7-16]
	mov.b	W10, [W0+6-16]
	mov.b	W9, [W0+5-16]
	mov.b	W5, [W0+3-16]
	mov.b	W7, [W0+2-16]
	mov.b	W12, [W0+1-16]
	pop		W1


	;
	;Decode key schedule
	;
	;Move key pointer to the end
	add		#16, W1

	;Column 4
	mov		[W1-6], W2			;key[14]^=key[10]; key[15]^=key[11];
	xor		W2, [--W1], [W1]
	mov		[W1-6], W2			;key[12]^=key[8]; key[13]^=key[9];
	xor		W2, [--W1], [W1]

	;Column 3
	mov		[W1-6], W2			;key[10]^=key[6]; key[11]^=key[7];
	xor		W2, [--W1], [W1]
	mov		[W1-6], W2			;key[8]^=key[4]; key[9]^=key[5];
	xor		W2, [--W1], [W1]

	;Column 2
	mov		[W1-6], W2			;key[6]^=key[2]; key[7]^=key[3];
	xor		W2, [--W1], [W1]
	mov		[W1-6], W2			;key[4]^=key[0]; key[5]^=key[1];
	xor		W2, [--W1], [W1]

	;Column 1
	mov		#psvoffset(STable), W6
	clr		W2

	mov.b	[W1+12-4], W2		;key[3]^=STable[key[12]];
	mov.b	[W6+W2], W2
	xor.b	W2, [--W1], [W1]
	mov.b	[W1+15-3], W2		;key[2]^=STable[key[15]];
	mov.b	[W6+W2], W2
	xor.b	W2, [--W1], [W1]
	mov.b	[W1+14-2], W2		;key[1]^=STable[key[14]];
	mov.b	[W6+W2], W2
	xor.b	W2, [--W1], [W1]
	mov.b	[W1+13-1], W2		;key[0]^=STable[key[13]];
	mov.b	[W6+W2], W2
	xor.b	W2, [--W1], [W1]

	xor.b	W13, [W1], [W1]		;key[0]^=_rcon;
	
	rrnc	W13, W13			;if(_rcon &0x01)
	btsc	W13, #15			;	_rcon = 0x80;
	mov		#0x0080, W13		;else
								;	_rcon >>= 1;

	;Move key pointer to the end again
	add		#16, W1

	;
	;Add key
	;
DecodeKeyAddition:
	mov.d	[--W1], W2
	xor		W3, [--W0], [W0]
	xor		W2, [--W0], [W0]
	mov.d	[--W1], W2
	xor		W3, [--W0], [W0]
	xor		W2, [--W0], [W0]
	mov.d	[--W1], W2
	xor		W3, [--W0], [W0]
	xor		W2, [--W0], [W0]
	mov.d	[--W1], W2
	xor		W3, [--W0], [W0]
	xor		W2, [--W0], [W0]

	;Process roundCounter loop
	dec2	W15, W2
	dec		[W2], [W2]	;roundCounter
	bra		NZ, DecodeRoundLoop

	;Pop roundCounter, and encryption key off the stack
	sub		#18, W15

	pop.d	W12
	pop.d	W10
	pop.d	W8
	pop		PSVPAG
.ifndecl	__HAS_EDS
	pop		CORCONL
.endif
	return



;***************************************************************************
; Function: void AESCalcDecKey(char *Key)
;
; Input: *Key: Pointer to 16 byte encryption key.  Must point to an even 
;			   address.
;
; Output: *Key: 16 byte array at Key is updated with the decryption key.
;
; Side Effects: Contents of W0:W7 are destroyed
;
; Memory Requirements: 2 bytes + 4 byte return address on stack.  2 less for 
;			devices with EDS support.
;
; Performance: 497 instruction cycles, including call and return.  3 less 
;			for devices with EDS support.
;
; Overview: Encrpytion key *Key is translated into a decryption key, in 
;			place.
;***************************************************************************
	.global	_AESCalcDecKey
_AESCalcDecKey:
.ifndecl	__HAS_EDS
	push	CORCONL
.endif
	mov		PSVPAG, W3

	;Enable Program Space Visibility of S-table
.ifndecl	__HAS_EDS
	bset.b	CORCONL, #PSV
.endif
	mov		#psvpage(STable), W7
	mov		W7, PSVPAG
	mov		#psvoffset(STable), W7

	;Initialize variables
	mov		#10, W6		; roundCounter
	mov		#1, W5		; rcon
	mov		#0x011B, W4	; xor constant for xtime operations
	clr		W1			; PSV window offset

CalcDecKeyLoop:
	;Column 1
	mov.b	[W0+13], W1			;key[0]^=STable[key[13]];
	mov.b	[W7+W1], W1
	xor.b	W1, W5, W1			;key[0]^=rcon;
	xor.b	W1, [W0], [W0++]
	mov.b	[W0+13], W1			;key[1]^=STable[key[14]];
	mov.b	[W7+W1], W1
	xor.b	W1, [W0], [W0++]
	mov.b	[W0+13], W1			;key[2]^=STable[key[15]];
	mov.b	[W7+W1], W1
	xor.b	W1, [W0], [W0++]
	mov.b	[W0+13-4], W1		;key[3]^=STable[key[12]];
	mov.b	[W7+W1], W1
	xor.b	W1, [W0], [W0++]

	sl		W5, W5				;rcon = xtime(rcon);
	btsc	W5, #8
	xor		W4, W5, W5

	;Column 2
	mov		[W0-4], W2			;key[4]^=key[0]; key[5]^=key[1];
	xor		W2, [W0], [W0++]
	mov		[W0-4], W2			;key[6]^=key[2]; key[7]^=key[3];
	xor		W2, [W0], [W0++]

	;Column 3
	mov		[W0-4], W2			;key[8]^=key[4]; key[9]^=key[5];
	xor		W2, [W0], [W0++]
	mov		[W0-4], W2			;key[10]^=key[6]; key[11]^=key[7];
	xor		W2, [W0], [W0++]

	;Column 4
	mov		[W0-4], W2			;key[12]^=key[8]; key[13]^=key[9];
	xor		W2, [W0], [W0++]
	mov		[W0-4], W2			;key[14]^=key[10]; key[15]^=key[11];
	xor		W2, [W0], [W0++]

	sub		#16, W0

	;Check roundCounter
	dec		W6, W6
	bra		NZ, CalcDecKeyLoop

	mov		W3, PSVPAG
.ifndecl	__HAS_EDS
	pop		CORCONL
.endif
	return
