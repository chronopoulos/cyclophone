EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:cyclophone-cache
LIBS:cyclo-adc-cache
EELAYER 27 0
EELAYER END
$Descr User 17000 11000
encoding utf-8
Sheet 1 1
Title ""
Date "9 apr 2014"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 12000 8650 2    60   Input ~ 0
+AREF
Text GLabel 11750 8750 2    60   Input ~ 0
GND
Text GLabel 8800 8750 2    60   Input ~ 0
GND
$Comp
L ADCLEFTPINS Left1
U 1 1 53274A2C
P 7900 7450
F 0 "Left1" H 7850 5950 60  0000 C CNN
F 1 "ADCLEFTPINS" H 7900 8450 60  0000 C CNN
F 2 "" H 7900 7450 60  0001 C CNN
F 3 "" H 7900 7450 60  0001 C CNN
	1    7900 7450
	-1   0    0    -1  
$EndComp
$Comp
L ADCRIGHTPINS Right1
U 1 1 53274980
P 10800 7450
F 0 "Right1" H 10750 5950 60  0000 C CNN
F 1 "ADCRIGHTPINS" H 10800 8450 60  0000 C CNN
F 2 "" H 10800 7450 60  0001 C CNN
F 3 "" H 10800 7450 60  0001 C CNN
	1    10800 7450
	-1   0    0    -1  
$EndComp
Text GLabel 8800 6950 2    60   Input ~ 0
DIO3
Text GLabel 9100 6850 2    60   Input ~ 0
DIO2
Text GLabel 9100 6650 2    60   Input ~ 0
DIO0
Text GLabel 8800 6750 2    60   Input ~ 0
DIO1
Text GLabel 11750 6750 2    60   Input ~ 0
DIO5
Text GLabel 12050 6650 2    60   Input ~ 0
DIO4
Text GLabel 12050 6850 2    60   Input ~ 0
DIO6
Text GLabel 11750 6950 2    60   Input ~ 0
DIO7
Text GLabel 11750 8550 2    60   Input ~ 0
CH31
Text GLabel 12050 8450 2    60   Input ~ 0
CH30
Text GLabel 11750 8350 2    60   Input ~ 0
CH29
Text GLabel 12050 8250 2    60   Input ~ 0
CH28
Text GLabel 11750 8150 2    60   Input ~ 0
CH27
Text GLabel 12050 8050 2    60   Input ~ 0
CH26
Text GLabel 11750 7950 2    60   Input ~ 0
CH25
Text GLabel 12050 7850 2    60   Input ~ 0
CH24
Text GLabel 11750 7750 2    60   Input ~ 0
CH23
Text GLabel 12050 7650 2    60   Input ~ 0
CH22
Text GLabel 11750 7550 2    60   Input ~ 0
CH21
Text GLabel 12050 7450 2    60   Input ~ 0
CH20
Text GLabel 11750 7350 2    60   Input ~ 0
CH19
Text GLabel 12050 7250 2    60   Input ~ 0
CH18
Text GLabel 11750 7150 2    60   Input ~ 0
CH17
Text GLabel 12050 7050 2    60   Input ~ 0
CH16
Text GLabel 9100 7850 2    60   Input ~ 0
CH8
Text GLabel 8800 7950 2    60   Input ~ 0
CH9
Text GLabel 9100 8050 2    60   Input ~ 0
CH10
Text GLabel 8800 8150 2    60   Input ~ 0
CH11
Text GLabel 9100 8250 2    60   Input ~ 0
CH12
Text GLabel 8800 8350 2    60   Input ~ 0
CH13
Text GLabel 9100 8450 2    60   Input ~ 0
CH14
Text GLabel 8800 8550 2    60   Input ~ 0
CH15
Text GLabel 9100 7050 2    60   Input ~ 0
CH0
Text GLabel 8800 7150 2    60   Input ~ 0
CH1
Text GLabel 9100 7250 2    60   Input ~ 0
CH2
Text GLabel 8800 7350 2    60   Input ~ 0
CH3
Text GLabel 9100 7450 2    60   Input ~ 0
CH4
Text GLabel 8800 7550 2    60   Input ~ 0
CH5
Text GLabel 9100 7650 2    60   Input ~ 0
CH6
Text GLabel 8800 7750 2    60   Input ~ 0
CH7
Text GLabel 9100 8650 2    60   Input ~ 0
+AREF
Text GLabel 11200 1850 0    60   Input ~ 0
3.3V
Text GLabel 12350 1100 2    60   Input ~ 0
5V
NoConn ~ 12150 1400
NoConn ~ 12150 1500
NoConn ~ 12150 1600
NoConn ~ 12150 1800
NoConn ~ 12150 1900
NoConn ~ 12150 2100
Text GLabel 11200 2350 0    60   Input ~ 0
GND
Text GLabel 12350 2000 2    60   Input ~ 0
GND
Text GLabel 12350 1700 2    60   Input ~ 0
GND
Text GLabel 12350 1300 2    60   Input ~ 0
GND
NoConn ~ 11350 1800
NoConn ~ 11350 1700
NoConn ~ 11350 1600
NoConn ~ 11350 1400
NoConn ~ 11350 1300
NoConn ~ 11350 1200
$Comp
L C C17
U 1 1 53208F3E
P 3900 6050
F 0 "C17" H 3900 6150 40  0000 L CNN
F 1 ".01 mf" H 3906 5965 40  0000 L CNN
F 2 "~" H 3938 5900 30  0000 C CNN
F 3 "~" H 3900 6050 60  0000 C CNN
	1    3900 6050
	0    -1   -1   0   
$EndComp
$Comp
L C C18
U 1 1 53208F3D
P 3900 6250
F 0 "C18" H 3900 6350 40  0000 L CNN
F 1 ".01 mf" H 3906 6165 40  0000 L CNN
F 2 "~" H 3938 6100 30  0000 C CNN
F 3 "~" H 3900 6250 60  0000 C CNN
	1    3900 6250
	0    -1   -1   0   
$EndComp
$Comp
L C C20
U 1 1 53208F3C
P 3900 6650
F 0 "C20" H 3900 6750 40  0000 L CNN
F 1 ".01 mf" H 3906 6565 40  0000 L CNN
F 2 "~" H 3938 6500 30  0000 C CNN
F 3 "~" H 3900 6650 60  0000 C CNN
	1    3900 6650
	0    -1   -1   0   
$EndComp
$Comp
L C C19
U 1 1 53208F3B
P 3900 6450
F 0 "C19" H 3900 6550 40  0000 L CNN
F 1 ".01 mf" H 3906 6365 40  0000 L CNN
F 2 "~" H 3938 6300 30  0000 C CNN
F 3 "~" H 3900 6450 60  0000 C CNN
	1    3900 6450
	0    -1   -1   0   
