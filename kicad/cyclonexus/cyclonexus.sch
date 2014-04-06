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
LIBS:cyclonexus-cache
EELAYER 27 0
EELAYER END
$Descr USLedger 17000 11000
encoding utf-8
Sheet 1 1
Title ""
Date "6 apr 2014"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L ADCLEFTPINS U1
U 1 1 5327640A
P 6250 6000
F 0 "U1" H 6200 4500 60  0000 C CNN
F 1 "ADCLEFTPINS" H 6250 7000 60  0000 C CNN
F 2 "" H 6250 6000 60  0001 C CNN
F 3 "" H 6250 6000 60  0001 C CNN
	1    6250 6000
	0    1    1    0   
$EndComp
$Comp
L RJ14 J1
U 1 1 532FA6C6
P 3350 3250
F 0 "J1" H 3550 3750 60  0000 C CNN
F 1 "RJ14" H 3200 3750 60  0000 C CNN
F 2 "" H 3350 3250 60  0000 C CNN
F 3 "" H 3350 3250 60  0000 C CNN
	1    3350 3250
	1    0    0    -1  
$EndComp
$Comp
L USB_1 J17
U 1 1 532FA7D3
P 11200 5600
F 0 "J17" H 11050 6000 60  0000 C CNN
F 1 "USB_1" H 11175 5000 60  0001 C CNN
F 2 "" H 11200 5600 60  0000 C CNN
F 3 "" H 11200 5600 60  0000 C CNN
	1    11200 5600
	1    0    0    -1  
$EndComp
Text GLabel 3300 4000 3    60   Input ~ 0
A0
Text GLabel 3150 3900 3    60   Input ~ 0
+5V
Text GLabel 3450 4000 3    60   Input ~ 0
GND
NoConn ~ 3650 3700
NoConn ~ 3150 3700
$Comp
L RJ14 J2
U 1 1 532FAA82
P 4050 3250
F 0 "J2" H 4250 3750 60  0000 C CNN
F 1 "RJ14" H 3900 3750 60  0000 C CNN
F 2 "" H 4050 3250 60  0000 C CNN
F 3 "" H 4050 3250 60  0000 C CNN
	1    4050 3250
	1    0    0    -1  
$EndComp
Text GLabel 4000 4000 3    60   Input ~ 0
A1
Text GLabel 3850 3900 3    60   Input ~ 0
+5V
Text GLabel 4150 4000 3    60   Input ~ 0
GND
NoConn ~ 4350 3700
NoConn ~ 3850 3700
$Comp
L RJ14 J3
U 1 1 532FAA98
P 4750 3250
F 0 "J3" H 4950 3750 60  0000 C CNN
F 1 "RJ14" H 4600 3750 60  0000 C CNN
F 2 "" H 4750 3250 60  0000 C CNN
F 3 "" H 4750 3250 60  0000 C CNN
	1    4750 3250
	1    0    0    -1  
$EndComp
Text GLabel 4700 4000 3    60   Input ~ 0
A2
Text GLabel 4550 3900 3    60   Input ~ 0
+5V
Text GLabel 4850 4000 3    60   Input ~ 0
GND
NoConn ~ 5050 3700
NoConn ~ 4550 3700
$Comp
L RJ14 J4
U 1 1 532FAAAE
P 5450 3250
F 0 "J4" H 5650 3750 60  0000 C CNN
F 1 "RJ14" H 5300 3750 60  0000 C CNN
F 2 "" H 5450 3250 60  0000 C CNN
F 3 "" H 5450 3250 60  0000 C CNN
	1    5450 3250
	1    0    0    -1  
$EndComp
Text GLabel 5400 4000 3    60   Input ~ 0
A3
Text GLabel 5250 3900 3    60   Input ~ 0
+5V
Text GLabel 5550 4000 3    60   Input ~ 0
GND
NoConn ~ 5750 3700
NoConn ~ 5250 3700
$Comp
L RJ14 J5
U 1 1 532FAB1C
P 6150 3250
F 0 "J5" H 6350 3750 60  0000 C CNN
F 1 "RJ14" H 6000 3750 60  0000 C CNN
F 2 "" H 6150 3250 60  0000 C CNN
F 3 "" H 6150 3250 60  0000 C CNN
	1    6150 3250
	1    0    0    -1  
