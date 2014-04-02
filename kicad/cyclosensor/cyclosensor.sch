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
Date "2 apr 2014"
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
P 4800 3150
F 0 "J1" H 5000 3650 60  0000 C CNN
F 1 "RJ14" H 4650 3650 60  0000 C CNN
F 2 "~" H 4800 3150 60  0000 C CNN
F 3 "~" H 4800 3150 60  0000 C CNN
	1    4800 3150
	1    0    0    -1  
$EndComp
$Comp
L TCRT5000 U1
U 1 1 532FB498
P 4850 4950
F 0 "U1" H 4850 4400 60  0000 C CNN
F 1 "TCRT5000" H 4850 5400 60  0000 C CNN
F 2 "" H 4850 4950 60  0000 C CNN
F 3 "" H 4850 4950 60  0000 C CNN
	1    4850 4950
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 5150 5350 5400
Wire Wire Line
	5350 5400 4150 5400
Wire Wire Line
	4150 5400 4150 3750
Wire Wire Line
	4150 3750 4700 3750
Wire Wire Line
	4700 3750 4700 3600
Wire Wire Line
	4350 4800 4350 3950
Wire Wire Line
	3300 3250 3300 3700
Wire Wire Line
	3400 3250 3400 3750
Wire Wire Line
	5350 3950 5350 4900
Wire Wire Line
	4350 5050 4350 5650
Wire Wire Line
	4350 5650 5600 5650
Wire Wire Line
	5600 5650 5600 3750
Wire Wire Line
	5600 3750 5000 3750
Wire Wire Line
	5000 3750 5000 3600
Text Notes 5000 2150 0    60   ~ 0
To do:\n1) verify correct sensor pins\n2) verify potentiometer location.\n3) verify potentiometer function with disconnected pin.
$Comp
L POT RV1
U 1 1 5330B579
P 3400 3900
F 0 "RV1" H 3400 3800 50  0000 C CNN
F 1 "POT" H 3400 3900 50  0000 C CNN
F 2 "" H 3400 3900 60  0000 C CNN
F 3 "" H 3400 3900 60  0000 C CNN
	1    3400 3900
	1    0    0    -1  
$EndComp
NoConn ~ 3650 3900
Wire Wire Line
	3300 3700 3150 3700
Wire Wire Line
	3150 3700 3150 3900
$Comp
L RJ14 J2
U 1 1 5338F808
P 7600 3200
F 0 "J2" H 7800 3700 60  0000 C CNN
F 1 "RJ14" H 7450 3700 60  0000 C CNN
F 2 "~" H 7600 3200 60  0000 C CNN
F 3 "~" H 7600 3200 60  0000 C CNN
	1    7600 3200
	1    0    0    -1  
$EndComp
$Comp
L TCRT5000 U2
U 1 1 5338F80E
P 7650 5000
F 0 "U2" H 7650 4450 60  0000 C CNN
F 1 "TCRT5000" H 7650 5450 60  0000 C CNN
F 2 "" H 7650 5000 60  0000 C CNN
F 3 "" H 7650 5000 60  0000 C CNN
	1    7650 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	8150 5200 8150 5450
Wire Wire Line
	8150 5450 6950 5450
Wire Wire Line
	6950 5450 6950 3800
Wire Wire Line
	6950 3800 7500 3800
Wire Wire Line
	7500 3800 7500 3650
Wire Wire Line
	7150 4850 7150 4000
Wire Wire Line
	8150 4000 8150 4950
Wire Wire Line
	7150 5100 7150 5700
Wire Wire Line
	7150 5700 8400 5700
Wire Wire Line
	8400 5700 8400 3800
Wire Wire Line
	8400 3800 7800 3800
Wire Wire Line
	7800 3800 7800 3650
Wire Wire Line
	4800 3600 4800 3950
Wire Wire Line
	4800 3950 4350 3950
Wire Wire Line
	4900 3600 4900 3950
Wire Wire Line
	4900 3950 5350 3950
Wire Wire Line
	7700 3650 7700 4000
Wire Wire Line
	7700 4000 8150 4000
Wire Wire Line
	7150 4000 7600 4000
Wire Wire Line
	7600 4000 7600 3650
$EndSCHEMATC
