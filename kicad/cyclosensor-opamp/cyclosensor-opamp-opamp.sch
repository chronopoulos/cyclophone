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
LIBS:cyclosensor-opamp-opamp-cache
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date "25 apr 2014"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L RJ14 J1
U 1 1 532FB864
P 9550 1750
F 0 "J1" H 9750 2250 60  0000 C CNN
F 1 "RJ14" H 9400 2250 60  0000 C CNN
F 2 "~" H 9550 1750 60  0000 C CNN
F 3 "~" H 9550 1750 60  0000 C CNN
	1    9550 1750
	1    0    0    -1  
$EndComp
Text GLabel 4900 4950 3    60   Input ~ 0
5V
Text GLabel 8200 4350 2    60   Input ~ 0
ADC
$Comp
L R R2
U 1 1 533B9B87
P 3650 4950
F 0 "R2" V 3730 4950 40  0000 C CNN
F 1 "20.7k" V 3657 4951 40  0000 C CNN
F 2 "~" V 3580 4950 30  0000 C CNN
F 3 "~" H 3650 4950 30  0000 C CNN
	1    3650 4950
	1    0    0    -1  
$EndComp
Text GLabel 2050 4200 0    60   Input ~ 0
5V
$Comp
L GND #PWR01
U 1 1 533B9F2F
P 3650 4400
F 0 "#PWR01" H 3650 4400 30  0001 C CNN
F 1 "GND" H 3650 4330 30  0001 C CNN
F 2 "" H 3650 4400 60  0000 C CNN
F 3 "" H 3650 4400 60  0000 C CNN
	1    3650 4400
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 533B9FB6
P 2300 4200
F 0 "R1" V 2380 4200 40  0000 C CNN
F 1 "220" V 2307 4201 40  0000 C CNN
F 2 "~" V 2230 4200 30  0000 C CNN
F 3 "~" H 2300 4200 30  0000 C CNN
	1    2300 4200
	0    1    1    0   
$EndComp
NoConn ~ 9350 2200
NoConn ~ 9850 2200
NoConn ~ 9750 2200
Text Notes 8850 2900 0    60   ~ 0
Ok to have 5V without 'pair' here?  \nYES
$Comp
L C C1
U 1 1 53449FBF
P 6100 5850
F 0 "C1" H 6100 5950 40  0000 L CNN
F 1 ".01uf" H 6106 5765 40  0000 L CNN
F 2 "~" H 6138 5700 30  0000 C CNN
F 3 "~" H 6100 5850 60  0000 C CNN
	1    6100 5850
	1    0    0    -1  
$EndComp
Text GLabel 6100 5500 1    60   Input ~ 0
5V
$Comp
L GND #PWR02
U 1 1 53449FDD
P 6100 6150
F 0 "#PWR02" H 6100 6150 30  0001 C CNN
F 1 "GND" H 6100 6080 30  0001 C CNN
F 2 "" H 6100 6150 60  0000 C CNN
F 3 "" H 6100 6150 60  0000 C CNN
	1    6100 6150
	1    0    0    -1  
$EndComp
Text Notes 5750 5250 0    60   ~ 0
Put near pin 5 on op-amp!
$Comp
L C C2
U 1 1 5344A0AE
P 6450 5850
F 0 "C2" H 6450 5950 40  0000 L CNN
F 1 "10uf" H 6456 5765 40  0000 L CNN
F 2 "~" H 6488 5700 30  0000 C CNN
F 3 "~" H 6450 5850 60  0000 C CNN
	1    6450 5850
	1    0    0    -1  
$EndComp
Text GLabel 6450 5500 1    60   Input ~ 0
5V
Text Notes 5900 6600 0    60   ~ 0
option of two caps \nfor different freq\nfiltering on each
$Comp
L GND #PWR03
U 1 1 5355C365
P 8000 4950
F 0 "#PWR03" H 8000 4950 30  0001 C CNN
F 1 "GND" H 8000 4880 30  0001 C CNN
F 2 "" H 8000 4950 60  0000 C CNN
F 3 "" H 8000 4950 60  0000 C CNN
	1    8000 4950
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 5355C3FF
P 4150 4350
F 0 "R3" V 4230 4350 40  0000 C CNN
F 1 "10k" V 4157 4351 40  0000 C CNN
F 2 "" V 4080 4350 30  0000 C CNN
F 3 "" H 4150 4350 30  0000 C CNN
	1    4150 4350
	0    1    1    0   
