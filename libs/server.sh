#!/bin/bash

set -eu

source metadata
source libs/console.sh

CONTAINER_NAME="ansible-server"
CONTAINER_ROOT_PASSWORD="ansible"
CONTAINER_ANSIBLE_USERNAME="ansible"
CONTAINER_ANSIBLE_PASSWORD="ansible"

function help() {

    echo "Usage: server <action>"
    echo 
    echo "  action:"
    echo "      start: start server"
    echo "      stop: stop server"
    echo "      console: open console to server"
    echo
}

function _setup() {

    info "SSH configuration" && \
        sed -i 's/#PermitRootLogin.*/PermitRootLogin\ yes/' /etc/ssh/sshd_config
        sed -ie 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
        
    info "Changing password for root" && \
        echo "root:${CONTAINER_ROOT_PASSWORD}" | chpasswd
    
    info "Preparing SSH keys" && \
        mkdir -p /run/sshd /root/.ssh && \
        chmod 0700 /root/.ssh && \
        cat /workspace/test/resources/ssh-keys/ansible.id_rsa.pub > /root/.ssh/authorized_keys && \
        chmod 600 /root/.ssh/authorized_keys

    info "Generate host keys if not present" && \
        ssh-keygen -A

    info "Adding user: ansible" && \
        adduser -h /home/ansible -D ansible && \
        echo "ansible:ansible" | chpasswd && \
        mkdir -p /home/ansible && \
        chown ansible:ansible /home/ansible
    
    info "Starting sshd server" && \
        /usr/sbin/sshd
}

function start() {

    ./libs/container.sh start ${CONTAINER_NAME}
    ./libs/container.sh exec ${CONTAINER_NAME} apk add --no-cache openssh
    ./libs/container.sh exec ${CONTAINER_NAME} ./manage.sh server _setup
}

function stop() {

    ./libs/container.sh stop ${CONTAINER_NAME}
}

function console() {

    ./libs/container.sh console ${CONTAINER_NAME}
}

$@