$EndComp
$Comp
L C C7
U 1 1 53208F3A
P 3550 7350
F 0 "C7" H 3550 7450 40  0000 L CNN
F 1 ".01 mf" H 3556 7265 40  0000 L CNN
F 2 "~" H 3588 7200 30  0000 C CNN
F 3 "~" H 3550 7350 60  0000 C CNN
	1    3550 7350
	0    -1   -1   0   
$EndComp
$Comp
L C C8
U 1 1 53208F39
P 3550 7550
F 0 "C8" H 3550 7650 40  0000 L CNN
F 1 ".01 mf" H 3556 7465 40  0000 L CNN
F 2 "~" H 3588 7400 30  0000 C CNN
F 3 "~" H 3550 7550 60  0000 C CNN
	1    3550 7550
	0    -1   -1   0   
$EndComp
$Comp
L C C6
U 1 1 53208F38
P 3550 7150
F 0 "C6" H 3550 7250 40  0000 L CNN
F 1 ".01 mf" H 3556 7065 40  0000 L CNN
F 2 "~" H 3588 7000 30  0000 C CNN
F 3 "~" H 3550 7150 60  0000 C CNN
	1    3550 7150
	0    -1   -1   0   
$EndComp
$Comp
L C C5
U 1 1 53208F37
P 3550 6950
F 0 "C5" H 3550 7050 40  0000 L CNN
F 1 ".01 mf" H 3556 6865 40  0000 L CNN
F 2 "~" H 3588 6800 30  0000 C CNN
F 3 "~" H 3550 6950 60  0000 C CNN
	1    3550 6950
	0    -1   -1   0   
$EndComp
$Comp
L C C9
U 1 1 53208F36
P 3550 7750
F 0 "C9" H 3550 7850 40  0000 L CNN
F 1 ".01 mf" H 3556 7665 40  0000 L CNN
F 2 "~" H 3588 7600 30  0000 C CNN
F 3 "~" H 3550 7750 60  0000 C CNN
	1    3550 7750
	0    -1   -1   0   
$EndComp
$Comp
L C C10
U 1 1 53208F35
P 3550 7950
F 0 "C10" H 3550 8050 40  0000 L CNN
F 1 ".01 mf" H 3556 7865 40  0000 L CNN
F 2 "~" H 3588 7800 30  0000 C CNN
F 3 "~" H 3550 7950 60  0000 C CNN
	1    3550 7950
	0    -1   -1   0   
$EndComp
$Comp
L C C12
U 1 1 53208F34
P 3550 8350
F 0 "C12" H 3550 8450 40  0000 L CNN
F 1 ".01 mf" H 3556 8265 40  0000 L CNN
F 2 "~" H 3588 8200 30  0000 C CNN
F 3 "~" H 3550 8350 60  0000 C CNN
	1    3550 8350
	0    -1   -1   0   
$EndComp
$Comp
L C C11
U 1 1 53208F33
P 3550 8150
F 0 "C11" H 3550 8250 40  0000 L CNN
F 1 ".01 mf" H 3556 8065 40  0000 L CNN
F 2 "~" H 3588 8000 30  0000 C CNN
F 3 "~" H 3550 8150 60  0000 C CNN
	1    3550 8150
	0    -1   -1   0   
$EndComp
$Comp
L C C1
U 1 1 53208F32
P 3550 6150
F 0 "C1" H 3550 6250 40  0000 L CNN
F 1 ".01 mf" H 3556 6065 40  0000 L CNN
F 2 "~" H 3588 6000 30  0000 C CNN
F 3 "~" H 3550 6150 60  0000 C CNN
	1    3550 6150
	0    -1   -1   0   
$EndComp
$Comp
L C C2
U 1 1 53208F31
P 3550 6350
F 0 "C2" H 3550 6450 40  0000 L CNN
F 1 ".01 mf" H 3556 6265 40  0000 L CNN
F 2 "~" H 3588 6200 30  0000 C CNN
F 3 "~" H 3550 6350 60  0000 C CNN
	1    3550 6350
	0    -1   -1   0   
$EndComp
$Comp
L C C4
U 1 1 53208F30
P 3550 6750
F 0 "C4" H 3550 6850 40  0000 L CNN
F 1 ".01 mf" H 3556 6665 40  0000 L CNN
F 2 "~" H 3588 6600 30  0000 C CNN
F 3 "~" H 3550 6750 60  0000 C CNN
	1    3550 6750
	0    -1   -1   0   
$EndComp
$Comp
L C C3
U 1 1 53208F2F
P 3550 6550
F 0 "C3" H 3550 6650 40  0000 L CNN
F 1 ".01 mf" H 3556 6465 40  0000 L CNN
F 2 "~" H 3588 6400 30  0000 C CNN
F 3 "~" H 3550 6550 60  0000 C CNN
	1    3550 6550
	0    -1   -1   0   
$EndComp
$Comp
L C C23
U 1 1 53208EAE
P 3900 7250
F 0 "C23" H 3900 7350 40  0000 L CNN
F 1 ".01 mf" H 3906 7165 40  0000 L CNN
F 2 "~" H 3938 7100 30  0000 C CNN
F 3 "~" H 3900 7250 60  0000 C CNN
	1    3900 7250
	0    -1   -1   0   
$EndComp
$Comp
L C C24
U 1 1 53208EAD
P 3900 7450
F 0 "C24" H 3900 7550 40  0000 L CNN
F 1 ".01 mf" H 3906 7365 40  0000 L CNN
F 2 "~" H 3938 7300 30  0000 C CNN
F 3 "~" H 3900 7450 60  0000 C CNN
	1    3900 7450
	0    -1   -1   0   
$EndComp
$Comp
L C C22
U 1 1 53208EAC
P 3900 7050
F 0 "C22" H 3900 7150 40  0000 L CNN
F 1 ".01 mf" H 3906 6965 40  0000 L CNN
F 2 "~" H 3938 6900 30  0000 C CNN
F 3 "~" H 3900 7050 60  0000 C CNN
	1    3900 7050
	0    -1   -1   0   
$EndComp
$Comp
L C C21
U 1 1 53208EAB
P 3900 6850
F 0 "C21" H 3900 6950 40  0000 L CNN
F 1 ".01 mf" H 3906 6765 40  0000 L CNN
F 2 "~" H 3938 6700 30  0000 C CNN
F 3 "~" H 3900 6850 60  0000 C CNN
	1    3900 6850
	0    -1   -1   0   
