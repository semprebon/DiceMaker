include <DiceMaker.scad>

DIE_TYPE = "base"; // [base,skill,d8,d10,d12]
//==========================================================================================================
// Year Zero System Dice

// Base & Gear Dice: 1=Fail on Push; 6=Success
// Skill Dice: 6=Success
// Artifact(gear) Dice:
//      D8:     6,7=Success; 8=2 successes
//      D10:    6,7=Success; 8,9=2 successes; 10=3 successes
//      D12:    6,7=Success; 8,9=2 successes; 10,11=3 successes; 12=4 Successes

// Base D6 with numbers
//die_from_coordinates(CUBE_COORDS, radius=8, label_size=5, labels=[define_face("💀", sizes=[7]),"2","3","4","5", define_face("☼6", sizes=[10,5])]);

// Base D6 without numbers - used for gear dice and base dice
module forbidden_lands_base_die() {
    r = 6.5;
    h = 5;
    a1 = atan(sqrt(1/2));

    translate([0,0,h]) rotate([45,-a1,0]) translate([r,r,r])
    die_from_coordinates(CUBE_COORDS, radius=r, label_size=6, labels=["💀","","","","", define_face("⚔", sizes=[9])]);
    for (i=[0,120,240]) rotate([0,0,i]) fin_support([0,0,h], [r*2*cos(a1),0,h+r*2*sin(a1)]);
    support([0,0,h+FIN_DEPTH], tip_width=0.2);
}

module forbidden_lands_skill_die() {
    r = 7.5;
    h = 5;
    a1 = atan(sqrt(1/2));

    translate([0,0,h]) rotate([45,-a1,0]) translate([r,r,r])
        die_from_coordinates(CUBE_COORDS, radius=r, label_size=6, labels=[define_face("⚔", sizes=[9]),"","","","",""]);
    for (i=[0,120,240]) rotate([0,0,i]) fin_support([0,0,h], [r*2*cos(a1),0,h+r*2*sin(a1)]);
    support([0,0,h+FIN_DEPTH], tip_width=0.2);
}

module forbidden_lands_d8() {
    r = 8;
    h = 5;
    a = sqrt(6) * r;
    alt = a * sqrt(2)/2;
    a1 = 45;

    s1 = define_face("⚔", sizes=[9], dist=SAME, rotation=30, offset=[0,0.5]);
    s2 = define_face("⚔⚔", sizes=[8,8], dist=VERTICAL, rotation=210, offset=[0,0.7]);
    //s1 = define_face("⚔", dist=SAME, rotation=30);
    // = define_face("⚔⚔", dist=VERTICAL, rotation=30);
    translate([0,0,h]) translate([0,0,alt])
        die_from_coordinates(OCTAHEDRON_COORDS, radius=8, label_size=3,
            labels=[s1,"","","","","",s1, s2]);

    for (i=[0,90,180,270]) rotate([0,0,i]) fin_support([0,0,h], [r*2*cos(a1),0,h+r*2*sin(a1)]);
    support([0,0,h+FIN_DEPTH], tip_width=0.2);
    //die_from_coordinates(OCTAHEDRON_COORDS, radius=7.9, label_size=5,
    //labels=["☼","","","","","☼","", define_face("☼☼", sizes=[4,4], dist=VERTICAL)]);
}

module forbidden_lands_d10() {
    r = 13;
    h = 5;
    a = sqrt(6) * r;
    alt = 19;
    a1 = 42;

    s1 = define_face("⚔", sizes=[10], dist=SAME, rotation=90, offset=[0,-0.6]);
    s2 = define_face("⚔⚔", sizes=[9,9], dist=VERTICAL, rotation=90, offset=[0,-0.6]);
    s3 = define_face("⚔⚔⚔", sizes=[8,8,8], dist=TRIANGULAR, rotation=90);
    s1a = define_face("⚔", sizes=[10], dist=SAME, rotation=-90, offset=[0,-0.6]);
    s2a = define_face("⚔⚔", sizes=[9,9], dist=VERTICAL, rotation=-90, offset=[0,-0.6]);

    translate([0,0,h]) translate([0,0,alt])
        die_from_coordinates(DECAHEDRON_COORDS, radius=13, label_size=5,
            labels=[s1a,s3,"","",s2a,s1,"", s2, "", ""]);
//            labels=["","","","","","","","","",""]);
    //die_from_coordinates(DECAHEDRON_COORDS, radius=14, label_size=8,
    //    labels=["1","2","3","4","5","6","7", "8", "9", "10"]);
    for (i=[0,72,144,216,288]) rotate([0,0,i-18]) fin_support([0,0,h], [r*2*cos(a1),0,h+r*2*sin(a1)]);
    support([0,0,h+FIN_DEPTH], tip_width=0.2);
}

