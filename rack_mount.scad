// rack_mount.scad — 19" 4U open tray rack mount
// ATX motherboard (flat) + EVGA 2080 Ti Black (vertical) + ATX PSU
//
// Four L-shaped printable sections with seam joints:
//   FL (front-left)  — board front standoffs + front panel left
//   FR (front-right) — PSU cradle front      + front panel right
//   RL (rear-left)   — board rear standoffs  + rear panel left
//   RR (rear-right)  — PSU cradle rear       + rear panel right
//
// Joint strategy — no interior walls:
//   • Floor-edge box joint tabs (tw=3mm tall) along the floor seam
//   • Front/rear panel tongue tabs at 2 Z heights (on the panel face)
//   • Side rail tongue tabs at 2 Z heights (on the rail face)
//   Each tab is part of an existing wall/floor, so nothing floats.

// ─── PARAMETERS ───────────────────────────────────────────────────────────────

rack_u   = 4;
u_mm     = 44.45;
rack_h   = rack_u * u_mm;   // 177.8 mm
rack_ow  = 482.6;
ear_w    = 19.3;
tray_w   = rack_ow - 2*ear_w;  // ≈ 444 mm

tray_d   = 350;
tw       = 4;   // wall thickness — increased from 3mm to compensate for honeycomb cutouts

// ─── HONEYCOMB PARAMETERS ─────────────────────────────────────────────────────
// hc_r  = hex cell inscribed radius (flat-to-flat = 2*hc_r)
// hc_w  = hex wall thickness between cells
// hc_mg = solid margin kept clear of any panel edge / joint / feature
hc_r     = 3.5;   // 7mm flat-to-flat cells — good airflow, finger-safe
hc_w     = 1.2;   // 2-extrusion-width walls — strong and clean
hc_mg    = 12;    // 12mm solid border around every edge and feature

atx_w    = 305;
atx_d    = 243.84;  // 9.6" standard ATX depth (board is 12" × 9.6")
soff_h   = 6;
soff_od  = 6.5;
soff_id  = 3.2;

// Hole positions from VenOunan ATX Motherboard Pattern (standard ATX layout).
// pt[0] = mm from left edge of board (X parallel to IO)
// pt[1] = mm from front edge of board (Y, increasing toward IO)
// by0 already adds the 1mm IO gap, so these are pure board-relative coords.
//
// Column X:  A/G/K = 16.51   C/H/L = 140.97   F/J/M = 298.45
// Row    Y:  K/L/M =  6.35   G/H/J =  66.04   F = 220.98   A/C = 233.68
atx_holes = [
  [  16, 231.68],  // A: 0.40" from IO, left column
  [ 140.97, 231.68],  // C: 0.40" from IO, center column
  [ 298.45, 218.98],  // F: 0.90" from IO, right column
  [  16,  78],  // G: middle row, left column
  [ 140.97,  78],  // H: middle row, center column
  [ 298.45,  78],  // J: middle row, right column
  [  16,   6],  // K: 0.25" from front, left column
  [ 140.97,   6],  // L: 0.25" from front, center column
  [ 298.45,   6],  // M: 0.25" from front, right column
];

bx0 = tw;
by0 = tray_d - tw - atx_d - 1;  // 1mm clearance between IO edge and rear panel for GPU bracket tabs

psu_xw   = 86;
psu_yd   = 140;
psu_zh   = 150;

// PSU mounting hole positions — X coords are in MODEL space (front-of-case view).
// Adam measures from the BACK, so left/right are mirrored: Adam's right = model's left.
//
//   Adam's view (from back)    →   Model coord
//   top-right  (5mm  from Adam-right) →  5.0mm from model-left
//   top-left   (16mm from Adam-left)  →  86-16 = 70.0mm from model-left
//   bottom-right (5.6mm from Adam-right, 7.3mm up)  →  5.6mm from model-left
//   bottom-left  (6.5mm from Adam-left, 31mm up)    →  86-6.5 = 79.5mm from model-left

psu_hole_tl_x =   5.4;   // model top-left    = Adam's top-right (confirmed correct)
psu_hole_tr_x =  69.7;   // model top-right   = Adam's top-left  (16mm from Adam's left)
psu_hole_bl_x =   5.4;   // model bottom-left = Adam's bottom-right (5.6mm from Adam's right)
psu_hole_br_x =  80;   // model bottom-right= Adam's bottom-left  (6.5mm from Adam's left → 86-6.5)

psu_hole_top_z =  145.0;  // both top holes: 5mm from top  (150 - 5)
psu_hole_bl_z  =    7.3;  // model bottom-left  = Adam's bottom-right: 7.3mm from bottom
psu_hole_br_z  =   31.0;  // model bottom-right = Adam's bottom-left:  31mm from bottom

psu_holes = [
    [ psu_hole_tl_x, psu_hole_top_z ],  // top-left
    [ psu_hole_tr_x, psu_hole_top_z ],  // top-right
    [ psu_hole_bl_x, psu_hole_bl_z  ],  // bottom-left
    [ psu_hole_br_x, psu_hole_br_z  ],  // bottom-right
];

