EESchema Schematic File Version 2
LIBS:cyclophone
LIBS:cyclosensor-opamp-noninverting-cache
EELAYER 27 0
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
Text GLabel 9450 2500 3    60   Input ~ 0
5V
Text GLabel 9600 2500 3    60   Input ~ 0
ADC
$Comp
L GND #PWR12
U 1 1 533B827E
P 9800 2500
F 0 "#PWR12" H 9800 2500 30  0001 C CNN
F 1 "GND" H 9800 2430 30  0001 C CNN
F 2 "" H 9800 2500 60  0000 C CNN
F 3 "" H 9800 2500 60  0000 C CNN
	1    9800 2500
	1    0    0    -1  
$EndComp
Text GLabel 4900 4950 3    60   Input ~ 0
5V
Text GLabel 8200 4350 2    60   Input ~ 0
ADC
$Comp
L R R1
U 1 1 533B9B87
P 3650 4950
F 0 "R1" V 3730 4950 40  0000 C CNN
F 1 "20.7k" V 3657 4951 40  0000 C CNN
F 2 "~" V 3580 4950 30  0000 C CNN
F 3 "~" H 3650 4950 30  0000 C CNN
	1    3650 4950
	1    0    0    -1  
$EndComp
Text GLabel 2050 4200 0    60   Input ~ 0
5V
$Comp
L GND #PWR3
U 1 1 533B9F2F
P 3650 4400
F 0 "#PWR3" H 3650 4400 30  0001 C CNN
F 1 "GND" H 3650 4330 30  0001 C CNN
F 2 "" H 3650 4400 60  0000 C CNN
F 3 "" H 3650 4400 60  0000 C CNN
	1    3650 4400
	1    0    0    -1  
$EndComp
$Comp
L R R5
U 1 1 533B9FB6
P 2300 4200
F 0 "R5" V 2380 4200 40  0000 C CNN
F 1 "220" V 2307 4201 40  0000 C CNN
F 2 "~" V 2230 4200 30  0000 C CNN
F 3 "~" H 2300 4200 30  0000 C CNN
	1    2300 4200
	0    1    1    0   
$EndComp
NoConn ~ 9350 2200
NoConn ~ 9850 2200
$Comp
L POT OFFSET1
U 1 1 533BA12C
P 2300 1250
F 0 "OFFSET1" H 2300 1150 50  0000 C CNN
F 1 "10k" H 2300 1250 50  0000 C CNN
F 2 "~" H 2300 1250 60  0000 C CNN
F 3 "~" H 2300 1250 60  0000 C CNN
	1    2300 1250
	1    0    0    -1  
$EndComp
Text GLabel 2050 1400 3    60   Input ~ 0
5V
NoConn ~ 9750 2200
Text Notes 8850 2900 0    60   ~ 0
Ok to have 5V without 'pair' here?  \nYES
$Comp
L C C1
U 1 1 53449FBF
P 4750 6250
F 0 "C1" H 4750 6350 40  0000 L CNN
F 1 ".01uf" H 4756 6165 40  0000 L CNN
F 2 "~" H 4788 6100 30  0000 C CNN
F 3 "~" H 4750 6250 60  0000 C CNN
	1    4750 6250
	1    0    0    -1  
$EndComp
Text GLabel 4750 5900 1    60   Input ~ 0
5V
$Comp
L GND #PWR8
U 1 1 53449FDD
P 4750 6550
F 0 "#PWR8" H 4750 6550 30  0001 C CNN
F 1 "GND" H 4750 6480 30  0001 C CNN
F 2 "" H 4750 6550 60  0000 C CNN
F 3 "" H 4750 6550 60  0000 C CNN
	1    4750 6550
	1    0    0    -1  
$EndComp
Text Notes 4500 5650 0    60   ~ 0
Put near pin 5 on op-amp!
$Comp
L C C2
U 1 1 5344A0AE
P 5100 6250
F 0 "C2" H 5100 6350 40  0000 L CNN
F 1 "10uf" H 5106 6165 40  0000 L CNN
F 2 "~" H 5138 6100 30  0000 C CNN
F 3 "~" H 5100 6250 60  0000 C CNN
	1    5100 6250
	1    0    0    -1  
$EndComp
Text GLabel 5100 5900 1    60   Input ~ 0
5V
$Comp
L GND #PWR9
U 1 1 5344A0B5
P 5100 6550
F 0 "#PWR9" H 5100 6550 30  0001 C CNN
F 1 "GND" H 5100 6480 30  0001 C CNN
F 2 "" H 5100 6550 60  0000 C CNN
F 3 "" H 5100 6550 60  0000 C CNN
	1    5100 6550
	1    0    0    -1  
