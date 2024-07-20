.PHONY: all
all: build poster.pdf poster_2024_summer.pdf

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

poster_2024_summer.pdf:poster_2024_summer.html stylesheet.css Dockerfile images/*.png images/*.jpg
	docker run \
	    -i --tty \
	    --rm \
	    --volume `pwd`:/htmltopdf:rw \
	    htmltopdf:1.0.0 \
	    poster_2024_summer.html poster_2024_summer.pdf
