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
	           + vgroup("Oscillator3", osc(meh * 2380 + 20) * (meh - 1.0) * -96) 
	           + vgroup("Oscillator4", osc(meh * 2380 + 20) * (meh - 1.0) * -96) 
	           + vgroup("Oscillator5", osc(meh * 2380 + 20) * (meh - 1.0) * -96) 
	           + vgroup("Oscillator6", osc(meh * 2380 + 20) * (meh - 1.0) * -96) 
	           + vgroup("Oscillator7", osc(meh * 2380 + 20) * (meh - 1.0) * -96) 
	           + vgroup("Oscillator8", osc(meh * 2380 + 20) * (meh - 1.0) * -96) 
	           + vgroup("Oscillator9", osc(meh * 2380 + 20) * (meh - 1.0) * -96) 
             + vgroup("Oscillator10", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator11", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator12", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator13", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator14", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator15", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator16", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator17", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator18", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator19", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator20", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator21", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator22", osc(meh * 2380 + 20) * (meh - 1.0) * -96)
	           + vgroup("Oscillator23", osc(meh * 2380 + 20) * (meh - 1.0) * -96);
