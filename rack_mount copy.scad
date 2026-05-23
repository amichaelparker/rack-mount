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
tw       = 3;

atx_w    = 305;
atx_d    = 244;
soff_h   = 6;
soff_od  = 6.5;
soff_id  = 3.2;

atx_holes = [
  [  6.35,   6.35], [  6.35,  50.80], [  6.35, 157.48], [  6.35, 234.95],
  [131.75,   6.35], [131.75, 157.48],
  [209.55,   6.35], [209.55, 157.48], [209.55, 234.95]
];

bx0 = tw;
by0 = tray_d - tw - atx_d;   // = 153 mm

psu_xw   = 86;
psu_yd   = 140;
psu_zh   = 150;
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

ret_bar_w   = bkt_cut_w + 20;
ret_bar_h   = 10;
ret_bar_d   = tw + 2;
ret_screw_d = 3.4;
ret_bar_z0  = bkt_cut_z0 + bkt_cut_h;

tab_sw  = 6;
tab_sd  = 5;
tab_x   = [gpu_x0 + gpu_xw*0.25, gpu_x0 + gpu_xw*0.75];

fan_sq   = 120;
fan_msp  = 105;
fan1_cx  = tray_w/2 - fan_sq/2 - 5;
fan2_cx  = tray_w/2 + fan_sq/2 + 5;
fan_cz   = rack_h / 2;

io_w     = 170;
io_h     = 44.50;
io_x0    = 140;   // IO shield at left (IO) edge of board — standard ATX position
io_z0    = tw + soff_h + 1.6;

cut_x    = tray_w / 2;   // ≈ 222 mm
cut_y    = tray_d / 2;   // 200 mm

// Joint geometry
fj_d     = 6;     // tab depth (protrusion past seam face)
fj_w     = 18;    // tab width along seam
fj_fit   = 0.25;  // socket clearance per side
fj_th    = 8;     // panel/rail tab height (for the wall-face tabs)

// ─── UTILITY ──────────────────────────────────────────────────────────────────

module standoff() {
    difference() {
        cylinder(h=soff_h, d=soff_od, $fn=24);
        cylinder(h=soff_h+0.1, d=soff_id, $fn=16);
    }
}

