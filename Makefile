.PHONY: all
all: build poster.pdf

.PHONY: build
build:
	docker build . \
	    --tag htmltopdf:1.0.0

poster.pdf:poster.html stylesheet.css Dockerfile images/*.png images/*.jpg
	docker run \
	    -i --tty \
	    --rm \
	    --volume `pwd`:/htmltopdf:rw \
	    htmltopdf:1.0.0 \
	    poster.html poster.pdf
