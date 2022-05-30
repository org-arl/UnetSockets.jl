.PHONY: all test clean

all: test

test:
	[ -d test/unet ] || (mkdir -p test/unet ; curl -o test/unet/unet-community-3.1.0.tgz https://unetstack.net/downloads/unet-community-3.1.0.tgz ; cd test/unet && tar xvzf unet-community-3.1.0.tgz)
	julia test/test.jl

clean:
	find test/unet -name log-0.txt -exec cat {} \;
	rm -rf test/unet