module fan_cutout(cx, cz) {
    translate([cx, -0.1, cz]) rotate([-90,0,0]) {
        cylinder(h=tw+0.2, d=fan_sq-8, $fn=64);
        for (sx=[-1,1], sz=[-1,1])
            translate([sx*fan_msp/2, sz*fan_msp/2, 0])
                cylinder(h=tw+0.2, d=4.4, $fn=12);
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
// Panel is tw=3mm thick in Y.  Tabs sit within that thickness, at 2 Z heights.
// FL has the tongue; FR has the groove.

module front_panel_tongue() {
    for (z=[rack_h*0.33, rack_h*0.67])
        translate([cut_x, 0, z-fj_th/2]) cube([fj_d, tw, fj_th]);
}
module front_panel_groove() {
    for (z=[rack_h*0.33, rack_h*0.67])
        translate([cut_x-0.01, -0.1, z-fj_th/2-fj_fit])
            cube([fj_d+0.12, tw+0.2, fj_th+2*fj_fit]);
}

// ── Rear panel seam at X=cut_x ────────────────────────────────────────────────
// RL has the tongue; RR has the groove.

module rear_panel_tongue() {
    for (z=[rack_h*0.33, rack_h*0.67])
        translate([cut_x, tray_d-tw, z-fj_th/2]) cube([fj_d, tw, fj_th]);
}
module rear_panel_groove() {
    for (z=[rack_h*0.33, rack_h*0.67])
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

// ─── STRUCTURAL MODULES ───────────────────────────────────────────────────────

module atx_standoffs() {
    for (pt = atx_holes)
        translate([bx0 + pt[0], by0 + pt[1], tw]) standoff();
}

module front_panel_solid() {
    difference() {
        cube([tray_w, tw, rack_h]);
        fan_cutout(fan1_cx, fan_cz);
        fan_cutout(fan2_cx, fan_cz);
        for (i = [-3:3])
            translate([tray_w/2 - 6, -0.1, fan_cz + i*15]) cube([12, tw+0.2, 9]);
    }
}

module rear_panel_solid() {
    difference() {
        union() {
            cube([tray_w, tw, rack_h]);
            translate([bkt_cut_x0-12, 0, ret_bar_z0-1]) cube([10, tw+ret_bar_d, ret_bar_h+2]);
            translate([bkt_cut_x0+bkt_cut_w+2, 0, ret_bar_z0-1]) cube([10, tw+ret_bar_d, ret_bar_h+2]);
        }
        translate([io_x0, -0.1, io_z0])          cube([io_w, tw+0.2, io_h]);
        translate([psu_x0, -0.1, tw])             cube([psu_xw, tw+0.2, psu_zh-tw]);
        translate([bkt_cut_x0, -0.1, bkt_cut_z0]) cube([bkt_cut_w, tw+0.2, bkt_cut_h]);
        for (bx = [bkt_cut_x0-7, bkt_cut_x0+bkt_cut_w+7])
            translate([bx, -0.1, ret_bar_z0+ret_bar_h/2])
                rotate([-90,0,0]) cylinder(h=tw+ret_bar_d+0.2, d=ret_screw_d, $fn=12);
    }
}

module psu_cradle() {
    cw = 4;
    translate([psu_x0-cw, psu_y0, 0])      cube([psu_xw+2*cw, psu_yd+cw, tw+cw]);
    translate([psu_x0-cw, psu_y0, tw+cw])  cube([cw, psu_yd, psu_zh/2]);
    translate([psu_x0+psu_xw, psu_y0, tw+cw]) cube([cw, psu_yd, psu_zh/2]);
}

// Plain tray shell — floor + two outer rails.  No interior ribs.
module tray_shell() {
    difference() {
        union() {
            cube([tray_w, tray_d, tw]);
            cube([tw, tray_d, rack_h]);
            translate([tray_w-tw, 0, 0]) cube([tw, tray_d, rack_h]);
        }
        for (tx = tab_x)
            translate([tx-tab_sw/2, tray_d-tw-tab_sd, -0.1])
                cube([tab_sw, tab_sd+tw+0.2, tw+0.2]);
    }
}

module gpu_retainer_bar() {
    lip_d = 3;  lip_h = 4;
    difference() {
        union() {
            cube([ret_bar_w, ret_bar_d, ret_bar_h]);
            translate([0, ret_bar_d, ret_bar_h-lip_h]) cube([ret_bar_w, lip_d, lip_h]);
        }
        for (bx = [7, ret_bar_w-7])
            translate([bx, -0.1, ret_bar_h/2]) rotate([-90,0,0]) {
                cylinder(h=ret_bar_d+0.2, d=ret_screw_d, $fn=12);
                cylinder(h=3, d1=6, d2=ret_screw_d, $fn=16);
            }
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
        translate([bkt_cut_x0-(ret_bar_w-bkt_cut_w)/2, tray_d, ret_bar_z0])
            gpu_retainer_bar();
    }
    color("dimgray") {
        translate([-ear_w, 0, 0]) rack_ear();
        translate([tray_w, 0, 0]) rack_ear();
    }
    ghost_board();  ghost_gpu();  ghost_psu();
}

// ─── PRINTABLE SECTIONS ───────────────────────────────────────────────────────

// ── FL: Front-Left ─────────────────────────────────────────────────────────────
module tray_FL() {
    difference() {
        union() {
            intersection() {
                union() { tray_shell(); front_panel_solid(); atx_standoffs(); }
                cube([cut_x, cut_y, rack_h+1]);
            }
            xj_floor_L(0, cut_y);       // floor tabs → FR
            yj_floor_F(0, cut_x);       // floor tabs → RL
            front_panel_tongue();        // panel tongue → FR
            left_rail_tongue();          // rail tongue  → RL
        }
        xj_floor_L_sock(0, cut_y);      // floor sockets for FR's tabs
        yj_floor_F_sock(0, cut_x);      // floor sockets for RL's tabs
    }
}

// ── FR: Front-Right ────────────────────────────────────────────────────────────
module tray_FR() {
    difference() {
        union() {
            intersection() {
                union() { tray_shell(); front_panel_solid(); psu_cradle(); }
                translate([cut_x,0,0]) cube([tray_w-cut_x, cut_y, rack_h+1]);
            }
            xj_floor_R(0, cut_y);       // floor tabs → FL
            yj_floor_F(cut_x, tray_w);  // floor tabs → RR
            right_rail_tongue();         // rail tongue → RR
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
                    psu_cradle();
                    translate([0, tray_d-tw, 0]) rear_panel_solid();
                }
                translate([cut_x,cut_y,0]) cube([tray_w-cut_x, tray_d-cut_y, rack_h+1]);
            }
            xj_floor_R(cut_y, tray_d);  // floor tabs → RL
            yj_floor_R(cut_x, tray_w);  // floor tabs → FR
        }
        xj_floor_R_sock(cut_y, tray_d); // floor sockets for RL's tabs
        yj_floor_R_sock(cut_x, tray_w); // floor sockets for FR's tabs
        rear_panel_groove();              // panel groove receives RL's tongue
        right_rail_groove();              // rail groove receives FR's tongue
    }
}

// ─── RENDER SELECTION ─────────────────────────────────────────────────────────

assembly();

// Uncomment ONE section → F6 → Export as STL.  Print floor-face-down.
//tray_FL();
//translate([-cut_x, 0, 0])      tray_FR();
//translate([0, -cut_y, 0])      tray_RL();
//translate([-cut_x, -cut_y, 0]) tray_RR();
//gpu_retainer_bar();
//rack_ear();
