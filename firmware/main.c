#include <xc.h>
#include <hspwm.h>
#include <adc.h>
#include <stdlib.h>


//Konfiguracija
#pragma config FNOSC = FRCPLL //RC oscilator sa PLL (FRCPLL)
#pragma config PWMLOCK = OFF //Iskljuci PWMLOCK!!!
#pragma config FWDTEN = OFF // Iskljuci WDT
#pragma config JTAGEN = OFF // Iskljuci JTAG (da bi radio RB5)
#pragma config ICS = PGD3 // Prebaci se na treci port za debugiranje (programiranje sam skonta)

//dsPIC33EP512MC502

//#define TRIS_RB5    TRISBbits.TRISB5 //io kontrola, 0=out
//#define IO_RB5	PORTBbits.RB5 //definicija pina

#define INPUT_RB3	PORTBbits.RB3

#define rezolucija 1024 //1024=10bit
#define oversampling 2048

#define AUTO_SAMPLING_CONVERTING 1

//use first and/or second half-bridge
#define USE_HB1 0
#define USE_HB2 0

int i = 0;
int os = 0;
long res = 0;
long tmp = 0;
long tmp2 = 0;
int rezolucija_pola;
int clipping_level;
unsigned AD_val_chan0, AD_val_chan1;

// Interapt za gasenje cliping LED
void __attribute__((__interrupt__, __auto_psv__)) _T5Interrupt(void);

void __attribute__((__interrupt__, __auto_psv__)) _T5Interrupt(void) {

    // Clear Timer 1 interrupt flag
    _T5IF = 0;

    //Togluj tj invertuj stanje (ON/OFF) za RB5
    _LATB5 = 1 - _LATB5;


}

// Function prototype
void InitMCPWM(void);

void InitMCPWM(void) {

    OpenHSPWM(PWM_MOD_EN, PWM_INPUT_CLK_DIV0, rezolucija, 0);

    if (USE_HB1) {
        //pwm1
        ConfigHSPWM1(PWM_TB_MODE_PER | PWM_CENTER_ALIGN_DIS |
                //PWM_D_CYLE_MDC | //zajednicki DC
                PWM_D_CYLE_DC | //pojedinacni DC
                PWM_DT_POS |
                PWM_PRI_TB | PWM_PAIR_COMP,
                PWM_H_PIN_EN |
                PWM_L_PIN_EN, 0, 0, 0);

        SetHSPWMDutyCycle1(rezolucija_pola);
    }

    if (USE_HB2) {
        //pwm2 (ima invertovan H/L - PWM_PIN_SWAP_EN)
        ConfigHSPWM2(PWM_TB_MODE_PER | PWM_CENTER_ALIGN_DIS |
                //PWM_D_CYLE_MDC | //zajednicki DC
                PWM_D_CYLE_DC | //pojedinacni DC
                PWM_DT_POS |
                PWM_PRI_TB | PWM_PAIR_COMP,
                PWM_H_PIN_EN |
                PWM_PIN_SWAP_EN |
                PWM_L_PIN_EN, 0, 0, 0);

        SetHSPWMDutyCycle2(rezolucija_pola);
    }

    //postavi zajednicku vrednost
    SetHSPWMMasterDutyCycle(rezolucija_pola);


    SetHSPWMDeadTime1(0, 0);

}

// Function prototype
void InitADC(void);

unsigned int Channel, PinConfig, Scanselect;
unsigned int Adcon3_reg, Adcon2_reg, Adcon1_reg;

void InitADC(void) {

    unsigned int config1;
    unsigned int config2;
    unsigned int config3;
    unsigned int config4;

    unsigned int configport_a;
    unsigned int configport_b;
    unsigned int configport_c;
    unsigned int configport_d;
    unsigned int configport_e;
    unsigned int configport_f;
    unsigned int configport_g;
    unsigned int configport_h;
    unsigned int configport_i;
    unsigned int configport_j;
    unsigned int configport_k;

    unsigned int configscan_h;
    unsigned int configscan_l;


    if (AUTO_SAMPLING_CONVERTING == 1) {
        config1 = ADC_MODULE_ON &
                ADC_IDLE_STOP &
                ADC_ADDMABM_ORDER &
                ADC_AD12B_10BIT &
                ADC_FORMAT_INTG &
                ADC_SSRC_AUTO & //automatska konverzija
                //ADC_SSRC_MANUAL & //manuelna konverzija
                ADC_AUTO_SAMPLING_ON & //automatski sampling
                ADC_SIMULTANEOUS &
                //ADC_MULTIPLE &
                ADC_SAMP_ON;

    } else {
        config1 = ADC_MODULE_ON &
                ADC_IDLE_STOP &
                ADC_ADDMABM_ORDER &
                ADC_AD12B_10BIT &
                ADC_FORMAT_INTG &
                //ADC_SSRC_AUTO & //automatska konverzija
                ADC_SSRC_MANUAL & //manuelna konverzija
                ADC_AUTO_SAMPLING_ON & //automatski sampling
                ADC_SIMULTANEOUS &
                ADC_SAMP_ON;
    }


    /*
    config1 = ADC_MODULE_ON & ADC_IDLE_STOP & ADC_ADDMABM_ORDER &
              ADC_AD12B_10BIT & ADC_FORMAT_INTG &
              ADC_SSRC_AUTO & //ovo ima kod MC verzije
              ADC_AUTO_SAMPLING_ON & ADC_SIMULTANEOUS &
            ADC_SAMP_ON;

    config2 = ADC_VREF_AVDD_AVSS & ADC_SCAN_OFF & ADC_SELECT_CHAN_0 &
              ADC_DMA_ADD_INC_1 ;

    config3 = ADC_CONV_CLK_SYSTEM & ADC_SAMPLE_TIME_1 &
              ADC_CONV_CLK_2Tcy;

    config4 = ADC_DMA_BUF_LOC_32;
     */


    config2 = ADC_VREF_AVDD_AVSS & ADC_SCAN_OFF & ADC_SELECT_CHAN_0 &
            ADC_DMA_ADD_INC_16;

    config3 = ADC_CONV_CLK_SYSTEM & ADC_SAMPLE_TIME_2 &
            ADC_CONV_CLK_4Tcy;

    config4 = ADC_DMA_BUF_LOC_16 & ADC_DMA_DIS;

    configport_a = ENABLE_AN0_ANA;
    configport_b = ENABLE_AN1_ANA;
    configport_c = 0;
    configport_d = 0;
    configport_e = 0;
    configport_f = 0;
    configport_g = 0;
    configport_h = 0;
    configport_i = 0;
    configport_j = 0;
    configport_k = 0;

    configscan_h = SCAN_NONE_16_31;
    configscan_l = SCAN_NONE_0_15;


    OpenADC1(config1, config2, config3, config4,
            configport_a, configport_b, configport_c, configport_d,
            configport_e, configport_f, configport_g, configport_h,
            configport_i, configport_j, configport_k,
            configscan_h, configscan_l);


    //_SMPI = 0b01111;
    //_CHPS = 0b00;
    //_BUFM = 0;
    //_ALTS = 0;
    //_ADDMAEN = 0;

    //_CH0SA = 0;
    //_CH0NA = 0;

    //_ADON = 1;

}