$EndComp
Text GLabel 6100 4000 3    60   Input ~ 0
A4
Text GLabel 5950 3900 3    60   Input ~ 0
+5V
Text GLabel 6250 4000 3    60   Input ~ 0
GND
NoConn ~ 6450 3700
NoConn ~ 5950 3700
$Comp
L RJ14 J6
U 1 1 532FAB32
P 6850 3250
F 0 "J6" H 7050 3750 60  0000 C CNN
F 1 "RJ14" H 6700 3750 60  0000 C CNN
F 2 "" H 6850 3250 60  0000 C CNN
F 3 "" H 6850 3250 60  0000 C CNN
	1    6850 3250
	1    0    0    -1  
$EndComp
Text GLabel 6800 4000 3    60   Input ~ 0
A5
Text GLabel 6650 3900 3    60   Input ~ 0
+5V
Text GLabel 6950 4000 3    60   Input ~ 0
GND
NoConn ~ 7150 3700
NoConn ~ 6650 3700
$Comp
L RJ14 J7
U 1 1 532FAB48
P 7550 3250
F 0 "J7" H 7750 3750 60  0000 C CNN
F 1 "RJ14" H 7400 3750 60  0000 C CNN
F 2 "" H 7550 3250 60  0000 C CNN
F 3 "" H 7550 3250 60  0000 C CNN
	1    7550 3250
	1    0    0    -1  
$EndComp
Text GLabel 7500 4000 3    60   Input ~ 0
A6
Text GLabel 7350 3900 3    60   Input ~ 0
+5V
Text GLabel 7650 4000 3    60   Input ~ 0
GND
NoConn ~ 7850 3700
NoConn ~ 7350 3700
$Comp
L RJ14 J8
U 1 1 532FAB5E
P 8250 3250
F 0 "J8" H 8450 3750 60  0000 C CNN
F 1 "RJ14" H 8100 3750 60  0000 C CNN
F 2 "" H 8250 3250 60  0000 C CNN
F 3 "" H 8250 3250 60  0000 C CNN
	1    8250 3250
	1    0    0    -1  
$EndComp
Text GLabel 8200 4000 3    60   Input ~ 0
A7
Text GLabel 8050 3900 3    60   Input ~ 0
+5V
Text GLabel 8350 4000 3    60   Input ~ 0
GND
NoConn ~ 8550 3700
NoConn ~ 8050 3700
$Comp
L RJ14 J9
U 1 1 532FAB74
P 8950 3250
F 0 "J9" H 9150 3750 60  0000 C CNN
F 1 "RJ14" H 8800 3750 60  0000 C CNN
F 2 "" H 8950 3250 60  0000 C CNN
F 3 "" H 8950 3250 60  0000 C CNN
	1    8950 3250
	1    0    0    -1  
$EndComp
Text GLabel 8900 4000 3    60   Input ~ 0
A8
Text GLabel 8750 3900 3    60   Input ~ 0
+5V
Text GLabel 9050 4000 3    60   Input ~ 0
GND
NoConn ~ 9250 3700
NoConn ~ 8750 3700
$Comp
L RJ14 J10
U 1 1 532FAB8A
P 9650 3250
F 0 "J10" H 9850 3750 60  0000 C CNN
F 1 "RJ14" H 9500 3750 60  0000 C CNN
F 2 "" H 9650 3250 60  0000 C CNN
F 3 "" H 9650 3250 60  0000 C CNN
	1    9650 3250
	1    0    0    -1  
