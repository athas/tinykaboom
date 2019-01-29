tinykaboom.py: tinykaboom.fut lib
	futhark pyopencl --library $<

lib: futhark.pkg
	futhark pkg sync

run: tinykaboom.py
	python tinykaboom-gui.py

clean:
	rm -f *.py tinykaboom.py
