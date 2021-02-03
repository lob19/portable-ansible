#!/bin/sh

set -eu

# you can also define some variables
COLOR_BLACK=0
COLOR_RED=1 
COLOR_GREEN=2
COLOR_YELLOW=3
COLOR_BLUE=4
COLOR_PINK=5
COLOR_CYAN=6
COLOR_WHITE=7;

function cecho() {
  
  local _color=$1; shift
  echo -e "$(tput setaf $_color)$@$(tput sgr0)"
}

# Error wrapping function
function error() {
  cecho $COLOR_RED "[ERROR] $@"
  exit 1
}

# Warning wrapping function
function warning() {
  cecho $COLOR_YELLOW "[WARNING] $@"
}

# Info wrapping function
function info() {
  cecho $COLOR_CYAN "[INFO] $@"
}