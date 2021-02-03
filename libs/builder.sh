#!/bin/bash

set -eu

source metadata
source libs/console.sh

CONTAINER_NAME="ansible-builder"
TARBALL="portable-ansible-${VERSION}-py3.tar.bz2"

function help() {

    echo "Usage: builder <action>"
    echo 
    echo "  action:"
    echo "      start: start builder"
    echo "      stop: stop builder"
    echo "      console: open console to builder"
    echo "      prepare: prepare builder"
    echo "      run: run building portable-ansible package"
    echo
}

function start() {

    ./libs/container.sh start ${CONTAINER_NAME}
}

function stop() {

    ./libs/container.sh stop ${CONTAINER_NAME}
}

function console() {

    ./libs/container.sh console ${CONTAINER_NAME}
}

function prepare() {

    echo "Preparing Ansible Builder" && \
    ./libs/container.sh exec ${CONTAINER_NAME} \
        apk add --no-cache py3-pip py3-wheel py3-setuptools
}

function run() {

    ./libs/container.sh exec ${CONTAINER_NAME} ./manage.sh builder _clean && \
    ./libs/container.sh exec ${CONTAINER_NAME} ./manage.sh builder _dependencies
    ./libs/container.sh exec ${CONTAINER_NAME} ./manage.sh builder _run
    ./libs/container.sh exec ${CONTAINER_NAME} ./manage.sh builder _post_clean
    ./libs/container.sh exec ${CONTAINER_NAME} ./manage.sh builder _tarball
}


function _clean() {

    info "Cleaning directory: /workspace/target"
    if [ -d /workspace/target ]; then 
        rm -rf /workspace/target
    fi
}

function _dependencies() {

    info "Preparing dependecies" && \
    mkdir -p "/workspace/target/ansible/" && \
        cp "/workspace/templates/__main__.py" "$(pwd)/target/ansible/"
    mkdir -p "/workspace/target/ansible/extras/"
    # cp $(shell pwd)/templates/ansible-compat-six-init.py $(shell pwd)/ansible/ansible/compat/six/__init__.py
} 

function _run() {

    info "Installing Ansible packages" && \
         pip3 install --no-deps \
             --no-compile --requirement conf/requirements \
             --target /workspace/target/ansible/
}

function _post_clean() {

    info 'Removing extra dirs and files' && \
         rm -rf /workspace/target/ansible/*.dist-info && \
         rm -rf /workspace/target/ansible/*.egg-info && \
         rm -rf /workspace/target/ansible/*.gz && \
         rm -rf /workspace/target/ansible/*.whl && \
         # rm -rf /workspace/target/ansible/bin/ && \
         rm -rf /workspace/target/ansible/ansible_test/ && \
     info 'Removing __pycache__ dirs' && \
         [ -d "/workspace/target/ansible/" ] && {
             find "/workspace/target/ansible/" -path '*/__pycache__/*' -delete
             find "/workspace/target/ansible/" -type d -name '__pycache__' -empty -delete
         }
         # rm -rf /workspace/target/ansible/bin && \
}

function _tarball() {
    
    info 'Building tarball' && \
        mkdir -p "/workspace/builds" && \
        tar cjf builds/${TARBALL} -C "/workspace/target/" ansible
}


$@