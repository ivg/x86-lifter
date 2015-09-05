SETUP=ocaml setup.ml -quiet
default: all

all: 
	oasis setup -setup-update dynamic
	touch setup.data
	$(SETUP) -build -cflag -annot -cflag -bin-annot

install:
	$(SETUP) -install 

clean:
	ocaml setup.ml -clean
