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
  [  17.5, 231],  // A: 0.40" from IO, left column
  [ 143.5, 229.5],  // C: 0.40" from IO, center column
  [ 299.45, 210],  // F: 0.90" from IO, right column
  [  18.5,  75.5],  // G: middle row, left column
  [ 143.5,  75.5],  // H: middle row, center column
  [ 299.45,  75.5],  // J: middle row, right column
  [  18.5,   4],  // K: 0.25" from front, left column
  [ 143.5,   4],  // L: 0.25" from front, center column
  [ 299.45,   4],  // M: 0.25" from front, right column
];

bx0 = tw;
by0 = tray_d - tw - atx_d - 1;  // 1mm clearance between IO edge and rear panel for GPU bracket tabs

psu_xw   = 88;
psu_yd   = 140;
psu_zh   = 153;

// PSU mounting hole positions — X coords are in MODEL space (front-of-case view).
// Adam measures from the BACK, so left/right are mirrored: Adam's right = model's left.
//
//   Adam's view (from back)    →   Model coord
//   top-right  (5mm  from Adam-right) →  5.0mm from model-left
//   top-left   (16mm from Adam-left)  →  86-16 = 70.0mm from model-left
//   bottom-right (5.6mm from Adam-right, 7.3mm up)  →  5.6mm from model-left
//   bottom-left  (6.5mm from Adam-left, 31mm up)    →  86-6.5 = 79.5mm from model-left

psu_hole_tl_x =   6.5;   // model top-left    = Adam's top-right (confirmed correct)
psu_hole_tr_x =  71;   // model top-right   = Adam's top-left  (16mm from Adam's left)
psu_hole_bl_x =   6.5;   // model bottom-left = Adam's bottom-right (5.6mm from Adam's right)
psu_hole_br_x =  82;   // model bottom-right= Adam's bottom-left  (6.5mm from Adam's left → 86-6.5)

psu_hole_top_z =  148;  // both top holes: 5mm from top  (150 - 5)
psu_hole_bl_z  =    10.5;  // model bottom-left  = Adam's bottom-right: 7.3mm from bottom
psu_hole_br_z  =   34.5;  // model bottom-right = Adam's bottom-left:  31mm from bottom

psu_holes = [
    [ psu_hole_tl_x, psu_hole_top_z ],  // top-left
    [ psu_hole_tr_x, psu_hole_top_z ],  // top-right
    [ psu_hole_bl_x, psu_hole_bl_z  ],  // bottom-left
    [ psu_hole_br_x, psu_hole_br_z  ],  // bottom-right
];

psu_boss_c  = 10;   // boss footprint size (square)
psu_boss_th = 4;    // boss protrusion beyond inner face (into tray)
psu_gap  = 12.5;
psu_x0   = bx0 + atx_w + psu_gap;   // 320
psu_y0   = tray_d - tw - psu_yd;

gpu_l    = 267;
gpu_zh   = 125;
gpu_xw   = 2 * 20.32;
pcie_bx  = 110;
pcie_by  = 50;
gpu_x0   = bx0 + pcie_bx - gpu_xw/2;
gpu_y0   = by0 + pcie_by - 73;

// PCIe expansion slot zone — standard ATX 6-slot layout
// GPU (2-slot 2080 Ti) occupies the rightmost 2 positions (slots 5–6).
pcie_n      = 6;                              // total slot positions
pcie_pitch  = 20.32;                          // 0.800" standard ATX pitch
pcie_bw     = 18.42;                          // slot opening width (0.725")
pcie_x0     = gpu_x0 - (pcie_n-2)*pcie_pitch;// left edge of slot zone ≈ 12.4mm
bkt_cut_z0  = tw;                             // slot zone bottom Z
bkt_cut_h   = 125;                            // total slot zone height (kept for Z refs)
pcie_oh     = bkt_cut_h - 14;                 // slot opening height = 111mm; 14mm screw-tab above
pcie_scr_d  = 3.4;                            // M3 clearance — bracket & bar retention screws

