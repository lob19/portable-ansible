#!/bin/bash

set -eu

OPTION=${1:-help}

source libs/console.sh

case ${OPTION} in
    help)
        cat << EOM
Usage: ./manage.sh <option> [arguments]

Available options:
    help        - this screen
    metadata    - print out details about meta
    container   - manage a docker container
    builder     - manage a build
    client      - manage a client   
    server      - manage a server   
EOM
        ;;
    metadata)
        shift
        info "Portable-Ansible version: ${VERSION}"
        info "Tagball: ${TARBALL}"
        ;;
    container)
        shift
        ./libs/container.sh $@
        ;;
    builder)
        shift
        ./libs/builder.sh $@
        ;;
    client)
        shift
        ./libs/client.sh $@
        ;;
    server)
        shift
        ./libs/server.sh $@
        ;;
    *)
        if [ ! "$@" ]; then
            warning "No arguments specified, use help for more details" 
        else
            exec "$@"
        fi
        ;;
esac 
