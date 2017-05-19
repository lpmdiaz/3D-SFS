# indicate which compiler to use
CC ?= g++

# compiler options
CFLAGS ?= -Wall

# set second directory
DIR=./plotting

# list programs
LIST=pop3Dclrt $(DIR)/parse3Dsfs

all: $(LIST)

$(LIST):
	$(CC) $(CFLAGS) $@.cpp -o $@

clean:
	@rm -rf $(LIST) *.o