$EndComp
Text Notes 4750 6800 0    60   ~ 0
option of two caps \nfor different freq\nfiltering on each
$Comp
L TCRT5000 U1
U 1 1 53499E1E
P 3050 4250
F 0 "U1" H 3050 3700 60  0000 C CNN
F 1 "TCRT5000" H 3050 4700 60  0000 C CNN
F 2 "~" H 3050 4250 60  0000 C CNN
F 3 "~" H 3050 4250 60  0000 C CNN
	1    3050 4250
	1    0    0    -1  
$EndComp
$Comp
L R R2
U 1 1 5349C83F
P 4150 2100
F 0 "R2" V 4230 2100 40  0000 C CNN
F 1 "20k" V 4157 2101 40  0000 C CNN
F 2 "~" V 4080 2100 30  0000 C CNN
F 3 "~" H 4150 2100 30  0000 C CNN
	1    4150 2100
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR7
U 1 1 5349C845
P 4150 2500
F 0 "#PWR7" H 4150 2500 30  0001 C CNN
F 1 "GND" H 4150 2430 30  0001 C CNN
F 2 "" H 4150 2500 60  0000 C CNN
F 3 "" H 4150 2500 60  0000 C CNN
	1    4150 2500
	1    0    0    -1  
$EndComp
$Comp
L POT OFFSET2
U 1 1 5349C84B
P 3800 2100
F 0 "OFFSET2" H 3800 2000 50  0000 C CNN
F 1 "20K" H 3800 2100 50  0000 C CNN
F 2 "~" H 3800 2100 60  0000 C CNN
F 3 "~" H 3800 2100 60  0000 C CNN
	1    3800 2100
	0    1    1    0   
$EndComp
Text GLabel 3950 2400 3    60   Input ~ 0
5V
NoConn ~ 3800 2350
$Comp
L GND #PWR2
U 1 1 5349C88D
P 2550 1450
F 0 "#PWR2" H 2550 1450 30  0001 C CNN
F 1 "GND" H 2550 1380 30  0001 C CNN
F 2 "" H 2550 1450 60  0000 C CNN
F 3 "" H 2550 1450 60  0000 C CNN
	1    2550 1450
	1    0    0    -1  
$EndComp
Text Notes 3450 1600 0    60   ~ 0
not used - change\nback to save on pots?
$Comp
L GND #PWR11
U 1 1 5355C365
P 8000 4950
F 0 "#PWR11" H 8000 4950 30  0001 C CNN
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
L GND #PWR4
U 1 1 5355C5B1
P 3650 5350
F 0 "#PWR4" H 3650 5350 30  0001 C CNN
F 1 "GND" H 3650 5280 30  0001 C CNN
F 2 "" H 3650 5350 60  0000 C CNN
F 3 "" H 3650 5350 60  0000 C CNN
	1    3650 5350
	1    0    0    -1  
$EndComp
$Comp
L R R4
U 1 1 5355C5BE
P 8000 4600
F 0 "R4" V 8080 4600 40  0000 C CNN
F 1 "empty" V 8007 4601 40  0000 C CNN
F 2 "" V 7930 4600 30  0000 C CNN
F 3 "" H 8000 4600 30  0000 C CNN
	1    8000 4600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR6
U 1 1 5355C66A
P 3850 4400
F 0 "#PWR6" H 3850 4400 30  0001 C CNN
F 1 "GND" H 3850 4330 30  0001 C CNN
F 2 "" H 3850 4400 60  0000 C CNN
F 3 "" H 3850 4400 60  0000 C CNN
	1    3850 4400
	1    0    0    -1  
$EndComp
$Comp
L R R6
U 1 1 535734BD
P 1700 2450
F 0 "R6" V 1780 2450 40  0000 C CNN
F 1 "10k" V 1707 2451 40  0000 C CNN
F 2 "~" V 1630 2450 30  0000 C CNN
F 3 "~" H 1700 2450 30  0000 C CNN
	1    1700 2450
	0    -1   -1   0   
$EndComp
$Comp
L POT GAIN1
U 1 1 53573527
P 1300 2450
F 0 "GAIN1" H 1300 2350 50  0000 C CNN
F 1 "100K" H 1300 2450 50  0000 C CNN
F 2 "~" H 1300 2450 60  0000 C CNN
F 3 "~" H 1300 2450 60  0000 C CNN
	1    1300 2450
	0    1    1    0   
