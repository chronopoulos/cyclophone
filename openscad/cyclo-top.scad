diameter = 40.2;
iringouter = 17.0;
iringinner = 13.5;
knobheight = 0.66;

module maindisc() {
cylinder(h=0.5,r=diameter*0.5,
    $fn=48);
}

module donut1() {
  difference() {  
    cylinder(h=0.5,r=diameter*0.5,
        $fn=48);

    translate([0,0,-0.5])  
    cylinder(h=1.5,r=(diameter - 1)*0.5,
        $fn=48);
  }
}

module donut2() {
  difference() {  
    cylinder(h=0.5,r=iringouter*0.5,
        $fn=48);

    translate([0,0,-0.5])  
    cylinder(h=1.5,r=iringinner*0.5,
        $fn=48);
  }
}

module both() {
  donut1();
  donut2();
}

module quarter1() {
  difference() {
    donut1();
    translate([-20.5,0,-.5])
    cube([41,21,2]);
    rotate([0,0,90])
    translate([-20.5,0,-.5])
    cube([41,21,2]);
  }  
}

module q1(i) { 
  spacing = 1.7;
  translate([spacing * i,-1 * spacing * i,0])
  quarter1();
}
module allq1() {
  q1(1);
  q1(2);
  q1(3);
  q1(4);
  q1(5);
  q1(6);
  q1(7);
  q1(8);
}

module quarter2() {
  difference() {
    donut2();

    translate([-20.5,0,-.5])
    cube([41,21,2]);
    rotate([0,0,90])
    translate([-20.5,0,-.5])
    cube([41,21,2]);
  }  
}

module q2(i) { 
  spacing = 2;
  translate([spacing * i,-1 * spacing * i,0])
  quarter2();
}

module allq2() {
  q2(1);
  q2(2);
  q2(3);
  q2(4);
  q2(5);
  q2(6);
  q2(7);
  q2(8);
}


// maindisc();
// allq1();
// allq2();


