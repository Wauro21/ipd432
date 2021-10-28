EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L 74xGxx:74AUC2G79 U?
U 1 1 6168F932
P 4700 3150
F 0 "U?" H 4700 3467 50  0001 C CNN
F 1 "74AUC2G79" H 4700 3376 50  0001 C CNN
F 2 "" H 4700 3150 50  0001 C CNN
F 3 "http://www.ti.com/lit/sg/scyt129e/scyt129e.pdf" H 4700 3150 50  0001 C CNN
	1    4700 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 3050 4450 3050
Wire Wire Line
	3500 3250 3400 3250
Wire Wire Line
	3400 3250 3400 3600
Wire Wire Line
	3400 3600 4350 3600
Wire Wire Line
	4350 3600 4350 3250
Wire Wire Line
	4350 3250 4450 3250
Text GLabel 2650 3600 0    50   Input ~ 0
CLK
Connection ~ 3400 3600
Text Label 4000 3050 0    50   ~ 0
PB_sync_aux
$Comp
L 74xGxx:74AUC2G79 U?
U 1 1 6168F2AD
P 3750 3150
F 0 "U?" H 3750 3467 50  0001 C CNN
F 1 "74AUC2G79" H 3750 3376 50  0001 C CNN
F 2 "" H 3750 3150 50  0001 C CNN
F 3 "http://www.ti.com/lit/sg/scyt129e/scyt129e.pdf" H 3750 3150 50  0001 C CNN
	1    3750 3150
	1    0    0    -1  
$EndComp
Wire Notes Line
	5250 2900 5250 3800
Wire Notes Line
	5250 3800 3200 3800
Wire Notes Line
	3200 3800 3200 2900
Wire Notes Line
	3200 2900 5250 2900
Text Notes 3200 2900 0    50   ~ 0
Async_To_sync
Wire Wire Line
	2650 3600 3400 3600
Wire Wire Line
	3500 3050 2650 3050
Text GLabel 2650 3050 0    50   Input ~ 0
PB
Text Label 5300 3050 0    50   ~ 0
PB_sync
$Comp
L 74xGxx:74AHC1G08 U?
U 1 1 61695506
P 6300 3100
F 0 "U?" H 6275 3367 50  0001 C CNN
F 1 "74AHC1G08" H 6275 3276 50  0001 C CNN
F 2 "" H 6300 3100 50  0001 C CNN
F 3 "http://www.ti.com/lit/sg/scyt129e/scyt129e.pdf" H 6300 3100 50  0001 C CNN
	1    6300 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	4950 3050 5600 3050
$EndSCHEMATC
