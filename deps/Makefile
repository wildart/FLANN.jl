all: flann_wrapper

flann_wrapper:
	gcc -o flann_wrapper.so -I/usr/include -fPIC -shared flann_wrapper.c -lflann

clean:
	rm -rf *o flann_wrapper