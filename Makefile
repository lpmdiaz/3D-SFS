# indicate which compiler to use
CCX ?= g++

# compiler options
CFLAGS = -O3 -Wall

# set second directory
DIR=./source

# list programs
LIST=$(DIR)/pop3Dclrt $(DIR)/parse3Dsfs

all: $(LIST)

$(LIST):
	$(CCX) $(CFLAGS) $@.cpp -o bin/$@ -std=c++11

clean:
	@rm -rf bin/$(LIST) *.o