// Retention bar — spans all 6 slots, mounts on inner face of rear panel
pbar_w      = pcie_n * pcie_pitch;            // bar width = 121.92mm
pbar_h      = 16;                             // bar height (screw-tab zone)
pbar_d      = tw - 1;                         // bar thickness = 3mm
pbar_z0     = bkt_cut_z0 + pcie_oh - 1;      // bar bottom Z = 114mm
pbar_lip_d  = 14;                             // lip protrudes inward — must cover ATX bracket tab (~12mm)
pbar_lip_h  = 4;                              // lip height (Z)

tab_sw  = 18;
tab_sd  = 5;
tab_x   = [for (i = [0:pcie_n-1]) pcie_x0 + i*pcie_pitch + pcie_bw/2];

btn_d    = 16.4;  // 16mm panel-mount power button + 0.4mm clearance
btn_cx   = 30;   // X: bottom-left, in the solid band below the fans
btn_cz   = 18;   // Z: center of bottom solid band (fans start at Z≈33mm)

fan_sq   = 120;
fan_msp  = 105;
// Three fans evenly spaced across the front panel (fp_w=436mm, gap=19mm each side)
fan1_cx  = tw + 79.0;   //  83mm from tray left — over GPU/PCIe slot
fan2_cx  = tray_w / 2;  // 222mm — centre, over mid-board
fan3_cx  = tray_w - tw - 79.0;  // 361mm — over board right + PSU gap
fan_cz   = rack_h / 2;

fh_w     = 18;                         // handle width in X (fits solid zone left/right of fans)
fh_d     = 22;                         // protrusion in front of panel face (−Y)
fh_z0    = fan_cz - (fan_sq-8)/2;     // flush with fan bottom ≈33mm
fh_z1    = fan_cz + (fan_sq-8)/2;     // flush with fan top ≈145mm
fh_h     = fh_z1 - fh_z0;             // matches fan height ≈112mm
fh_ro    = 4;                          // outer corner radius
fh_wy    = 6;                          // back wall thickness (at panel face)
fh_wz    = 10;                         // top/bottom wall thickness around finger slot
fh_xm    = 3;                          // X margin each side of finger slot

io_w     = 165;
io_h     = 46;
io_x0    = 150;   // IO shield at left (IO) edge of board — standard ATX position
io_z0    = tw + soff_h;

cut_x    = tray_w / 2;   // ≈ 222 mm
cut_y    = tray_d / 2;   // 200 mm

// Joint geometry — floor box joints (kept; easy to engage flat-on-table)
fj_d     = 6;     // tab depth (protrusion past seam face)
fj_w     = 18;    // tab width along seam
fj_fit   = 0.25;  // socket clearance per side

// Panel/rail seam bolt joint parameters (replaces tongue-and-groove)
// M3×20 SHCS through clearance boss; M3 hex nut drops into nut-trap from above.
bj_w    = 14;   // clearance-side boss width along seam (bolt head side)
bj_nt_d = 7;    // nut-trap boss depth along seam (nut side)
bj_d    = 10;   // boss depth into case interior (perpendicular to panel/rail)
bj_h    = 16;   // boss height in Z
bj_md   = 3.4;  // M3 clearance hole diameter
bj_csd  = 6.5;  // M3 socket-head counterbore diameter
bj_csz  = 3.5;  // counterbore depth
bj_nw   = 5.8;  // M3 hex nut flat-to-flat + 0.3mm clearance
bj_nh   = 2.6;  // M3 hex nut height + 0.2mm clearance

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
    for (i=[0:n-1]) if (i%2==1)
        translate([cut_x, y0+i*fj_w, 0]) cube([fj_d, fj_w, tw]);
}
module xj_floor_L_sock(y0, y1) {    // LEFT sockets (receive R tabs)
    n = floor((y1-y0)/fj_w);
    for (i=[0:n-1]) if (i%2==0)
        translate([cut_x-fj_d-0.01, y0+i*fj_w-fj_fit, -0.01])
            cube([fj_d+0.02, fj_w+2*fj_fit, tw+0.02]);
}
module xj_floor_R(y0, y1) {         // RIGHT tabs protruding -X
    n = floor((y1-y0)/fj_w);
    for (i=[0:n-1]) if (i%2==0)
        translate([cut_x-fj_d, y0+i*fj_w, 0]) cube([fj_d, fj_w, tw]);
}
module xj_floor_R_sock(y0, y1) {    // RIGHT sockets (receive L tabs)
    n = floor((y1-y0)/fj_w);
    for (i=[0:n-1]) if (i%2==1)
        translate([cut_x-0.01, y0+i*fj_w-fj_fit, -0.01])
            cube([fj_d+0.02, fj_w+2*fj_fit, tw+0.02]);
}