$EndComp
Text GLabel 9600 4000 3    60   Input ~ 0
A9
Text GLabel 9450 3900 3    60   Input ~ 0
+5V
Text GLabel 9750 4000 3    60   Input ~ 0
GND
NoConn ~ 9950 3700
NoConn ~ 9450 3700
$Comp
L RJ14 J11
U 1 1 532FABA0
P 10350 3250
F 0 "J11" H 10550 3750 60  0000 C CNN
F 1 "RJ14" H 10200 3750 60  0000 C CNN
F 2 "" H 10350 3250 60  0000 C CNN
F 3 "" H 10350 3250 60  0000 C CNN
	1    10350 3250
	1    0    0    -1  
$EndComp
Text GLabel 10300 4000 3    60   Input ~ 0
A10
Text GLabel 10150 3900 3    60   Input ~ 0
+5V
Text GLabel 10450 4000 3    60   Input ~ 0
GND
NoConn ~ 10650 3700
NoConn ~ 10150 3700
$Comp
L RJ14 J12
U 1 1 532FABB6
P 11050 3250
F 0 "J12" H 11250 3750 60  0000 C CNN
F 1 "RJ14" H 10900 3750 60  0000 C CNN
F 2 "" H 11050 3250 60  0000 C CNN
F 3 "" H 11050 3250 60  0000 C CNN
	1    11050 3250
	1    0    0    -1  
$EndComp
Text GLabel 11000 4000 3    60   Input ~ 0
A11
Text GLabel 10850 3900 3    60   Input ~ 0
+5V
Text GLabel 11150 4000 3    60   Input ~ 0
GND
NoConn ~ 11350 3700
NoConn ~ 10850 3700
$Comp
L RJ14 J13
U 1 1 532FABCC
P 11750 3250
F 0 "J13" H 11950 3750 60  0000 C CNN
F 1 "RJ14" H 11600 3750 60  0000 C CNN
F 2 "" H 11750 3250 60  0000 C CNN
F 3 "" H 11750 3250 60  0000 C CNN
	1    11750 3250
	1    0    0    -1  
$EndComp
Text GLabel 11700 4000 3    60   Input ~ 0
A12
Text GLabel 11550 3900 3    60   Input ~ 0
+5V
Text GLabel 11850 4000 3    60   Input ~ 0
GND
NoConn ~ 12050 3700
NoConn ~ 11550 3700
$Comp
L RJ14 J14
U 1 1 532FABE2
P 12450 3250
F 0 "J14" H 12650 3750 60  0000 C CNN
F 1 "RJ14" H 12300 3750 60  0000 C CNN
F 2 "" H 12450 3250 60  0000 C CNN
F 3 "" H 12450 3250 60  0000 C CNN
	1    12450 3250
	1    0    0    -1  
$EndComp
Text GLabel 12400 4000 3    60   Input ~ 0
A13
Text GLabel 12250 3900 3    60   Input ~ 0
+5V
Text GLabel 12550 4000 3    60   Input ~ 0
GND
NoConn ~ 12750 3700
NoConn ~ 12250 3700
$Comp
L RJ14 J15
U 1 1 532FABF8
P 13150 3250
F 0 "J15" H 13350 3750 60  0000 C CNN
F 1 "RJ14" H 13000 3750 60  0000 C CNN
F 2 "" H 13150 3250 60  0000 C CNN
F 3 "" H 13150 3250 60  0000 C CNN
	1    13150 3250
	1    0    0    -1  
$EndComp
Text GLabel 13100 4000 3    60   Input ~ 0
A14
Text GLabel 12950 3900 3    60   Input ~ 0
+5V
Text GLabel 13250 4000 3    60   Input ~ 0
GND
NoConn ~ 13450 3700
NoConn ~ 12950 3700
$Comp
L RJ14 J16
U 1 1 532FAC0E
P 13850 3250
F 0 "J16" H 14050 3750 60  0000 C CNN
F 1 "RJ14" H 13700 3750 60  0000 C CNN
F 2 "" H 13850 3250 60  0000 C CNN
F 3 "" H 13850 3250 60  0000 C CNN
	1    13850 3250
	1    0    0    -1  
