const sprite = @import("sprite.zig").sprite;

pub const W = 120;
pub const H = 160;
const WH = W * H;

// actual w and h
const WW = 240;
const HH = 320;
const WWHH = 240 * 320;

// colors by their names
pub const black: u4 = 0;
pub const dark_blue: u4 = 1;
pub const dark_purple: u4 = 2;
pub const dark_green: u4 = 3;
pub const brown: u4 = 4;
pub const dark_grey: u4 = 5;
pub const light_grey: u4 = 6;
pub const white: u4 = 7;
pub const red: u4 = 8;
pub const orange: u4 = 9;
pub const yellow: u4 = 10;
pub const green: u4 = 11;
pub const blue: u4 = 12;
pub const lavender: u4 = 13;
pub const pink: u4 = 14;
pub const light_peach: u4 = 15;

const RGB565 = u16;

// in RGB565 format
// pico8 palette. converted from 24 to 16 bits
pub const palette = [16]RGB565{
    0x0000,
    0x194a,
    0x792a,
    0x042a,
    0xaa86,
    0x5aa9,
    0xc618,
    0xff9d,
    0xf809,
    0xfd00,
    0xff64,
    0x0726,
    0x2d7f,
    0x83b3,
    0xfbb5,
    0xfe75,
};

// allocation is done here
pub var buf: [WWHH]RGB565 = undefined;

// private methods, used internally
// Clear screen with color.
pub fn _clear(color: RGB565) void {
    for (0..WWHH) |i| {
        buf[i] = color;
    }
    // for (&(buf)) |*pix| {
    //     pix.* = color;
    // }
}
// draws a single pixel at (x,y)
pub fn _pset(x: u32, y: u32, color: RGB565) void {
    const i: u32 = (y * WW + x);
    if (i < WWHH)
        buf[i] = color;
}
// returns the color of the pixel at (x,y)
pub fn _pget(x: u32, y: u32) RGB565 {
    const i: u32 = (y * WW + x);
    return buf[i];
}

pub fn cls(c: u4) void {
    _clear(palette[c]);
}

pub fn pset(x: u32, y: u32, c: u4) void {
    const xx: u32 = 2 * x;
    const yy: u32 = 2 * y;
    const color = palette[c];

    // draw 4 pixels starting from top left
    _pset(xx, yy, color);
    _pset(xx + 1, yy, color);
    _pset(xx, yy + 1, color);
    _pset(xx + 1, yy + 1, color);
}

pub fn pget(x: u32, y: u32) u4 {
    const xx: u32 = 2 * x;
    const yy: u32 = 2 * y;

    const c = _pget(xx, yy);

    return palette_idx(c);
}
// Copy the region of size (w, h) from (u, v) of the sprite bank to (x, y). Black is transparent.
pub fn blt(x: u32, y: u32, u: u32, v: u32, w: u32, h: u32) void {
    var pix: u4 = 0;
    var idx: usize = 0;

    for (0..h) |j| {
        for (0..w) |i| {
            idx = (v + j) * W + (u + i);
            pix = sprite[idx];
            if (pix != 0) // transparent
                pset(@intCast(x + i), @intCast(y + j), pix);
        }
    }
}

// writes char c at (x,y) with color.
pub fn char(chr: u8, x: u32, y: u32, c: u4) void {
    var u: u32 = 0;
    var v: u32 = 0;
    var pix: RGB565 = 0;
    var idx: u32 = 0;

    switch (chr) {
        // special case for SPACE, print blank.
        ' ' => {
            u = 0;
            v = 0;
        },

        // the spritesheet is in the ASCII order but in a 30x4 table, starting at (0, 136)
        // subtract 33 so '!' is 0
        // then find the coordinates from the linear index
        // multiply by cell width and add the table starting coordinates
        0...127 => {
            c = c - 33;
            u = (c % 30) * 4;
            v = (c / 30) * 6 + 136;
        },

        // out of range, print the DEL character
        _ => {
            u = 64;
            v = 304;
        },
    }

    for (0..6) |j| {
        for (0..4) |i| {
            idx = (v + j) * W + (u + i);
            pix = sprite[idx];

            if (pix != 0)
                pset(x + i, y + j, c);
        }
    }
}

pub fn text(txt: []const u8, x: u32, y: u32, c: u4) void {
    // char width is 4, so we move 4*i to the right
    for (txt, 0..) |chr, i| {
        char(chr, x + (4 * i), y, c);
    }
}

pub fn spr(n: i32, x: i32, y: i32) void {
    var u = @mod(n, 15) * 8;
    var v = @divTrunc(n, 15) * 8;

    blt(@intCast(x), @intCast(y), @intCast(u), @intCast(v), 8, 8);
}

// return the index of the color.
pub fn palette_idx(color: RGB565) u4 {
    return switch (color) {
        palette[0] => 0,
        palette[1] => 1,
        palette[2] => 2,
        palette[3] => 3,
        palette[4] => 4,
        palette[5] => 5,
        palette[6] => 6,
        palette[7] => 7,
        palette[8] => 8,
        palette[9] => 9,
        palette[10] => 10,
        palette[11] => 11,
        palette[12] => 12,
        palette[13] => 13,
        palette[14] => 14,
        palette[15] => 15,
    };
}
