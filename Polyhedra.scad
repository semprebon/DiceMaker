//------------------------------------------
// Wire-frame Geometric regular solids in OpenSCAD
//------------------------------------------

WIRE_RADIUS = 0.75;
TOLERANCE = 0.005;
FN = 10;

function cat(L1, L2) = [for(L=[L1, L2], a=L) a];

function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];

function with_opposites(angles, z_rotation=0) =
cat(angles, reverse([ for (a = angles) [a.x-180, a.y, a.z+z_rotation] ]));

function rotation_from_coordinates(coord) = [0,atan2(coord.z,distance([coord.x,coord.y])),atan2(coord.y,coord.x)];

function rotations_from_coordinates(coords) = [ for (c = coords) rotation_from_coordinates(c) ];

function with_opposite_coords(coords) = cat(coords, reverse(-1*coords));

//RHOMBIC_DODECAHEDRON = with_opposites([[90,0,45], [0, 90, 45], [45, 0, 0], [0, 45, 0], [-45,0,0], [0,-45,0]]);
//rotate([0,45,90])
//RHOMBIC_DODECAHEDRON = with_opposites([[0,0,0], [0,90,0], [45,120,0] ]);

function ends_with(ext, s) = search(ext, s)[0] == len(s)-len(ext);

d = sqrt(3)/2;

function default_from(v, i, d) = (i < len(v) && v[i] != undef) ? v[i] : d;
function scale_by(s, v) = [ for (i=[0:(len(v)-1)]) s[i]*v[i]];

module make_polyhedron(radius, angles) {
    echo(angles=angles);
    //    a = angles[0];
    intersection_for(a=angles) {
        rotate(a) translate([-radius/2,0,0]) cube([3*radius, 4*radius, 4*radius], center=true);
    }
}

function distance(p1, p2=undef) =
    (p2 == undef) ? sqrt(p1*p1) : distance(p2-p1);

function is_nearly_equal(a, b, err=TOLERANCE) = abs(a - b) < err;

function each_pair(v) =
    (len(v) <= 1) ? []
        : [ for (i = [0:(len(v)-2)], j = [i+1:(len(v)-1)]) [v[i], v[j]] ];

function edges_from_vertices(coords) = each_pair(coords);

function filter(v, pred) = [ for (x=v) if (pred(x)) x ];

// returns true if the predicate is true for any element in the vector
function any(v, pred) = len(filter(v, pred)) > 0;


create_length_predicate = function(lengths)
    function(edge) any(lengths, function(length) is_nearly_equal(distance(edge[0], edge[1]), length));

//filter_edges_by_length = function(edges, lengths)
/*
Creates a "wire" from one point to the other. The wire is a cyliner capped by hemispheres.
 */
module line_segment(p1, p2, radius=WIRE_RADIUS, fn=FN) {
    echo("line_segment", $fn=fn);
    hull() {
        translate(p1) sphere(r=radius, $fn=fn);
        translate(p2) sphere(r=radius, $fn=fn);
    }
}

// put a copy of children at each point in a list
module mark_points(points) {
    for (p = points) {
        translate(p) children();
    }
}

/*
Creates a wire-frame polyhedron by connecting verticies that have the specified edge length(s)
 */
module polyhedron_from_coordinates(radius, coords, edge_filter = function(edge) true, fn=FN) {
    echo("poly", fn=fn);
    _coords = [ for (p = coords) radius * p];

    //mark_points(_coords) sphere(r=WIRE_RADIUS);

    edges = filter(edges_from_vertices(_coords), edge_filter);
    for (edge = edges) {
        echo(edge=edge, distance(edge[0], edge[1]));
        line_segment(edge[0], edge[1], fn=fn);
    }
}

module torus(r1=1, r2=0.25) {
    rotate_extrude($fn=40) {
        translate([r1, 0, 0]) circle(r=r2, $fs=FN);
    }
}

// note: these are all scaled (with a scaling factor) so that the mid-radius is 1
PHI = (1+sqrt(5)) / 2;

