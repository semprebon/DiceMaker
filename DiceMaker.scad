//------------------------------------------
// Geometric regular solids in OpenSCAD
//------------------------------------------

DEPTH = 0.3; // Depth of symbols
LABELS = [ for (i=[1:120]) str(i) ];

module rounded(radius=1) {
    minkowski() {
        children();
        sphere(r=1, $fs=0.1);
    }
}

module label(height, rotation=[0,0,0], depth=DEPTH) {
    rotate(rotation) translate([height-depth,0,0]) rotate([0,90,0]) {
        minkowski() {
            linear_extrude(height=0.01) children();
            cylinder(r1=0, r2=depth, h=depth);
        }
    }
}

function cat(L1, L2) = [for(L=[L1, L2], a=L) a];

function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

function with_opposites(angles, z_rotation=0) =
    cat(angles, reverse([ for (a = angles) [a.x-180, a.y, a.z+z_rotation] ]));

function distance(p) = sqrt(p*p);

function rotation_from_coordinates(coord) = [0,atan2(coord.z,distance([coord.x,coord.y])),atan2(coord.y,coord.x)];

function rotations_from_coordinates(coords) = [ for (c = coords) rotation_from_coordinates(c) ];

function with_opposite_coords(coords) = cat(coords, reverse(-1*coords));

//RHOMBIC_DODECAHEDRON = with_opposites([[90,0,45], [0, 90, 45], [45, 0, 0], [0, 45, 0], [-45,0,0], [0,-45,0]]);
//rotate([0,45,90])
//RHOMBIC_DODECAHEDRON = with_opposites([[0,0,0], [0,90,0], [45,120,0] ]);


module label_polyhedron(radius, angles, labels, label_size, depth=DEPTH) {
    all_angles = angles;
    echo(radius=radius, angles=angles,labels=labels, depth=depth);
//    all_angles = angles;
    echo(all_angles=all_angles);
    difference() {
        children();
        for (i=[0:(len(all_angles)-1)]) {
            if (labels[i] != "") {
                label(radius, all_angles[i], depth) {
                    offset(delta=-depth/2) {
                        text(labels[i], size=label_size/sqrt(len(labels[i])), font="Segoe UI Symbol", halign="center", valign="center");
                    }
                }
            }
        }
    }
}

module make_polyhedron(radius, angles) {
    echo(angles=angles);
//    a = angles[0];
    intersection_for(a=angles) {
        rotate(a) translate([-radius/2,0,0]) cube([3*radius, 4*radius, 4*radius], center=true);
    }
}

module polyhedron_from_coordinates(radius, coords) {
    angles = rotations_from_coordinates(coords);
    intersection_for(a=angles) {
        rotate(a) translate([-radius/2,0,0]) cube([3*radius, 4*radius, 4*radius], center=true);
    }
}

NUMBERED = [ for (i=[1:120]) str(i) ];

module die_from_coordinates(coords, radius=10, labels=undef, label_size=6, depth=DEPTH) {
    _labels = (labels==undef) ? [ for (i=[1:len(coords)]) str(i) ] : labels;
    angles=rotations_from_coordinates(coords);
    //edge_radius = radius/10;
    edge_radius = 1.0;
    label_polyhedron(radius, angles, _labels, label_size, depth) {
        rounded(edge_radius) make_polyhedron(radius-edge_radius, angles);
    }
}

function define_die(coordinates, edge_length, face_rotations=undef) =
    let(_edge_rotations=1)
    [];

// note: these are all scaled (with a scaling factor) so that the mid-radius is 1
PHI = (1+sqrt(5)) / 2;

CUBE_COORDS = sqrt(2) * with_opposite_coords([ [1,0,0], [0,1,0], [0,0,1] ]);
TETRAHEDRON_COORDS = 1/3 * [ [sqrt(8/9),0,-1/3], [-sqrt(2/9),sqrt(2/3), -1/3], [-sqrt(2/9),-sqrt(2/3), -1/3], [0,0,1] ];
OCTAHEDRON_COORDS = sqrt(1/2) * with_opposite_coords([ [1,1,1], [1,1,-1], [1,-1,1], [1,-1,-1] ]);
DODECAHEDRON_COORDS = PHI * with_opposite_coords([ [0,1,PHI], [0,-1,PHI], [PHI,0,1], [-PHI,0,1], [1,PHI,0], [1,-PHI, 0] ]);
ICOSAHEDRON_COORDS = (sqrt(PHI+2)-PHI) * with_opposite_coords([ [1,1,1], [1,1,-1], [1,-1,1], [1,-1,-1],
        [0,PHI,1/PHI], [0,PHI,-1/PHI], [1/PHI,0,PHI], [1/PHI,0,-PHI], [PHI,1/PHI,0], [PHI, -1/PHI,0] ]);