$EndComp
$Comp
L C C25
U 1 1 53208E86
P 3900 7650
F 0 "C25" H 3900 7750 40  0000 L CNN
F 1 ".01 mf" H 3906 7565 40  0000 L CNN
F 2 "~" H 3938 7500 30  0000 C CNN
F 3 "~" H 3900 7650 60  0000 C CNN
	1    3900 7650
	0    -1   -1   0   
$EndComp
$Comp
L C C26
U 1 1 53208E85
P 3900 7850
F 0 "C26" H 3900 7950 40  0000 L CNN
F 1 ".01 mf" H 3906 7765 40  0000 L CNN
F 2 "~" H 3938 7700 30  0000 C CNN
F 3 "~" H 3900 7850 60  0000 C CNN
	1    3900 7850
	0    -1   -1   0   
$EndComp
$Comp
L C C28
U 1 1 53208E84
P 3900 8250
F 0 "C28" H 3900 8350 40  0000 L CNN
F 1 ".01 mf" H 3906 8165 40  0000 L CNN
F 2 "~" H 3938 8100 30  0000 C CNN
F 3 "~" H 3900 8250 60  0000 C CNN
	1    3900 8250
	0    -1   -1   0   
$EndComp
$Comp
L C C27
U 1 1 53208E83
P 3900 8050
F 0 "C27" H 3900 8150 40  0000 L CNN
F 1 ".01 mf" H 3906 7965 40  0000 L CNN
F 2 "~" H 3938 7900 30  0000 C CNN
F 3 "~" H 3900 8050 60  0000 C CNN
	1    3900 8050
	0    -1   -1   0   
$EndComp
Text GLabel 3350 9450 2    60   Input ~ 0
GND
Text GLabel 11200 1100 0    60   Input ~ 0
3.3V
Text GLabel 9200 3050 2    60   Input ~ 0
3.3V
Text GLabel 5300 3050 2    60   Input ~ 0
3.3V
Text GLabel 9450 3250 2    60   Input ~ 0
GND
Text GLabel 5550 3250 2    60   Input ~ 0
GND
Text GLabel 2200 3450 0    60   Input ~ 0
GND
Text GLabel 5050 4750 2    60   Input ~ 0
GND
Text GLabel 2800 4750 0    60   Input ~ 0
GND
Text GLabel 8900 4750 2    60   Input ~ 0
GND
Text GLabel 6100 3450 0    60   Input ~ 0
GND
Text GLabel 6700 4750 0    60   Input ~ 0
GND
Text GLabel 11200 1500 0    60   Input ~ 0
GND
Text GLabel 13900 5500 2    60   Input ~ 0
CS0
Text GLabel 13900 5650 2    60   Input ~ 0
CS1
Text GLabel 13900 5350 2    60   Input ~ 0
SCLK
Text GLabel 13900 5200 2    60   Input ~ 0
SDI
Text GLabel 13900 5050 2    60   Input ~ 0
SDO
Text GLabel 13650 5500 0    60   Input ~ 0
CE0
Text GLabel 13650 5650 0    60   Input ~ 0
CE1
Text GLabel 13650 5050 0    60   Input ~ 0
MOSI
Text GLabel 13650 5200 0    60   Input ~ 0
MISO
Text GLabel 13650 5350 0    60   Input ~ 0
SCLK
Text GLabel 12500 2300 2    60   Input ~ 0
CE1
Text GLabel 12250 2200 2    60   Input ~ 0
CE0
Text GLabel 11200 2200 0    60   Input ~ 0
SCLK
Text GLabel 10900 2100 0    60   Input ~ 0
MISO
Text GLabel 11200 2000 0    60   Input ~ 0
MOSI
Text GLabel 9100 2850 2    60   Input ~ 0
DIO5
Text GLabel 8800 2950 2    60   Input ~ 0
DIO4
Text GLabel 6500 2850 0    60   Input ~ 0
DIO6
Text GLabel 6750 2950 0    60   Input ~ 0
DIO7
Text GLabel 2850 2950 0    60   Input ~ 0
DIO3
Text GLabel 2600 2850 0    60   Input ~ 0
DIO2
Text GLabel 4900 2950 2    60   Input ~ 0
DIO0
Text GLabel 5150 2850 2    60   Input ~ 0
DIO1
Text GLabel 8800 7750 2    60   Input ~ 0
CH7
Text GLabel 9100 7650 2    60   Input ~ 0
CH6
Text GLabel 8800 7550 2    60   Input ~ 0
CH5
Text GLabel 9100 7450 2    60   Input ~ 0
CH4
Text GLabel 8800 7350 2    60   Input ~ 0
CH3
Text GLabel 9100 7250 2    60   Input ~ 0
CH2
Text GLabel 8800 7150 2    60   Input ~ 0
CH1
Text GLabel 9100 7050 2    60   Input ~ 0
CH0
Text GLabel 8800 8550 2    60   Input ~ 0
CH15
Text GLabel 9100 8450 2    60   Input ~ 0
CH14
Text GLabel 8800 8350 2    60   Input ~ 0
CH13
Text GLabel 9100 8250 2    60   Input ~ 0
CH12
Text GLabel 8800 8150 2    60   Input ~ 0
CH11
Text GLabel 9100 8050 2    60   Input ~ 0
CH10
Text GLabel 8800 7950 2    60   Input ~ 0
CH9
Text GLabel 9100 7850 2    60   Input ~ 0
CH8
Text GLabel 12050 7050 2    60   Input ~ 0
CH16
Text GLabel 11750 7150 2    60   Input ~ 0
CH17
Text GLabel 12050 7250 2    60   Input ~ 0
CH18
Text GLabel 11750 7350 2    60   Input ~ 0
CH19
Text GLabel 12050 7450 2    60   Input ~ 0
CH20
Text GLabel 11750 7550 2    60   Input ~ 0
CH21
Text GLabel 12050 7650 2    60   Input ~ 0
CH22
Text GLabel 11750 7750 2    60   Input ~ 0
CH23
Text GLabel 12050 7850 2    60   Input ~ 0
CH24
Text GLabel 11750 7950 2    60   Input ~ 0
CH25
Text GLabel 12050 8050 2    60   Input ~ 0
CH26
Text GLabel 11750 8150 2    60   Input ~ 0
CH27
Text GLabel 12050 8250 2    60   Input ~ 0
CH28
Text GLabel 11750 8350 2    60   Input ~ 0
CH29
Text GLabel 12050 8450 2    60   Input ~ 0
CH30
Text GLabel 11750 8550 2    60   Input ~ 0
CH31
$Comp
L CONN_13X2 Raspberry1
U 1 1 531F8E51
P 11750 1700
F 0 "Raspberry1" H 11750 2400 60  0000 C CNN
F 1 "CONN_13X2" V 11750 1700 50  0000 C CNN
F 2 "" H 11750 1700 60  0001 C CNN
F 3 "" H 11750 1700 60  0001 C CNN
	1    11750 1700
	1    0    0    -1  
