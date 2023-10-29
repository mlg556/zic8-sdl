import imageio.v3 as iio

im = iio.imread("sprite.png")

W, H = 120, 160

with open("sprite.zig", "w+") as f:
    f.write(f"const sprite = [{W*H}]u8{{")
    for pix_row in im:
        for pix in pix_row:
            f.write(f"{pix},")
        f.write("\n")
    f.write("};")
