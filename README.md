# KABOOM! in 110 lines of Futhark

This is a port/theft of
[tinykaboom](https://github.com/ssloy/tinykaboom) from C++ to
[Futhark](https://futhark-lang.org).  It was done for the following
purposes:

  * To see how easy it is to port such straightforward graphics-ish
    C++ to Futhark (*very easy*).

  * To see how fast it would run (*see below*).

  * If fast enough, to render the explosion in real time.

## Issues

I think I do the colour computation slightly differently - my darks
are not really very dark.

I depend on two small Futhark packages
([vector](https://github.com/athas/vector)) and
([matte](https://github.com/athas/matte)) for vector and ARGB
colouring respectively.  If I were enough of a purist, I'd inline the
necessary parts.

## Performance

The runtime when rendering a 640x480 frame is as follows:

  * [`tinykaboom.cpp`](https://github.com/ssloy/tinykaboom/blob/master/tinykaboom.cpp)
compiled with `-O3 -fopenmp` and running on a Ryzen 1700X: 1.3s

  * [`tinykaboom.fut`](https://github.com/athas/tinykaboom/blob/master/tinykaboom.fut) compiled with `futhark opencl` and running on a Vega 64: 0.022s

## The animation

It runs slightly slower than I would like, but that's probably just
the nature of the beast.  It's good enough to be real time-ish.  If
you have Python, [PySDL2](https://pypi.org/project/PySDL2/), and
[PyOpenCL](https://documen.tician.de/pyopencl/) installed, do `make
run` to see the animation.

## The future

It would be cool if the explosion could be rotated a bit, or maybe not
be the same for every run.