$EndComp
Text GLabel 2450 4450 0    60   Input ~ 0
5V
$Comp
L GND #PWR04
U 1 1 5355C5B1
P 3650 5350
F 0 "#PWR04" H 3650 5350 30  0001 C CNN
F 1 "GND" H 3650 5280 30  0001 C CNN
F 2 "" H 3650 5350 60  0000 C CNN
F 3 "" H 3650 5350 60  0000 C CNN
	1    3650 5350
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 5355C5BE
P 8000 4600
F 0 "R5" V 8080 4600 40  0000 C CNN
F 1 "empty" V 8007 4601 40  0000 C CNN
F 2 "" V 7930 4600 30  0000 C CNN
F 3 "" H 8000 4600 30  0000 C CNN
	1    8000 4600
	1    0    0    -1  
$EndComp
$Comp
L MCP6001U U2
U 1 1 5358437A
P 5000 4450
F 0 "U2" H 4950 4650 60  0000 L CNN
F 1 "MCP6001U" H 4950 4200 60  0000 L CNN
F 2 "~" H 5000 4450 60  0000 C CNN
F 3 "~" H 5000 4450 60  0000 C CNN
	1    5000 4450
	1    0    0    1   
$EndComp
$Comp
L GND #PWR05
U 1 1 5359E691
P 7400 3850
F 0 "#PWR05" H 7400 3850 30  0001 C CNN
F 1 "GND" H 7400 3780 30  0001 C CNN
F 2 "" H 7400 3850 60  0000 C CNN
F 3 "" H 7400 3850 60  0000 C CNN
	1    7400 3850
	-1   0    0    1   
$EndComp
Text GLabel 7400 4850 3    60   Input ~ 0
5V
Wire Wire Line
	2450 4450 2550 4450
Wire Wire Line
	8000 4350 8200 4350
Wire Wire Line
	3650 5200 3650 5350
Wire Wire Line
	6100 6050 6100 6150
Wire Wire Line
	6100 5500 6100 5650
Wire Wire Line
	6450 6050 6450 6150
Wire Wire Line
	6450 5500 6450 5650
Wire Wire Line
	4400 4350 4500 4350
Wire Wire Line
	3550 4550 4500 4550
Wire Wire Line
	3650 4700 3650 4550
Connection ~ 3650 4550
Wire Wire Line
	3550 4300 3650 4300
Wire Wire Line
	3650 4300 3650 4400
Wire Wire Line
	8000 4850 8000 4950
Wire Wire Line
	3850 4400 3850 4350
Wire Wire Line
	3850 4350 3900 4350
Wire Wire Line
	7400 3850 7400 3950
Wire Wire Line
	7400 4750 7400 4850
Text GLabel 3900 3250 2    60   Input ~ 0
lowcut
Text GLabel 4900 4000 1    60   Input ~ 0
lowcut
$Comp
L POT LOW1
U 1 1 5359E724
P 3750 3250
F 0 "LOW1" H 3750 3150 50  0000 C CNN
F 1 "100k" H 3750 3250 50  0000 C CNN
F 2 "~" H 3750 3250 60  0000 C CNN
F 3 "~" H 3750 3250 60  0000 C CNN
	1    3750 3250
	0    1    1    0   
$EndComp
Text GLabel 3750 3000 1    60   Input ~ 0
5V
$Comp
L GND #PWR06
U 1 1 5359E72B
P 3750 3650
F 0 "#PWR06" H 3750 3650 30  0001 C CNN
F 1 "GND" H 3750 3580 30  0001 C CNN
F 2 "" H 3750 3650 60  0000 C CNN
F 3 "" H 3750 3650 60  0000 C CNN
	1    3750 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	3750 3500 3750 3650
$Comp
L POT GAIN2
U 1 1 5359E737
P 7400 3350
F 0 "GAIN2" H 7400 3250 50  0000 C CNN
F 1 "100K" H 7400 3350 50  0000 C CNN
F 2 "~" H 7400 3350 60  0000 C CNN
F 3 "~" H 7400 3350 60  0000 C CNN
	1    7400 3350
	1    0    0    -1  
$EndComp
NoConn ~ 7650 3350
Wire Wire Line
	7400 3200 8000 3200
Wire Wire Line
	6900 3350 7150 3350
Wire Wire Line
	8000 2950 8000 4350
Wire Wire Line
	6900 2950 6900 4250
Wire Wire Line
	6800 4250 7000 4250
Connection ~ 6900 4250
Wire Wire Line
	5500 3550 5500 5350
Wire Wire Line
	5500 3550 4500 3550
