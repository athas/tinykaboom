-- The time for the benchmark is chosen to match the exact scene
-- rendered by tinykaboom.cpp.
-- ==
-- input { 640i64 480i64 0.1f32 6.28f32 }

def sphere_radius: f32 = 1.5
def noise_amplitude: f32 = 1.0

def hash n =
  let x = f32.sin(n)*43758.5453
  in x-f32.floor(x)

import "lib/github.com/athas/vector/vspace"
import "lib/github.com/athas/matte/colour"

module vec3 = mk_vspace_3d f32
type vec3 = vec3.vector

def vec3f (x, y, z): vec3 = {x,y,z}

def lerp (v0, v1, t) =
  f32.lerp v0 v1 (f32.max 0 (f32.min 1 t))

def vlerp (v0, v1, t) =
  vec3.map2 (\x y -> lerp (x, y, t)) v0 v1

def noise (x: vec3) =
  let p = {x = f32.floor(x.x), y = f32.floor(x.y), z = f32.floor(x.z)}
  let f = {x = x.x-p.x, y = x.y-p.y, z = x.z-p.z}
  let f = vec3.((f `dot` ({x=3,y=3,z=3} - scale 2 f)) `scale` f)
  let n = vec3.(p `dot` {x=1, y=57, z=113})
  in lerp(lerp(lerp(hash(n +  0), hash(n +  1), f.x),
               lerp(hash(n + 57), hash(n + 58), f.x), f.y),
          lerp(lerp(hash(n + 113), hash(n + 114), f.x),
               lerp(hash(n + 170), hash(n + 171), f.x), f.y), f.z)

def rotate v =
  vec3f(vec3f(0.00,  0.80,  0.60) `vec3.dot` v,
        vec3f(-0.80,  0.36, -0.48) `vec3.dot` v,
        vec3f(-0.60, -0.48,  0.64) `vec3.dot` v)

def fractal_brownian_motion (x: vec3) =
  let p = rotate x
  let f = 0
  let f = f + 0.5000*noise p
  let p = 2.32 `vec3.scale` p
  let f = f + 0.2500*noise p
  let p = 3.03 `vec3.scale` p
  let f = f + 0.1250*noise p
  let p = 2.61 `vec3.scale` p
  let f = f + 0.0625*noise p
  in f/0.9375

def palette_fire (d: f32): vec3 =
  let yellow = vec3f (1.7, 1.3, 1.0)
  let orange = vec3f (1.0, 0.6, 0.0)
  let red = vec3f (1.0, 0.0, 0.0)
  let darkgray = vec3f (0.2, 0.2, 0.2)
  let gray = vec3f (0.4, 0.4, 0.4)

  let x = f32.max 0 (f32.min 1 d)
  in if x < 0.25 then vlerp(gray, darkgray, x*4)
     else if x < 0.5 then vlerp(darkgray, red, x*4-1)
     else if x < 0.75 then vlerp(red, orange, x*4-2)
     else vlerp(orange, yellow, x*4-3)

def signed_distance t p =
  let displacement = -fractal_brownian_motion(3.4 `vec3.scale` p) * noise_amplitude
  in vec3.norm p - (sphere_radius * f32.sin(t*0.25) + displacement)

def sphere_trace t (orig: vec3, dir: vec3): (bool, vec3) =
  let check (i, hit) = (i == 1337, hit) in
  if (orig `vec3.dot` orig) - (orig `vec3.dot` dir) ** 2 > sphere_radius ** 2
  then (false, orig)
  else check <|
       loop (i, pos) = (0, orig) while i < 64i32 do
       let d = signed_distance t pos
       in if d < 0
          then (1337, pos)
          else (i + 1, pos vec3.+ ((f32.max (d*0.1) 0.1) `vec3.scale` dir))

def distance_field_normal t pos =
  let eps = 0.1
  let d = signed_distance t pos
  let nx = signed_distance t (pos vec3.+ vec3f(eps, 0, 0)) - d
  let ny = signed_distance t (pos vec3.+ vec3f(0, eps, 0)) - d
  let nz = signed_distance t (pos vec3.+ vec3f(0, 0, eps)) - d
  in vec3.normalise (vec3f(nx, ny, nz))

def main (width: i64) (height: i64) (td: f32) (t: f32): ([height][width]argb.colour, f32) =
  let fov = f32.pi/3
  let f j i =
    let dir_x = (f32.i64 i + 0.5) - f32.i64 width/2
    let dir_y = -(f32.i64 j + 0.5) + f32.i64 height/2
    let dir_z = -(f32.i64 height)/(2*f32.tan(fov/2))
    let (is_hit, hit) =
      sphere_trace t (vec3f(0, 0, 3),
                      vec3.normalise (vec3f(dir_x, dir_y, dir_z)))
    in if is_hit
       then let noise_level = (sphere_radius - vec3.norm hit)/noise_amplitude
            let light_dir = vec3.normalise (vec3f(10, 10, 10) vec3.- hit)
            let light_intensity = f32.max 0.4 (light_dir `vec3.dot` distance_field_normal t hit)
            let {x, y, z} =
              light_intensity `vec3.scale` palette_fire((noise_level - 0.2)*2)
            in argb.from_rgba x y z 1
       else argb.from_rgba 0.2 0.7 0.8 1
  in (tabulate_2d height width f, t + td)
