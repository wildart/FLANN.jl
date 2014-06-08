MKDIR_P = mkdir -p

OUT_DIR = usr/lib

.PHONY: directories

all: directories flann_wrapper

flann_wrapper:
	gcc -o usr/lib/flann_wrapper.so -I/usr/include -fPIC -shared src/flann_wrapper.c -lflann

directories: ${OUT_DIR}

${OUT_DIR}:
	${MKDIR_P} ${OUT_DIR}

clean:
	rm -rf usr