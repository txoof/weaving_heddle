/* [Dimensions] */
//slot width (mm)
slot_width = 2.1; // [0.5:0.05:5]

//spacing between slots (mm)
slot_spacing = 1.5; // [1.3:.05:3]

//heddle Y (mm)
heddle_y = 100; // [30:100]


//corner radius (mm)
radius = 1.5; //[0:0.1:10]


// handle X (mm)
handle_x = 60; //[0:1:100]
// handle Y (mm)
handle_y = 20; //[0:1:60]



/* [Pattern] */

//predefined patterns
predefined = "five";//[five, seven, nine, thirteen, 17, 77_plain]
/* //custom pattern
c_pattern = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0];
//c_pattern = [0, 1, 0]; */
// center slot or hole
c_center = .5;//[0.5, 0, 1]

/* [Hidden] */
$fn=36;

center = [c_center];

patterns = [
  ["five", [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, .5, 1, 0, .5, 0, 1]],
  [ "seven", [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, .5, 0, 1, .5, 1, 0, .5, 0, 1]],
  ["nine", [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0, .5, 0, 1]],
  /* ["15", [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1,  .5, 1, 0, .5, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0, .5, 0, 1,  .5, 1, 0]], */
  ["thirteen", [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, .5, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0, ]],
  ["17", [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, .5, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0, .5, 0, 1, .5, 1, 0]],
  ["77_plain", [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, ]]
];

function reverse(list) = [for (i = [len(list)-1:-1:0]) list[i]];


/* if (use_custom==true) {
  r_pattern = reverse(c_pattern);
  pattern = concat(c_pattern, center, r_pattern);
} */

result = search(predefined, patterns);
my_pattern = patterns[result[0]][1];
r_pattern = reverse(my_pattern);
echo(my_pattern, r_pattern);
pattern = concat(my_pattern, center, r_pattern);


text_size = (slot_width*5)/2*.6;

// see this post for how to create an accumulator
// http://forum.openscad.org/simple-accumulator-question-tp26060p26065.html
// count the numbe rof pattern threads in this heddle
pattern_threads = ([for(i = 0, t = 0;  i < len(pattern)+1; t = (1 > pattern[i] &&  pattern[i] > 0)  ? t + 1 : t, i = i + 1) if(i == len(pattern)) t][0]);




echo("**************************************************");
echo("heddle x: ", heddle_x);
echo("heddle y: ", heddle_y);
echo("Total Threads: ", len(pattern));
echo("Total Pattern Threads: ", pattern_threads);
echo("**************************************************");
heddle_x = slot_width * len(pattern) + slot_spacing*(len(pattern)+1);

module heddle() {
    h_x = heddle_x-radius*2;
    h_y = heddle_y-radius*2;

        translate([-heddle_x/2+radius, -heddle_y/2+radius])
        minkowski() {
            square([h_x, h_y], center = true);
            translate([h_x/2, h_y/2])
                circle(radius);
        }

}

module slot(y) {
    slot_y = (heddle_y - (slot_width*5))*y;
    union() {
        square([slot_width, slot_y], center=true);
        translate([0, slot_y/2])
            circle(slot_width/2);
        translate([0, -slot_y/2])
            circle(r=slot_width/2);
    }
}

module slots() {
    for (i = [0: len(pattern)-1] ) {
        translate([-heddle_x/2+slot_width/2+(slot_width+slot_spacing)*i+slot_spacing, 0])
            slot(pattern[i]);
    }
}

module handle() {
    han_x = handle_x-radius*2;
    han_y = handle_y-radius*2 + radius;
    minkowski() {
        square([han_x, han_y], true);

            circle(radius);
    }
}

module pattern_count() {
    if (pattern_threads > 0) {
        #translate([-heddle_x/2+slot_width/2, -text_size*1.1+heddle_y/2])
            text(str(pattern_threads," count"), size=text_size);
    }
}

module assemble() {
    union() {
        difference() {
            heddle();
            slots();

        }
        translate([0, -heddle_y/2-(handle_y)/2+radius])
        handle();
        pattern_count();
    }

}

assemble();