psu_boss_c  = 10;   // boss footprint size (square)
psu_boss_th = 4;    // boss protrusion beyond inner face (into tray)
psu_gap  = 12;
psu_x0   = bx0 + atx_w + psu_gap;   // 320
psu_y0   = tray_d - tw - psu_yd;

gpu_l    = 267;
gpu_zh   = 125;
gpu_xw   = 2 * 20.32;
pcie_bx  = 110;
pcie_by  = 50;
gpu_x0   = bx0 + pcie_bx - gpu_xw/2;
gpu_y0   = by0 + pcie_by - 73;

bkt_cut_w   = gpu_xw + 1;
bkt_cut_h   = 121;
bkt_cut_z0  = tw;
bkt_cut_x0  = gpu_x0 - 0.5;

ret_bar_w      = bkt_cut_w + 20;
ret_bar_h      = 10;
ret_bar_d      = tw + 2;
ret_screw_d    = 3.4;
ret_bar_z0     = bkt_cut_z0 + bkt_cut_h;
ret_boss_inset = 8;   // how far bosses protrude INWARD from inner panel face

ret_lip_d   = 8;    // lip protrusion depth — extended to sit over GPU bracket (was 3mm)
ret_lip_h   = 4;    // lip thickness (Z)
ret_gpu_screw_d = 3.2;          // M3 clearance for GPU bracket screws
ret_gpu_screw_sp = 20.5;        // center-to-center spacing of GPU bracket holes

tab_sw  = 10.5;
tab_sd  = 5;
tab_x   = [gpu_x0 + gpu_xw*0.25, gpu_x0 + gpu_xw*0.75];

fan_sq   = 120;
fan_msp  = 105;
// Three fans evenly spaced across the front panel (fp_w=436mm, gap=19mm each side)
fan1_cx  = tw + 79.0;   //  83mm from tray left — over GPU/PCIe slot
fan2_cx  = tray_w / 2;  // 222mm — centre, over mid-board
fan3_cx  = tray_w - tw - 79.0;  // 361mm — over board right + PSU gap
fan_cz   = rack_h / 2;

io_w     = 165;
io_h     = 46;
io_x0    = 150;   // IO shield at left (IO) edge of board — standard ATX position
io_z0    = tw + soff_h;

cut_x    = tray_w / 2;   // ≈ 222 mm
cut_y    = tray_d / 2;   // 200 mm

// Joint geometry
fj_d     = 6;     // tab depth (protrusion past seam face)
fj_w     = 18;    // tab width along seam
fj_fit   = 0.25;  // socket clearance per side
fj_th    = 8;     // panel/rail tab height (for the wall-face tabs)

// Ear interlock geometry
etab_d   = tw;    // tab depth = wall thickness — slot goes flush through rail, clearly visible
etab_h   = 15;    // tab height (Z direction)
etab_fit = 0.2;   // slot clearance per side

// Rear support lip
lip_yd   = 25;    // how far the lip extends behind the rear panel
lip_zh   = 6;     // lip thickness (Z)
lip_md   = 4.5;   // M4 clearance hole for bolting to rear cross-brace

// ─── UTILITY ──────────────────────────────────────────────────────────────────

module standoff() {
    difference() {
        cylinder(h=soff_h, d=soff_od, $fn=24);
        cylinder(h=soff_h+0.1, d=soff_id, $fn=16);
    }
}

// Filter channel parameters — fits standard 120×120mm bare foam pads (3mm or 5mm thick)
filter_face  = 122;   // channel opening: 120mm pad + 1mm clearance per side
filter_depth =   3;   // recess depth — must be < tw (4mm); 3mm fits most common pads snugly

module fan_cutout(cx, cz) {
    translate([cx, -0.1, cz]) rotate([-90,0,0]) {
        // Main airflow hole (112mm dia — standard 120mm fan cutout)
        cylinder(h=tw+0.2, d=fan_sq-8, $fn=64);
        // Fan screw holes (M4 clearance)
        for (sx=[-1,1], sz=[-1,1])
            translate([sx*fan_msp/2, sz*fan_msp/2, 0])
                cylinder(h=tw+0.2, d=4.4, $fn=12);
        // Filter pad recess — square channel on the OUTER face (z=0 in rotated space)
        // 3mm deep, leaving 1mm of wall behind the foam before the airflow hole opens
        translate([-filter_face/2, -filter_face/2, 0])
            cube([filter_face, filter_face, filter_depth]);
    }
}