$EndComp
Text GLabel 13800 4000 3    60   Input ~ 0
A15
Text GLabel 13650 3900 3    60   Input ~ 0
+5V
Text GLabel 13950 4000 3    60   Input ~ 0
GND
NoConn ~ 14150 3700
NoConn ~ 13650 3700
Text GLabel 6650 5550 1    60   Input ~ 0
A0
Text GLabel 6550 5550 1    60   Input ~ 0
A1
Text GLabel 6450 5550 1    60   Input ~ 0
A2
Text GLabel 6350 5550 1    60   Input ~ 0
A3
Text GLabel 6250 5550 1    60   Input ~ 0
A4
Text GLabel 6150 5550 1    60   Input ~ 0
A5
Text GLabel 6050 5550 1    60   Input ~ 0
A6
Text GLabel 5950 5550 1    60   Input ~ 0
A7
Text GLabel 5850 5550 1    47   Input ~ 0
A8
Text GLabel 5750 5550 1    47   Input ~ 0
A9
Text GLabel 5650 5550 1    47   Input ~ 0
A10
Text GLabel 5550 5550 1    47   Input ~ 0
A11
Text GLabel 5450 5550 1    47   Input ~ 0
A12
Text GLabel 5350 5550 1    47   Input ~ 0
A13
Text GLabel 5250 5550 1    47   Input ~ 0
A14
Text GLabel 5150 5550 1    47   Input ~ 0
A15
Text GLabel 4950 5550 1    47   Input ~ 0
GND
Text GLabel 10550 5950 0    60   Input ~ 0
GND
NoConn ~ 11550 5800
NoConn ~ 11550 5950
NoConn ~ 11550 6050
NoConn ~ 10800 6050
Text GLabel 10550 5800 0    60   Input ~ 0
+5V
Wire Wire Line
	3150 3900 3150 3800
Wire Wire Line
	3150 3800 3250 3800
Wire Wire Line
	3250 3800 3250 3700
Wire Wire Line
	3450 4000 3450 3700
Wire Wire Line
	3300 4000 3300 3850
Wire Wire Line
	3300 3850 3350 3850
Wire Wire Line
	3350 3850 3350 3700
Wire Wire Line
	3850 3900 3850 3800
Wire Wire Line
	3850 3800 3950 3800
Wire Wire Line
	3950 3800 3950 3700
Wire Wire Line
	4150 4000 4150 3700
Wire Wire Line
	4000 4000 4000 3850
Wire Wire Line
	4000 3850 4050 3850
Wire Wire Line
	4050 3850 4050 3700
Wire Wire Line
	4550 3900 4550 3800
Wire Wire Line
	4550 3800 4650 3800
Wire Wire Line
	4650 3800 4650 3700
Wire Wire Line
	4850 4000 4850 3700
Wire Wire Line
	4700 4000 4700 3850
Wire Wire Line
	4700 3850 4750 3850
Wire Wire Line
	4750 3850 4750 3700
Wire Wire Line
	5250 3900 5250 3800
Wire Wire Line
	5250 3800 5350 3800
Wire Wire Line
	5350 3800 5350 3700
Wire Wire Line
	5550 4000 5550 3700
Wire Wire Line
	5400 4000 5400 3850
Wire Wire Line
	5400 3850 5450 3850
Wire Wire Line
	5450 3850 5450 3700
Wire Wire Line
	5950 3900 5950 3800
Wire Wire Line
	5950 3800 6050 3800
Wire Wire Line
	6050 3800 6050 3700
Wire Wire Line
	6250 4000 6250 3700
Wire Wire Line
	6100 4000 6100 3850
Wire Wire Line
	6100 3850 6150 3850
Wire Wire Line
	6150 3850 6150 3700
Wire Wire Line
	6650 3900 6650 3800
Wire Wire Line
	6650 3800 6750 3800
Wire Wire Line
	6750 3800 6750 3700
