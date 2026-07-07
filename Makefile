.PHONY: all test clean

# location of a built UnetStack 7 tree (contains bin/unet, lib/, etc/)
UNET_HOME ?= $(HOME)/Projects/unet

all: test

test:
	UNET_HOME=$(UNET_HOME) julia test/test.jl

clean:
	rm -f test/unet.pid test/logs/log-*.txt