// ─── HONEYCOMB MODULE ─────────────────────────────────────────────────────────
// Cuts a hex grid through a wall of thickness `depth`.
// Place this in a difference() — the grid is oriented in the XZ plane (wall in Y).
//
//   w, h   = bounding box of the vent zone in X and Z
//   depth  = wall thickness (cut goes full depth + 0.2mm overcut)
//   r      = hex inscribed radius (flat-to-flat = 2r)
//   wall   = wall width between cells
//
// Origin is the bottom-left corner of the vent zone.
// Rotate/translate before calling to position on the target face.
module honeycomb(w, h, depth, r=hc_r, wall=hc_w) {
    pitch_x = (r + wall/2) * 2;          // column pitch
    pitch_z = (r + wall/2) * sqrt(3);    // row pitch
    nx = ceil(w / pitch_x) + 1;
    nz = ceil(h / pitch_z) + 1;
    for (col = [0:nx-1], row = [0:nz-1]) {
        cx = col * pitch_x + (row % 2 == 1 ? pitch_x/2 : 0);
        cz = row * pitch_z;
        if (cx > 0 && cx < w && cz > 0 && cz < h)
            translate([cx, -0.1, cz])
                rotate([-90, 30, 0])
                    cylinder(h=depth+0.2, r=r, $fn=6);
    }
}

// ─── JOINT MODULES ────────────────────────────────────────────────────────────
// All tabs attach to existing geometry (floor/panel/rail).  Nothing floats.
//
// ── X=cut_x seam: floor-edge box joints (3mm tall = floor thickness) ──────────
// Even-index tabs belong to the LEFT piece (FL, RL).
// Odd-index tabs belong to the RIGHT piece (FR, RR).

module xj_floor_L(y0, y1) {         // LEFT tabs protruding +X
    n = floor((y1-y0)/fj_w);
    for (i=[0:n-1]) if (i%2==0)
        translate([cut_x, y0+i*fj_w, 0]) cube([fj_d, fj_w, tw]);
}
module xj_floor_L_sock(y0, y1) {    // LEFT sockets (receive R tabs)
    n = floor((y1-y0)/fj_w);
    for (i=[0:n-1]) if (i%2==1)
        translate([cut_x-fj_d-0.01, y0+i*fj_w-fj_fit, -0.01])
            cube([fj_d+0.02, fj_w+2*fj_fit, tw+0.02]);
}
module xj_floor_R(y0, y1) {         // RIGHT tabs protruding -X
    n = floor((y1-y0)/fj_w);
    for (i=[0:n-1]) if (i%2==1)
        translate([cut_x-fj_d, y0+i*fj_w, 0]) cube([fj_d, fj_w, tw]);
}
module xj_floor_R_sock(y0, y1) {    // RIGHT sockets (receive L tabs)
    n = floor((y1-y0)/fj_w);
    for (i=[0:n-1]) if (i%2==0)
        translate([cut_x-0.01, y0+i*fj_w-fj_fit, -0.01])
            cube([fj_d+0.02, fj_w+2*fj_fit, tw+0.02]);
}

// ── Y=cut_y seam: floor-edge box joints ──────────────────────────────────────
// Even-index tabs belong to the FRONT piece (FL, FR).
// Odd-index tabs belong to the REAR piece (RL, RR).

module yj_floor_F(x0, x1) {         // FRONT tabs protruding +Y
    n = floor((x1-x0)/fj_w);
    for (i=[0:n-1]) if (i%2==0)
        translate([x0+i*fj_w, cut_y, 0]) cube([fj_w, fj_d, tw]);
}
module yj_floor_F_sock(x0, x1) {    // FRONT sockets (receive R tabs)
    n = floor((x1-x0)/fj_w);
    for (i=[0:n-1]) if (i%2==1)
        translate([x0+i*fj_w-fj_fit, cut_y-fj_d-0.01, -0.01])
            cube([fj_w+2*fj_fit, fj_d+0.02, tw+0.02]);
}
module yj_floor_R(x0, x1) {         // REAR tabs protruding -Y
    n = floor((x1-x0)/fj_w);
    for (i=[0:n-1]) if (i%2==1)
        translate([x0+i*fj_w, cut_y-fj_d, 0]) cube([fj_w, fj_d, tw]);
}
module yj_floor_R_sock(x0, x1) {    // REAR sockets (receive F tabs)
    n = floor((x1-x0)/fj_w);
    for (i=[0:n-1]) if (i%2==0)
        translate([x0+i*fj_w-fj_fit, cut_y-0.01, -0.01])
            cube([fj_w+2*fj_fit, fj_d+0.02, tw+0.02]);
}

// ── Front panel seam at X=cut_x ───────────────────────────────────────────────
// Panel is tw=4mm thick in Y.  Tabs sit within that thickness, at 2 Z heights.
// FL has the tongue; FR has the groove.
// Tab Z positions are near top/bottom of panel — the centre fan (fan2) sits exactly
// at cut_x and its cutout spans z=27.9–149.9mm, so tabs must be outside that range.
fp_tab_z = [15, rack_h - 15];   // z=15mm (bottom) and z=162.8mm (top) — both clear of fan

module front_panel_tongue() {
    for (z = fp_tab_z)
        translate([cut_x, 0, z-fj_th/2]) cube([fj_d, tw, fj_th]);
}
module front_panel_groove() {
    for (z = fp_tab_z)
        translate([cut_x-0.01, -0.1, z-fj_th/2-fj_fit])
            cube([fj_d+0.12, tw+0.2, fj_th+2*fj_fit]);
}

