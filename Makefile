# indicate which compiler to use
CCX ?= g++

# compiler options
CFLAGS = -O3 -Wall

# list programs
LIST = pop3Dclrt parse3Dsfs

all: $(LIST)

$(LIST):
	mkdir bin
	$(CCX) $(CFLAGS) /source/$@.cpp -o bin/$@ -std=c++11

clean:
	@rm -rf /bin/* #*.o
