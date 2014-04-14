EESchema Schematic File Version 2
LIBS:74xx
LIBS:adc-dac
LIBS:analog_switches
LIBS:atmel
LIBS:audio
LIBS:cmos4000
LIBS:conn
LIBS:contrib
LIBS:cypress
LIBS:device
LIBS:digital-audio
LIBS:display
LIBS:dsp
LIBS:intel
LIBS:interface
LIBS:linear
LIBS:memory
LIBS:microchip
LIBS:microcontrollers
LIBS:motorola
LIBS:opto
LIBS:philips
LIBS:power
LIBS:regul
LIBS:siliconi
LIBS:special
LIBS:texas
LIBS:transistors
LIBS:valves
LIBS:xilinx
LIBS:extras-cache
EELAYER 27 0
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
Text GLabel 4350 4700 0    60   Input ~ 0
3.3V
Text GLabel 5500 3950 2    60   Input ~ 0
5V
NoConn ~ 5300 4250
NoConn ~ 5300 4350
NoConn ~ 5300 4450
NoConn ~ 5300 4650
NoConn ~ 5300 4750
NoConn ~ 5300 4950
Text GLabel 4350 5200 0    60   Input ~ 0
GND
Text GLabel 5500 4850 2    60   Input ~ 0
GND
Text GLabel 5500 4550 2    60   Input ~ 0
GND
Text GLabel 5500 4150 2    60   Input ~ 0
GND
NoConn ~ 4500 4650
NoConn ~ 4500 4550
NoConn ~ 4500 4450
NoConn ~ 4500 4250
NoConn ~ 4500 4150
NoConn ~ 4500 4050
Text GLabel 4350 3950 0    60   Input ~ 0
3.3V
Text GLabel 4350 4350 0    60   Input ~ 0
GND
Text GLabel 5650 5150 2    60   Input ~ 0
CE1
Text GLabel 5400 5050 2    60   Input ~ 0
CE0
Text GLabel 4350 5050 0    60   Input ~ 0
SCLK
Text GLabel 4050 4950 0    60   Input ~ 0
MISO
Text GLabel 4350 4850 0    60   Input ~ 0
MOSI
$Comp
L CONN_13X2 Raspberry1
U 1 1 531F8E51
P 4900 4550
F 0 "Raspberry1" H 4900 5250 60  0000 C CNN
F 1 "CONN_13X2" V 4900 4550 50  0000 C CNN
F 2 "" H 4900 4550 60  0001 C CNN
F 3 "" H 4900 4550 60  0001 C CNN
	1    4900 4550
	1    0    0    -1  
$EndComp
NoConn ~ 5300 4050
Text Notes 9450 4050 0    60   ~ 0
Add voltage regulator gadget for 2.5v reference!
$Comp
L LM317T U2
U 1 1 5341C926
P 10100 4450
F 0 "U2" H 9900 4650 40  0000 C CNN
F 1 "LM317T" H 10100 4650 40  0000 L CNN
F 2 "TO-220" H 10100 4550 30  0000 C CIN
F 3 "" H 10100 4450 60  0000 C CNN
	1    10100 4450
	1    0    0    -1  
$EndComp
$Comp
L C 4.7
U 1 1 5341D36B
P 10950 4700
F 0 "4.7" H 10950 4800 40  0000 L CNN
F 1 "C" H 10956 4615 40  0000 L CNN
F 2 "~" H 10988 4550 30  0000 C CNN
F 3 "~" H 10950 4700 60  0000 C CNN
	1    10950 4700
	1    0    0    -1  
$EndComp
$Comp
L POT RV1
U 1 1 5341D3A9
P 10100 5100
F 0 "RV1" H 10100 5000 50  0000 C CNN
F 1 "POT" H 10100 5100 50  0000 C CNN
F 2 "~" H 10100 5100 60  0000 C CNN
F 3 "~" H 10100 5100 60  0000 C CNN
	1    10100 5100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR2
U 1 1 5341D4E7
P 9700 5200
F 0 "#PWR2" H 9700 5200 30  0001 C CNN
F 1 "GND" H 9700 5130 30  0001 C CNN
F 2 "" H 9700 5200 60  0000 C CNN
F 3 "" H 9700 5200 60  0000 C CNN
	1    9700 5200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR3
U 1 1 5341D80F
P 10950 5100
F 0 "#PWR3" H 10950 5100 30  0001 C CNN
F 1 "GND" H 10950 5030 30  0001 C CNN
F 2 "" H 10950 5100 60  0000 C CNN
F 3 "" H 10950 5100 60  0000 C CNN
	1    10950 5100
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 5341DA54
P 10450 4800
F 0 "R2" V 10550 4800 40  0000 C CNN
F 1 "220" V 10457 4801 40  0000 C CNN
F 2 "~" V 10380 4800 30  0000 C CNN
F 3 "~" H 10450 4800 30  0000 C CNN
	1    10450 4800
	0    -1   -1   0   
$EndComp
NoConn ~ 10350 5100
Text GLabel 9600 4400 0    60   Input ~ 0
5V
Text GLabel 11250 4400 2    60   Input ~ 0
+AREF
Text Notes 10650 4200 0    60   ~ 0
Actually not used right now!!
$Comp
L C .1
U 1 1 5341E866
P 9700 4800
F 0 ".1" H 9250 4800 40  0000 L CNN
F 1 "C" H 9706 4715 40  0000 L CNN
F 2 "~" H 9738 4650 30  0000 C CNN
F 3 "~" H 9700 4800 60  0000 C CNN
	1    9700 4800
	1    0    0    -1  
$EndComp
Wire Wire Line
	4500 4750 4400 4750
Wire Wire Line
	4400 4750 4400 4700
Wire Wire Line
	4400 4700 4350 4700
Wire Wire Line
	5300 4850 5500 4850
Wire Wire Line
	5300 4150 5500 4150
Wire Wire Line
	4350 3950 4500 3950
Wire Wire Line
	4500 4850 4350 4850
Wire Wire Line
	5650 5150 5300 5150
Wire Wire Line
	5300 5050 5400 5050
Wire Wire Line
	4500 5050 4350 5050
Wire Wire Line
	4500 4950 4050 4950
Wire Wire Line
	4350 4350 4500 4350
Wire Wire Line
	5300 4550 5500 4550
Wire Wire Line
	4350 5200 4400 5200
Wire Wire Line
	4400 5200 4400 5150
Wire Wire Line
	4400 5150 4500 5150
Wire Wire Line
	5300 3950 5500 3950
Wire Wire Line
	10950 5100 10950 4900
Wire Wire Line
	10950 4400 10950 4500
Wire Wire Line
	10500 4400 11250 4400
Wire Wire Line
	10100 4700 10100 4950
Connection ~ 10100 4800
Wire Wire Line
	10800 4400 10800 4800
Wire Wire Line
	10800 4800 10700 4800
Connection ~ 10800 4400
Wire Wire Line
	10100 4800 10200 4800
Wire Wire Line
	9600 4400 9700 4400
Connection ~ 10950 4400
Wire Wire Line
	9700 4400 9700 4600
Wire Wire Line
	9700 5000 9700 5200
Connection ~ 9700 5100
Wire Wire Line
	9850 5100 9700 5100
$EndSCHEMATC
