include <DiceMaker.scad>

DIE_TYPE = "upper"; // [upper,lower,digits,symbols]
//==========================================================================================================

// Upper case letters on d20
module d20_die(labels) {
    r = 11;
    ri = r*0.9510/0.7557;
    h = 3;
    //a1 = atan(sqrt(1/2));
    a1 = 31.5;
    a2 = -18;

    translate([0,0,h+ri]) rotate([a1,0,a2]) translate([0,0,0])
        die_from_coordinates(ICOSAHEDRON_COORDS, radius=r, label_size=5, labels=labels, font="Arial");
    for (i=[0,72,144,216,288]) rotate([0,0,i]) fin_support([0,0,h], [r*1.3*cos(a1),0,h+r*1.3*sin(a1)]);
        support([0,0,h+FIN_DEPTH], tip_width=0.2);
}

module upper_case_die() {
    d20_die(["A","B","D","E","F","G","H","K","L","M","N","P","Q","R","S","T","V","X","Y", "Z"]);
}

module lower_case_die() {
    d20_die(["a","b","d","e","f","g","h","k","m","n","p","q","r","s","t","u","w","x","y","z"]);
}

function range_for(a) = [0:(len(a)-1)];
function bool_to_signum(b) = b ? 1 : -1;

module d10_die(labels) {
    r = 9;
    h = 5;
    a = sqrt(6) * r;
    alt = 19*r/13;
    a1 = 42;
    sides = [ for (i=range_for(labels)) define_face(labels[i], dist=SAME, rotation=(i%2==0)?-90:90, offset=[0,(i%2==0)?-0.6:-0.6]) ];
    // sides = [ for (s=labels) define_face(s, dist=SAME, rotation=90, offset=[0,-0.6]) ];
    echo(sides=sides, length=len(sides));

    translate([0,0,h]) translate([0,0,alt])
        die_from_coordinates(DECAHEDRON_COORDS, radius=r, label_size=5, labels=sides);
    //            labels=["","","","","","","","","",""]);
    //die_from_coordinates(DECAHEDRON_COORDS, radius=14, label_size=8,
    //    labels=["1","2","3","4","5","6","7", "8", "9", "10"]);
    for (i=[0,72,144,216,288]) rotate([0,0,i-18]) fin_support([0,0,h], [r*2*cos(a1),0,h+r*2*sin(a1)]);
    support([0,0,h+FIN_DEPTH], tip_width=0.2);
}

module d8_die(labels) {
    r = 8;
    h = 5;
    a = sqrt(6) * r;
    alt = a * sqrt(2)/2;
    a1 = 45;

    translate([0,0,h]) translate([0,0,alt])
        die_from_coordinates(OCTAHEDRON_COORDS, radius=8, label_size=6, labels=labels, font="Arial");

    for (i=[0,90,180,270]) rotate([0,0,i]) fin_support([0,0,h], [r*2*cos(a1),0,h+r*2*sin(a1)]);
    support([0,0,h+FIN_DEPTH], tip_width=0.2);
    //die_from_coordinates(OCTAHEDRON_COORDS, radius=7.9, label_size=5,
    //labels=["☼","","","","","☼","", define_face("☼☼", sizes=[4,4], dist=VERTICAL)]);
}

module digits_diex() {
    d10_die(["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
}

module digits_die() {
    d8_die(["2", "3", "4", "5", "6", "7", "8", "9"]);
}

module d12_die(labels) {
    r = 9;
    h = 4.5;
    a = r/1.1135;

    alt = 18.811*r/16;
    a1 = 22;

    a2 = 52;
    a3 = 37.7;
    r2 =r*18.9/16;
    delta = -21;

    sides = [ for (s=labels) define_face(s, dist=SAME) ];

    translate([0,0,h]) rotate([0,delta,0]) translate([a/2,0,alt])
        die_from_coordinates(DODECAHEDRON_COORDS, radius=r, label_size=6, labels=labels, font="Arial");

    for (i=[0,120,240]) rotate([0,0,i]) {
        fin_support([0,0,h], [0.85*r*cos(a1),0,h+0.85*r*sin(a1)]);
        echo(r=r, h=h, r2=r2, a2=a2, a3=a3);
        //fin_support([0.85*r,0,h], [0.90*r2*sin(a2), r2*cos(a2), h+0.90*r + r2*sin(a2)], raft_width=0); // NEEDS WORK
        fin_support([0.90*r*cos(a1),0,h+0.90*r*sin(a1)], [r2*cos(a3),r2*sin(a3),h+0.90*r2*sin(a2)]);
        fin_support([0.90*r*cos(a1),0,h+0.90*r*sin(a1)], [r2*cos(a3),r2*sin(-a3),h+0.90*r2*sin(a2)]);

    }
    support([0,0,h+FIN_DEPTH], tip_width=0.2);

}

module symbols_die(labels) {
    d12_die(["!","@","#","$","%","|",":","*","~","?","=","+"]);
}

//module forbidden_lands_d12() {
//    s1 = define_face("⚔", sizes = [6], dist = SAME);
//    s2 = define_face("⚔⚔", sizes = [5, 5], dist = VERTICAL * 0.4);
//    s3 = define_face("⚔⚔⚔", sizes = [4.5, 4.5, 4.5], dist = TRIANGULAR * 0.4, rotation = 180, offset = [0, 0.2]);
//    s4 = define_face("⚔⚔⚔⚔", sizes = [4.5, 4.5, 4.5], dist = SQUARE * 0.4, rotation = - 90);
//    die_from_coordinates(DODECAHEDRON_COORDS, radius=8.75, label_size = 6, ,
//    labels = [s1, "", s3, "", s2, s2, "", s1, "", s3, s4, ""]);
//}

if (DIE_TYPE == "upper") upper_case_die();
if (DIE_TYPE == "lower") lower_case_die();
if (DIE_TYPE == "digits") digits_die();
if (DIE_TYPE == "symbols") symbols_die();