$EndComp
$Comp
L C C13
U 1 1 5313DE53
P 3550 8550
F 0 "C13" H 3550 8650 40  0000 L CNN
F 1 ".01 mf" H 3556 8465 40  0000 L CNN
F 2 "~" H 3588 8400 30  0000 C CNN
F 3 "~" H 3550 8550 60  0000 C CNN
	1    3550 8550
	0    -1   -1   0   
$EndComp
$Comp
L C C14
U 1 1 5313DE52
P 3550 8750
F 0 "C14" H 3550 8850 40  0000 L CNN
F 1 ".01 mf" H 3556 8665 40  0000 L CNN
F 2 "~" H 3588 8600 30  0000 C CNN
F 3 "~" H 3550 8750 60  0000 C CNN
	1    3550 8750
	0    -1   -1   0   
$EndComp
$Comp
L C C16
U 1 1 5313DE51
P 3550 9150
F 0 "C16" H 3550 9250 40  0000 L CNN
F 1 ".01 mf" H 3556 9065 40  0000 L CNN
F 2 "~" H 3588 9000 30  0000 C CNN
F 3 "~" H 3550 9150 60  0000 C CNN
	1    3550 9150
	0    -1   -1   0   
$EndComp
$Comp
L C C15
U 1 1 5313DE50
P 3550 8950
F 0 "C15" H 3550 9050 40  0000 L CNN
F 1 ".01 mf" H 3556 8865 40  0000 L CNN
F 2 "~" H 3588 8800 30  0000 C CNN
F 3 "~" H 3550 8950 60  0000 C CNN
	1    3550 8950
	0    -1   -1   0   
$EndComp
$Comp
L C C31
U 1 1 5313DE32
P 3900 8850
F 0 "C31" H 3900 8950 40  0000 L CNN
F 1 ".01 mf" H 3906 8765 40  0000 L CNN
F 2 "~" H 3938 8700 30  0000 C CNN
F 3 "~" H 3900 8850 60  0000 C CNN
	1    3900 8850
	0    -1   -1   0   
$EndComp
$Comp
L C C32
U 1 1 5313DE31
P 3900 9050
F 0 "C32" H 3900 9150 40  0000 L CNN
F 1 ".01 mf" H 3906 8965 40  0000 L CNN
F 2 "~" H 3938 8900 30  0000 C CNN
F 3 "~" H 3900 9050 60  0000 C CNN
	1    3900 9050
	0    -1   -1   0   
$EndComp
$Comp
L C C30
U 1 1 5313DE30
P 3900 8650
F 0 "C30" H 3900 8750 40  0000 L CNN
F 1 ".01 mf" H 3906 8565 40  0000 L CNN
F 2 "~" H 3938 8500 30  0000 C CNN
F 3 "~" H 3900 8650 60  0000 C CNN
	1    3900 8650
	0    -1   -1   0   
$EndComp
$Comp
L C C29
U 1 1 5313DE2F
P 3900 8450
F 0 "C29" H 3900 8550 40  0000 L CNN
F 1 ".01 mf" H 3906 8365 40  0000 L CNN
F 2 "~" H 3938 8300 30  0000 C CNN
F 3 "~" H 3900 8450 60  0000 C CNN
	1    3900 8450
	0    -1   -1   0   
$EndComp
$Comp
L ADS7957 ADS-1
U 1 1 5313C81B
P 7800 3900
F 0 "ADS-1" H 7500 5100 60  0000 C CNN
F 1 "ADS7957" H 7800 4000 60  0000 C CNN
F 2 "" H 7800 3900 60  0001 C CNN
F 3 "" H 7800 3900 60  0001 C CNN
	1    7800 3900
	1    0    0    -1  
$EndComp
$Comp
L ADS7957 ADS-0
U 1 1 5313C810
P 3900 3900
F 0 "ADS-0" H 3600 5100 60  0000 C CNN
F 1 "ADS7957" H 3900 4000 60  0000 C CNN
F 2 "" H 3900 3900 60  0001 C CNN
F 3 "" H 3900 3900 60  0001 C CNN
	1    3900 3900
	1    0    0    -1  
