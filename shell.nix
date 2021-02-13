# Use this file with nix-shell or similar tools; see https://nixos.org/
with import <nixpkgs> {};

mkShell {
  buildInputs = [
    futhark
    ocl-icd
    opencl-headers
    ffmpeg
  ];
}