Wire Wire Line
	6950 4000 6950 3700
Wire Wire Line
	6800 4000 6800 3850
Wire Wire Line
	6800 3850 6850 3850
Wire Wire Line
	6850 3850 6850 3700
Wire Wire Line
	7350 3900 7350 3800
Wire Wire Line
	7350 3800 7450 3800
Wire Wire Line
	7450 3800 7450 3700
Wire Wire Line
	7650 4000 7650 3700
Wire Wire Line
	7500 4000 7500 3850
Wire Wire Line
	7500 3850 7550 3850
Wire Wire Line
	7550 3850 7550 3700
Wire Wire Line
	8050 3900 8050 3800
Wire Wire Line
	8050 3800 8150 3800
Wire Wire Line
	8150 3800 8150 3700
Wire Wire Line
	8350 4000 8350 3700
Wire Wire Line
	8200 4000 8200 3850
Wire Wire Line
	8200 3850 8250 3850
Wire Wire Line
	8250 3850 8250 3700
Wire Wire Line
	8750 3900 8750 3800
Wire Wire Line
	8750 3800 8850 3800
Wire Wire Line
	8850 3800 8850 3700
Wire Wire Line
	9050 4000 9050 3700
Wire Wire Line
	8900 4000 8900 3850
Wire Wire Line
	8900 3850 8950 3850
Wire Wire Line
	8950 3850 8950 3700
Wire Wire Line
	9450 3900 9450 3800
Wire Wire Line
	9450 3800 9550 3800
Wire Wire Line
	9550 3800 9550 3700
Wire Wire Line
	9750 4000 9750 3700
Wire Wire Line
	9600 4000 9600 3850
Wire Wire Line
	9600 3850 9650 3850
Wire Wire Line
	9650 3850 9650 3700
Wire Wire Line
	10150 3900 10150 3800
Wire Wire Line
	10150 3800 10250 3800
Wire Wire Line
	10250 3800 10250 3700
Wire Wire Line
	10450 4000 10450 3700
Wire Wire Line
	10300 4000 10300 3850
Wire Wire Line
	10300 3850 10350 3850
Wire Wire Line
	10350 3850 10350 3700
Wire Wire Line
	10850 3900 10850 3800
Wire Wire Line
	10850 3800 10950 3800
Wire Wire Line
	10950 3800 10950 3700
Wire Wire Line
	11150 4000 11150 3700
Wire Wire Line
	11000 4000 11000 3850
Wire Wire Line
	11000 3850 11050 3850
Wire Wire Line
	11050 3850 11050 3700
Wire Wire Line
	11550 3900 11550 3800
Wire Wire Line
	11550 3800 11650 3800
Wire Wire Line
	11650 3800 11650 3700
Wire Wire Line
	11850 4000 11850 3700
Wire Wire Line
	11700 4000 11700 3850
Wire Wire Line
	11700 3850 11750 3850
Wire Wire Line
	11750 3850 11750 3700
Wire Wire Line
	12250 3900 12250 3800
Wire Wire Line
	12250 3800 12350 3800
Wire Wire Line
	12350 3800 12350 3700
Wire Wire Line
	12550 4000 12550 3700
Wire Wire Line
	12400 4000 12400 3850
Wire Wire Line
	12400 3850 12450 3850
Wire Wire Line
	12450 3850 12450 3700
Wire Wire Line
	12950 3900 12950 3800
Wire Wire Line
	12950 3800 13050 3800
Wire Wire Line
	13050 3800 13050 3700
Wire Wire Line
	13250 4000 13250 3700
Wire Wire Line
	13100 4000 13100 3850
Wire Wire Line
	13100 3850 13150 3850
Wire Wire Line
	13150 3850 13150 3700
Wire Wire Line
	13650 3900 13650 3800
Wire Wire Line
	13650 3800 13750 3800
Wire Wire Line
	13750 3800 13750 3700
Wire Wire Line
	13950 4000 13950 3700
Wire Wire Line
	13800 4000 13800 3850
