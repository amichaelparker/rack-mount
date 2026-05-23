// rack_frame.scad — modular 19" open-frame rack for 4U trays
// All-printed, stackable post modules, EIA-310 hole pattern for tray ears

// ─── PARAMETERS ───────────────────────────────────────────────────────────────

// EIA-310 / Tray compatibility
rack_u   = 4;
u_mm     = 44.45;
rack_h   = rack_u * u_mm;    // 177.8 mm
rack_ow  = 482.6;            // 19" outer width
ear_w    = 19.3;
tray_w   = rack_ow - 2*ear_w; // 444 mm (tray body width, no ears)
tray_d   = 350;              // tray depth

// Post dimensions
post_w   = 25;   // post cross-section width (X)
post_d   = 25;   // post depth (Y, toward rear)
post_h   = rack_h; // 4U = 177.8 mm per module

// Calculated post positions (world coords)
post_left_x   = 0;
post_right_x  = tray_w + 2*ear_w - post_w; // = 457.6 mm
post_rear_y   = tray_d + 20;               // = 370 mm

// EIA-310 mounting hole pattern
eia_hole_spacing = 15.875; // mm within a U
eia_hole_offset  = (u_mm - eia_hole_spacing) / 2; // 14.2875 mm
eia_hole_d       = 6.2;    // M6 clearance

// Base riser: lifts the first rack U to a comfortable working height
base_h = 5 * 25.4;  // 127 mm (5") from floor to first rack slot

// Stack connector (tab/socket between post modules)
stack_tab_w  = 10;
stack_tab_d  = 10;
stack_fit    = 0.2;

// Cross-rail dimensions (both left-right and front-rear rails share these)
rail_h           = 8;   // height (Z thickness)
rail_d           = 12;  // width perpendicular to span direction
rail_connector_d = 8;   // how far rail laps into post slot

// Lock-pin system
pin_d    = 3;   // lock pin diameter (mm)
blind_d  = 4;   // blind hole depth in rail top face (mm)
bridge_t = 5;   // solid bridge height above slot inside post hollow (mm)
// Derived: pin length = blind_d + bridge_t = 9 mm (see lock_pin module)

// ─── POST MODULE ──────────────────────────────────────────────────────────────

module post_section() {
    // Nested structure: inner difference hollows the post; bridges are added to
    // the union AFTER hollowing so they survive; outer difference cuts pin holes
    // (and slots/EIA holes) through everything including the bridge blocks.
    difference() {
        union() {
            // Hollowed post body
            difference() {
                cube([post_w, post_d, post_h]);
                translate([2, 2, 1]) cube([post_w-4, post_d-4, post_h-1]);
            }

            // Stacking tabs on top
            translate([3, 3, post_h])
                cube([stack_tab_w, stack_tab_d, 3]);
            translate([post_w-stack_tab_w-3, 3, post_h])
                cube([stack_tab_w, stack_tab_d, 3]);

            // ── Lock-pin bridge blocks (4 corners, bottom slot) ──
            // Added after hollow so they are not subtracted by the hollow.
            // Each 4×4×bridge_t block sits just above a corner of the bottom slot,
            // inside the open cavity — accessible via the post's open top.
            // Pin drops from above through bridge into rail's blind hole, then the
            // next stacked post section traps it permanently.
            for (bx = [2, post_w-2-(rail_d/2-2)])
                for (by = [2, post_d-2-(rail_d/2-2)])
                    translate([bx, by, rail_h])
                        cube([rail_d/2-2, rail_d/2-2, bridge_t]);
        }

        // ── Lock-pin through-holes (bridge + slot depth) ──
        // Centers at (4,4), (21,4), (4,21), (21,21) — one per corner bridge.
        // At Z < rail_h the slot faces are already open; hole gives pin clearance.
        for (px = [4, post_w-4])
            for (py = [4, post_d-4])
                translate([px, py, -0.1])
                    cylinder(h=rail_h+bridge_t+0.2, d=pin_d, $fn=12);

        // Stacking sockets on bottom
        translate([3-stack_fit, 3-stack_fit, -0.1])
            cube([stack_tab_w+2*stack_fit, stack_tab_d+2*stack_fit, 3.2]);
        translate([post_w-stack_tab_w-3-stack_fit, 3-stack_fit, -0.1])
            cube([stack_tab_w+2*stack_fit, stack_tab_d+2*stack_fit, 3.2]);

        // ── Front/rear cross-rail slots (Y-face slots, spanning full X width) ──
        // Front face (Y=0): bottom and top slots
        translate([-0.1, 0, 0])
            cube([post_w+0.2, rail_d/2+0.1, rail_h+0.2]);
        translate([-0.1, 0, post_h-rail_h])
            cube([post_w+0.2, rail_d/2+0.1, rail_h+0.2]);
        // Rear face (Y=post_d): bottom and top slots
        translate([-0.1, post_d-rail_d/2, 0])
            cube([post_w+0.2, rail_d/2+0.1, rail_h+0.2]);
        translate([-0.1, post_d-rail_d/2, post_h-rail_h])
            cube([post_w+0.2, rail_d/2+0.1, rail_h+0.2]);

        // ── Side rail slots (X-face slots, spanning full Y depth) ──
        // Left face (X=0): bottom and top slots
        translate([-0.1, -0.1, 0])
            cube([rail_d/2+0.2, post_d+0.2, rail_h+0.2]);
        translate([-0.1, -0.1, post_h-rail_h])
            cube([rail_d/2+0.2, post_d+0.2, rail_h+0.2]);
        // Right face (X=post_w): bottom and top slots
        translate([post_w-rail_d/2, -0.1, 0])
            cube([rail_d/2+0.2, post_d+0.2, rail_h+0.2]);
        translate([post_w-rail_d/2, -0.1, post_h-rail_h])
            cube([rail_d/2+0.2, post_d+0.2, rail_h+0.2]);

        // ── EIA-310 mounting holes for rack tray ears ──
        // One M6 hole per Z position, drilled front-to-back (Y direction)
        // at X=post_w/2 so tray ears can bolt through the front face
        for (u = [0:rack_u-1]) {
            z_base = u * u_mm;
            z1 = z_base + eia_hole_offset;
            z2 = z1 + eia_hole_spacing;
            for (zh = [z1, z2])
                translate([post_w/2, -0.1, zh])
                    rotate([-90, 0, 0])
                        cylinder(h=post_d+0.2, d=eia_hole_d, $fn=16);
        }
    }
}

