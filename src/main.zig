const std = @import("std");
const sdl = @import("zsdl");

const game = @import("game.zig");

const W = 240 * 2;
const H = 320 * 2;

pub fn main() !void {
    try sdl.init(.{ .video = true });
    defer sdl.quit();

    const window = try sdl.Window.create(
        "zake8",
        sdl.Window.pos_centered,
        sdl.Window.pos_centered,
        W,
        H,
        .{ .opengl = true, .allow_highdpi = true },
    );

    // // fill framebuffer
    // for (&fbuf) |*pix| {
    //     pix.* = COLOR_BLUE;
    // }

    const renderer = try sdl.Renderer.create(window, -1, .{ .accelerated = true });

    game.init();

    mainLoop: while (true) {
        // poll events
        var ev: sdl.Event = undefined;
        while (sdl.pollEvent(&ev)) {
            if (ev.type == sdl.EventType.quit)
                break :mainLoop;
        }

        try renderer.clear();

        game.update();
        game.draw();

        for (0..H / 2) |y| {
            for (0..W / 2) |x| {
                const pix = game.z._pget(@intCast(x), @intCast(y));
                try renderer.setDrawColor(convert_color(pix));
                try renderer.fillRect(.{ .x = @intCast(2 * x), .y = @intCast(2 * y), .w = 2, .h = 2 });
            }
        }

        // try renderer.setDrawColor(.{ .r = 0, .g = 0, .b = 255, .a = 255 });
        // try renderer.fillRect(.{ .x = 0, .y = 0, .w = 100, .h = 100 });

        try renderer.setDrawColor(.{ .r = 0, .g = 0, .b = 0, .a = 255 });
        sdl.Renderer.present(renderer);

        // sdl.delay(10);

        // try renderer.setDrawColor(.{ .r = 0, .g = 255, .b = 255, .a = 255 });
        // try renderer.clear();

    }

    defer window.destroy();
}

// convert from RGB565 to SDL.Color.
pub fn convert_color(color: u16) sdl.Color {
    const r: u8 = @intCast((color & 0xF800) >> 8);
    const g: u8 = @intCast((color & 0x07E0) >> 3);
    const b: u8 = @intCast((color & 0x1F) << 3);

    return .{ .r = r, .g = g, .b = b, .a = 255 };
}

test "stuff" {
    for (0..3) |y| {
        for (0..5) |x| {
            std.debug.print("x: {}, y: {} \n", .{ x, y });
        }
    }
}