// ── Y=cut_y seam: floor-edge box joints ──────────────────────────────────────
// Even-index tabs belong to the FRONT piece (FL, FR).
// Odd-index tabs belong to the REAR piece (RL, RR).

module yj_floor_F(x0, x1) {         // FRONT tabs protruding +Y
    n = floor((x1-x0)/fj_w);
    for (i=[0:n-1]) if (i%2==1)
        translate([x0+i*fj_w, cut_y, 0]) cube([fj_w, fj_d, tw]);
}
module yj_floor_F_sock(x0, x1) {    // FRONT sockets (receive R tabs)
    n = floor((x1-x0)/fj_w);
    for (i=[0:n-1]) if (i%2==0)
        translate([x0+i*fj_w-fj_fit, cut_y-fj_d-0.01, -0.01])
            cube([fj_w+2*fj_fit, fj_d+0.02, tw+0.02]);
}
module yj_floor_R(x0, x1) {         // REAR tabs protruding -Y
    n = floor((x1-x0)/fj_w);
    for (i=[0:n-1]) if (i%2==0)
        translate([x0+i*fj_w, cut_y-fj_d, 0]) cube([fj_w, fj_d, tw]);
}
module yj_floor_R_sock(x0, x1) {    // REAR sockets (receive F tabs)
    n = floor((x1-x0)/fj_w);
    for (i=[0:n-1]) if (i%2==1)
        translate([x0+i*fj_w-fj_fit, cut_y-0.01, -0.01])
            cube([fj_w+2*fj_fit, fj_d+0.02, tw+0.02]);
}

// ── Seam bolt-joint Z positions ───────────────────────────────────────────────
// Front panel: 2 bolts, clear of fan zone (Z≈28–150mm).
fp_tab_z = [15, rack_h - 15];
// Rear panel: 3 bolts in solid border bands (below IO, above IO, top).
rp_tab_z = [hc_mg/2, io_z0 + io_h + hc_mg/2, rack_h - hc_mg/2];
// Left/right rails: 2 bolts at ⅓ and ⅔ height.
lr_tab_z = [rack_h * 0.33, rack_h * 0.67];

// ─── SEAM BOLT-JOINT MODULES ─────────────────────────────────────────────────
// Replaces tongue-and-groove on all panel and rail seams.
// Each seam gets one clearance-side boss (bolt head counterbore on interior face)
// and one nut-trap boss (hex slot open at +Z — drop nut in before assembly).
// Bolt: M3×20 SHCS.  Floor box joints unchanged; they handle in-plane shear.

// ── Front panel seam (X=cut_x, bolt in X, boss protrudes +Y from panel) ──────

module fp_seam_bolt_L(z) {    // FL — clearance + head counterbore
    difference() {
        translate([cut_x - bj_w, tw, z - bj_h/2]) cube([bj_w, bj_d, bj_h]);
        translate([cut_x - bj_w - 0.1, tw + bj_d/2, z]) rotate([0,90,0]) {
            cylinder(h=bj_w+0.2, d=bj_md, $fn=16);
            cylinder(h=bj_csz,   d=bj_csd, $fn=24);
        }
    }
}
module fp_seam_bolt_R(z) {    // FR — nut-trap slot open at +Z
    difference() {
        translate([cut_x, tw, z - bj_h/2]) cube([bj_nt_d, bj_d, bj_h]);
        // clearance hole
        translate([cut_x - 0.1, tw + bj_d/2, z]) rotate([0,90,0])
            cylinder(h=bj_nt_d+0.2, d=bj_md, $fn=16);
        // hex nut slot — open at top so nut drops in before assembly
        translate([cut_x, tw + bj_d/2 - bj_nw/2, z - bj_nh/2])
            cube([bj_nh, bj_nw, bj_h/2 + bj_nh/2 + 0.1]);
    }
}