// ─── BASE RISER ───────────────────────────────────────────────────────────────
// Lifts the rack off the floor; no EIA holes, same stacking tabs on top.
// Prints in one piece (127 mm < 250 mm P1S limit). Need 4 (one per corner).

module base_riser() {
    difference() {
        union() {
            cube([post_w, post_d, base_h]);
            // Stacking tabs on top (receive post_section socket)
            translate([3, 3, base_h])
                cube([stack_tab_w, stack_tab_d, 3]);
            translate([post_w-stack_tab_w-3, 3, base_h])
                cube([stack_tab_w, stack_tab_d, 3]);
        }

        // Hollow interior
        translate([2, 2, 1]) cube([post_w-4, post_d-4, base_h-1]);

        // ── Rail slots at bottom of riser (base-level stabilising rails) ──
        // Y-face slots
        translate([-0.1, 0, 0])
            cube([post_w+0.2, rail_d/2+0.1, rail_h+0.2]);
        translate([-0.1, post_d-rail_d/2, 0])
            cube([post_w+0.2, rail_d/2+0.1, rail_h+0.2]);
        // X-face slots
        translate([-0.1, -0.1, 0])
            cube([rail_d/2+0.2, post_d+0.2, rail_h+0.2]);
        translate([post_w-rail_d/2, -0.1, 0])
            cube([rail_d/2+0.2, post_d+0.2, rail_h+0.2]);

        // ── Rail slots at top of riser (aligns with post_section level bottom) ──
        // Y-face slots
        translate([-0.1, 0, base_h-rail_h])
            cube([post_w+0.2, rail_d/2+0.1, rail_h+0.2]);
        translate([-0.1, post_d-rail_d/2, base_h-rail_h])
            cube([post_w+0.2, rail_d/2+0.1, rail_h+0.2]);
        // X-face slots
        translate([-0.1, -0.1, base_h-rail_h])
            cube([rail_d/2+0.2, post_d+0.2, rail_h+0.2]);
        translate([post_w-rail_d/2, -0.1, base_h-rail_h])
            cube([rail_d/2+0.2, post_d+0.2, rail_h+0.2]);
    }
}

// ─── FRONT/REAR CROSS-RAILS (left-right, X direction) ─────────────────────────
// Each half printed separately; each half ≈ 228mm — fits P1S.
//
// Each half straddles the post's inner face so that rail_d/2 sits inside the
// post face-slot and rail_d/2 overhangs outside.  No seating notch — the post
// slot already carves out the necessary material.

module rail_front_half(left_half, z_height) {
    xL      = post_left_x  + post_w;          // left post inner face  = 25
    xR      = post_right_x;                   // right post inner face = 457.6
    mid_x   = xL + (xR - xL) / 2;            // span midpoint         = 241.3
    overlap = 5;                              // each half laps 5mm past centre