// ── Rear panel seam at X=cut_x ────────────────────────────────────────────────
// RL has the tongue; RR has the groove.
// Tab Z positions are in the solid border zones above and below the honeycomb
// (honeycomb spans hc_mg=12mm to rack_h-hc_mg=165.8mm).
rp_tab_z = [hc_mg/2, rack_h - hc_mg/2];  // z=6mm (bottom) and z=171.8mm (top)

module rear_panel_tongue() {
    for (z = rp_tab_z)
        translate([cut_x, tray_d-tw, z-fj_th/2]) cube([fj_d, tw, fj_th]);
}
module rear_panel_groove() {
    for (z = rp_tab_z)
        translate([cut_x-0.01, tray_d-tw-0.1, z-fj_th/2-fj_fit])
            cube([fj_d+0.12, tw+0.2, fj_th+2*fj_fit]);
}

// ── Left rail seam at Y=cut_y ─────────────────────────────────────────────────
// Rail is tw=3mm wide in X.  FL has tongue; RL has groove.

module left_rail_tongue() {
    for (z=[rack_h*0.33, rack_h*0.67])
        translate([0, cut_y, z-fj_th/2]) cube([tw, fj_d, fj_th]);
}
module left_rail_groove() {
    for (z=[rack_h*0.33, rack_h*0.67])
        translate([-0.1, cut_y-0.01, z-fj_th/2-fj_fit])
            cube([tw+0.2, fj_d+0.12, fj_th+2*fj_fit]);
}

// ── Right rail seam at Y=cut_y ────────────────────────────────────────────────
// FR has tongue; RR has groove.

module right_rail_tongue() {
    for (z=[rack_h*0.33, rack_h*0.67])
        translate([tray_w-tw, cut_y, z-fj_th/2]) cube([tw, fj_d, fj_th]);
}
module right_rail_groove() {
    for (z=[rack_h*0.33, rack_h*0.67])
        translate([tray_w-tw-0.1, cut_y-0.01, z-fj_th/2-fj_fit])
            cube([tw+0.2, fj_d+0.12, fj_th+2*fj_fit]);
}

// ── Ear interlocks ────────────────────────────────────────────────────────────
// The tray rails start at Y=tw (no front face).  The ear extension fills that
// front face gap (X=0..tw, Y=0..tw, Z=tw..rack_h).  Interlock tabs protrude
// from the extension's back face (+Y from Y=tw) into the rail front face slots.
// The ear slides in from the side (+X for left, -X for right) and the tabs ride
// into the slots — no through-holes, no assembly conflict.

module left_ear_tabs() {
    // Protrude +Y from extension back face (Y=tw in ear module space)
    for (zi = [1:3])
        translate([ear_w, tw, rack_h*zi/4 - etab_h/2]) cube([tw, etab_d, etab_h]);
}
module left_ear_slots() {
    // Cut into the left rail's front face in the +Y direction
    for (zi = [1:3])
        translate([-0.1, tw-0.1, rack_h*zi/4 - etab_h/2 - etab_fit])
            cube([tw+0.2, etab_d+etab_fit+0.1, etab_h+2*etab_fit]);
}

module right_ear_tabs() {
    // Protrude +Y from extension back face (Y=tw in ear module space)
    for (zi = [1:3])
        translate([-tw, tw, rack_h*zi/4 - etab_h/2]) cube([tw, etab_d, etab_h]);
}
module right_ear_slots() {
    // Cut into the right rail's front face in the +Y direction
    for (zi = [1:3])
        translate([tray_w-tw-0.1, tw-0.1, rack_h*zi/4 - etab_h/2 - etab_fit])
            cube([tw+0.2, etab_d+etab_fit+0.1, etab_h+2*etab_fit]);
}

// ─── STRUCTURAL MODULES ───────────────────────────────────────────────────────

module atx_standoffs() {
    for (pt = atx_holes)
        translate([bx0 + pt[0], by0 + pt[1], tw]) standoff();
}

module front_panel_solid() {
    // Inset by tw on each side — ears fill the gap at X=[0,tw] and X=[tray_w-tw,tray_w]
    // Three 120mm fan cutouts handle all the ventilation — no honeycomb needed here.
    difference() {
        translate([tw, 0, 0]) cube([tray_w-2*tw, tw, rack_h]);
        fan_cutout(fan1_cx, fan_cz);
        fan_cutout(fan2_cx, fan_cz);
        fan_cutout(fan3_cx, fan_cz);
    }
}

