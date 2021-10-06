image ?= swarm:dev
container_id_file ?= ./container_id
name ?= swarm_development


build:
	docker build -t $(image) -f dev.dockerfile .

buildrm:
	docker rmi $(image)

$(container_id_file):
	xhost local:docker
	docker run -it \
		--cidfile $(container_id_file) \
		--device /dev/dri:/dev/dri \
		-e DISPLAY \
		--workdir=/home/swarm/package \
		-v $(shell pwd):/home/swarm/package \
		-v $(HOME)/.vim:/home/swarm/.vim \
		-e QT_X11_NO_MITSHM=1 \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v ~/.Xauthority:/root/.Xauthority \
		-v /run/user/1000:/run/user/1000 \
		-e XDG_RUNTIME_DIR \
		--name $(name) \
		$(image) 
	
start: $(container_id_file)
	xhost local:docker
	docker container start $(shell cat $(container_id_file) )

stop:
	docker container stop $(shell cat $(container_id_file) )

rm:
	docker container stop $(shell cat $(container_id_file) )
	docker container rm $(shell cat $(container_id_file) )
	rm $(container_id_file)

enter: $(container_id_file)
	docker exec -it $(shell cat $(container_id_file)) vim

.PHONY: build buildrm create start stop rm enter