$EndComp
Text GLabel 4500 9150 2    60   Input ~ 0
CH31
Text GLabel 4200 9050 2    60   Input ~ 0
CH30
Text GLabel 4500 8950 2    60   Input ~ 0
CH29
Text GLabel 4200 8850 2    60   Input ~ 0
CH28
Text GLabel 4500 8750 2    60   Input ~ 0
CH27
Text GLabel 4200 8650 2    60   Input ~ 0
CH26
Text GLabel 4500 8550 2    60   Input ~ 0
CH25
Text GLabel 4200 8450 2    60   Input ~ 0
CH24
Text GLabel 4500 8350 2    60   Input ~ 0
CH23
Text GLabel 4200 8250 2    60   Input ~ 0
CH22
Text GLabel 4500 8150 2    60   Input ~ 0
CH21
Text GLabel 4200 8050 2    60   Input ~ 0
CH20
Text GLabel 4500 7950 2    60   Input ~ 0
CH19
Text GLabel 4200 7850 2    60   Input ~ 0
CH18
Text GLabel 4500 7750 2    60   Input ~ 0
CH17
Text GLabel 4200 7650 2    60   Input ~ 0
CH16
Text GLabel 4200 6850 2    60   Input ~ 0
CH8
Text GLabel 4500 6950 2    60   Input ~ 0
CH9
Text GLabel 4200 7050 2    60   Input ~ 0
CH10
Text GLabel 4500 7150 2    60   Input ~ 0
CH11
Text GLabel 4200 7250 2    60   Input ~ 0
CH12
Text GLabel 4500 7350 2    60   Input ~ 0
CH13
Text GLabel 4200 7450 2    60   Input ~ 0
CH14
Text GLabel 4500 7550 2    60   Input ~ 0
CH15
Text GLabel 4200 6050 2    60   Input ~ 0
CH0
Text GLabel 4500 6150 2    60   Input ~ 0
CH1
Text GLabel 4200 6250 2    60   Input ~ 0
CH2
Text GLabel 4500 6350 2    60   Input ~ 0
CH3
Text GLabel 4200 6450 2    60   Input ~ 0
CH4
Text GLabel 4500 6550 2    60   Input ~ 0
CH5
Text GLabel 4200 6650 2    60   Input ~ 0
CH6
Text GLabel 4500 6750 2    60   Input ~ 0
CH7
Text GLabel 8750 3250 2    60   Input ~ 0
SDO
Text GLabel 9050 3350 2    60   Input ~ 0
SDI
Text GLabel 8750 3450 2    60   Input ~ 0
SCLK
Text GLabel 9050 3550 2    60   Input ~ 0
CS1
Text GLabel 8800 3750 2    60   Input ~ 0
+AREF
Text GLabel 6650 3250 0    60   Input ~ 0
+AREF
Text GLabel 9150 3850 2    60   Input ~ 0
CH16
Text GLabel 8850 3950 2    60   Input ~ 0
CH17
Text GLabel 9150 4050 2    60   Input ~ 0
CH18
Text GLabel 8850 4150 2    60   Input ~ 0
CH19
Text GLabel 9150 4250 2    60   Input ~ 0
CH20
Text GLabel 8850 4350 2    60   Input ~ 0
CH21
Text GLabel 9150 4450 2    60   Input ~ 0
CH22
Text GLabel 8850 4550 2    60   Input ~ 0
CH23
Text GLabel 6800 4550 0    60   Input ~ 0
CH24
Text GLabel 6500 4450 0    60   Input ~ 0
CH25
Text GLabel 6800 4350 0    60   Input ~ 0
CH26
Text GLabel 6500 4250 0    60   Input ~ 0
CH27
Text GLabel 6800 4150 0    60   Input ~ 0
CH28
Text GLabel 6500 4050 0    60   Input ~ 0
CH29
Text GLabel 6800 3950 0    60   Input ~ 0
CH30
Text GLabel 6500 3850 0    60   Input ~ 0
CH31
Text GLabel 11750 6950 2    60   Input ~ 0
DIO7
Text GLabel 12050 6850 2    60   Input ~ 0
DIO6
Text GLabel 12050 6650 2    60   Input ~ 0
DIO4
Text GLabel 11750 6750 2    60   Input ~ 0
DIO5
Text GLabel 8800 6750 2    60   Input ~ 0
DIO1
Text GLabel 9100 6650 2    60   Input ~ 0
DIO0
Text GLabel 9100 6850 2    60   Input ~ 0
DIO2
Text GLabel 8800 6950 2    60   Input ~ 0
DIO3
Text GLabel 2600 3850 0    60   Input ~ 0
CH15
Text GLabel 2900 3950 0    60   Input ~ 0
CH14
Text GLabel 2600 4050 0    60   Input ~ 0
CH13
Text GLabel 2900 4150 0    60   Input ~ 0
CH12
Text GLabel 2600 4250 0    60   Input ~ 0
CH11
Text GLabel 2900 4350 0    60   Input ~ 0
CH10
Text GLabel 2600 4450 0    60   Input ~ 0
CH9
Text GLabel 2900 4550 0    60   Input ~ 0
CH8
Text GLabel 4950 4550 2    60   Input ~ 0
CH7
Text GLabel 5200 4450 2    60   Input ~ 0
CH6
Text GLabel 4950 4350 2    60   Input ~ 0
CH5
Text GLabel 5200 4250 2    60   Input ~ 0
CH4
Text GLabel 4950 4150 2    60   Input ~ 0
CH3
Text GLabel 5200 4050 2    60   Input ~ 0
CH2
Text GLabel 4950 3950 2    60   Input ~ 0
CH1
Text GLabel 5200 3850 2    60   Input ~ 0
CH0
Text GLabel 5150 3550 2    60   Input ~ 0
CS0
Text GLabel 4850 3450 2    60   Input ~ 0
SCLK
Text GLabel 5150 3350 2    60   Input ~ 0
SDI
Text GLabel 4900 3250 2    60   Input ~ 0
SDO
Text GLabel 2750 3250 0    60   Input ~ 0
+AREF
Text GLabel 4850 3750 2    60   Input ~ 0
+AREF
Text GLabel 13800 3700 0    60   Input ~ 0
3.3V
Text GLabel 13500 3600 0    60   Input ~ 0
GND
Text GLabel 13800 4100 0    60   Input ~ 0
SCLK
Text GLabel 13500 4000 0    60   Input ~ 0
MISO
Text GLabel 13800 3900 0    60   Input ~ 0
MOSI
Text GLabel 13750 4300 0    60   Input ~ 0
CE1
Text GLabel 13500 4200 0    60   Input ~ 0
CE0
Text GLabel 13500 3800 0    60   Input ~ 0
5V
$Comp
L CONN_8 P1
U 1 1 53390A45
P 14300 3950
F 0 "P1" V 14250 3950 60  0000 C CNN
F 1 "CONN_8" V 14350 3950 60  0000 C CNN
F 2 "" H 14300 3950 60  0000 C CNN
F 3 "" H 14300 3950 60  0000 C CNN
	1    14300 3950
	1    0    0    -1  
$EndComp
Text Notes 12900 3300 0    60   ~ 0
Maybe go with generic 8 pin connector rather than PI pins.\n
Text Notes 13400 4700 0    60   ~ 0
Different names for\nthe same things.
Text Notes 3400 5600 0    60   ~ 0
All analog inputs connected \nto capacitors.  necessary?
Text Notes 9050 5950 0    60   ~ 0
Identical pinouts for both.  \nShould face opposite directions on layout,\n to allow using two of the same daughtercard, \none for each set of pins.\n
NoConn ~ 12150 1200
Text Notes 13200 1100 0    60   ~ 0
Add voltage regulator gadget for 2.5v reference!
Text Notes 3200 5350 0    60   ~ 0
Maybe do this on cyclo-nexus board.
$Comp
L LM317T U2
U 1 1 5341C926
P 13850 1500
F 0 "U2" H 13650 1700 40  0000 C CNN
F 1 "LM317T" H 13850 1700 40  0000 L CNN
F 2 "TO-220" H 13850 1600 30  0000 C CIN
F 3 "" H 13850 1500 60  0000 C CNN
	1    13850 1500
	1    0    0    -1  
$EndComp
$Comp
L C 4.7
U 1 1 5341D36B
P 14700 1750
F 0 "4.7" H 14700 1850 40  0000 L CNN
F 1 "C" H 14706 1665 40  0000 L CNN
F 2 "~" H 14738 1600 30  0000 C CNN
F 3 "~" H 14700 1750 60  0000 C CNN
	1    14700 1750
	1    0    0    -1  