// Helper: one L-shaped boss that bridges a PSU mounting hole to the two nearest panel edges
// so the boss is never a floating island in the middle of the PSU opening.
module psu_boss_bridge(h) {
    hx   = psu_x0 + h[0];
    hz   = tw + h[1];
    // Horizontal bridge: hole centred at hx, spans from PSU edge to hole+half-boss
    bx0_ = (h[0] < psu_xw/2) ? psu_x0           : hx - psu_boss_c/2;
    bx1_ = (h[0] < psu_xw/2) ? hx + psu_boss_c/2 : psu_x0 + psu_xw;
    // Vertical bridge: hole centred at hz, spans from floor/ceiling edge to hole+half-boss
    bz0_ = (h[1] < psu_zh/2) ? tw                : hz - psu_boss_c/2;
    bz1_ = (h[1] < psu_zh/2) ? hz + psu_boss_c/2 : tw + psu_zh;
    translate([bx0_,              -psu_boss_th, hz - psu_boss_c/2]) cube([bx1_-bx0_,    tw+psu_boss_th, psu_boss_c]);
    translate([hx - psu_boss_c/2, -psu_boss_th, bz0_])             cube([psu_boss_c, tw+psu_boss_th, bz1_-bz0_]);
}

module rear_panel_solid() {
    psu_c   = psu_boss_c;
    boss_th = psu_boss_th;
    m4_d    = 4.5;  // M4 clearance hole diameter

    // Honeycomb zones (all in rear-panel local coords where Y=0 is outer face):
    //   Zone A: left of PCIe bracket opening — board/VRM area
    //     x: hc_mg  ..  bkt_cut_x0 - hc_mg
    //     z: hc_mg  ..  rack_h - hc_mg
    //   Zone B: between PCIe bracket and IO shield
    //     x: bkt_cut_x0+bkt_cut_w+hc_mg  ..  io_x0-hc_mg
    //     z: hc_mg  ..  io_z0-hc_mg  (below IO opening)  AND  io_z0+io_h+hc_mg..rack_h-hc_mg (above)
    //   Zone C: right of PSU
    //     x: psu_x0+psu_xw+hc_mg  ..  tray_w-hc_mg
    //     z: hc_mg  ..  rack_h-hc_mg

    rp_zone_a_x0 = hc_mg;
    rp_zone_a_x1 = bkt_cut_x0 - hc_mg;
    rp_zone_b_x0 = bkt_cut_x0 + bkt_cut_w + hc_mg;
    rp_zone_b_x1 = io_x0 - hc_mg;
    rp_zone_c_x0 = psu_x0 + psu_xw + hc_mg;
    rp_zone_c_x1 = tray_w - hc_mg;

    difference() {
        union() {
            // Panel with all openings already cut — bosses added after so they
            // survive the opening cuts even when not in a corner zone
            difference() {
                cube([tray_w, tw, rack_h]);
                // IO shield opening
                translate([io_x0, -0.1, io_z0]) cube([io_w, tw+0.2, io_h]);
                // PSU opening — 3 cuts that preserve 10mm corners
                translate([psu_x0,       -0.1, tw+psu_c])        cube([psu_xw,          tw+0.2, psu_zh-2*psu_c]);
                translate([psu_x0+psu_c, -0.1, tw])               cube([psu_xw-2*psu_c, tw+0.2, psu_c]);
                translate([psu_x0+psu_c, -0.1, tw+psu_zh-psu_c]) cube([psu_xw-2*psu_c, tw+0.2, psu_c]);
                // PCIe bracket opening
                translate([bkt_cut_x0, -0.1, bkt_cut_z0]) cube([bkt_cut_w, tw+0.2, bkt_cut_h]);
            }
            // PSU mounting bosses — L-shaped bridges so no boss floats in the opening
            for (h = psu_holes) psu_boss_bridge(h);
        }
        // PSU M4 mounting holes drilled through bosses and panel
        for (h = psu_holes)
            translate([psu_x0 + h[0], -boss_th-0.1, tw + h[1]])
                rotate([-90,0,0]) cylinder(h=tw+boss_th+0.2, d=m4_d, $fn=16);
        // Retainer bar screw holes through rear panel (bosses are separate geometry, inward)
        for (bx = [bkt_cut_x0-7, bkt_cut_x0+bkt_cut_w+7])
            translate([bx, -0.1, ret_bar_z0+ret_bar_h/2])
                rotate([-90,0,0]) cylinder(h=tw+0.2, d=ret_screw_d, $fn=12);
        // ── Honeycomb venting ───────────────────────────────────────────────────
        // Zone A: left of PCIe bracket opening
        if (rp_zone_a_x1 > rp_zone_a_x0 + hc_mg)
            translate([rp_zone_a_x0, 0, hc_mg])
                honeycomb(rp_zone_a_x1-rp_zone_a_x0, rack_h-2*hc_mg, tw);
        // Zone B: between PCIe bracket and IO shield — split above/below IO opening
        if (rp_zone_b_x1 > rp_zone_b_x0 + hc_mg) {
            // Below IO shield
            translate([rp_zone_b_x0, 0, hc_mg])
                honeycomb(rp_zone_b_x1-rp_zone_b_x0, io_z0-2*hc_mg, tw);
            // Above IO shield (in this narrow strip)
            translate([rp_zone_b_x0, 0, io_z0+io_h+hc_mg])
                honeycomb(rp_zone_b_x1-rp_zone_b_x0, rack_h-io_z0-io_h-2*hc_mg, tw);
        }
        // Zone C: right of PSU
        if (rp_zone_c_x1 > rp_zone_c_x0 + hc_mg)
            translate([rp_zone_c_x0, 0, hc_mg])
                honeycomb(rp_zone_c_x1-rp_zone_c_x0, rack_h-2*hc_mg, tw);
        // Zone D: directly above IO shield opening — full IO opening width
        translate([io_x0 + hc_mg, 0, io_z0 + io_h + hc_mg])
            honeycomb(io_w - 2*hc_mg, rack_h - io_z0 - io_h - 2*hc_mg, tw);
    }
}

