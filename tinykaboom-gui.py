#!/usr/bin/env python

from tinykaboom import tinykaboom

from sdl2 import *
import sdl2.ext
import numpy as np
import time

tinykaboom = tinykaboom(interactive=True)

width=640
height=480

size=(width, height)
SDL_Init(SDL_INIT_EVERYTHING)
window = SDL_CreateWindow("Ising 2D",
                          SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
		          width, height, SDL_WINDOW_SHOWN)

def reWindow(window):
    window_surface = SDL_GetWindowSurface(window)
    frame_py = np.ndarray(shape=(height, width), dtype=np.int32, order='C')
    surface = SDL_CreateRGBSurfaceFrom(frame_py.ctypes.data, width, height, 32, width*4,
                                       0xFF0000, 0xFF00, 0xFF, 0x00000000)
    return (window_surface, frame_py, surface)

(window_surface, frame_py, surface) = reWindow(window)

start = time.time()

def render():
    global state
    futhark_start = time.time()

    frame_fut = tinykaboom.main(time.time()-start, width, height)
    frame_fut.get(ary=frame_py)

    futhark_end = time.time()

    SDL_BlitSurface(surface, None, window_surface, None)
    SDL_UpdateWindowSurface(window)
    print("{}ms".format((futhark_end-futhark_start)*1000))

running=True

while running:
    render()

    events = sdl2.ext.get_events()
    for event in events:
        if event.type == SDL_QUIT:
            running=False
