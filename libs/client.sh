#!/bin/bash

set -eu

source metadata
source libs/console.sh

CONTAINER_NAME="ansible-client"
TARBALL="portable-ansible-${VERSION}-py3.tar.bz2"

function help() {

    echo "Usage: client <action>"
    echo 
    echo "  action:"
    echo "      start: start client"
    echo "      stop: stop client"
    echo "      console: open console to client"
    echo "      local_tests: run local tests"
    echo "      remove_tests: run remote tests"
    echo
}

function start() {

    ./libs/container.sh start ${CONTAINER_NAME}
    _prepare
}

function stop() {

    ./libs/container.sh stop ${CONTAINER_NAME}
}

function console() {

    ./libs/container.sh console ${CONTAINER_NAME}
}

function _prepare() {

    echo "Preparing Ansible Client"
    ./libs/container.sh exec ${CONTAINER_NAME} \
        apk add --no-cache openssh-client ncurses && \
    ./libs/container.sh exec ${CONTAINER_NAME} rm -rf /workspace/opt && \
    ./libs/container.sh exec ${CONTAINER_NAME} mkdir -p /workspace/opt && \
    ./libs/container.sh exec ${CONTAINER_NAME} \
        tar -xjf /workspace/builds/${TARBALL} -C /workspace/opt/ && \
    ./libs/container.sh exec ${CONTAINER_NAME} \
        ln -s /workspace/opt/ansible /workspace/opt/ansible-playbook
}

function local_tests() {

    ./libs/container.sh exec ${CONTAINER_NAME} \
        python3 /workspace/opt/ansible-playbook \
            -i /workspace/test/hosts.yaml \
            /workspace/test/local.yaml
}

function remote_tests() {

    ./libs/container.sh exec ${CONTAINER_NAME} \
        python3 /workspace/opt/ansible-playbook \
            -i /workspace/test/hosts.yaml \
            /workspace/test/remote-via-ssh-key.yaml

    ./libs/container.sh exec ${CONTAINER_NAME} \
        python3 /workspace/opt/ansible-playbook \
            -i /workspace/test/hosts.yaml \
            /workspace/test/remote-via-username-and-password.yaml
}


$@