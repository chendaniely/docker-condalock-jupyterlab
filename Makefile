# create a separate lock file for each OS
.PHONY: cl
cl:
	# the linux-aarch64 is used for ARM Macs using linux docker container
	conda-lock lock \
		--file environment.yml \
		-p linux-64 \
		-p osx-64 \
		-p osx-arm64 \
		-p win-64 \
		-p linux-aarch64

.PHONY: env
env:
	# remove the existing env, and ignore if missing
	conda env remove dockerlock || true
	conda-lock install -n dockerlock conda-lock.yml

.PHONY: build
build:
	docker build -t dockerlock --file Dockerfile .

.PHONY: run
run:
	make up

.PHONY: up
up:
	docker-compose up -d

.PHONY: stop
stop:
	docker-compose stop
