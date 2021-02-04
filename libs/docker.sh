#!/bin/bash

set -eu

source libs/console.sh


function container_start() {

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
    info "Installing bash" && \
        container_exec ${CONTAINER_NAME} apk add bash python3
    # -u $(id -u ${USER}):$(id -g ${USER}) \
}

function container_stop() {

    CONTAINER_NAME=${1:-}
    [ -z "${CONTAINER_NAME}" ] && {
        error "Container name cannot be empty"
        exit 1
    }
    info "Stoping and removing docker container: ${CONTAINER_NAME}" && \
        docker container stop ${CONTAINER_NAME} && \
        docker container rm ${CONTAINER_NAME}
}

function container_exec() {

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

function container_console() {

    CONTAINER_NAME=${1:-}
    container_exec ${CONTAINER_NAME} /bin/bash
}

# ===================================================================================
# Build container
#
function build_container_prepare() {

    container_exec \
        "ansible-build" \
        apk add --no-cache ncurses py3-pip py3-wheel py3-setuptools
}

function build_container_run() {

    container_exec "ansible-build" "./manage.sh build clean" && \
    container_exec "ansible-build" "./manage.sh build dependencies" && \
    container_exec "ansible-build" "./manage.sh build run" && \
    container_exec "ansible-build" "./manage.sh build post-clean" && \
    container_exec "ansible-build" "./manage.sh build tarball"
}

# ===================================================================================
# Client container
#
function client_container_prepare() {

    TARBALL=${1:-}
    [ -z "${TARBALL}" ] && {
        error "Tarball path is missing"
        exit 1
    }
    container_exec "ansible-client" \
        apk add --no-cache ncurses && \
    container_exec "ansible-client" \
        rm -rf /workspace/opt && \
    container_exec "ansible-client" \
        mkdir -p /workspace/opt && \
    container_exec "ansible-client" \
        tar -xjf /workspace/builds/${TARBALL} -C /workspace/opt/ && \
    container_exec "ansible-client" \
        ln -s /workspace/opt/ansible /workspace/opt/ansible-playbook
}

function client_container_run() {

    container_exec "ansible-client" \
        python3 /workspace/opt/ansible-playbook -i /workspace/test/hosts.yaml /workspace/test/local.yaml
}

# ===================================================================================
# Server container
#
function server_container_prepare() {

    container_exec "ansible-server" apk add --no-cache openssh
}

