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
//vol 			= hslider("volume [unit:dB]", -96, -96, 0, 0.1) : db2linear : smooth(0.999) ;
//freq 			= hslider("freq [unit:Hz]", 1000, 20, 24000, 1);

meh 			= hslider("meh", 0.0,0.0, 1.0, 1);

process 		=  vgroup("Oscillator0", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator1", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator2", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator3", osc(meh * 2380 + 20) * (meh - 1.0) * -96);
