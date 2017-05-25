# indicate which compiler to use
CCX ?= g++

# compiler options
CFLAGS = -O3 -Wall -std=c++11

# list programs
LIST = pop3Dclrt parse3Dsfs

all: $(LIST)

$(LIST):
	$(CCX) $(CFLAGS) ./source/$@.cpp -o ./bin/$@

clean:
	@rm -rf bin/*