Wire Wire Line
	4500 3550 4500 4350
Text Notes 4700 3450 0    60   ~ 0
Unity gain!
Text Notes 3900 3000 0    60   ~ 0
Whatever is below the 'lowcut' \nis ignored by the first op-amp.
Text GLabel 6150 4250 0    60   Input ~ 0
lowcut
Text Notes 5750 4000 0    60   ~ 0
'lowcut' is the low input\nto the final opamp.
Text Notes 6650 2700 0    60   ~ 0
Gain regulates the distance from \nsensor surface where the signal maxes out.\nCan use a fixed resistor instead \nof the pot if desired.
$Comp
L MCP6001U U3
U 1 1 5359ECE1
P 7500 4350
F 0 "U3" H 7450 4550 60  0000 L CNN
F 1 "MCP6001U" H 7450 4100 60  0000 L CNN
F 2 "~" H 7500 4350 60  0000 C CNN
F 3 "~" H 7500 4350 60  0000 C CNN
	1    7500 4350
	1    0    0    1   
$EndComp
Wire Wire Line
	5500 4450 7000 4450
$Comp
L R R4
U 1 1 5359ED67
P 6550 4250
F 0 "R4" V 6630 4250 40  0000 C CNN
F 1 "10k" V 6557 4251 40  0000 C CNN
F 2 "~" V 6480 4250 30  0000 C CNN
F 3 "~" H 6550 4250 30  0000 C CNN
	1    6550 4250
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6150 4250 6300 4250
Text GLabel 2950 3250 2    60   Input ~ 0
lowcut
$Comp
L GND #PWR07
U 1 1 535AB41D
P 2300 3350
F 0 "#PWR07" H 2300 3350 30  0001 C CNN
F 1 "GND" H 2300 3280 30  0001 C CNN
F 2 "" H 2300 3350 60  0000 C CNN
F 3 "" H 2300 3350 60  0000 C CNN
	1    2300 3350
	0    1    1    0   
$EndComp
$Comp
L R R6
U 1 1 535AB429
P 2550 3350
F 0 "R6" V 2630 3350 40  0000 C CNN
F 1 "empty" V 2557 3351 40  0000 C CNN
F 2 "~" V 2480 3350 30  0000 C CNN
F 3 "~" H 2550 3350 30  0000 C CNN
	1    2550 3350
	0    1    1    0   
$EndComp
$Comp
L CONN_3 K1
U 1 1 535AE01E
P 9650 3200
F 0 "K1" V 9600 3200 50  0000 C CNN
F 1 "CONN_3" V 9700 3200 40  0000 C CNN
F 2 "" H 9650 3200 60  0000 C CNN
F 3 "" H 9650 3200 60  0000 C CNN
	1    9650 3200
	0    -1   -1   0   
$EndComp
Text Notes 9000 4350 0    60   ~ 0
for use without the rj14 jack
Text Notes 7900 5200 0    60   ~ 0
this resistor is just for when there is capacitance \nover the ADC line, for instance over a long coax \ncable run.   empty by default.
Text Notes 2000 3000 0    60   ~ 0
If fixed lowcut is desired, \nuse appropriate resistors here.  
Text Notes 3650 1000 0    60   ~ 0
Qs:\n- what ohms for lowcut pot?\nA: it affects current draw.  1k to 10k for more current.  
Text Notes 3650 1350 0    60   ~ 0
tcrt5000 is through hole.  also rj14.  also pots.  \njust make the whole thing through hole?
Wire Wire Line
	4900 4850 4900 4950
Wire Wire Line
	4900 4000 4900 4050
NoConn ~ 9600 1800
NoConn ~ 10550 1700
$Comp
L GND #PWR08
U 1 1 535BCF20
P 9900 3850
F 0 "#PWR08" H 9900 3850 30  0001 C CNN
F 1 "GND" H 9900 3780 30  0001 C CNN
F 2 "" H 9900 3850 60  0000 C CNN
F 3 "" H 9900 3850 60  0000 C CNN
	1    9900 3850
	1    0    0    -1  
$EndComp
Text GLabel 9550 3850 3    60   Input ~ 0
5V
Text GLabel 9700 3850 3    60   Input ~ 0
ADC
Wire Wire Line
	9550 3550 9550 3850
Wire Wire Line
	9650 3550 9650 3700
Wire Wire Line
	9650 3700 9700 3700
Wire Wire Line
	9700 3700 9700 3850
Wire Wire Line
	9750 3550 9750 3700