$EndComp
$Comp
L POT RV1
U 1 1 5341D3A9
P 13850 2150
F 0 "RV1" H 13850 2050 50  0000 C CNN
F 1 "POT" H 13850 2150 50  0000 C CNN
F 2 "~" H 13850 2150 60  0000 C CNN
F 3 "~" H 13850 2150 60  0000 C CNN
	1    13850 2150
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR2
U 1 1 5341D4E7
P 13450 2250
F 0 "#PWR2" H 13450 2250 30  0001 C CNN
F 1 "GND" H 13450 2180 30  0001 C CNN
F 2 "" H 13450 2250 60  0000 C CNN
F 3 "" H 13450 2250 60  0000 C CNN
	1    13450 2250
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR3
U 1 1 5341D80F
P 14700 2150
F 0 "#PWR3" H 14700 2150 30  0001 C CNN
F 1 "GND" H 14700 2080 30  0001 C CNN
F 2 "" H 14700 2150 60  0000 C CNN
F 3 "" H 14700 2150 60  0000 C CNN
	1    14700 2150
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 5341DA54
P 14200 1850
F 0 "R2" V 14300 1850 40  0000 C CNN
F 1 "220" V 14207 1851 40  0000 C CNN
F 2 "~" V 14130 1850 30  0000 C CNN
F 3 "~" H 14200 1850 30  0000 C CNN
	1    14200 1850
	0    -1   -1   0   
$EndComp
NoConn ~ 14100 2150
Text GLabel 13350 1450 0    60   Input ~ 0
5V
Text GLabel 15000 1450 2    60   Input ~ 0
+AREF
Text Notes 14400 1250 0    60   ~ 0
Actually not used right now!!
$Comp
L C .1
U 1 1 5341E866
P 13450 1850
F 0 ".1" H 13000 1850 40  0000 L CNN
F 1 "C" H 13456 1765 40  0000 L CNN
F 2 "~" H 13488 1700 30  0000 C CNN
F 3 "~" H 13450 1850 60  0000 C CNN
	1    13450 1850
	1    0    0    -1  
$EndComp
$Comp
L TL431LP U1
U 1 1 5341EFA8
P 11300 4600
F 0 "U1" V 11550 4850 70  0000 C CNN
F 1 "TL431LP" V 11050 4600 70  0000 C CNN
F 2 "" H 11300 4600 60  0000 C CNN
F 3 "" H 11300 4600 60  0000 C CNN
	1    11300 4600
	0    -1   -1   0   
$EndComp
Text GLabel 10100 4600 0    60   Input ~ 0
5V
$Comp
L R R1
U 1 1 5341F690
P 10450 4600
F 0 "R1" V 10530 4600 40  0000 C CNN
F 1 "2K" V 10457 4601 40  0000 C CNN
F 2 "~" V 10380 4600 30  0000 C CNN
F 3 "~" H 10450 4600 30  0000 C CNN
	1    10450 4600
	0    -1   -1   0   
$EndComp
Text GLabel 11300 4100 1    60   Input ~ 0
2.5V
$Comp
L GND #PWR1
U 1 1 534472D8
P 12000 4700
F 0 "#PWR1" H 12000 4700 30  0001 C CNN
F 1 "GND" H 12000 4630 30  0001 C CNN
F 2 "" H 12000 4700 60  0000 C CNN
F 3 "" H 12000 4700 60  0000 C CNN
	1    12000 4700
	1    0    0    -1  
$EndComp
Wire Wire Line
	11250 8650 12000 8650
Wire Wire Line
	11750 8750 11250 8750
Wire Wire Line
	8800 8750 8350 8750
Wire Wire Line
	11350 1900 11250 1900
Wire Wire Line
	11250 1900 11250 1850
Wire Wire Line
	11250 1850 11200 1850
Wire Wire Line
	12150 2000 12350 2000
Wire Wire Line
	12150 1300 12350 1300
Wire Wire Line
	6900 3550 6800 3550
Wire Wire Line
	6800 3550 6800 3450
Wire Wire Line
	6800 3450 6900 3450
Wire Wire Line
	11200 1100 11350 1100
Wire Wire Line
	5450 3150 5450 3650
Wire Wire Line
	5450 3650 4800 3650
Wire Wire Line
	6200 3450 6100 3450
Wire Wire Line
	5050 4750 4900 4750
Wire Wire Line
	6800 4750 6800 4650
Wire Wire Line
	6800 4750 6700 4750
Wire Wire Line
	13900 5650 13650 5650
Wire Wire Line
	13900 5350 13650 5350
Wire Wire Line
	13650 5050 13900 5050
Wire Wire Line
	11350 2000 11200 2000
Wire Wire Line
	12500 2300 12150 2300
Wire Wire Line
	3000 2850 2600 2850
Wire Wire Line
	6900 2850 6500 2850
Wire Wire Line
	11250 6850 12050 6850
Wire Wire Line
	11250 8550 11750 8550
Wire Wire Line
	11250 8350 11750 8350
Wire Wire Line
	11250 8150 11750 8150
Wire Wire Line
	11250 7750 11750 7750
Wire Wire Line
	11250 7550 11750 7550
Wire Wire Line
	11250 7950 11750 7950
Wire Wire Line
	11250 7350 11750 7350
Wire Wire Line
	11250 6950 11750 6950
Wire Wire Line
	11250 6750 11750 6750
Wire Wire Line
	11250 7150 11750 7150
Wire Wire Line
	8350 8450 9100 8450
Wire Wire Line
	8350 8250 9100 8250
Wire Wire Line
	8350 8050 9100 8050
Wire Wire Line
	8350 7650 9100 7650
Wire Wire Line
	8350 7450 9100 7450
Wire Wire Line
	8350 7850 9100 7850
Wire Wire Line
	8350 7250 9100 7250
Wire Wire Line
	8350 6850 9100 6850
Wire Wire Line
	8350 6650 9100 6650
Wire Wire Line
	8350 7050 9100 7050
Wire Wire Line
	8350 6750 8800 6750
Wire Wire Line
	8350 6950 8800 6950
Wire Wire Line
	8350 8350 8800 8350
Wire Wire Line
	8350 7950 8800 7950
Wire Wire Line
	8350 8150 8800 8150
Wire Wire Line
	8350 8550 8800 8550
Wire Wire Line
	8350 7550 8800 7550
Wire Wire Line
	8350 7150 8800 7150
Wire Wire Line
	12050 7650 11250 7650
Wire Wire Line
	12050 7450 11250 7450
Wire Wire Line
	12050 7250 11250 7250
Wire Wire Line
	12050 7050 11250 7050
Wire Wire Line
	11250 7850 12050 7850
Wire Wire Line
	11250 8050 12050 8050
Wire Wire Line
	12050 8250 11250 8250
Wire Wire Line
	11250 8450 12050 8450
Wire Wire Line
	8350 7350 8800 7350
Wire Wire Line
	8350 7750 8800 7750
Connection ~ 3200 6250
Wire Wire Line
	3200 6250 3700 6250
Connection ~ 3200 6650
Wire Wire Line
	3200 6650 3700 6650
Connection ~ 3200 7050
Wire Wire Line
	3200 7050 3700 7050