    x_start = xL - rail_d/2;                 // = 19  (6mm into left post slot)
    x_end   = xR + rail_d/2;                 // = 463.6 (6mm into right post slot)
    jt_x    = mid_x + overlap - 8;           // alignment tab X start

    difference() {
        union() {
            if (left_half) {
                translate([x_start, -rail_d/2, z_height])
                    cube([mid_x + overlap - x_start, rail_d, rail_h]);
                translate([jt_x, -rail_d/2, z_height + rail_h])
                    cube([8, rail_d, 2]);
            } else {
                translate([mid_x - overlap, -rail_d/2, z_height])
                    cube([x_end - (mid_x - overlap), rail_d, rail_h]);
            }
        }
        // Right half only: socket receives the left-half alignment tab
        if (!left_half)
            translate([jt_x - 0.15, -rail_d/2 - 0.1, z_height + rail_h - 0.1])
                cube([8.3, rail_d + 0.2, 2.3]);

        // Lock-pin blind hole on top face of rail end (matches post bridge pin)
        // Left half: pin from left post at world (21, 4)
        // Right half: pin from right post at world (post_right_x+4, 4)
        translate([left_half ? (post_left_x+21) : (post_right_x+4),
                   4,
                   z_height + rail_h - blind_d])
            cylinder(h=blind_d+0.1, d=pin_d, $fn=12);
    }
}

module rail_front(z_height) {
    rail_front_half(true,  z_height);
    rail_front_half(false, z_height);
}

module rail_rear_half(left_half, z_height) {
    xL      = post_left_x  + post_w;
    xR      = post_right_x;
    mid_x   = xL + (xR - xL) / 2;
    overlap = 5;
    x_start = xL - rail_d/2;
    x_end   = xR + rail_d/2;
    jt_x    = mid_x + overlap - 8;
    ry      = post_rear_y - rail_d/2;        // rail straddles rear post front face

    difference() {
        union() {
            if (left_half) {
                translate([x_start, ry, z_height])
                    cube([mid_x + overlap - x_start, rail_d, rail_h]);
                translate([jt_x, ry, z_height + rail_h])
                    cube([8, rail_d, 2]);
            } else {
                translate([mid_x - overlap, ry, z_height])
                    cube([x_end - (mid_x - overlap), rail_d, rail_h]);
            }
        }
        if (!left_half)
            translate([jt_x - 0.15, ry - 0.1, z_height + rail_h - 0.1])
                cube([8.3, rail_d + 0.2, 2.3]);

        // Lock-pin blind hole: rear posts sit at world Y=post_rear_y
        // Post-local pin Y=4 → world Y = post_rear_y+4
        translate([left_half ? (post_left_x+21) : (post_right_x+4),
                   post_rear_y + 4,
                   z_height + rail_h - blind_d])
            cylinder(h=blind_d+0.1, d=pin_d, $fn=12);
    }
}

module rail_rear(z_height) {
    rail_rear_half(true,  z_height);
    rail_rear_half(false, z_height);
}

// ─── SIDE RAILS (front-to-rear, Y direction) ──────────────────────────────────
// Each half ≈ 184mm — fits P1S.
// Rail straddles the post face-slot end: rail_d/2 inside slot, rail_d/2 outside.
// left_side=true: along left posts (X = post_left_x + post_w)
// front_half=true: front-post-to-centre section; false: centre-to-rear-post.

module rail_side_half(left_side, front_half, z_height) {
    rx      = left_side
              ? (post_left_x + post_w - rail_d/2)   // straddles right face of left posts
              : (post_right_x          - rail_d/2);  // straddles left face of right posts

    y_start = post_d      - rail_d/2;               // = 19  (6mm into front-post rear slot)
    y_end   = post_rear_y + rail_d/2;               // = 376 (6mm into rear-post front slot)
    mid_y   = (y_start + y_end) / 2;               // = 197.5
    overlap = 5;
    jt_y    = mid_y + overlap - 8;                 // alignment tab Y start

    difference() {
        union() {
            if (front_half) {
                translate([rx, y_start, z_height])
                    cube([rail_d, mid_y + overlap - y_start, rail_h]);
                translate([rx, jt_y, z_height + rail_h])
                    cube([rail_d, 8, 2]);
            } else {
                translate([rx, mid_y - overlap, z_height])
                    cube([rail_d, y_end - (mid_y - overlap), rail_h]);
            }
        }
        if (!front_half)
            translate([rx - 0.1, jt_y - 0.15, z_height + rail_h - 0.1])
                cube([rail_d + 0.2, 8.3, 2.3]);

        // Lock-pin blind hole on rail top face.
        // Front end: pin from front post at world (rx+2, post_d-4); post_d-4=21
        // Rear end:  pin from rear post at world (rx+2, post_rear_y+4)
        translate([left_side ? (post_left_x+21) : (post_right_x+4),
                   front_half ? (post_d-4) : (post_rear_y+4),
                   z_height + rail_h - blind_d])
            cylinder(h=blind_d+0.1, d=pin_d, $fn=12);
    }
}