int main(void) {

    TRISAbits.TRISA0 = 1; //an0
    TRISAbits.TRISA1 = 1; //an1

    TRISAbits.TRISA2 = 0;
    TRISAbits.TRISA3 = 0;
    TRISAbits.TRISA4 = 0;

    TRISBbits.TRISB0 = 0;
    TRISBbits.TRISB1 = 0;
    TRISBbits.TRISB2 = 0;

    //za MC
    _ANSB3 = 0; //nije analogni vec digitalni
    _CNPUB3 = 1; //stavi pullup


    TRISBbits.TRISB3 = 1; //IN

    TRISBbits.TRISB4 = 0;
    TRISBbits.TRISB5 = 0;
    TRISBbits.TRISB6 = 0;
    TRISBbits.TRISB7 = 0;
    TRISBbits.TRISB8 = 0;
    TRISBbits.TRISB9 = 0;
    TRISBbits.TRISB10 = 0;
    TRISBbits.TRISB11 = 0;
    TRISBbits.TRISB12 = 0;
    TRISBbits.TRISB13 = 0;
    TRISBbits.TRISB14 = 0;
    TRISBbits.TRISB15 = 0;


    //_PLLDIV = 256; //odsrafi clok :)
    _PLLDIV = 1; //odsrafi clok :)
    _PLLPOST = 1; //odsrafi  MC=2 :)
    _PLLPRE = 32; //odsrafi  MC=2 :)
    _TUN = 0; //odsrafi  :)

    while (_LOCK == 0);


    //postavimo pocetno stanje za RB5 da bude logicka nula (ugasen LED)
    _LATB5 = 0;

    //inicijalizuj neke vars da ne radimo to stalno
    rezolucija_pola = rezolucija / 2;
    clipping_level = rezolucija * 0.95; //95% od full-scale


    /* -------------- TAJMER5 za 0.5s -------------------------- */
    // Configure Timer 5.
    // PR5 and TCKPS are set to call interrupt every 500ms.
    // Period = PR5 * prescaler * Tcy = 58594 * 256 * 33.33ns = 500ms
    T5CON = 0; // Clear Timer 2 configuration
    T5CONbits.TCKPS = 3; // Set timer 2 prescaler (0=1:1, 1=1:8, 2=1:64, 3=1:256)

    PR5 = 58594; // Set Timer 2 period (max value is 65535)

    _T5IP = 3; // Set Timer 2 interrupt priority
    _T5IF = 0; // Clear Timer 2 interrupt flag
    _T5IE = 1; // Enable Timer 2 interrupt
    T5CONbits.TON = 1; // Turn on Timer 2        

    InitMCPWM();
    InitADC();

    while (1) {
            
            AD_val_chan0 = ReadADC1(0);
            AD_val_chan1 = ReadADC1(1);

        
            //oversampling
            if (oversampling > 1) {
                //sabiraj
                for (os = 0; os < oversampling; os++) {
                    tmp2 += ReadADC1(0);//MC
                }

                //izracunaj oversampling
                AD_val_chan0 = tmp2 / oversampling;
                tmp2=0;
            } else {
                AD_val_chan0 = ReadADC1(0);
            }        
        
                // -------------- GLAVNI UPDATE PWM-a --------------
                //HW mute
                if (INPUT_RB3 == 1) {
                    //default stanje pina
                    if (USE_HB1) {SetHSPWMDutyCycle1(AD_val_chan0);}
                    if (USE_HB2) {SetHSPWMDutyCycle2(rezolucija - AD_val_chan0);}
                } else {
                    //mute ON
                    if (USE_HB1) {SetHSPWMDutyCycle1(rezolucija_pola);}
                    if (USE_HB2) {SetHSPWMDutyCycle2(rezolucija_pola);}
                }
        
            }
         
        //while (1) {

            //Togluj tj invertuj stanje (ON/OFF) za RB5
            _LATB5 = 1 - _LATB5;
           
        //}


    }