// GPU retainer bar mounting bosses — protrude INWARD from inner panel face.
// Screws go: bar (outside) → panel → boss (inside). Bar sits flush on outer face.
module retainer_bar_bosses() {
    difference() {
        union() {
            // Bosses on the INSIDE (−Y from inner face = tray_d−tw, protrude inward)
            translate([bkt_cut_x0-12,          tray_d-tw-ret_boss_inset, ret_bar_z0-1]) cube([10, ret_boss_inset, ret_bar_h+2]);
            translate([bkt_cut_x0+bkt_cut_w+2, tray_d-tw-ret_boss_inset, ret_bar_z0-1]) cube([10, ret_boss_inset, ret_bar_h+2]);
        }
        // Clearance holes drilled from outside (outer face) through panel and full boss depth
        for (bx = [bkt_cut_x0-7, bkt_cut_x0+bkt_cut_w+7])
            translate([bx, tray_d-tw-ret_boss_inset-0.1, ret_bar_z0+ret_bar_h/2])
                rotate([-90,0,0]) cylinder(h=tw+ret_boss_inset+0.2, d=ret_screw_d, $fn=12);
    }
}

// Rear support lip — world coordinates. Extends behind the rear panel so the tray
// can rest on a cross-brace or rear rack rails instead of hanging from the ears alone.
// x0/x1 define which X slice of the tray this lip spans (split at cut_x for RL/RR).
module rear_support_lip(x0, x1) {
    difference() {
        translate([x0, tray_d-tw, 0]) cube([x1-x0, tw+lip_yd, lip_zh]);
        for (x = [x0+lip_yd/2 : lip_yd : x1-lip_yd/2])
            translate([x, tray_d+lip_yd/2, -0.1])
                cylinder(h=lip_zh+0.2, d=lip_md, $fn=16);
    }
}

module psu_cradle() {
    cw = 4;
    // psu_x0 is the LEFT edge of the PSU opening in model space.
    // The motherboard sits at X=4..309, PSU at X=321..407.
    // So psu_x0-cw side = LEFT wall = CLOSEST to motherboard → gets honeycomb.
    //    psu_x0+psu_xw side = RIGHT wall = further from motherboard → solid, full height.
    difference() {
        union() {
            // Floor cradle
            translate([psu_x0-cw, psu_y0, 0]) cube([psu_xw+2*cw, psu_yd+cw, tw+cw]);
            // Left wall (closest to motherboard) — full PSU height
            translate([psu_x0-cw, psu_y0, 0]) cube([cw, psu_yd, psu_zh]);
            // Right wall (further from motherboard) — full PSU height
            translate([psu_x0+psu_xw, psu_y0, 0]) cube([cw, psu_yd, psu_zh]);
        }
        // Honeycomb left wall only — wall is `cw` thick in X, spans psu_yd in Y, psu_zh in Z.
        // Module drills in +Y; rotate([0,0,-90]) maps Y→X so holes drill through the wall in X.
        // After that rotation, the grid's "w" param spans -Y (so translate to far Y edge),
        // and "h" spans Z as normal.
        translate([psu_x0 - cw, psu_y0 + psu_yd - hc_mg, hc_mg])
            rotate([0, 0, -90])
                honeycomb(psu_yd - 2*hc_mg, psu_zh - 2*hc_mg, cw, r=2.5, wall=1.0);
    }
}