module rail_side(left_side, z_height) {
    rail_side_half(left_side, true,  z_height);
    rail_side_half(left_side, false, z_height);
}

// ─── LOCK PIN ─────────────────────────────────────────────────────────────────
// Printed pin, 9mm tall × 3mm dia.  Slight taper for press-fit.
// Assembly: insert rail into post slot → drop pin from above through hollow →
//   pin passes through bridge block into blind hole in rail top face →
//   stack next post section which traps the pin permanently.

module lock_pin() {
    lp_h = blind_d + bridge_t;   // 9 mm
    cylinder(h=lp_h, d1=pin_d-0.1, d2=pin_d-0.3, $fn=12);
}

// ─── FOOT BASE ────────────────────────────────────────────────────────────────

module foot_base() {
    foot_sz = 40;
    difference() {
        union() {
            cube([foot_sz, foot_sz, 8]);
            translate([foot_sz/2-3, foot_sz/2-3, 8]) cube([6, 6, 6]);
        }
        // M8 adjustable foot socket
        translate([foot_sz/2, foot_sz/2, 0])
            cylinder(h=16, d=9, $fn=20);
        // Corner bolt holes
        translate([3, 3, -0.1])          cylinder(h=8.2, d=5, $fn=12);
        translate([foot_sz-3, 3, -0.1])  cylinder(h=8.2, d=5, $fn=12);
        translate([3, foot_sz-3, -0.1])  cylinder(h=8.2, d=5, $fn=12);
        translate([foot_sz-3, foot_sz-3, -0.1]) cylinder(h=8.2, d=5, $fn=12);
    }
}

// ─── ASSEMBLY ─────────────────────────────────────────────────────────────────

levels = 3;

module assembly_preview() {
    color("silver") {
        // Base risers — 5" legs under each corner post
        for (x = [post_left_x, post_right_x])
            for (y = [0, post_rear_y])
                translate([x, y, 0]) base_riser();

        // Stabilising rails at the base of the risers (floor level)
        rail_front(0);            rail_rear(0);
        rail_side(true, 0);       rail_side(false, 0);

        // Rack post sections sit on top of the risers
        for (lvl = [0:levels-1]) {
            z = base_h + lvl * post_h;
            translate([post_left_x,  0,           z]) post_section();
            translate([post_right_x, 0,           z]) post_section();
            translate([post_left_x,  post_rear_y, z]) post_section();
            translate([post_right_x, post_rear_y, z]) post_section();
        }

        // Left-right cross-rails: bottom of each rack level + very top
        for (lvl = [0:levels-1]) {
            z = base_h + lvl * post_h;
            rail_front(z);  rail_rear(z);
        }
        rail_front(base_h + levels * post_h - rail_h);
        rail_rear (base_h + levels * post_h - rail_h);

        // Front-to-rear side rails: same Z positions as cross-rails
        for (lvl = [0:levels-1]) {
            z = base_h + lvl * post_h;
            rail_side(true,  z);
            rail_side(false, z);
        }
        rail_side(true,  base_h + levels * post_h - rail_h);
        rail_side(false, base_h + levels * post_h - rail_h);
    }

    // Feet: 40×40 centered under each 25×25 corner (offset = (40-25)/2 = 7.5)
    color("dimgray") {
        translate([post_left_x-7.5,  -7.5,             -8]) foot_base();
        translate([post_right_x-7.5, -7.5,             -8]) foot_base();
        translate([post_left_x-7.5,  post_rear_y-7.5,  -8]) foot_base();
        translate([post_right_x-7.5, post_rear_y-7.5,  -8]) foot_base();
    }
}

// ─── RENDER SELECTION ─────────────────────────────────────────────────────────

assembly_preview();

// Uncomment individual parts for printing (one at a time):
//base_riser();    // ×4, one per corner — 127mm tall, prints upright
//post_section();  // ×(levels×4) — 178mm tall, prints upright
//rail_front_half(true,  0);   // left half  — print flat
//rail_front_half(false, 0);   // right half — print flat
//rail_rear_half(true,   0);
//rail_rear_half(false,  0);
//rail_side_half(true,  true,  0);   // left side, front half
//rail_side_half(true,  false, 0);   // left side, rear half
//rail_side_half(false, true,  0);   // right side, front half
//rail_side_half(false, false, 0);   // right side, rear half
//foot_base();
//lock_pin();  // ×8 per level (one per rail end at each corner) — 9mm tall, print flat or upright