// Skill D6
//die_from_coordinates(CUBE_COORDS, radius=8, label_size=6, labels=["","","","","", define_face("⚔", sizes=[9])]);

// Skill D6 without numbers
//die_from_coordinates(CUBE_COORDS, radius=8, label_size=10, labels=["","","","","", "☼"]);

// Skill D8 without numbers
//s1 = define_face("⚔", sizes=[6], dist=SAME, rotation=30);
//s2 = define_face("⚔⚔", sizes=[5,5], dist=VERTICAL, rotation=30);
//die_from_coordinates(OCTAHEDRON_COORDS, radius=8, label_size=6,
//    labels=[s1,"","","","",s1,"", s2]);
//die_from_coordinates(OCTAHEDRON_COORDS, radius=7.9, label_size=5,
//labels=["☼","","","","","☼","", define_face("☼☼", sizes=[4,4], dist=VERTICAL)]);

//s1t = define_face("⚔", sizes=[6], dist=SAME, rotation=-90, offset=[0,0.4]);
//s1b = define_face("⚔", sizes=[6], dist=SAME, rotation=-90, offset=[0,-0.4]);
//s2t = define_face("⚔⚔", sizes=[5,5], dist=VERTICAL*0.5, rotation=90, offset=[0,-0.4]);
//s2b = define_face("⚔⚔", sizes=[5,5], dist=VERTICAL*0.5, rotation=90, offset=[0,0.4]);
//s3 = define_face("⚔⚔⚔", sizes=[5,5,5], dist=TRIANGULAR*0.5, rotation=-90, offset=[0,-0.4]);
//die_from_coordinates(DECAHEDRON, radius=10, label_size=6,
//labels=[s1b,"","",s1t,s2b,"",s3,s2t,"",""]);

module forbidden_lands_d12() {
    r = 16;
    h = 5;
    a = r/1.1135;

    alt = 18.811;
    a1 = 20;
    a2 = 30;
    delta = -21;
    //elta = 0;
    echo(delta=delta);
    s1 = define_face("⚔", sizes = [10], dist = SAME);
    s2 = define_face("⚔⚔", sizes = [8, 8], dist = VERTICAL * 0.4);
    s3 = define_face("⚔⚔⚔", sizes = [8, 8, 8], dist = TRIANGULAR * 0.5, rotation = 2000, offset = [0, 0.2]);
    s4 = define_face("⚔⚔⚔⚔", sizes = [8, 8, 8, 8], dist = SQUARE * 0.5, rotation = 170, offset = [0, 0.2]);

    translate([0,0,h]) rotate([0,delta,0]) translate([a/2,0,alt])
        die_from_coordinates(DODECAHEDRON_COORDS, radius=r, label_size = 8,,
            labels = [s1, "", s3, "", s2, s2, "", s1, "", s3, s4, ""]);

    for (i=[0,120,240]) rotate([0,0,i]) {
        fin_support([0,0,h], [0.85*r*cos(a1),0,h+0.85*r*sin(a1)]);
        fin_support([0.85*r,0,h], [r*cos(a1),0,h+r*sin(a2)]); // NEEDS WORK
    }
    support([0,0,h+FIN_DEPTH], tip_width=0.2);

}

//module forbidden_lands_d12() {
//    s1 = define_face("⚔", sizes = [6], dist = SAME);
//    s2 = define_face("⚔⚔", sizes = [5, 5], dist = VERTICAL * 0.4);
//    s3 = define_face("⚔⚔⚔", sizes = [4.5, 4.5, 4.5], dist = TRIANGULAR * 0.4, rotation = 180, offset = [0, 0.2]);
//    s4 = define_face("⚔⚔⚔⚔", sizes = [4.5, 4.5, 4.5], dist = SQUARE * 0.4, rotation = - 90);
//    die_from_coordinates(DODECAHEDRON_COORDS, radius=8.75, label_size = 6, ,
//    labels = [s1, "", s3, "", s2, s2, "", s1, "", s3, s4, ""]);
//}

if (DIE_TYPE == "base") forbidden_lands_base_die();
if (DIE_TYPE == "skill") forbidden_lands_skill_die();
if (DIE_TYPE == "d8") forbidden_lands_d8();
if (DIE_TYPE == "d10") forbidden_lands_d10();
if (DIE_TYPE == "d12") forbidden_lands_d12();