$EndComp
Text GLabel 1300 2200 1    60   Input ~ 0
5V
$Comp
L GND #PWR1
U 1 1 5357352F
P 1300 2850
F 0 "#PWR1" H 1300 2850 30  0001 C CNN
F 1 "GND" H 1300 2780 30  0001 C CNN
F 2 "" H 1300 2850 60  0000 C CNN
F 3 "" H 1300 2850 60  0000 C CNN
	1    1300 2850
	1    0    0    -1  
$EndComp
Text Notes 1100 3000 0    60   ~ 0
Extra stuff for positive\noffset from zero!
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
L GND #PWR10
U 1 1 5359E691
P 7400 3850
F 0 "#PWR10" H 7400 3850 30  0001 C CNN
F 1 "GND" H 7400 3780 30  0001 C CNN
F 2 "" H 7400 3850 60  0000 C CNN
F 3 "" H 7400 3850 60  0000 C CNN
	1    7400 3850
	-1   0    0    1   
$EndComp
Text GLabel 7400 4850 3    60   Input ~ 0
5V
Wire Wire Line
	9650 2200 9650 2350
Wire Wire Line
	9650 2350 9800 2350
Wire Wire Line
	2450 4450 2550 4450
Wire Wire Line
	8000 4350 8200 4350
Wire Wire Line
	3650 5200 3650 5350
Wire Wire Line
	9550 2200 9550 2400
Wire Wire Line
	9550 2400 9600 2400
Wire Wire Line
	9600 2400 9600 2500
Wire Wire Line
	4900 4850 4900 4950
Wire Wire Line
	9800 2350 9800 2500
Wire Wire Line
	9450 2500 9450 2200
Wire Wire Line
	4750 6450 4750 6550
Wire Wire Line
	4750 5900 4750 6050
Wire Wire Line
	5100 6450 5100 6550
Wire Wire Line
	5100 5900 5100 6050
Wire Wire Line
	3800 1750 4250 1750
Wire Wire Line
	4150 1750 4150 1850
Wire Wire Line
	4150 2350 4150 2500
Wire Wire Line
	3800 1750 3800 1850
Connection ~ 4150 1750
Wire Wire Line
	3950 2100 3950 2400
Wire Wire Line
	2050 1400 2050 1250
Wire Wire Line
	2550 1250 2550 1450
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
	1300 2700 1300 2850
Wire Wire Line
	7400 3850 7400 3950
Wire Wire Line
	7400 4750 7400 4850
Text GLabel 3900 3250 2    60   Input ~ 0
lowcut
Text GLabel 4900 4050 1    60   Input ~ 0
lowcut
$Comp
L POT LOW1
U 1 1 5359E724
P 3750 3250
F 0 "LOW1" H 3750 3150 50  0000 C CNN
F 1 "1k" H 3750 3250 50  0000 C CNN
F 2 "~" H 3750 3250 60  0000 C CNN
F 3 "~" H 3750 3250 60  0000 C CNN
	1    3750 3250
	0    1    1    0   
$EndComp
Text GLabel 3750 3000 1    60   Input ~ 0
5V
$Comp
L GND #PWR5
U 1 1 5359E72B
P 3750 3650
F 0 "#PWR5" H 3750 3650 30  0001 C CNN
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
	8000 3200 8000 4350
Wire Wire Line
	6900 3350 6900 4250
Wire Wire Line
	6800 4250 7000 4250
Connection ~ 6900 4250
Wire Wire Line
	5500 4450 5500 3550
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
Text Notes 5950 4000 0    60   ~ 0
'lowcut' is the low input\nto the final opamp.
Text Notes 6050 3000 0    60   ~ 0
Gain regulates the distance from \nsensor surface where the signal maxes out.
$Comp
L MCP6001U U3
U 1 1 5359ECE1
P 7500 4350
F 0 "U3" H 7450 4550 60  0000 L CNN
F 1 "MCP6001U" H 7450 4100 60  0000 L CNN
F 2 "~" H 7500 4350 60  0000 C CNN
F 3 "~" H 7500 4350 60  0000 C CNN
	1    7500 4350
	1    0    0    -1  
$EndComp
Wire Wire Line
	5500 4450 7000 4450
$Comp
L R R5
U 1 1 5359ED67
P 6550 4250
F 0 "R5" V 6630 4250 40  0000 C CNN
F 1 "10k" V 6557 4251 40  0000 C CNN
F 2 "~" V 6480 4250 30  0000 C CNN
F 3 "~" H 6550 4250 30  0000 C CNN
	1    6550 4250
	0    -1   -1   0   
$EndComp
Wire Wire Line
	6150 4250 6300 4250
$EndSCHEMATC
