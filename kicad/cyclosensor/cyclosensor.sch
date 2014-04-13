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
LIBS:cyclophone
LIBS:cyclosensor-cache
EELAYER 27 0
EELAYER END
$Descr A4 11693 8268
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
$Comp
L RJ14 J1
U 1 1 532FB492
P 4800 2950
F 0 "J1" H 5000 3450 60  0000 C CNN
F 1 "RJ14" H 4650 3450 60  0000 C CNN
F 2 "~" H 4800 2950 60  0000 C CNN
F 3 "~" H 4800 2950 60  0000 C CNN
	1    4800 2950
	1    0    0    -1  
$EndComp
$Comp
L TCRT5000 U1
U 1 1 532FB498
P 4850 5500
F 0 "U1" H 4850 4950 60  0000 C CNN
F 1 "TCRT5000" H 4850 5950 60  0000 C CNN
F 2 "" H 4850 5500 60  0000 C CNN
F 3 "" H 4850 5500 60  0000 C CNN
	1    4850 5500
	-1   0    0    1   
$EndComp
Text Notes 3600 1900 0    60   ~ 0
To do:\n1) verify correct sensor pins\n2) verify potentiometer location.\n3) verify potentiometer function with disconnected pin.
Text GLabel 4650 3650 3    60   Input ~ 0
5V
Text GLabel 4800 3650 3    60   Input ~ 0
ADC
$Comp
L GND #PWR?
U 1 1 534162D0
P 4950 3650
F 0 "#PWR?" H 4950 3650 30  0001 C CNN
F 1 "GND" H 4950 3580 30  0001 C CNN
F 2 "" H 4950 3650 60  0000 C CNN
F 3 "" H 4950 3650 60  0000 C CNN
	1    4950 3650
	1    0    0    -1  
$EndComp
Text GLabel 6050 5550 2    60   Input ~ 0
5V
Text GLabel 5700 5300 2    60   Input ~ 0
ADC
$Comp
L R R?
U 1 1 534163EA
P 5700 5550
F 0 "R?" V 5780 5550 40  0000 C CNN
F 1 "220" V 5707 5551 40  0000 C CNN
F 2 "~" V 5630 5550 30  0000 C CNN
F 3 "~" H 5700 5550 30  0000 C CNN
	1    5700 5550
	0    1    1    0   
$EndComp
Wire Wire Line
	4700 3400 4700 3550
Wire Wire Line
	4700 3550 4650 3550
Wire Wire Line
	4650 3550 4650 3650
Wire Wire Line
	4800 3400 4800 3650
Wire Wire Line
	4900 3400 4900 3550
Wire Wire Line
	4900 3550 4950 3550
Wire Wire Line
	4950 3550 4950 3650
Wire Wire Line
	5450 5550 5350 5550
Wire Wire Line
	6050 5550 5950 5550
$Comp
L POT 30K
U 1 1 5341646B
P 4850 4600
F 0 "30K" H 4850 4500 50  0000 C CNN
F 1 "POT" H 4850 4600 50  0000 C CNN
F 2 "~" H 4850 4600 60  0000 C CNN
F 3 "~" H 4850 4600 60  0000 C CNN
	1    4850 4600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 53416487
P 3650 4700
F 0 "#PWR?" H 3650 4700 30  0001 C CNN
F 1 "GND" H 3650 4630 30  0001 C CNN
F 2 "" H 3650 4700 60  0000 C CNN
F 3 "" H 3650 4700 60  0000 C CNN
	1    3650 4700
	1    0    0    -1  
$EndComp
Wire Wire Line
	4850 4450 5500 4450
Wire Wire Line
	5500 4450 5500 5300
Wire Wire Line
	5350 5300 5700 5300
Connection ~ 5500 5300
Wire Wire Line
	3650 4700 3650 4600
Wire Wire Line
	3650 4600 4600 4600
NoConn ~ 5100 4600
NoConn ~ 4600 3400
NoConn ~ 5000 3400
NoConn ~ 5100 3400
Text Notes 4400 4300 0    60   ~ 0
coll/emitter +/-??
Wire Wire Line
	4200 4600 4200 5450
Wire Wire Line
	4200 5200 4350 5200
Connection ~ 4200 4600
Wire Wire Line
	4200 5450 4350 5450
Connection ~ 4200 5200
$EndSCHEMATC