Wire Wire Line
	13800 3850 13850 3850
Wire Wire Line
	13850 3850 13850 3700
Wire Wire Line
	10550 5800 10800 5800
Wire Wire Line
	10800 5950 10550 5950
NoConn ~ 6750 5550
NoConn ~ 6850 5550
NoConn ~ 6950 5550
NoConn ~ 7050 5550
Text Notes 5700 5150 0    60   ~ 0
AREF needed here?  
NoConn ~ 14050 3700
NoConn ~ 13350 3700
NoConn ~ 12650 3700
NoConn ~ 11950 3700
NoConn ~ 11250 3700
NoConn ~ 10550 3700
NoConn ~ 9850 3700
NoConn ~ 9150 3700
NoConn ~ 8450 3700
NoConn ~ 7750 3700
NoConn ~ 7050 3700
NoConn ~ 6350 3700
NoConn ~ 5650 3700
NoConn ~ 4950 3700
NoConn ~ 4250 3700
NoConn ~ 3550 3700
$Comp
L BARREL_JACK CON?
U 1 1 53402D91
P 8550 6550
F 0 "CON?" H 8550 6800 60  0000 C CNN
F 1 "BARREL_JACK" H 8550 6350 60  0000 C CNN
F 2 "" H 8550 6550 60  0000 C CNN
F 3 "" H 8550 6550 60  0000 C CNN
	1    8550 6550
	1    0    0    -1  
$EndComp
Text GLabel 9000 6450 2    60   Input ~ 0
+5V
Text GLabel 9000 6650 2    60   Input ~ 0
GND
Wire Wire Line
	8850 6650 9000 6650
Wire Wire Line
	8850 6550 8950 6550
Wire Wire Line
	8950 6550 8950 6650
Connection ~ 8950 6650
Wire Wire Line
	8850 6450 9000 6450
Text Notes 9200 6150 2    60   ~ 0
connect both to gnd?
Text Notes 9750 5050 0    60   ~ 0
usb power to pi - use square plug for micro-usb cable use
Text GLabel 9050 5400 2    60   Input ~ 0
+5V
Text GLabel 8350 5400 0    60   Input ~ 0
GND
Wire Wire Line
	8900 5400 9050 5400
$Comp
L C C?
U 1 1 534031B8
P 8700 5400
F 0 "C?" H 8700 5500 40  0000 L CNN
F 1 "10mf" H 8706 5315 40  0000 L CNN
F 2 "~" H 8738 5250 30  0000 C CNN
F 3 "~" H 8700 5400 60  0000 C CNN
	1    8700 5400
	0    1    1    0   
$EndComp
Wire Wire Line
	8350 5400 8500 5400
Text Notes 8400 5050 0    60   ~ 0
10mf enough?
Text Notes 6650 4500 0    60   ~ 0
.1 mf between all power and gnd?  or op-amp circuit makes unecessary?
$Comp
L BARREL_JACK CON?
U 1 1 53403D81
P 8550 7500
F 0 "CON?" H 8550 7750 60  0000 C CNN
F 1 "BARREL_JACK" H 8550 7300 60  0000 C CNN
F 2 "" H 8550 7500 60  0000 C CNN
F 3 "" H 8550 7500 60  0000 C CNN
	1    8550 7500
	1    0    0    -1  
$EndComp
Text GLabel 9000 7400 2    60   Input ~ 0
+5V
Wire Wire Line
	8850 7400 9000 7400
Text Notes 10250 7050 2    60   ~ 0
second barrel connector, daisy chain to power 2 boards \nand ARM computer
Text Notes 10650 6350 0    60   ~ 0
connect GND to shield?
Text GLabel 9000 7600 2    60   Input ~ 0
GND
Wire Wire Line
	8850 7600 9000 7600
Wire Wire Line
	8850 7500 8950 7500
Wire Wire Line
	8950 7500 8950 7600
Connection ~ 8950 7600
$EndSCHEMATC
