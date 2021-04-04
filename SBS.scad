include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>

$fa = 1; // Set these to 1 for faster preview.
$fs = 1; // ----------------------------------
fudge=0.1; // Don't change this value

module battery_21700 () {
cylinder(h=70.5,d=21);
}

module mUSB(){
  //usb.org CabConn20.pdf
  
  M= 6.9;   //Rece inside width
  N= 1.85;  //Rece inside Height -left/right
  
  C= 3.5;   //Plastic width
  X= 0.6;   //plastic height
  U= 0.22;  //plastic from shell
  P= 0.48;  //Conntacst from plastic
  
  Q= 5.4;   //shell inside bevel width
  R= 1.1;   //shell inside bevel height -left/right
  
  S= 4.75;  //Latch separation 
  T= 0.6;   //Latch width -left/right
  V= 1.05;  //Latch recess
  W= 2.55;  //Latch recess
  Y= 0.56;  //Latch Height
  Z= 60;    //Latch Angle
  
  H= 2.6;   //Pin1-5 separation
  I= 1.3;   //Pin2-4 separation
  conWdth= 0.37; //# contact width
  
  conThck= 0.1; //contact thickness
  
  //JAE DX4R005J91
  r=0.25; //corner radius
  t=0.25; //sheet thickness
  
  //flaps
  flpLngth=0.6;
  flpDimTop=[6.2,flpLngth,t];
  flpDimBot=[5.2,flpLngth,t];
  flpDimSide=[0.75,flpLngth,t];
  
  flpAng=40;
  
  THT_OZ=-(5-1.8);
  legDim=[0.9,0.65-r/2,t];
    translate([0,-THT_OZ,0]){
    //THT pins
    color("silver"){
      for (ix=[-1,1]){
        translate([ix*(6.45/2-r),THT_OZ,t/2])
          rotate(ix*-90)
            bend(size=legDim,radius=r,angle=-90,center=true)
              flap(legDim);
      }
      translate([0,THT_OZ,t/2]) cube([6.45-r*2,0.9,t],true);  
    }
    
    //SMD pads
    padDim=[1,1,t];
    color("silver")
      for (ix=[-1,1]){
        translate([ix*(M+t)/2,-(padDim.x/2),r+t]) rotate([-90,0,ix*-90])
          bend(padDim,angle=-90,radius=r+t/2,center=true)
            flap(padDim);
        translate([ix*(M+t)/2,-(padDim.x/2),1.1/2+t/2+r])
          cube([t,padDim.x,1.1-r],true);
      }
      
    //SMD pins
      for (ix=[-H/2,-I/2,0,I/2,H/2]){
        color("gold")
        translate([ix,-0.7,r+conThck/2])
          rotate([-90,0,0])
            bend([conWdth,1-r,conThck],center=true,angle=90,radius=r)
              cube([conWdth,1-r,conThck],center=true);
        color("gold")
        translate([ix,-W/2-1-t,-X+t+N-(conThck)/2]) 
          cube([conWdth,W-fudge,conThck],true); 
     }
     
    //plastics
    color("darkSlateGrey")
      translate([0,-t,N/2+t])
        rotate([90,0,0])
         hull()
            for (ix=[-1,1],iy=[-1,1])
              translate([ix*(M/2-r),iy*(N/2-r)]) cylinder(r=r-0.01, h=1);
    color("darkSlateGrey")
       translate([0,-W/2-1-t,-X/2+t+N-U]) plastic();     
                
    //metal-body with cutouts
    color("silver"){
      difference(){
        shell();
        translate([0,THT_OZ,t+(t+1)/2]) cube([7.4+fudge,1,1+t],true);
        translate([0,-(1+t)/2+fudge/2,(t+1.1-fudge)/2]) cube([7.4+fudge,1+t+fudge,1.1+t+fudge],true);
        //Latch
        for (ix=[-1,1])
          translate([ix*S/2,THT_OZ,N+t*1.5]) cube([T,1.2,t+fudge],true);
      }
      //flaps
      translate([0,-5,N+t/2+t])
        rotate(180)
          bend(flpDimTop,angle=flpAng,radius=r,center=true)
            flap(flpDimTop);
      translate([0,-5,t/2])
        rotate(180)
        bend(flpDimBot,angle=-flpAng,radius=r,center=true)
          flap(flpDimBot);
      for (ix=[-1,1])
        translate([ix*(M+t)/2,-5,t+N-R/2])
          rotate([0,ix*-90,180])
            bend(flpDimSide,angle=flpAng,radius=r,center=true)
              flap(flpDimSide);
    }
  }
  
  module plastic(){
    difference(){
      cube([C,W,X],true);
      for (ix=[-H/2,-I/2,0,I/2,H/2])
        translate([ix,0,-X/2+(X-P+conThck-fudge)/2]) 
          cube([conWdth,W+fudge,X-P+conThck+fudge],true); 
    }
  }
  
  module shell(){
    translate([0,0,N-R/2+t])
      rotate([90,0,0]){
          difference(){ //2D
            shape(radius=r+t,length=5);
            translate([0,0,-fudge/2]) shape(radius=r,length=5+fudge);
          }
    }
  }

  //the usb shape
  module shape(radius=r,length=5){
    hull(){
      for (ix=[-1,1],iy=[-1,1])
        translate([ix*(M/2-r),iy*(R/2-r),0]) cylinder(r=radius,h=length);
      for (ix=[-1,1])
        translate([ix*(Q/2-r/2),-N+(R/2+r),0]) cylinder(r=radius,h=length);
    }
  }
 