Wire Wire Line
	9750 3700 9900 3700
Wire Wire Line
	9900 3700 9900 3850
$Comp
L GND #PWR09
U 1 1 535BD06C
P 6450 6150
F 0 "#PWR09" H 6450 6150 30  0001 C CNN
F 1 "GND" H 6450 6080 30  0001 C CNN
F 2 "" H 6450 6150 60  0000 C CNN
F 3 "" H 6450 6150 60  0000 C CNN
	1    6450 6150
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR010
U 1 1 535BD092
P 9800 2500
F 0 "#PWR010" H 9800 2500 30  0001 C CNN
F 1 "GND" H 9800 2430 30  0001 C CNN
F 2 "" H 9800 2500 60  0000 C CNN
F 3 "" H 9800 2500 60  0000 C CNN
	1    9800 2500
	1    0    0    -1  
$EndComp
Text GLabel 9450 2500 3    60   Input ~ 0
5V
Text GLabel 9600 2500 3    60   Input ~ 0
ADC
Wire Wire Line
	9450 2200 9450 2500
Wire Wire Line
	9550 2200 9550 2350
Wire Wire Line
	9550 2350 9600 2350
Wire Wire Line
	9600 2350 9600 2500
Wire Wire Line
	9650 2200 9650 2350
Wire Wire Line
	9650 2350 9800 2350
Wire Wire Line
	9800 2350 9800 2500
$Comp
L GND #PWR011
U 1 1 535BD0A6
P 3850 4400
F 0 "#PWR011" H 3850 4400 30  0001 C CNN
F 1 "GND" H 3850 4330 30  0001 C CNN
F 2 "" H 3850 4400 60  0000 C CNN
F 3 "" H 3850 4400 60  0000 C CNN
	1    3850 4400
	1    0    0    -1  
$EndComp
$Comp
L TCRT5000 U1
U 1 1 535BDDB2
P 3050 4250
F 0 "U1" H 3050 3700 60  0000 C CNN
F 1 "TCRT5000" H 3050 4700 60  0000 C CNN
F 2 "" H 3050 4250 60  0000 C CNN
F 3 "" H 3050 4250 60  0000 C CNN
	1    3050 4250
	1    0    0    -1  
$EndComp
Text Notes 3650 1700 0    60   ~ 0
Q: 'lowcut' beyond op-amp specs?  might blow it up?\nA: no, but its not 'correct'!
Text Notes 3650 1950 0    60   ~ 0
Mount POTs, RJ14 on bottom of board!!
$Comp
L R R8
U 1 1 535D1A3C
P 4950 5350
F 0 "R8" V 5030 5350 40  0000 C CNN
F 1 "empty" V 4957 5351 40  0000 C CNN
F 2 "~" V 4880 5350 30  0000 C CNN
F 3 "~" H 4950 5350 30  0000 C CNN
	1    4950 5350
	0    1    1    0   
$EndComp
Wire Wire Line
	4500 4550 4500 5350
Wire Wire Line
	4500 5350 4700 5350
Wire Wire Line
	5500 5350 5200 5350
Connection ~ 5500 4450
Text Notes 4600 5700 0    60   ~ 0
bypass, for leaving \nout op-amp #1
$Comp
L R R7
U 1 1 535D1DDF
P 2550 3150
F 0 "R7" V 2630 3150 40  0000 C CNN
F 1 "empty" V 2557 3151 40  0000 C CNN
F 2 "~" V 2480 3150 30  0000 C CNN
F 3 "~" H 2550 3150 30  0000 C CNN
	1    2550 3150
	0    1    1    0   
$EndComp
Text GLabel 2300 3150 0    60   Input ~ 0
5V
Wire Wire Line
	2800 3150 2850 3150
Wire Wire Line
	2850 3150 2850 3350
Wire Wire Line
	2850 3350 2800 3350
Wire Wire Line
	2950 3250 2850 3250
Connection ~ 2850 3250
$Comp
L R R9
U 1 1 535D1ECA
P 7400 2950
F 0 "R9" V 7480 2950 40  0000 C CNN
F 1 "empty" V 7407 2951 40  0000 C CNN
F 2 "~" V 7330 2950 30  0000 C CNN
F 3 "~" H 7400 2950 30  0000 C CNN
	1    7400 2950
	0    -1   -1   0   
$EndComp
Wire Wire Line
	8000 2950 7650 2950
Connection ~ 8000 3200
Wire Wire Line
	7150 2950 6900 2950
Connection ~ 6900 3350
$EndSCHEMATC