// Plain tray shell — floor + two outer rails.  No interior ribs.
// Rails start at Y=tw (not Y=0) so the ear extensions can fill the front face gap.
module tray_shell(ear_slots=true) {
    difference() {
        union() {
            cube([tray_w, tray_d, tw]);
            translate([0,        tw, 0]) cube([tw, tray_d-tw, rack_h]);
            translate([tray_w-tw, tw, 0]) cube([tw, tray_d-tw, rack_h]);
        }
        // GPU floor tab slots
        for (tx = tab_x)
            translate([tx-tab_sw/2, tray_d-tw-tab_sd, -0.1])
                cube([tab_sw, tab_sd+tw+0.2, tw+0.2]);
        // Ear interlock slots — omit when ears are fused directly to FL/FR
        if (ear_slots) {
            left_ear_slots();
            right_ear_slots();
        }
        // ── Left rail honeycomb (inner face, X=0..tw, wall in X direction) ─────
        // Split at cut_y seam with hc_mg margin either side.
        // Honeycomb module expects wall in Y — rotate -90° around Z so Y→X.
        // Front half (Y=tw..cut_y)
        rotate([0, 0, -90])
            translate([-(cut_y - hc_mg), 0, hc_mg])
                honeycomb(cut_y - tw - 2*hc_mg, rack_h - 2*hc_mg, tw);
        // Rear half (Y=cut_y..tray_d-tw)
        rotate([0, 0, -90])
            translate([-(tray_d - tw - hc_mg), 0, hc_mg])
                honeycomb(tray_d - tw - cut_y - 2*hc_mg, rack_h - 2*hc_mg, tw);
        // ── Right rail honeycomb (inner face, X=tray_w-tw..tray_w, wall in X) ──
        // Same split at cut_y.
        // Front half
        translate([tray_w-tw, 0, 0]) rotate([0, 0, -90])
            translate([-(cut_y - hc_mg), 0, hc_mg])
                honeycomb(cut_y - tw - 2*hc_mg, rack_h - 2*hc_mg, tw);
        // Rear half
        translate([tray_w-tw, 0, 0]) rotate([0, 0, -90])
            translate([-(tray_d - tw - hc_mg), 0, hc_mg])
                honeycomb(tray_d - tw - cut_y - 2*hc_mg, rack_h - 2*hc_mg, tw);
    }
}

module gpu_retainer_bar() {
    difference() {
        union() {
            // Main bar body — screws to rear panel bosses
            cube([ret_bar_w, ret_bar_d, ret_bar_h]);
            // Lip at BOTTOM of bar (z=0), protruding in +Y — sits on top of GPU bracket
            // Bar is "upside down" vs original: lip hangs down over the bracket edge
            translate([0, ret_bar_d, 0]) cube([ret_bar_w, ret_lip_d, ret_lip_h]);
        }
        // Panel mounting screw holes (through bar body, front-to-back in Y)
        for (bx = [7, ret_bar_w-7])
            translate([bx, -0.1, ret_bar_h/2]) rotate([-90,0,0]) {
                cylinder(h=ret_bar_d+0.2, d=ret_screw_d, $fn=12);
                cylinder(h=3, d1=6, d2=ret_screw_d, $fn=16);
            }
        // GPU bracket screw holes — through lip in Z, 20.5mm apart, centered on bar
        for (gx = [ret_bar_w/2 - ret_gpu_screw_sp/2, ret_bar_w/2 + ret_gpu_screw_sp/2])
            translate([gx, ret_bar_d + ret_lip_d/2, -0.1])
                cylinder(h=ret_lip_h+0.2, d=ret_gpu_screw_d, $fn=12);
    }
}

module rack_ear() {
    difference() {
        cube([ear_w, tw, rack_h]);
        for (u = [0:rack_u-1]) {
            z1 = u*u_mm + (u_mm-15.875)/2;
            z2 = z1 + 15.875;
            for (zh = [z1, z2])
                translate([ear_w/2, -0.1, zh]) rotate([-90,0,0])
                    hull() {
                        translate([0,-2.5,0]) cylinder(h=tw+0.2, d=7.1, $fn=20);
                        translate([0, 2.5,0]) cylinder(h=tw+0.2, d=7.1, $fn=20);
                    }
        }
    }
}

// Extension fills the front face gap left by the rail recess (starts at Z=tw, above floor)
module rack_ear_L() { union() { rack_ear(); left_ear_tabs();  translate([ear_w,  0, tw]) cube([tw, tw, rack_h-tw]); } }
module rack_ear_R() { union() { rack_ear(); right_ear_tabs(); translate([-tw,    0, tw]) cube([tw, tw, rack_h-tw]); } }

// ─── GHOSTS ───────────────────────────────────────────────────────────────────

module ghost_board() {
    color("limegreen",0.2) translate([bx0,by0,tw+soff_h]) cube([atx_w,atx_d,1.6]);
}
module ghost_gpu() {
    color("royalblue",0.2) translate([gpu_x0,gpu_y0,tw+soff_h+1.6]) cube([gpu_xw,gpu_l,gpu_zh]);
}
module ghost_psu() {
    color("darkorange",0.2) translate([psu_x0,psu_y0,tw]) cube([psu_xw,psu_yd,psu_zh]);
}

// ─── ASSEMBLY ─────────────────────────────────────────────────────────────────

module assembly() {
    color("silver") {
        tray_shell();
        atx_standoffs();
        psu_cradle();
        front_panel_solid();
        translate([0, tray_d-tw, 0]) rear_panel_solid();
        retainer_bar_bosses();
        rear_support_lip(0, cut_x);
        rear_support_lip(cut_x, tray_w);
        translate([bkt_cut_x0-(ret_bar_w-bkt_cut_w)/2, tray_d, ret_bar_z0])
            gpu_retainer_bar();  // bar body sits above bracket top; lip at z=0 drops over it
    }
    color("dimgray") {
        // Ears fused into tray_FL/FR for printing — shown here for assembly preview only
        translate([-ear_w, 0, 0]) rack_ear_L();
        translate([tray_w, 0, 0]) rack_ear_R();
    }
    ghost_board();  ghost_gpu();  ghost_psu();
}

