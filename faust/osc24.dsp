declare name 		"osc";
declare version 	"1.0";
declare author 		"Grame";
declare license 	"BSD";
declare copyright 	"(c)GRAME 2009";

//-----------------------------------------------
// 			Sinusoidal Oscillator
//-----------------------------------------------

import("music.lib");

smooth(c)		= *(1-c) : +~*(c);
// initial value 0, ie full blast:
//vol 			= hslider("volume [unit:dB]", 0, -96, 0, 0.1) : db2linear : smooth(0.999) ;
// initial value -96, ie off.
vol 			= hslider("volume [unit:dB]", -96, -96, 0, 0.1) : db2linear : smooth(0.999) ;
freq 			= hslider("freq [unit:Hz]", 1000, 20, 24000, 1);


process 		=  vgroup("Oscillator0", osc(freq) * vol)
	           + vgroup("Oscillator1", osc(freq) * vol)
	           + vgroup("Oscillator2", osc(freq) * vol)
	           + vgroup("Oscillator3", osc(freq) * vol)
	           + vgroup("Oscillator4", osc(freq) * vol)
	           + vgroup("Oscillator5", osc(freq) * vol)
	           + vgroup("Oscillator6", osc(freq) * vol)
	           + vgroup("Oscillator7", osc(freq) * vol)
	           + vgroup("Oscillator8", osc(freq) * vol)
	           + vgroup("Oscillator9", osc(freq) * vol)
             + vgroup("Oscillator10", osc(freq) * vol)
	           + vgroup("Oscillator11", osc(freq) * vol)
	           + vgroup("Oscillator12", osc(freq) * vol)
	           + vgroup("Oscillator13", osc(freq) * vol)
	           + vgroup("Oscillator14", osc(freq) * vol)
	           + vgroup("Oscillator15", osc(freq) * vol)
	           + vgroup("Oscillator16", osc(freq) * vol)
	           + vgroup("Oscillator17", osc(freq) * vol)
	           + vgroup("Oscillator18", osc(freq) * vol)
	           + vgroup("Oscillator19", osc(freq) * vol)
	           + vgroup("Oscillator20", osc(freq) * vol)
	           + vgroup("Oscillator21", osc(freq) * vol)
	           + vgroup("Oscillator22", osc(freq) * vol)
	           + vgroup("Oscillator23", osc(freq) * vol);
