pub const z = @import("zic8");

const Ship = struct {
    x: i32,
    y: i32,
    vx: i32,
    vy: i32,

    pub fn draw(s: Ship) void {
        z.spr(1, s.x, s.y);
    }

    pub fn update(s: *Ship) void {
        s.x += s.vx;
        s.y += s.vy;
    }
};

var ship = Ship{
    .x = z.W / 2,
    .y = z.H / 2,
    .vx = 1,
    .vy = 0,
};

pub fn init() void {
    z.cls(z.blue);
}

pub fn draw() void {
    z.cls(z.blue);
    ship.draw();
}

pub fn update() void {
    ship.update();
}
