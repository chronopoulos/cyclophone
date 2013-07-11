top_or = 24;
top_ir = 12;
top_thick = 0.5;

cutwidth = 0.2;

spacer_l = 3;
spacer_w = 1.5;
spacer_h = 4;

bottom_or = 15;
bottom_ir = top_ir - spacer_l;
bottom_thick = 3/8.;


// top
difference(){

	cylinder(h=top_thick, r=top_or, center=True);

	union(){
		for ( i = [0 : 23] ){
			rotate(i*360/24+360/48, [0, 0, 1])
			translate([top_or-top_ir,-cutwidth/2,0])
			cube([top_or-top_ir,cutwidth,top_thick]);
		}
	}

}

// spacers
for ( i = [0 : 23] ){
	rotate(i*360/24, [0, 0, 1])
	translate([top_or-top_ir-spacer_l,-spacer_w/2,top_thick])
	cube([spacer_l,spacer_w,spacer_h]);
}

// bottom
translate([0,0,top_thick+spacer_h])
difference(){
cylinder(h=bottom_thick, r=bottom_or, center=True);
cylinder(h=bottom_thick, r=bottom_ir, center=True);
};