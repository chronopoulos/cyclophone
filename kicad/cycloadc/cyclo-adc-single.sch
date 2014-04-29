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
LIBS:cyclo-adc-single-cache
EELAYER 24 0
EELAYER END
$Descr User 17000 11000
encoding utf-8
Sheet 1 1
Title ""
Date "13 apr 2014"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 8700 7300 2    60   Input ~ 0
GND
$Comp
L ADCLEFTPINS Left1
U 1 1 53274A2C
P 7800 6000
F 0 "Left1" H 7750 4500 60  0000 C CNN
F 1 "ADCPINS" H 7800 7000 60  0000 C CNN
F 2 "" H 7800 6000 60  0001 C CNN
F 3 "" H 7800 6000 60  0001 C CNN
	1    7800 6000
	-1   0    0    -1  
$EndComp
Text GLabel 8700 5500 2    60   Input ~ 0
DIO3
Text GLabel 9000 5400 2    60   Input ~ 0
DIO2
Text GLabel 9000 5200 2    60   Input ~ 0
DIO0
Text GLabel 8700 5300 2    60   Input ~ 0
DIO1
Text GLabel 9000 6400 2    60   Input ~ 0
CH8
Text GLabel 8700 6500 2    60   Input ~ 0
CH9
Text GLabel 9000 6600 2    60   Input ~ 0
CH10
Text GLabel 8700 6700 2    60   Input ~ 0
CH11
Text GLabel 9000 6800 2    60   Input ~ 0
CH12
Text GLabel 8700 6900 2    60   Input ~ 0
CH13
Text GLabel 9000 7000 2    60   Input ~ 0
CH14
Text GLabel 8700 7100 2    60   Input ~ 0
CH15
Text GLabel 9000 5600 2    60   Input ~ 0
CH0
Text GLabel 8700 5700 2    60   Input ~ 0
CH1
Text GLabel 9000 5800 2    60   Input ~ 0
CH2
Text GLabel 8700 5900 2    60   Input ~ 0
CH3
Text GLabel 9000 6000 2    60   Input ~ 0
CH4
Text GLabel 8700 6100 2    60   Input ~ 0
CH5
Text GLabel 9000 6200 2    60   Input ~ 0
CH6
Text GLabel 8700 6300 2    60   Input ~ 0
CH7
Text GLabel 9000 7200 2    60   Input ~ 0
+AREF
Text GLabel 9750 2950 2    60   Input ~ 0
3.3V
Text GLabel 10000 3150 2    60   Input ~ 0
GND
Text GLabel 6650 3350 0    60   Input ~ 0
GND
Text GLabel 9500 4650 2    60   Input ~ 0
GND
Text GLabel 7250 4650 0    60   Input ~ 0
GND
Text GLabel 13900 5500 2    60   Input ~ 0
CS0
Text GLabel 13900 5350 2    60   Input ~ 0
SCLK
Text GLabel 13900 5200 2    60   Input ~ 0
SDI
Text GLabel 13900 5050 2    60   Input ~ 0
SDO
Text GLabel 13650 5500 0    60   Input ~ 0
CE0
Text GLabel 13650 5050 0    60   Input ~ 0
MOSI
Text GLabel 13650 5200 0    60   Input ~ 0
MISO
Text GLabel 13650 5350 0    60   Input ~ 0
SCLK
Text GLabel 7300 2850 0    60   Input ~ 0
DIO3
Text GLabel 7050 2750 0    60   Input ~ 0
DIO2
Text GLabel 9350 2850 2    60   Input ~ 0
DIO0
Text GLabel 9600 2750 2    60   Input ~ 0
DIO1
Text GLabel 8700 6300 2    60   Input ~ 0
CH7
Text GLabel 9000 6200 2    60   Input ~ 0
CH6
Text GLabel 8700 6100 2    60   Input ~ 0
CH5
Text GLabel 9000 6000 2    60   Input ~ 0
CH4
Text GLabel 8700 5900 2    60   Input ~ 0
CH3
Text GLabel 9000 5800 2    60   Input ~ 0
CH2
Text GLabel 8700 5700 2    60   Input ~ 0
CH1
Text GLabel 9000 5600 2    60   Input ~ 0
CH0
Text GLabel 8700 7100 2    60   Input ~ 0
CH15
Text GLabel 9000 7000 2    60   Input ~ 0
CH14
Text GLabel 8700 6900 2    60   Input ~ 0
CH13
Text GLabel 9000 6800 2    60   Input ~ 0
CH12
Text GLabel 8700 6700 2    60   Input ~ 0
CH11
Text GLabel 9000 6600 2    60   Input ~ 0
CH10
Text GLabel 8700 6500 2    60   Input ~ 0
CH9
Text GLabel 9000 6400 2    60   Input ~ 0
CH8
$Comp
L ADS7957 ADS-0
U 1 1 5313C810
P 8350 3800
F 0 "ADS-0" H 8050 5000 60  0000 C CNN
F 1 "ADS7957" H 8350 3900 60  0000 C CNN
F 2 "" H 8350 3800 60  0001 C CNN
F 3 "" H 8350 3800 60  0001 C CNN
	1    8350 3800
	1    0    0    -1  