Connection ~ 3200 7500
Wire Wire Line
	3200 6050 3200 9450
Wire Wire Line
	3200 7450 3700 7450
Connection ~ 3200 7850
Wire Wire Line
	3200 7850 3700 7850
Connection ~ 3200 8250
Wire Wire Line
	3200 8250 3700 8250
Connection ~ 3200 8650
Wire Wire Line
	3200 8650 3700 8650
Connection ~ 3200 9050
Wire Wire Line
	3200 9050 3700 9050
Connection ~ 3200 8950
Wire Wire Line
	3200 8950 3350 8950
Connection ~ 3200 8550
Wire Wire Line
	3200 8550 3350 8550
Connection ~ 3200 8150
Wire Wire Line
	3200 8150 3350 8150
Connection ~ 3200 7750
Wire Wire Line
	3200 7750 3350 7750
Connection ~ 3200 7350
Wire Wire Line
	3200 7350 3350 7350
Connection ~ 3200 6950
Wire Wire Line
	3350 6950 3200 6950
Connection ~ 3200 6550
Wire Wire Line
	3200 6550 3350 6550
Connection ~ 3200 6150
Wire Wire Line
	3200 6150 3350 6150
Wire Wire Line
	3750 9150 4500 9150
Wire Wire Line
	3750 8750 4500 8750
Wire Wire Line
	3750 8350 4500 8350
Wire Wire Line
	3750 7950 4500 7950
Wire Wire Line
	3750 7550 4500 7550
Wire Wire Line
	3750 7150 4500 7150
Wire Wire Line
	3750 6750 4500 6750
Wire Wire Line
	3750 6350 4500 6350
Wire Wire Line
	4100 9050 4200 9050
Wire Wire Line
	4200 8850 4100 8850
Wire Wire Line
	4100 8650 4200 8650
Wire Wire Line
	4100 8450 4200 8450
Wire Wire Line
	4200 7650 4100 7650
Wire Wire Line
	4200 7850 4100 7850
Wire Wire Line
	4200 8050 4100 8050
Wire Wire Line
	4200 8250 4100 8250
Wire Wire Line
	4100 6850 4200 6850
Wire Wire Line
	4100 7050 4200 7050
Wire Wire Line
	4200 7250 4100 7250
Wire Wire Line
	4100 7450 4200 7450
Wire Wire Line
	4200 6650 4100 6650
Wire Wire Line
	4200 6450 4100 6450
Wire Wire Line
	4200 6250 4100 6250
Wire Wire Line
	4200 6050 4100 6050
Wire Wire Line
	4950 4550 4800 4550
Wire Wire Line
	8700 4550 8850 4550
Wire Wire Line
	3000 4450 2600 4450
Wire Wire Line
	3000 4250 2600 4250
Wire Wire Line
	2600 4050 3000 4050
Wire Wire Line
	2600 3850 3000 3850
Wire Wire Line
	4950 4350 4800 4350
Wire Wire Line
	4950 4150 4800 4150
Wire Wire Line
	4950 3950 4800 3950
Wire Wire Line
	4800 4650 4900 4650
Connection ~ 2500 3650
Wire Wire Line
	2500 3350 2500 3750
Wire Wire Line
	2500 3750 3000 3750
Wire Wire Line
	4800 3550 5150 3550
Wire Wire Line
	4800 3350 5150 3350
Wire Wire Line
	3000 3550 2900 3550
Wire Wire Line
	2900 3550 2900 3450
Wire Wire Line
	2900 3450 3000 3450
Wire Wire Line
	2750 3250 3000 3250
Wire Wire Line
	5450 3150 4800 3150
Wire Wire Line
	2900 4650 2900 4750
Wire Wire Line
	4900 4650 4900 4750
Wire Wire Line
	2300 3350 3000 3350
Wire Wire Line
	4800 3750 4850 3750
Wire Wire Line
	5300 3050 4800 3050
Wire Wire Line
	3000 3050 2300 3050
Wire Wire Line
	2300 3050 2300 3450
Connection ~ 2300 3350
Wire Wire Line
	4850 3450 4800 3450
Wire Wire Line
	3000 3650 2500 3650
Connection ~ 2500 3350
Wire Wire Line
	2900 4650 3000 4650
Wire Wire Line
	5200 3850 4800 3850
Wire Wire Line
	5200 4050 4800 4050
Wire Wire Line
	5200 4250 4800 4250
Wire Wire Line
	5200 4450 4800 4450
Wire Wire Line
	3000 3950 2900 3950
Wire Wire Line
	2900 4150 3000 4150
Wire Wire Line
	3000 4350 2900 4350
Wire Wire Line
	3000 4550 2900 4550
Wire Wire Line
	4800 2950 4900 2950
Wire Wire Line
	2850 2950 3000 2950
Wire Wire Line
	6750 2950 6900 2950
Wire Wire Line
	8700 2950 8800 2950
Wire Wire Line
	6900 4550 6800 4550
Wire Wire Line
	6900 4350 6800 4350
Wire Wire Line
	6800 4150 6900 4150
Wire Wire Line
	6900 3950 6800 3950
Wire Wire Line
	9150 4450 8700 4450
Wire Wire Line
	9150 4250 8700 4250
Wire Wire Line
	9150 4050 8700 4050
Wire Wire Line
	9150 3850 8700 3850
Wire Wire Line
	6800 4650 6900 4650
Connection ~ 6400 3350
Wire Wire Line
	6900 3650 6400 3650
Connection ~ 6200 3350
Wire Wire Line
	6200 3050 6200 3450
Wire Wire Line
	6200 3050 6900 3050
Wire Wire Line
	9200 3050 8700 3050
Wire Wire Line
	8700 3750 8800 3750
Wire Wire Line
	6200 3350 6900 3350
Wire Wire Line
	8800 4650 8800 4750
Wire Wire Line
	6650 3250 6900 3250
Wire Wire Line
	6400 3750 6900 3750
Wire Wire Line
	6400 3350 6400 3750
Connection ~ 6400 3650
Wire Wire Line
	8800 4650 8700 4650
Wire Wire Line
	8850 3950 8700 3950
Wire Wire Line
	8850 4150 8700 4150
Wire Wire Line
	8850 4350 8700 4350
Wire Wire Line
	6500 3850 6900 3850
Wire Wire Line
	6500 4050 6900 4050
Wire Wire Line
	6900 4250 6500 4250
Wire Wire Line
	6900 4450 6500 4450
Wire Wire Line
	8750 3450 8700 3450
Wire Wire Line
	8700 3250 8750 3250
Wire Wire Line
	8700 3350 9050 3350
Wire Wire Line
	8700 3550 9050 3550
