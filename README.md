# KABOOM! in 110 lines of Futhark

This is a port/theft of
[tinykaboom](https://github.com/ssloy/tinykaboom) from C++ to
[Futhark](https://futhark-lang.org).  It was done for the following
purposes:

  * To see how easy it is to port such straightforward graphics-ish
    C++ to Futhark (*very easy*).

  * To see how fast it would run (*see below*).

  * If fast enough, to render the explosion in real time.

It looks like this (the actual rendering is much faster; I think
browsers don't like high-framerate GIFs):

```futhark
module tk = import "tinykaboom"

let step = tk.main
```

```
> :video (step 640i64 480i64 4.1e-2f32, 0.0f32, 300i64)
```


![](README-img/4ed9dbbdb8f23474-video.gif)


## Details

I tried to match the coding style closely, even in the naming and
order of functions.  One of the notable differences is that the C++
version is able to use an ad-hoc polymorphic template function,
`lerp`, for linear interpolation of both vectors and scalars.  For the
Futhark version, two functions are needed.  This could have been
written as a single parameterised higher-order function, but I don't
think the complexity is worth it here.

I have added a time parameter to some functions, which is used to vary
the radius of the sphere, in order to give it an expanding feel.  This
is used in the `signed_distance` function.

I think I do the colour computation slightly differently - my darks
are not really very dark.

I depend on two small Futhark packages
([vector](https://github.com/athas/vector)) and
([matte](https://github.com/athas/matte)) for vectors and ARGB
colouring respectively.  If I were enough of a purist, I'd inline the
necessary parts.  The 110 lines mentioned in the title do not include
these packages.

## Performance

The runtime when rendering a 640x480 frame is as follows:

  * [`tinykaboom.cpp`](https://github.com/ssloy/tinykaboom/blob/master/tinykaboom.cpp)
compiled with `-O3 -fopenmp` and running on a Ryzen 1700X: 1.3s

  * [`tinykaboom.fut`](https://github.com/athas/tinykaboom/blob/master/tinykaboom.fut) compiled with `futhark opencl` and running on a Vega 64: 0.012s

  * [`tinykaboom.fut`](https://github.com/athas/tinykaboom/blob/master/tinykaboom.fut) compiled with `futhark multicore` and running on a Ryzen 1700X: 0.38s

  * [`tinykaboom.fut`](https://github.com/athas/tinykaboom/blob/master/tinykaboom.fut) compiled with `futhark cuda` and running on an RTX 2080 Ti: 0.003s

It runs slightly slower than I would like, especially on the Vega 64,
but that's probably just the nature of the beast.  I inspected the
generated code and could not find any obvious smoking guns, except for
the kernel being fairly large.  It's good enough to be real-time in a small window.

## The future

It would be cool if the explosion could be rotated a bit, or maybe not
be the same for every run.