  module flap(size){
    hull() for (ix=[-1,1])
      translate([ix*(size.x/2-r),size.y/2-r,0]) cylinder(r=r,h=size.z,center=true); 
    translate([0,-r/2,0]) cube([size.x,size.y-r,size.z],true);
  }
  module pcb(){
      difference(){
      translate([0,6.25,-0.75])
      cube([16.8,15.5,1.6], center=true);
      translate([-7.25,12.75,-0.75])
      cylinder(r=1, h=1.8, center=true);
      translate([7.25,12.75,-0.75])
      cylinder(r=1, h=1.8, center=true);  
   }
  }
 pcb();
module bend(size=[50,20,2],angle=45,radius=10,center=false, flatten=false){
  alpha=angle*PI/180; //convert in RAD
  strLngth=abs(radius*alpha);
  i = (angle<0) ? -1 : 1;
  
  
  bendOffset1= (center) ? [-size.z/2,0,0] : [-size.z,0,0];
  bendOffset2= (center) ? [0,0,-size.x/2] : [size.z/2,0,-size.x/2];
  bendOffset3= (center) ? [0,0,0] : [size.x/2,0,size.z/2];
  
  childOffset1= (center) ? [0,size.y/2,0] : [0,0,size.z/2*i-size.z/2];
  childOffset2= (angle<0 && !center) ? [0,0,size.z] : [0,0,0]; //check
  
  flatOffsetChld= (center) ? [0,size.y/2+strLngth,0] : [0,strLngth,0];  
  flatOffsetCb= (center) ? [0,strLngth/2,0] : [0,0,0];  
  
  angle=abs(angle);
  
  if (flatten){
    translate(flatOffsetChld) children();
    translate(flatOffsetCb) cube([size.x,strLngth,size.z],center);
  }
  else{
    //move child objects
    translate([0,0,i*radius]+childOffset2) //checked for cntr+/-, cntrN+
      rotate([i*angle,0,0]) 
      translate([0,0,i*-radius]+childOffset1) //check
        children(0);
    //create bend object
    
    translate(bendOffset3) //checked for cntr+/-, cntrN+/-
      rotate([0,i*90,0]) //re-orientate bend
       translate([-radius,0,0]+bendOffset2)
        rotate_extrude(angle=angle) 
          translate([radius,0,0]+bendOffset1) square([size.z,size.x]);
  }
}
}

module mUSB_hole(){
    translate([0,28,4.75])
    fillet(fillet=1.5, size=[8.5,10,3], $fn=64) {
    cube(size=[8.5,10,3], center=true);
 }
}

module Chassis(){
    translate([0,0,40])
    difference(){
    union(){
    cube(size=[25,25,80], center=true);
    translate([0,12.5,0])
    cylinder(d=25, h=80, center=true);
    translate([0,-12.5,0])
    cylinder(d=25, h=80, center=true);
    }
    translate([0,12.5,9])
    cylinder(d=22, h=2, center=true);
    translate([0,0,-39])
    battery_enclosure();
    battery_door_cut();
    rotate([0,90,0])
    translate([0,-30.75,0])
    cylinder(d=40, h=26, center=true);
 }  
}
module battery_enclosure(){
  union(){
    translate([0,-12.5,39])
    cylinder(h=75,d=24, center=true);
    translate([0,0,23])
    cube([22,22,43],center=true);
    translate([0,12,23])
    cylinder(d=22, h=43, center=true);
    translate([0,12,42.5])
    cylinder(d=10.5, h=10, center=true);
}
}
module sbs_cut(){
    cylinder(d=26, h=31, center=true);
}

module battery_door_cut(){
  translate([0,-12.75,0])
  rotate([0,0,90])
  union(){
  difference(){
  cylinder(d=25, h=81, center=true);
  cylinder(d=22, h=82, center=true);
  translate([10,0,0])
  cube([20,25,82],center=true);
  }
  translate([-1,11,38.5])
  cylinder(r=1, h=2.1, center=true);
  translate([-1,11,-38.5])
  cylinder(r=1, h=2.1, center=true);
  translate([-1,-11,38.5])
  cylinder(r=1, h=2.1, center=true);
  translate([-1,-11,-38.5])
  cylinder(r=1, h=2.1, center=true);
 }
}
module battery_door(){
  translate([0,-12.75,0])
  rotate([0,0,90])
  union(){
  difference(){
  cylinder(d=25, h=80, center=true);
  cylinder(d=22, h=81, center=true);
  translate([10,0,0])
  cube([20,25,81],center=true);
  rotate([0,90,90])
  translate([0,-18,0])
  cylinder(d=40, h=25, center=true);
  }
  translate([-1,11,38.5])
  cylinder(r=1, h=2, center=true);
  translate([-1,11,-38.5])
  cylinder(r=1, h=2, center=true);
  translate([-1,-11,38.5])
  cylinder(r=1, h=2, center=true);
  translate([-1,-11,-38.5])
  cylinder(r=1, h=2, center=true);
 }
}

difference(){
Chassis();
translate([0,12.5,64.51])
sbs_cut();
}

//battery_enclosure();
translate([0,-12.5,4.5])
battery_21700();

translate([0,0,40])
battery_door();
