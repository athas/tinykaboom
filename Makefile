FUTHARK_BACKEND?=multicore

all: tinykaboom.mp4

README.md: README.fut
	futhark literate --backend=$(FUTHARK_BACKEND) README.fut

lib: futhark.pkg
	futhark pkg sync

tinykaboom.py: tinykaboom.fut
	futhark pyopencl --library tinykaboom.fut

tinykaboom.mp4: frames
	ffmpeg -r 60 -y -i frames/%03d.png -b:v 3M $@

tinykaboom.gif: tinykaboom.mp4 tinykaboom-palette.png
	ffmpeg -r 60 -y -i tinykaboom.mp4 -i tinykaboom-palette.png -filter_complex paletteuse $@

tinykaboom-palette.png: tinykaboom.mp4
	ffmpeg -y -i $< -vf palettegen $@

frames: tinykaboom.py
	python3 tinykaboom-frames.py frames