TETRAKIS_HEXAHEDRON = 5/3 * with_opposite_coords([ [2,1,1],[2,1,-1],[2,-1,1],[2,-1,-1],
        [1,2,1],[1,2,-1],[-1,2,1],[-1,2,-1], [1,1,2],[1,-1,2],[-1,1,2],[-1,-1,2] ]);

ITH = 1 + sqrt(2);
ICOSITETRAHEDRON = with_opposite_coords([
    [1, 1, ITH], [1, 1, -ITH], [1, -1, ITH], [1, -1, -ITH],
    [1, ITH, 1], [1, -ITH, 1], [1, ITH, -1], [1, -ITH, -1],
    [ITH, 1, 1], [-ITH, 1, 1], [ITH, 1, -1], [-ITH, 1, -1],
]);

RHOMBIC_DODECAHEDRON = with_opposite_coords([ [1,1,0],[1,-1,0],[1,0,1],[1,0,-1],[0,1,1],[0,1,-1] ]);
HEDRONS = [ CUBE_COORDS, TETRAHEDRON_COORDS, OCTAHEDRON_COORDS, DODECAHEDRON_COORDS, ICOSAHEDRON_COORDS,
    TETRAKIS_HEXAHEDRON, RHOMBIC_DODECAHEDRON ] ;

//for (i =[0:(len(HEDRONS)-1)]) {
//    i=6;
//    translate([25*i,0,0]) die_from_coordinates(HEDRONS[i], 10);
//}
//make_labled_polyhedron(10, RHOMBIC_DODECAHEDRON, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"]);
//make_labled_polyhedron(10, RHOMBIC_DODECAHEDRON, ["△", "◇", "", "", "", "", "", "⭘", "△", "", "△", ""]);

// BASIC Dice
//die_from_coordinates(RHOMBIC_DODECAHEDRON, radius=9, label_size=5, depth=0.15, labels=["⭘", "⭘", "", "", "", "◇", "", "", "△", "", "", "⭘"]);
//die_from_coordinates(RHOMBIC_DODECAHEDRON, radius=9, label_size=5, depth=0.15, labels=["◇", "◇", "", "", "", "△", "", "", "⭘", "", "", "◇"]);
//die_from_coordinates(RHOMBIC_DODECAHEDRON, radius=9, label_size=5, depth=0.15, labels=["△", "△", "", "", "", "⭘", "", "", "◇", "", "", "△"]);

//// FLEX Die
//translate([30,0,0])
//die_from_coordinates(CUBE_COORDS, radius=8, label_size=7, depth=0.15, labels=["⭘", "", "◇", "△", "", ""]);

// RISK Dice
//translate([160,0,0])
//die_from_coordinates(DODECAHEDRON_COORDS, radius=9, label_size=5, depth=0.15, labels=["△△", "", "", "", "", "△", "", "", "△△", "△", "", ""]);
//translate([200,0,0])
//die_from_coordinates(DODECAHEDRON_COORDS, radius=9, label_size=5, depth=0.15, labels=["◇◇", "", "", "", "", "◇", "", "", "◇◇", "◇", "", ""]);
//translate([240,0,0])
//die_from_coordinates(DODECAHEDRON_COORDS, radius=9, label_size=5, depth=DEPTH, labels=["⭘⭘", "", "", "", "", "⭘", "", "", "⭘⭘", "⭘", "", ""]);
//die_from_coordinates(DODECAHEDRON, radius=12, labels=["◇◇", "", "◇", "", "", "", "◇◇", "", "◇", "", "", ""]);

//die_from_coordinates(RHOMBIC_DODECAHEDRON, radius=14, label_size=10, labels=["⭘", "", "△", "", "⭘", "", "◇", "", "⭘", "", "", ""]);
//die_from_coordinates(RHOMBIC_DODECAHEDRON, radius=14, label_size=8, labels=["⭘", "⭘", "", "", "", "◇", "", "", "△", "", "", "⭘"]);

// Wild Die (⚝)
//die_from_coordinates(DODECAHEDRON_COORDS, radius=9, label_size=5, depth=0.15, labels=["△", "", "⭘", "◇", "", "⚝", "⭘", "◇", "", "", "△", ""]);

die_from_coordinates(ICOSITETRAHEDRON, radius=10, label_size=4,
//            1     2    3     4    5     6      7    8    9    10    11   12
    labels=[ "△",  "",  "",  "◇", "💀",  "☆",  "⭘",  "", "◇", "△",  "", "⭘",
//           13     14   15   16    17   18   19    20    21   22   23   24
             "⭘",  "", "△", "◇", "", "⭘",  "☆", "", "◇", "", "", "△" ]);
//die_from_coordinates(ICOSITETRAHEDRON, radius=15, label_size=5);