// ── Rear panel seam (X=cut_x, bolt in X, boss protrudes −Y from panel) ───────

module rp_seam_bolt_L(z) {    // RL — clearance + head counterbore
    difference() {
        translate([cut_x - bj_w, tray_d - tw - bj_d, z - bj_h/2]) cube([bj_w, bj_d, bj_h]);
        translate([cut_x - bj_w - 0.1, tray_d - tw - bj_d/2, z]) rotate([0,90,0]) {
            cylinder(h=bj_w+0.2, d=bj_md, $fn=16);
            cylinder(h=bj_csz,   d=bj_csd, $fn=24);
        }
    }
}
module rp_seam_bolt_R(z) {    // RR — nut-trap slot open at +Z
    difference() {
        translate([cut_x, tray_d - tw - bj_d, z - bj_h/2]) cube([bj_nt_d, bj_d, bj_h]);
        translate([cut_x - 0.1, tray_d - tw - bj_d/2, z]) rotate([0,90,0])
            cylinder(h=bj_nt_d+0.2, d=bj_md, $fn=16);
        translate([cut_x, tray_d - tw - bj_d/2 - bj_nw/2, z - bj_nh/2])
            cube([bj_nh, bj_nw, bj_h/2 + bj_nh/2 + 0.1]);
    }
}

// ── Left rail seam (Y=cut_y, bolt in Y, boss protrudes +X from rail) ─────────

module lr_seam_bolt_F(z) {    // FL — clearance + head counterbore
    difference() {
        translate([tw, cut_y - bj_w, z - bj_h/2]) cube([bj_d, bj_w, bj_h]);
        translate([tw + bj_d/2, cut_y - bj_w - 0.1, z]) rotate([-90,0,0]) {
            cylinder(h=bj_w+0.2, d=bj_md, $fn=16);
            cylinder(h=bj_csz,   d=bj_csd, $fn=24);
        }
    }
}
module lr_seam_bolt_R(z) {    // RL — nut-trap slot open at +Z
    difference() {
        translate([tw, cut_y, z - bj_h/2]) cube([bj_d, bj_nt_d, bj_h]);
        translate([tw + bj_d/2, cut_y - 0.1, z]) rotate([-90,0,0])
            cylinder(h=bj_nt_d+0.2, d=bj_md, $fn=16);
        translate([tw + bj_d/2 - bj_nw/2, cut_y, z - bj_nh/2])
            cube([bj_nw, bj_nh, bj_h/2 + bj_nh/2 + 0.1]);
    }
}

// ── Right rail seam (Y=cut_y, bolt in Y, boss protrudes −X from rail) ────────