// ─── PRINTABLE SECTIONS ───────────────────────────────────────────────────────

// ── FL: Front-Left ─────────────────────────────────────────────────────────────
// On a Bambu P1S (256mm bed) the ear fits: 241×178mm total — print as one piece.
module tray_FL() {
    difference() {
        union() {
            intersection() {
                union() { tray_shell(ear_slots=false); front_panel_solid(); atx_standoffs(); }
                cube([cut_x, cut_y, rack_h+1]);
            }
            xj_floor_L(0, cut_y);       // floor tabs → FR
            yj_floor_F(0, cut_x);       // floor tabs → RL
            front_panel_tongue();        // panel tongue → FR
            left_rail_tongue();          // rail tongue  → RL
            // Left rack ear fused in — no separate ear piece needed
            translate([-ear_w, 0, 0]) rack_ear();
            translate([0, 0, tw]) cube([tw, tw, rack_h-tw]);  // front-face gap fill
        }
        xj_floor_L_sock(0, cut_y);      // floor sockets for FR's tabs
        yj_floor_F_sock(0, cut_x);      // floor sockets for RL's tabs
    }
}

// ── FR: Front-Right ────────────────────────────────────────────────────────────
// On a Bambu P1S (256mm bed) the ear fits: 241×178mm total — print as one piece.
module tray_FR() {
    difference() {
        union() {
            intersection() {
                union() { tray_shell(ear_slots=false); front_panel_solid(); psu_cradle(); atx_standoffs(); }
                translate([cut_x,0,0]) cube([tray_w-cut_x, cut_y, rack_h+1]);
            }
            xj_floor_R(0, cut_y);       // floor tabs → FL
            yj_floor_F(cut_x, tray_w);  // floor tabs → RR
            right_rail_tongue();         // rail tongue → RR
            // Right rack ear fused in — no separate ear piece needed
            translate([tray_w, 0, 0]) rack_ear();
            translate([tray_w-tw, 0, tw]) cube([tw, tw, rack_h-tw]);  // front-face gap fill
        }
        xj_floor_R_sock(0, cut_y);      // floor sockets for FL's tabs
        yj_floor_F_sock(cut_x, tray_w); // floor sockets for RR's tabs
        front_panel_groove();            // panel groove receives FL's tongue
    }
}

// ── RL: Rear-Left ──────────────────────────────────────────────────────────────
module tray_RL() {
    difference() {
        union() {
            intersection() {
                union() {
                    tray_shell();
                    atx_standoffs();
                    translate([0, tray_d-tw, 0]) rear_panel_solid();
                }
                translate([0,cut_y,0]) cube([cut_x, tray_d-cut_y, rack_h+1]);
            }
            xj_floor_L(cut_y, tray_d);  // floor tabs → RR
            yj_floor_R(0, cut_x);        // floor tabs → FL
            rear_panel_tongue();          // panel tongue → RR
            retainer_bar_bosses();        // outside mask — protrude beyond tray_d
            rear_support_lip(0, cut_x);  // outside mask — extends beyond tray_d
        }
        xj_floor_L_sock(cut_y, tray_d); // floor sockets for RR's tabs
        yj_floor_R_sock(0, cut_x);       // floor sockets for FL's tabs
        left_rail_groove();               // rail groove receives FL's tongue
    }
}

// ── RR: Rear-Right ─────────────────────────────────────────────────────────────
module tray_RR() {
    difference() {
        union() {
            intersection() {
                union() {
                    tray_shell();
                    atx_standoffs();
                    psu_cradle();
                    translate([0, tray_d-tw, 0]) rear_panel_solid();
                }
                translate([cut_x,cut_y,0]) cube([tray_w-cut_x, tray_d-cut_y, rack_h+1]);
            }
            xj_floor_R(cut_y, tray_d);  // floor tabs → RL
            yj_floor_R(cut_x, tray_w);  // floor tabs → FR
            rear_support_lip(cut_x, tray_w); // outside mask — extends beyond tray_d
        }
        xj_floor_R_sock(cut_y, tray_d); // floor sockets for RL's tabs
        yj_floor_R_sock(cut_x, tray_w); // floor sockets for FR's tabs
        rear_panel_groove();              // panel groove receives RL's tongue
        right_rail_groove();              // rail groove receives FR's tongue
    }
}

// ─── RENDER SELECTION ─────────────────────────────────────────────────────────
// Uncomment ONE section → F6 → Export as STL.  Print floor-face-down.
// tray_FL and tray_FR include their rack ears — no separate ear print needed (Bambu P1S bed).

//assembly();

//tray_FL();                              // left front half + left ear  (241×178mm)
//translate([-cut_x, 0, 0]) tray_FR();   // right front half + right ear (241×178mm)
translate([0, -cut_y, 0])      tray_RL();
//translate([-cut_x, -cut_y, 0]) tray_RR();
//gpu_retainer_bar();
//rack_ear();   // standalone ear (no longer needed — fused into FL/FR)
