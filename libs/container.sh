#!/bin/bash

set -eu

source libs/console.sh

function help() {
 
    echo "Usage: container <action> <container name>"
    echo 
    echo "  action:"
    echo "      start:      start the container"
    echo "      stop:       stop the contiainer"
    echo "      console:    open console in the container"
    echo "      list:       list active docker containers"
    echo "      exec:       run command in container"
    echo "      ip:         get IP address"
    echo "  container name: container name"
    echo
}

function list() {

    docker container ls -l
}

function start() {

    CONTAINER_NAME=${1:-}
    [ -z "${CONTAINER_NAME}" ] && {
        error "Container name cannot be empty"
        exit 1
    }
    info "Starting docker container: ${CONTAINER_NAME}" && \
        docker run -d --name ${CONTAINER_NAME} \
            --volume "$(pwd)":/workspace \
            --workdir /workspace \
            alpine:latest tail -f /dev/null
    info "Installing packages" && \
        docker container exec -ti ${CONTAINER_NAME} apk add --no-cache bash python3 ncurses
    info "Updating hosts file" && \
        IP_ADDRESS=$(ip ${CONTAINER_NAME}) && \
        sed -i "s/*${CONTAINER_NAME}/${IP_ADDRESS}  ${CONTAINER_NAME}/" etc/hosts && \
        docker container exec -ti ${CONTAINER_NAME} \
            /bin/bash -c 'cat /workspace/etc/hosts >> /etc/hosts'
}

function stop() {

    CONTAINER_NAME=${1:-}
    [ -z "${CONTAINER_NAME}" ] && {
        error "Container name cannot be empty"
        exit 1
    }
    info "Stoping and removing docker container: ${CONTAINER_NAME}" && \
        docker container stop ${CONTAINER_NAME} && \
        docker container rm ${CONTAINER_NAME}
}

function exec() {

    CONTAINER_NAME=${1:-}
    [ -z "${CONTAINER_NAME}" ] && {
        error "Container name cannot be empty"
        exit 1
    }
    shift
    COMMAND=$@
    [ -z "${COMMAND}" ] && {
        error "Command cannot be empty string"
        exit 1
    }

    info "Connecting to container: ${CONTAINER_NAME} to run command: ${COMMAND}" && \
        docker container exec -ti ${CONTAINER_NAME} ${COMMAND}
}

function console() {

    CONTAINER_NAME=${1:-}
    docker container exec -ti ${CONTAINER_NAME} /bin/bash
}

function ip() {

    CONTAINER_NAME=${1:-}
    docker inspect -f "{{ .NetworkSettings.IPAddress }}" ${CONTAINER_NAME}
}

$@