module rr_seam_bolt_F(z) {    // FR — clearance + head counterbore
    difference() {
        translate([tray_w - tw - bj_d, cut_y - bj_w, z - bj_h/2]) cube([bj_d, bj_w, bj_h]);
        translate([tray_w - tw - bj_d/2, cut_y - bj_w - 0.1, z]) rotate([-90,0,0]) {
            cylinder(h=bj_w+0.2, d=bj_md, $fn=16);
            cylinder(h=bj_csz,   d=bj_csd, $fn=24);
        }
    }
}
module rr_seam_bolt_R(z) {    // RR — nut-trap slot open at +Z
    difference() {
        translate([tray_w - tw - bj_d, cut_y, z - bj_h/2]) cube([bj_d, bj_nt_d, bj_h]);
        translate([tray_w - tw - bj_d/2, cut_y - 0.1, z]) rotate([-90,0,0])
            cylinder(h=bj_nt_d+0.2, d=bj_md, $fn=16);
        translate([tray_w - tw - bj_d/2 - bj_nw/2, cut_y, z - bj_nh/2])
            cube([bj_nw, bj_nh, bj_h/2 + bj_nh/2 + 0.1]);
    }
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
    // Pull handles sit just inside each rail; power button bottom-left below fans.
    difference() {
        union() {
            translate([tw, 0, 0]) cube([tray_w-2*tw, tw, rack_h]);
            front_handle(tw);                    // left handle, just inside left rail
            front_handle(tray_w - tw - fh_w);   // right handle, just inside right rail
        }
        fan_cutout(fan1_cx, fan_cz);
        fan_cutout(fan2_cx, fan_cz);
        fan_cutout(fan3_cx, fan_cz);
        // 16mm panel-mount power button — bottom-left corner, below fans
        translate([btn_cx, -0.1, btn_cz]) rotate([-90,0,0])
            cylinder(h=tw+0.2, d=btn_d, $fn=32);
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
    //   Zone A: left of PCIe slot zone — effectively zero-width with 6-slot array, skipped by guard
    //   Zone B: between PCIe slot zone and IO shield — ~4mm gap, also skipped by guard
    //   Zone C: right of PSU  |  Zone D: above IO shield (split at cut_x)

    rp_zone_a_x0 = hc_mg;
    rp_zone_a_x1 = pcie_x0 - hc_mg;
    rp_zone_b_x0 = pcie_x0 + pcie_n*pcie_pitch + hc_mg;
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
                translate([io_x0, -0.1, io_z0-1]) cube([io_w, tw+0.2, io_h+1]);
                // PSU opening — 3 cuts that preserve 10mm corners
                translate([psu_x0,       -0.1, tw+psu_c])        cube([psu_xw,          tw+0.2, psu_zh-2*psu_c]);
                translate([psu_x0+psu_c, -0.1, tw])               cube([psu_xw-2*psu_c, tw+0.2, psu_c]);
                translate([psu_x0+psu_c, -0.1, tw+psu_zh-psu_c]) cube([psu_xw-2*psu_c, tw+0.2, psu_c]);
                // PCIe expansion slots — 6 openings at standard ATX pitch, dividers between
                for (i = [0:pcie_n-1])
                    translate([pcie_x0 + i*pcie_pitch, -0.1, bkt_cut_z0])
                        cube([pcie_bw, tw+0.2, pcie_oh]);
            }
            // PSU mounting bosses — L-shaped bridges so no boss floats in the opening
            for (h = psu_holes) psu_boss_bridge(h);
        }
        // PSU M4 mounting holes drilled through bosses and panel
        for (h = psu_holes)
            translate([psu_x0 + h[0], -boss_th-0.1, tw + h[1]])
                rotate([-90,0,0]) cylinder(h=tw+boss_th+0.2, d=m4_d, $fn=16);
        // Retention bar mounting holes — 3 screws at divider centres, screw-tab zone
        // (per-slot bracket thumbscrews go through the bar lip in Z, NOT through this panel)
        for (i = [1, 3, 5])
            translate([pcie_x0 + i*pcie_pitch - 0.95, -0.1, pbar_z0 + pbar_h/2])
                rotate([-90,0,0]) cylinder(h=tw+0.2, d=pcie_scr_d, $fn=12);
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
        // Zone D: above IO shield — split at cut_x so each half is self-contained within its piece.
        // D-L lives entirely in RL (X=162..210), D-R entirely in RR (X=234..303).
        // 12mm solid margin at the seam prevents partial hexes hanging off the edge.
        if (cut_x - hc_mg > io_x0 + hc_mg)
            translate([io_x0 + hc_mg, 0, io_z0 + io_h + hc_mg])
                honeycomb(cut_x - hc_mg - (io_x0 + hc_mg), rack_h - io_z0 - io_h - 2*hc_mg, tw);
        if (io_x0 + io_w - hc_mg > cut_x + hc_mg)
            translate([cut_x + hc_mg, 0, io_z0 + io_h + hc_mg])
                honeycomb((io_x0 + io_w - hc_mg) - (cut_x + hc_mg), rack_h - io_z0 - io_h - 2*hc_mg, tw);
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

