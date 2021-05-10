IMAGE_NAME := python3.8-arm-cross
CONTAINER_NAME := $(IMAGE_NAME)-builder

.PHONY: build run 
.DEFAULT: all

all: build run

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -it --rm -v $(CURDIR):/home/builder --name $(CONTAINER_NAME) $(IMAGE_NAME)

clean:
	docker rmi -f $(IMAGE_NAME)
