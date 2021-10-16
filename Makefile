IMAGE_NAME=openpose

DOCKER_DOCKERFILE=Dockerfile
DOCKER_BUILD_CONTEXT=.

IMAGE_VERSION=0.0.1

VOLUMES=-v ${PWD}:/home/root/project/ \
	-v ${HOME}/.ssh/:/home/root/.ssh \
	-v ${HOME}/.gitconfig:/home/root/.gitconfig \
	-v ${PWD}/.bash_history:/home/root/.bash_history

.PHONY: run docker-build

.ONESHELL:

run: 
	docker run --rm -it \
		${VOLUMES} \
		${IMAGE_NAME}:${IMAGE_VERSION}

docker-build: 
	docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} ${DOCKER_BUILD_CONTEXT} -f ${DOCKER_DOCKERFILE}
