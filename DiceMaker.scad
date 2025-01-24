//------------------------------------------
// Geometric regular solids in OpenSCAD
//------------------------------------------

DEPTH = 0.5; // Depth of symbols
LABELS = [ for (i=[1:120]) str(i) ];
DEFAULT_FONT = "Segoe UI Symbol";

// Fin Support Settings
FIN_BASE_WIDTH = 1.2;
FIN_TIP_WIDTH = 0.50;
FIN_TIP_HEIGHT = 3.5;
FIN_DEPTH = 0.3;
FIN_CORNER_SETBACK = 0.2;
FIN_RAFT_WIDTH = 12;
FIN_RAFT_HEIGHT = 1;
FIN_STEP = FIN_TIP_WIDTH;

module bevel(bevel=1) {
    minkowski() {
        children();
        resize([bevel,bevel,bevel]);
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

function distance(p1, p2=undef) =
    (p2 == undef) ? sqrt(p1*p1) : distance(p2-p1);

function rotation_from_coordinates(coord) = [0,atan2(coord.z,distance([coord.x,coord.y])),atan2(coord.y,coord.x)];

function rotations_from_coordinates(coords) = [ for (c = coords) rotation_from_coordinates(c) ];

function with_opposite_coords(coords) = cat(coords, reverse(-1*coords));



//RHOMBIC_DODECAHEDRON = with_opposites([[90,0,45], [0, 90, 45], [45, 0, 0], [0, 45, 0], [-45,0,0], [0,-45,0]]);
//rotate([0,45,90])
//RHOMBIC_DODECAHEDRON = with_opposites([[0,0,0], [0,90,0], [45,120,0] ]);

function ends_with(ext, s) = search(ext, s)[0] == len(s)-len(ext);

d = sqrt(3)/2;
SAME = [[0,0],[0,0],[0,0]];
DIAGONAL = [[-1,-1],[+1,+1],[0,0]];
TRIANGULAR = [[-1,-d],[+1,-d],[0,d],[0,0]];
TRIANGULAR_DOWN = [[-1,d],[+1, d],[0,-d],[0,0]];
SQUARE = [[-1,-1],[-1,+1],[+1,+1],[+1,-1],[0,0]];
VERTICAL = [[0,-1],[0,+1],[0,0]];
HORIZONTAL = [[-1,0],[+1,0],[0,0]];

function default_from(v, i, d) = (i < len(v) && v[i] != undef) ? v[i] : d;
function scale_by(s, v) = [ for (i=[0:(len(v)-1)]) s[i]*v[i]];

module inscribe(source, size=6, dist=SAME, rotation=0, offset=[0,0], font=DEFAULT_FONT) {
    echo(font=font);
    ext = ".svg";
    if (is_list(source)) {
        symbols = [ for (c = source[0]) c ];
        sizes = default_from(source, 1, size);
        positions = default_from(source, 2, dist)*size;
        _rotation = default_from(source, 3, rotation);
        _offset = size*default_from(source, 4, offset);
        echo(source=source);
        echo(sizes=sizes, positions=positions, _offset=_offset, _rotation=rotation)
        for (i = [0:(len(symbols)-1)]) {
            rotate([0,0,_rotation]) translate([_offset.x, _offset.y, 0]) translate(positions[i % len(positions)]) {
                text(symbols[i], size=sizes[i % len(sizes)], font=font, halign="center", valign="center");
            }
        }
    } else {
        text(source, size=size, font=font, halign="center", valign="center");
    }
}

module label_polyhedron(radius, angles, labels, label_size, depth=DEPTH, offset=[0,0], rotation=0, font=DEFAULT_FONT) {
    all_angles = angles;
    echo(radius=radius, angles=angles,labels=labels, depth=depth);
//    all_angles = angles;
    echo(all_angles=all_angles);
    difference() {
        children();
        #for (i=[0:(len(all_angles)-1)]) {
        //for (i=[(len(all_angles)-1):(len(all_angles)-1)]) {
            if (labels[i] != "") {
                label(radius, all_angles[i], depth) {
                    offset(delta=-depth/2) {
                        inscribe(labels[i], label_size, rotation=rotation, offset=offset, font=font);
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

/* create a polyhedron from the coordinates of the faces (i.e., the vertices of its dual) */
module polyhedron_from_coordinates(radius, coords) {
    angles = rotations_from_coordinates(coords);
    intersection_for(a=angles) {
        rotate(a) translate([-radius/2,0,0]) cube([3*radius, 4*radius, 4*radius], center=true);
    }
}

module fin_plain(a, b, r1, r2) {
    hull() {
        translate([a.x, a.y, 0]) cylinder(r1=r1, r2=r2, h=a.z);
        translate([b.x, b.y, 0]) cylinder(r1=r1, r2=r2, h=b.z);
    }
}

module support(p, raft_width=FIN_RAFT_WIDTH, base_width=FIN_BASE_WIDTH, tip_width=FIN_TIP_WIDTH) {
    translate([p.x, p.y, 0]) {
        cylinder(r1 = raft_width/2, r2 = raft_width/2 + FIN_RAFT_HEIGHT, h = FIN_RAFT_HEIGHT);
        cylinder(r = base_width/2, h = p.z-FIN_TIP_HEIGHT, $fn=20);
        translate([0, 0, p.z-FIN_TIP_HEIGHT]) cylinder(r1=base_width/2, r2=FIN_TIP_WIDTH/2, h = FIN_TIP_HEIGHT, $fn=20);
    }
}

module fin_conic(a, b, r1, r2, raft_width=FIN_RAFT_WIDTH) {
    count = round(distance(a,b) / FIN_STEP);
    step = (b-a) / count;
    //echo(a=a, b=b, dist=distance(a,b), FIN_STEP=FIN_STEP, step=step, count=count);
    for (i = [0:(count-1)]) {
        //translate([a.x+i*step.x, a.y+i*step.y, 0]) cylinder(r1=r1, r2=r2, h=a.z+i*step.z, $fn=20);
        support(a+i*step, raft_width=raft_width, base_width=r1*2, tip_width=r2*2);
    }
}

module fin_support(a, b, base_width=FIN_BASE_WIDTH, top_width=FIN_TIP_WIDTH, raft_width=FIN_RAFT_WIDTH,
        setback=FIN_CORNER_SETBACK, depth=FIN_DEPTH) {
    sbv = setback * (b-a) / distance(b,a);
    a2 = a + sbv;
    b2 = b - sbv;
    fin_conic([a2.x, a2.y, a2.z+depth], [b2.x, b2.y, b2.z+depth], r1=base_width/2, r2=top_width/2, raft_width=raft_width);
//    fin_conic([a2.x, a2.y, a2.z+depth], [b2.x, b2.y, b2.z+depth], r1=base_width/2, r2=top_width/2);
//    fin_plain([a2.x, a2.y, FIN_RAFT_HEIGHT], [b2.x, b2.y, FIN_RAFT_HEIGHT], r1=0.5*raft_width, r2=0.5*raft_width+FIN_RAFT_HEIGHT);
}

NUMBERED = [ for (i=[1:120]) str(i) ];

/* create a polyhedron from intersection of planes defined by rotations */
module die_from_coordinates(coords, radius=10, labels=undef, label_size=6, offset=[0,0], depth=DEPTH, dual_coords=undef,
        font=DEFAULT_FONT) {
    _labels = (labels==undef) ? [ for (i=[1:len(coords)]) str(i) ] : labels;
    angles=rotations_from_coordinates(coords);
    //edge_radius = radius/10;
    //edge_radius = 1.0;
    edge_bevel = 0.0;
    label_polyhedron(radius, angles, _labels, label_size, depth=depth, offset=offset, font=font) {
        if (edge_bevel == 0) {
            make_polyhedron(radius, angles);
        } else {
            minkowski() {
                make_polyhedron(radius-edge_bevel, angles);
                make_polyhedron(edge_bevel, rotations_from_coordinates(dual_coords));
            }
        }
    }
}

function define_face(icons=[], sizes=[], dist=SAME, rotation=undef, offset=undef) = [icons, sizes, dist, rotation, offset];

function define_die(coordinates, edge_length, face_rotations=undef) =
    let(_edge_rotations=1)
    [];

function is_even(x) = x % 2 == 0;

// note: these are all scaled (with a scaling factor) so that the mid-radius is 1
PHI = (1+sqrt(5)) / 2;

CUBE_COORDS = sqrt(2) * with_opposite_coords([ [1,0,0], [0,1,0], [0,0,1] ]);
TETRAHEDRON_COORDS = 1/3 * [ [sqrt(8/9),0,-1/3], [-sqrt(2/9),sqrt(2/3), -1/3], [-sqrt(2/9),-sqrt(2/3), -1/3], [0,0,1] ];
OCTAHEDRON_COORDS = sqrt(1/2) * with_opposite_coords([ [1,1,1], [1,1,-1], [1,-1,1], [1,-1,-1] ]);

DECAHEDRON_Z = 0.94;
DECAHEDRON_COORDS = [ for (i=[0:9]) [sin(36*i), cos(36*i), DECAHEDRON_Z * (is_even(i) ? +1 : -1)] ];

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

//die_from_coordinates(ICOSITETRAHEDRON, radius=10, label_size=4,
////            1     2    3     4    5     6      7    8    9    10    11   12
//    labels=[ "△",  "",  "",  "◇", "💀",  "☆",  "⭘",  "", "◇", "△",  "", "⭘",
////           13     14   15   16    17   18   19    20    21   22   23   24
//             "⭘",  "", "△", "◇", "", "⭘",  "☆", "", "◇", "", "", "△" ]);
//die_from_coordinates(ICOSITETRAHEDRON, radius=15, label_size=5);