// PCIe retention bar — interior piece, presses against inner face of rear panel.
// Install before cards: 3 M3 screws at divider centres hold the bar to the panel.
// Lip at Y=0 face (inward) forms a shelf — bracket screw tabs slide under it.
// Then 6 per-slot thumbscrews secure individual brackets through panel + bar.
// Assembly position: translate([pcie_x0, tray_d-tw-pbar_d, pbar_z0])
// Print orientation: flat face (Y=0) on the bed.
module pcie_retention_bar() {
    difference() {
        union() {
            cube([pbar_w, pbar_d, pbar_h]);
            // Lip at bottom protrudes inward (−Y from inner face) — bracket tabs rest here
            translate([0, -pbar_lip_d, 0]) cube([pbar_w, pbar_lip_d, pbar_lip_h]);
        }
        // 3 bar mounting holes at divider centres — screws come from outside through rear panel
        for (i = [1, 3, 5])
            translate([i*pcie_pitch - 0.95, -0.1, pbar_h/2])
                rotate([-90,0,0]) cylinder(h=pbar_d+0.2, d=pcie_scr_d, $fn=12);
        // 6 per-slot bracket thumbscrew holes — drill Z-down through the lip from inside
        // Screw comes from above (inside case), through lip, into bracket screw tab below
        for (i = [0:pcie_n-1])
            translate([i*pcie_pitch + pcie_bw/2, -pbar_lip_d/2, -0.1])
                cylinder(h=pbar_lip_h+0.2, d=pcie_scr_d, $fn=12);
    }
}

// Blank slot cover — print one per unused PCIe slot position.
// Drop in from outside, screw tab at top captured by retention bar lip.
// Print floor-face-down (the flat back face is the floor).
module pcie_slot_cover() {
    sc_w  = pcie_bw - 0.4;              // 0.2mm clearance per side
    sc_h  = pcie_oh + 10;               // full height: opening + screw tab stub
    sc_d  = tw;                          // matches panel wall thickness
    vent_w = sc_w - 4;                  // louvered vent width
    difference() {
        cube([sc_w, sc_d, sc_h]);
        // Bracket thumbscrew hole in screw tab zone
        translate([sc_w/2, -0.1, pcie_oh + 5])
            rotate([-90,0,0]) cylinder(h=sc_d+0.2, d=pcie_scr_d, $fn=12);
        // Louvered vent slots — 7mm tall slots at 13mm pitch across lower 90% of opening
        for (z = [8 : 13 : pcie_oh - 8])
            translate([2, -0.1, z]) cube([vent_w, sc_d+0.2, 7]);
    }
}

