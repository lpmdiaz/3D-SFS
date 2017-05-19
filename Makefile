# indicate which compiler to use
CCX ?= g++

# compiler options
CFLAGS = -Wall

# set second directory
DIR=./plotting

# list programs
LIST=pop3Dclrt $(DIR)/parse3Dsfs

all: $(LIST)

$(LIST):
	$(CCX) $(CFLAGS) $@.cpp -o $@