CUBE_COORDS = sqrt(2) * with_opposite_coords([ [1,0,0], [0,1,0], [0,0,1] ]);
TETRAHEDRON_COORDS = 1/3 * [ [sqrt(8/9),0,-1/3], [-sqrt(2/9),sqrt(2/3), -1/3], [-sqrt(2/9),-sqrt(2/3), -1/3], [0,0,1] ];
OCTAHEDRON_COORDS = sqrt(1/2) * with_opposite_coords([ [1,1,1], [1,1,-1], [1,-1,1], [1,-1,-1] ]);

function is_even(x) = x % 2 == 0;
DECAHEDRON_Z = 0.94;
DECAHEDRON = [ for (i=[0:9]) [sin(36*i), cos(36*i), DECAHEDRON_Z * (is_even(i) ? +1 : -1)] ];

ICOSAHEDRON_COORDS = (1/sqrt(PHI+2)) * with_opposite_coords([ [0,1,PHI], [0,-1,PHI], [PHI,0,1], [-PHI,0,1], [1,PHI,0], [1,-PHI, 0] ]);
DODECAHEDRON_COORDS = (sqrt(PHI+2)-PHI) * with_opposite_coords([ [1,1,1], [1,1,-1], [1,-1,1], [1,-1,-1],
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

radius = 12*sqrt(3);
//polyhedron_from_coordinates(radius, ICOSAHEDRON_COORDS, edge_length= 20.4156);
// Dodecahedron edges = 4.21369, 6.8179, 9.64196, 11.0316
edge_lengths = [9.64196];

EDGE = DODECAHEDRON_COORDS[11];
for (i=[0:19]) {
    let(edge = DODECAHEDRON_COORDS[i])
    echo(i, [ for (j=[0:(len(DODECAHEDRON_COORDS)-1)]) if (is_nearly_equal(9.64196/12, distance(edge, DODECAHEDRON_COORDS[j]))) j ]);
}
echo([ for (i=[0:(len(DODECAHEDRON_COORDS)-1)]) if (is_nearly_equal(9.64196/12, distance(EDGE, DODECAHEDRON_COORDS[i]))) i ]);
TETRA_1 = [DODECAHEDRON_COORDS[0], DODECAHEDRON_COORDS[3], DODECAHEDRON_COORDS[17], DODECAHEDRON_COORDS[18]];
TETRA_2 = [DODECAHEDRON_COORDS[1], DODECAHEDRON_COORDS[6], DODECAHEDRON_COORDS[10], DODECAHEDRON_COORDS[15]];
// P4:7,9,11,13 P7: 0,2,4,10,11,14
TETRA_3 = [DODECAHEDRON_COORDS[2], DODECAHEDRON_COORDS[4], DODECAHEDRON_COORDS[7], DODECAHEDRON_COORDS[11]];
TETRA_4 = [DODECAHEDRON_COORDS[5], DODECAHEDRON_COORDS[9], DODECAHEDRON_COORDS[12], DODECAHEDRON_COORDS[19]];
TETRA_5 = [DODECAHEDRON_COORDS[8], DODECAHEDRON_COORDS[13], DODECAHEDRON_COORDS[14], DODECAHEDRON_COORDS[16]];
translate([0,0,radius/2]) rotate([0,    0,0]) {
//translate([0,0,radius/2]) rotate([0,20,0]) {
    polyhedron_from_coordinates(radius, TETRA_1, fn=FN);
    polyhedron_from_coordinates(radius, TETRA_2, fn=FN);
    polyhedron_from_coordinates(radius, TETRA_3, fn=FN);
    polyhedron_from_coordinates(radius, TETRA_4, fn=FN);
    polyhedron_from_coordinates(radius, TETRA_5, fn=FN);
}
//polyhedron_from_coordinates(1, ICOSAHEDRON_COORDS, edge_length=5.236);
translate([0,0,radius+1.5]) rotate([90,0,0]) torus(r1=1.5, r2=0.5);

is_2 = function(x) x==2;
echo(any([1,2,3], is_2));