Wire Wire Line
	3750 6150 4500 6150
Wire Wire Line
	3750 6550 4500 6550
Wire Wire Line
	3750 6950 4500 6950
Wire Wire Line
	3750 7350 4500 7350
Wire Wire Line
	3750 7750 4500 7750
Wire Wire Line
	3750 8150 4500 8150
Wire Wire Line
	3750 8550 4500 8550
Wire Wire Line
	3750 8950 4500 8950
Wire Wire Line
	3700 6050 3200 6050
Wire Wire Line
	3200 6350 3350 6350
Connection ~ 3200 6350
Wire Wire Line
	3200 6750 3350 6750
Connection ~ 3200 6750
Wire Wire Line
	3200 7150 3350 7150
Connection ~ 3200 7150
Wire Wire Line
	3200 7550 3350 7550
Connection ~ 3200 7550
Wire Wire Line
	3200 7950 3350 7950
Connection ~ 3200 7950
Wire Wire Line
	3200 8350 3350 8350
Connection ~ 3200 8350
Wire Wire Line
	3200 8750 3350 8750
Connection ~ 3200 8750
Wire Wire Line
	3350 9150 3200 9150
Connection ~ 3200 9150
Wire Wire Line
	3200 8850 3700 8850
Connection ~ 3200 8850
Wire Wire Line
	3200 8450 3700 8450
Connection ~ 3200 8450
Wire Wire Line
	3200 8050 3700 8050
Connection ~ 3200 8050
Wire Wire Line
	3200 7650 3700 7650
Connection ~ 3200 7650
Wire Wire Line
	3200 7250 3700 7250
Connection ~ 3200 7250
Wire Wire Line
	3200 6850 3700 6850
Connection ~ 3200 6850
Wire Wire Line
	3200 6450 3700 6450
Connection ~ 3200 6450
Wire Wire Line
	12050 6650 11250 6650
Wire Wire Line
	9100 2850 8700 2850
Wire Wire Line
	4800 2850 5150 2850
Wire Wire Line
	12150 2200 12250 2200
Wire Wire Line
	11350 2200 11200 2200
Wire Wire Line
	11350 2100 10900 2100
Wire Wire Line
	13650 5200 13900 5200
Wire Wire Line
	13650 5500 13900 5500
Wire Wire Line
	11200 1500 11350 1500
Wire Wire Line
	8800 4750 8900 4750
Wire Wire Line
	2900 4750 2800 4750
Wire Wire Line
	2300 3450 2200 3450
Wire Wire Line
	5450 3250 5550 3250
Connection ~ 5450 3250
Connection ~ 9350 3250
Wire Wire Line
	9350 3250 9450 3250
Wire Wire Line
	8700 3150 9350 3150
Wire Wire Line
	9350 3650 8700 3650
Wire Wire Line
	9350 3150 9350 3650
Wire Wire Line
	3200 9450 3350 9450
Wire Wire Line
	4900 3250 4800 3250
Wire Wire Line
	12150 1700 12350 1700
Wire Wire Line
	11200 2350 11250 2350
Wire Wire Line
	11250 2350 11250 2300
Wire Wire Line
	11250 2300 11350 2300
Wire Wire Line
	8350 8650 9100 8650
Wire Wire Line
	13950 3900 13800 3900
Wire Wire Line
	13950 4100 13800 4100
Wire Wire Line
	13950 4000 13500 4000
Wire Wire Line
	13750 4300 13950 4300
Wire Wire Line
	13950 4200 13500 4200
Wire Wire Line
	13950 3600 13500 3600
Wire Wire Line
	13800 3700 13950 3700
Wire Wire Line
	13950 3800 13500 3800
Wire Wire Line
	12150 1100 12350 1100
Wire Wire Line
	14700 2150 14700 1950
Wire Wire Line
	14700 1450 14700 1550
Wire Wire Line
	14250 1450 15000 1450
Wire Wire Line
	13850 1750 13850 2000
Connection ~ 13850 1850
Wire Wire Line
	14550 1450 14550 1850
Wire Wire Line
	14550 1850 14450 1850
Connection ~ 14550 1450
Wire Wire Line
	13850 1850 13950 1850
Wire Wire Line
	13350 1450 13450 1450
Connection ~ 14700 1450
Wire Wire Line
	13450 1450 13450 1650
Wire Wire Line
	13450 2050 13450 2250
Connection ~ 13450 2150
Wire Wire Line
	13600 2150 13450 2150
Wire Wire Line
	10100 4600 10200 4600
Wire Wire Line
	10700 4600 10800 4600
Wire Wire Line
	11300 4100 11300 4200
Wire Wire Line
	11800 4600 12350 4600
Wire Wire Line
	12000 4600 12000 4700
Text GLabel 12250 3700 2    60   Input ~ 0
2.5V
Wire Wire Line
	12000 3700 12250 3700
Text GLabel 6600 3100 0    49   Input ~ 0
REFP
Wire Wire Line
	6600 3100 6750 3100
Wire Wire Line
	6750 3100 6750 3150
Wire Wire Line
	6750 3150 6900 3150
Text GLabel 2700 3100 0    49   Input ~ 0
REFP
Wire Wire Line
	2700 3100 2850 3100
Wire Wire Line
	2850 3100 2850 3150
Wire Wire Line
	2850 3150 3000 3150
Text GLabel 12000 3700 0    60   Input ~ 0
REFP
Text GLabel 12000 3450 0    60   Input ~ 0
AREF
Text GLabel 12250 3450 2    60   Input ~ 0
5V
Wire Wire Line
	12000 3450 12250 3450
Text Notes 11700 4150 0    60   ~ 0
bypass cap here?  2.5 to ground
Wire Wire Line
	10800 4200 12350 4200
Wire Wire Line
	10800 4600 10800 4200
Text Notes 10500 4100 0    60   ~ 0
Added re Dan
$Comp
L C C?
U 1 1 53449C6F
P 12350 4400
F 0 "C?" H 12350 4500 40  0000 L CNN
F 1 "C" H 12356 4315 40  0000 L CNN
F 2 "~" H 12388 4250 30  0000 C CNN
F 3 "~" H 12350 4400 60  0000 C CNN
	1    12350 4400
	1    0    0    -1  
$EndComp
Connection ~ 11300 4200
Connection ~ 12000 4600
Text Notes 11850 4900 0    60   ~ 0
could leave cap empty
Text Notes 6400 5600 0    60   ~ 0
More general purpose:  jumper for + and - REFS
Text Notes 13650 2850 0    60   ~ 0
Bypass Caps for power\n
Text Notes 9700 4850 0    60   ~ 0
Change to 3.3?\nMight be ok - then allows \nchange of 5V input
$EndSCHEMATC
