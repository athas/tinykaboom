#!/usr/bin/env python3
#
# Generate a tinykaboom video.
#
# The actual rendering is fast, but encoding all the images takes
# forever.

from tinykaboom import tinykaboom
import os
import sys
import png
import numpy as np

tinykaboom = tinykaboom(interactive=True)

fps=60.0

dir = sys.argv[1]
width=int(sys.argv[2]) if len(sys.argv) > 2 else 640
height=int(sys.argv[3]) if len(sys.argv) > 3 else 480
frames=int(sys.argv[4]) if len(sys.argv) > 4 else int(fps*10)

try:
    os.mkdir(dir)
except FileExistsError:
    pass

for i in range(frames):
    fut_image, _ = tinykaboom.step(width, height, 1/fps, i*(1/fps)).get()
    fname = os.path.join(dir, '%.3d.png' % i)

    # Futhark gives us an array of 32-bit integers encoding the color,
    # but the PNG writer expects each colour channel to be separate.
    image=np.empty((height,width,3))
    image[:,:,0] = (fut_image & 0xFF0000) >> 16
    image[:,:,1] = (fut_image & 0xFF00) >> 8
    image[:,:,2] = (fut_image & 0xFF)

    with open(fname, 'wb') as f:
        w = png.Writer(width=width, height=height, alpha=False)
        w.write(f, np.reshape(image, (height, width*3)))
        f.close()

    print('Wrote %s' % fname)
