# BSD 3-Clause License
# 
# Copyright (c) 2021, TheWorldOfCode
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#################################################################################################

########################################
# Default parameters                   #
########################################

# The name of the image
image ?= test
# The tag of the image
tag ?= test
# Name of the container
name ?= container_name
# Name of the dockerfile to build from
dockerfile ?= dockerfile
# Localation and name of the entrypoint file 
entrypoint ?= ./entrypoint.sh
# Docker home (Used for storing tmp files 
docker_home ?= .docker
# Where to save the container id 
container_id_file ?= $(docker_home)/container_id
# Set the work directory for the container
#container_workdir ?= 
# The network 

########################################
# Setting up work areax                #
########################################
$(shell mkdir -p $(docker_home))

########################################
# Setting creating paramenters         #
########################################
display ?= -e DISPLAY  -v /tmp/.X11-unix:/tmp/.X11-unix --device /dev/dri

ifeq ($(container_workdir),)
	workdir := 
else
	workdir := --workdir=$(container_workdir)
endif
options = $(display) # $(workdir)


image_file = $(docker_home)/$(image)_$(tag).image


test: 
	echo $(options)

# Automated building, adding an empty file for time stamping the image
$(image_file): $(dockerfile) $(entrypoint)
	docker build -t $(image):$(tag) -f $(dockerfile) .
	@touch $(image_file)

build: $(image_file)

buildrm:
	docker rmi $(image):$(tag)
	@rm  $(image_file)

$(container_id_file):
	xhost local:docker
	docker run -it \
		--cidfile $(container_id_file) \
		--workdir=/home/swarm/package \
		-v $(shell pwd):/home/swarm/package \
		-v $(HOME)/.vim:/home/swarm/.vim \
		-v ~/.Xauthority:/root/.Xauthority \
		-v /run/user/1000:/run/user/1000 \
		-e XDG_RUNTIME_DIR \
		--name $(name) \
		$(image) 

create: $(container_id_file)
	
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