$EndComp
Text GLabel 8700 5300 2    60   Input ~ 0
DIO1
Text GLabel 9000 5200 2    60   Input ~ 0
DIO0
Text GLabel 9000 5400 2    60   Input ~ 0
DIO2
Text GLabel 8700 5500 2    60   Input ~ 0
DIO3
Text GLabel 7050 3750 0    60   Input ~ 0
CH15
Text GLabel 7350 3850 0    60   Input ~ 0
CH14
Text GLabel 7050 3950 0    60   Input ~ 0
CH13
Text GLabel 7350 4050 0    60   Input ~ 0
CH12
Text GLabel 7050 4150 0    60   Input ~ 0
CH11
Text GLabel 7350 4250 0    60   Input ~ 0
CH10
Text GLabel 7050 4350 0    60   Input ~ 0
CH9
Text GLabel 7350 4450 0    60   Input ~ 0
CH8
Text GLabel 9400 4450 2    60   Input ~ 0
CH7
Text GLabel 9650 4350 2    60   Input ~ 0
CH6
Text GLabel 9400 4250 2    60   Input ~ 0
CH5
Text GLabel 9650 4150 2    60   Input ~ 0
CH4
Text GLabel 9400 4050 2    60   Input ~ 0
CH3
Text GLabel 9650 3950 2    60   Input ~ 0
CH2
Text GLabel 9400 3850 2    60   Input ~ 0
CH1
Text GLabel 9650 3750 2    60   Input ~ 0
CH0
Text GLabel 9600 3450 2    60   Input ~ 0
CS0
Text GLabel 9300 3350 2    60   Input ~ 0
SCLK
Text GLabel 9600 3250 2    60   Input ~ 0
SDI
Text GLabel 9350 3150 2    60   Input ~ 0
SDO
Text GLabel 9300 3650 2    60   Input ~ 0
+AREF
Text GLabel 13950 3750 0    60   Input ~ 0
3.3V
Text GLabel 13650 3850 0    60   Input ~ 0
GND
Text GLabel 13950 4150 0    60   Input ~ 0
SCLK
Text GLabel 13650 4050 0    60   Input ~ 0
MISO
Text GLabel 13950 3950 0    60   Input ~ 0
MOSI
Text GLabel 13650 4250 0    60   Input ~ 0
CE0
Text GLabel 13650 3650 0    60   Input ~ 0
5V
Text Notes 13400 4700 0    60   ~ 0
Different names for\nthe same things.
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
L GND #PWR01
U 1 1 534472D8
P 12000 4700
F 0 "#PWR01" H 12000 4700 30  0001 C CNN
F 1 "GND" H 12000 4630 30  0001 C CNN
F 2 "" H 12000 4700 60  0000 C CNN
F 3 "" H 12000 4700 60  0000 C CNN
	1    12000 4700
	1    0    0    -1  
$EndComp
Wire Wire Line
	8700 7300 8250 7300
Wire Wire Line
	9900 3050 9900 3550
Wire Wire Line
	9900 3550 9250 3550
Wire Wire Line
	9500 4650 9350 4650
Wire Wire Line
	13900 5350 13650 5350
Wire Wire Line
	13650 5050 13900 5050
Wire Wire Line
	7450 2750 7050 2750
Wire Wire Line
	8250 7000 9000 7000
Wire Wire Line
	8250 6800 9000 6800
Wire Wire Line
	8250 6600 9000 6600
Wire Wire Line
	8250 6200 9000 6200
Wire Wire Line
	8250 6000 9000 6000
Wire Wire Line
	8250 6400 9000 6400
Wire Wire Line
	8250 5800 9000 5800
Wire Wire Line
	8250 5400 9000 5400
Wire Wire Line
	8250 5200 9000 5200
Wire Wire Line
	8250 5600 9000 5600
Wire Wire Line
	8250 5300 8700 5300
Wire Wire Line
	8250 5500 8700 5500
Wire Wire Line
	8250 6900 8700 6900
Wire Wire Line
	8250 6500 8700 6500
Wire Wire Line
	8250 6700 8700 6700
Wire Wire Line
	8250 7100 8700 7100
Wire Wire Line
	8250 6100 8700 6100
Wire Wire Line
	8250 5700 8700 5700
Wire Wire Line
	8250 5900 8700 5900
Wire Wire Line
	8250 6300 8700 6300
Wire Wire Line
	9400 4450 9250 4450
