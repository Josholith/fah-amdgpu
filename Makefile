all: clean build

build:
	docker build -t fah-amdgpu:latest .

clean:
	docker image ls --filter reference=fah-amdgpu --quiet | xargs --no-run-if-empty docker rmi

.PHONY: all build clean
