// units are mm

base_l = 12;
base_h = 3;

switch_height = 6.51-1.;
switch_width = 6.63;
switch_thickness = 3.08;

diff = 0.5;
wire = 0.5;

top_layer = switch_thickness-wire;
bottom_layer = h - top_layer;

wall_thickness = 2;


//////////

// base
cube([base_l,2*switch_width,base_h]);

// shelf long
translate([0,0,base_h])
cube([switch_height,switch_width,switch_thickness-wire]);

// shelf short
translate([0,switch_width,base_h])
cube([switch_height-diff,switch_width,switch_thickness-wire]);

// walls
translate([0,-wall_thickness,0])
cube([base_l,wall_thickness,base_h+switch_thickness-wire]);
translate([0,2*switch_width,0])
cube([base_l,wall_thickness,base_h+switch_thickness-wire]);