Wire Wire Line
	7450 4350 7050 4350
Wire Wire Line
	7450 4150 7050 4150
Wire Wire Line
	7050 3950 7450 3950
Wire Wire Line
	7050 3750 7450 3750
Wire Wire Line
	9400 4250 9250 4250
Wire Wire Line
	9400 4050 9250 4050
Wire Wire Line
	9400 3850 9250 3850
Wire Wire Line
	9250 4550 9350 4550
Connection ~ 6950 3550
Wire Wire Line
	6950 3250 6950 3650
Wire Wire Line
	6950 3650 7450 3650
Wire Wire Line
	9250 3450 9600 3450
Wire Wire Line
	9250 3250 9600 3250
Wire Wire Line
	7450 3450 7350 3450
Wire Wire Line
	7350 3450 7350 3350
Wire Wire Line
	7350 3350 7450 3350
Wire Wire Line
	9900 3050 9250 3050
Wire Wire Line
	7350 4550 7350 4650
Wire Wire Line
	9350 4550 9350 4650
Wire Wire Line
	6750 3250 7450 3250
Wire Wire Line
	9250 3650 9300 3650
Wire Wire Line
	9750 2950 9250 2950
Wire Wire Line
	7450 2950 6750 2950
Wire Wire Line
	6750 2950 6750 3350
Connection ~ 6750 3250
Wire Wire Line
	9300 3350 9250 3350
Wire Wire Line
	7450 3550 6950 3550
Connection ~ 6950 3250
Wire Wire Line
	7350 4550 7450 4550
Wire Wire Line
	9650 3750 9250 3750
Wire Wire Line
	9650 3950 9250 3950
Wire Wire Line
	9650 4150 9250 4150
Wire Wire Line
	9650 4350 9250 4350
Wire Wire Line
	7450 3850 7350 3850
Wire Wire Line
	7350 4050 7450 4050
Wire Wire Line
	7450 4250 7350 4250
Wire Wire Line
	7450 4450 7350 4450
Wire Wire Line
	9250 2850 9350 2850
Wire Wire Line
	7300 2850 7450 2850
Wire Wire Line
	9250 2750 9600 2750
Wire Wire Line
	13650 5200 13900 5200
Wire Wire Line
	13650 5500 13900 5500
Wire Wire Line
	7350 4650 7250 4650
Wire Wire Line
	6750 3350 6650 3350
Wire Wire Line
	9900 3150 10000 3150
Connection ~ 9900 3150
Wire Wire Line
	9350 3150 9250 3150
Wire Wire Line
	8250 7200 9000 7200
Wire Wire Line
	14100 3950 13950 3950
Wire Wire Line
	14100 4150 13950 4150
Wire Wire Line
	14100 4050 13650 4050
Wire Wire Line
	14100 4250 13650 4250
Wire Wire Line
	14100 3850 13650 3850
Wire Wire Line
	13950 3750 14100 3750
Wire Wire Line
	14100 3650 13650 3650
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
Text GLabel 11450 3550 2    60   Input ~ 0
2.5V
Wire Wire Line
	11200 3550 11450 3550
Text GLabel 11200 3550 0    60   Input ~ 0
REFP
Text Notes 11700 4150 0    60   ~ 0
bypass cap here?  2.5 to ground
Wire Wire Line
	10800 4200 12350 4200
Wire Wire Line
	10800 4600 10800 4200
Text Notes 10500 4100 0    60   ~ 0
Added re Dan
$Comp
L C C1
U 1 1 53449C6F
P 12350 4400
F 0 "C1" H 12350 4500 40  0000 L CNN
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
Text Notes 12850 2800 0    60   ~ 0
More general purpose:  jumper for + and - REFS\n- AGND and +VA, but not REFP and REFM?\n
Text GLabel 13850 3550 0    60   Input ~ 0
5V
Wire Wire Line
	14100 3550 13850 3550
Text GLabel 13650 3450 0    60   Input ~ 0
+AREF
Wire Wire Line
	13650 3450 14100 3450
Text Notes 13200 3250 0    60   ~ 0
normally jumper pins 1 and 2 for 0 to 5v range.
Text GLabel 7200 3150 0    49   Input ~ 0
+AREF
Wire Wire Line
	7200 3150 7450 3150
Text GLabel 7150 3050 0    49   Input ~ 0
REFP
Wire Wire Line
	7150 3050 7450 3050
$Comp
L CONN_9 P1
U 1 1 535DD5C4
P 14450 3850
F 0 "P1" V 14400 3850 60  0000 C CNN
F 1 "CONN_9" V 14500 3850 60  0000 C CNN
F 2 "" H 14450 3850 60  0000 C CNN
F 3 "" H 14450 3850 60  0000 C CNN
	1    14450 3850
	1    0    0    -1  
$EndComp
$EndSCHEMATC