// Pull handle — sits on the front panel just inside each side rail, protrudes in −Y.
// Rounded-rectangle body with a capsule finger slot that opens on the left/right faces.
// x0 = left edge of the handle in world X.
// Slot drills through in X — slip fingers in from the inner side face toward the fan.
module front_handle(x0) {
    slot_r  = (fh_w - 2*fh_xm) / 2;        // slot radius = 7mm
    slot_ch = fh_h/2 - fh_wz - slot_r;      // capsule half-height of centre section = 39mm
    slot_yc = -(fh_d / 2);                  // slot Y centre = mid-depth; 4mm walls front/back
    difference() {
        // Rounded-rectangle body: back face at Y=0 (panel outer face), front at Y=−fh_d
        hull()
            for (dx = [fh_ro, fh_w - fh_ro], dz = [fh_ro, fh_h - fh_ro])
                translate([x0 + dx, -fh_d, fh_z0 + dz])
                    rotate([-90,0,0]) cylinder(h=fh_d, r=fh_ro, $fn=24);
        // Capsule finger slot: drills through in X, openings on left and right side faces
        hull()
            for (dz = [slot_ch, -slot_ch])
                translate([x0 - 0.1, slot_yc, fh_z0 + fh_h/2 + dz])
                    rotate([0,90,0]) cylinder(h=fh_w + 0.2, r=slot_r, $fn=32);
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
        rear_support_lip(0, cut_x);
        rear_support_lip(cut_x, tray_w);
        translate([pcie_x0, tray_d-tw-pbar_d, pbar_z0])
            pcie_retention_bar();  // interior bar — brackets insert from inside, tabs rest on lip
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
                union() {
                    tray_shell(ear_slots=false); front_panel_solid(); atx_standoffs();
                    for (z = fp_tab_z) fp_seam_bolt_L(z);  // front panel bolt bosses → FR
                    for (z = lr_tab_z) lr_seam_bolt_F(z);  // left rail bolt bosses   → RL
                }
                cube([cut_x, cut_y, rack_h+1]);
            }
            xj_floor_L(0, cut_y);       // floor tabs → FR
            yj_floor_F(0, cut_x);       // floor tabs → RL
            // Left rack ear fused in — no separate ear piece needed
            translate([-ear_w, 0, 0]) rack_ear();
            translate([0, 0, tw]) cube([tw, tw, rack_h-tw]);  // front-face gap fill
            // G standoff (atx_holes[3]) lands in RL's yj socket zone and floats there.
            // Place it here on FL's tab instead — it sits squarely on the i=1 tab (X=18–36, Y=175–181).
            translate([bx0 + atx_holes[3][0], by0 + atx_holes[3][1], tw]) standoff();
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
                union() {
                    tray_shell(ear_slots=false); front_panel_solid(); psu_cradle(); atx_standoffs();
                    for (z = fp_tab_z) fp_seam_bolt_R(z);  // front panel bolt bosses → FL
                    for (z = lr_tab_z) rr_seam_bolt_F(z);  // right rail bolt bosses  → RR
                }
                translate([cut_x,0,0]) cube([tray_w-cut_x, cut_y, rack_h+1]);
            }
            xj_floor_R(0, cut_y);       // floor tabs → FL
            yj_floor_F(cut_x, tray_w);  // floor tabs → RR
            // Right rack ear fused in — no separate ear piece needed
            translate([tray_w, 0, 0]) rack_ear();
            translate([tray_w-tw, 0, tw]) cube([tw, tw, rack_h-tw]);  // front-face gap fill
        }
        xj_floor_R_sock(0, cut_y);      // floor sockets for FL's tabs
        yj_floor_F_sock(cut_x, tray_w); // floor sockets for RR's tabs
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
                    for (z = rp_tab_z) rp_seam_bolt_L(z);  // rear panel bolt bosses → RR
                    for (z = lr_tab_z) lr_seam_bolt_R(z);  // left rail bolt bosses  → FL
                }
                translate([0,cut_y,0]) cube([cut_x, tray_d-cut_y, rack_h+1]);
            }
            xj_floor_L(cut_y, tray_d);  // floor tabs → RR
            yj_floor_R(0, cut_x);        // floor tabs → FL
            rear_support_lip(0, cut_x);  // outside mask — extends beyond tray_d
        }
        xj_floor_L_sock(cut_y, tray_d); // floor sockets for RR's tabs
        yj_floor_R_sock(0, cut_x);       // floor sockets for FL's tabs
        // Remove G standoff — it's floating here (floor cut by yj socket). Moved to FL's tab.
        translate([bx0 + atx_holes[3][0], by0 + atx_holes[3][1], tw])
            cylinder(h=soff_h+0.1, d=soff_od+0.1, $fn=24);
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
                    for (z = rp_tab_z) rp_seam_bolt_R(z);  // rear panel bolt bosses → RL
                    for (z = lr_tab_z) rr_seam_bolt_R(z);  // right rail bolt bosses → FR
                }
                translate([cut_x,cut_y,0]) cube([tray_w-cut_x, tray_d-cut_y, rack_h+1]);
            }
            xj_floor_R(cut_y, tray_d);  // floor tabs → RL
            yj_floor_R(cut_x, tray_w);  // floor tabs → FR
            rear_support_lip(cut_x, tray_w); // outside mask — extends beyond tray_d
        }
        xj_floor_R_sock(cut_y, tray_d); // floor sockets for RL's tabs
        yj_floor_R_sock(cut_x, tray_w); // floor sockets for FR's tabs
    }
}

// ─── RENDER SELECTION ─────────────────────────────────────────────────────────
// Uncomment ONE section → F6 → Export as STL.  Print floor-face-down.
// tray_FL and tray_FR include their rack ears — no separate ear print needed (Bambu P1S bed).

assembly();

//tray_FL();                              // left front half + left ear  (241×178mm)
//translate([-cut_x, 0, 0]) tray_FR();   // right front half + right ear (241×178mm)
//translate([0, -cut_y, 0])      tray_RL();
//translate([-cut_x, -cut_y, 0]) tray_RR();
//pcie_retention_bar();               // interior retention bar — install before cards; 3×M3 to panel + 6×thumbscrews
//pcie_slot_cover();                  // blank cover — print 4× for unused slots
//rack_ear();   // standalone ear (no longer needed — fused into FL/FR)
