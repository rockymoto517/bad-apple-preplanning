from PIL import Image
from os import fsencode, fsdecode, listdir

# Video dimensions
HEIGHT = 360
WIDTH = 480

# Method used for PNGs with transparent backgrounds
# Basically, if a pixel is not transparent, return true
def check_transparent(pixel):
    return pixel[3] != 0

# Checks for almost black in case of bad compression
def check_bw(pixel):
    return pixel[0] + pixel[1] + pixel[2] <= 30

# Sum the color of the pixels to add a softer check
# in case of ugly image compression issues
def sum_pixel(pixel):
    return sum(pixel[i] for i in range(3))

# Make the output file a .txt instead of .bmp
def switch_extension(string):
    res = ''
    for i in range(len(string)-3):
        res += string[i]
    return res + "txt"

# Used in test runs to give the cleanest images possible
# i.e. no grey pixels, purely black or white pixels
def clean_image(path, result):
    with Image.open(path) as im:
        for y in range(HEIGHT):
            for x in range(WIDTH):
                if sum_pixel(im.getpixel((x,y))) <= 80:
                    im.putpixel((x,y), (0,0,0))
                else:
                    im.putpixel((x,y), (255,255,255))
        im.save(result)

# Really annoying but necessary way to convert pixel data to vector data
# Basically find the first instance of a black enough pixel then record
# the last instance of a black enough pixel to create a vector between them
# Rinse and repeat for every y-layer of pixels and our data file is complete
def write_data(px, file):
    with open(file, "w") as output:
        first = True
        prev_x = 0
        prev_y = 0
        if check_bw(px[0,0]):
            output.write(f"0,0\n")
        for y in range(HEIGHT):
            for x in range(WIDTH):
                if check_bw(px[x,y]):
                    if first:
                        if x == 0 and y == 0:
                            first = False
                        else:
                            output.write(f"{x},{y}\n")
                            first = False
                    if y != prev_y and not (prev_x == 0 and prev_y == 0):
                        output.write(f"{prev_x},{prev_y}\n")
                        output.write(f"{x},{y}\n")
                    elif x != (prev_x + 1) and not (prev_x == 0 and prev_y == 0):
                        output.write(f"{prev_x},{prev_y}\n")
                        if prev_x != x and not (x == 0 and y == 0):
                            output.write(f"{x},{y}\n")
                    prev_x = x
                    prev_y = y
        output.write(f"{prev_x},{prev_y}\n")

# Take every bmp in our collection of frames
# and turn them into vector data for lua to process
def main():
    directory = fsencode("BadAppleFrames")
    for file in listdir(directory):
        filename = fsdecode(file)
        result = switch_extension(filename)
        with Image.open(f"BadAppleFrames/{filename}") as im:
            px = im.load()
            write_data(px, f"BadAppleData/{result}")

if __name__ == "__main__":
    main()