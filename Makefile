tinykaboom.py: tinykaboom.fut lib
	futhark pyopencl --library $<

lib: futhark.pkg
	futhark pkg sync

run: tinykaboom.py
	python tinykaboom-gui.py

tinykaboom.webm: frames
	ffmpeg -r 60 -i frames/%03d.png -c:v libvpx -b:v 3M -c:a libvorbis $@

frames: tinykaboom.py
	python3 tinykaboom-frames.py frames

clean:
	rm -f *.py tinykaboom.py
