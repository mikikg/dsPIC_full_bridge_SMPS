;/*****************************************************************************
; *
; * Tripple Data Encryption Standard (TDES) Include Header
; *   168 bit key, 64 bit data block
; *   For more information see, AN1044
; *
; *****************************************************************************
; * FileName:		TDES.h
; * Dependencies:	DES_asm.s, TDES_asm.s
; * Processor:		PIC24F, PIC24H, dsPIC30F, or dsPIC33F
; * Compiler:		MPLAB C30 2.03 or later
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
; * David Flowers		08/08/06	Original release
; *****************************************************************************/
#ifndef __TDES_H_
#define __TDES_H_

// Variables allocated in DES_asm.s
extern unsigned int Key[12];
extern unsigned int subKeyBlock;
extern unsigned int M[4];
extern unsigned char mode;

// Prototypes to functions defined in TDES_asm.s
extern void initTDES(unsigned int*);
extern void TDES(unsigned int*);
#define TDES_encrypt(a) {mode = 1; TDES(a);}
#define TDES_decrypt(a) {mode = 0; TDES(a);}


#endif
