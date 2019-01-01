#!/usr/bin/env bash
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NOCOLOR='\033[0m'
VERSION=`cat version`

echo -e "=================================="
echo -e "| Install WPTunnel ${VERSION}     "
echo -e "=================================="

trap ctrl_c INT

ctrl_c() {
  error "Failed to ensure dependencies."
}

error () {
  echo -e "${RED}${1}${NOCOLOR}"
  exit 1
}

installViaPackageManager () {
  if [ -x "$(command -v apt-get)" ]; then
    sh -c "sudo apt-get install ${1}"
  elif [ -x "$(command -v yum)" ]; then
    sh -c "sudo yum install ${1}"
  elif [ -x "$(command -v brew)" ]; then
    sh -c "brew install ${1}"
  else
    error "Cannot find package manager."
  fi
}

downloadExec () {
  if [ -x "$(command -v curl)" ]; then
    curl ${1} | sh
  elif [ -x "$(command -v wget)" ]; then
    wget -qO- ${1} | sh
  fi
}

downloadToSudo () {
  if [ -x "$(command -v curl)" ]; then
    sudo curl -L ${1} > ${2}
  elif [ -x "$(command -v wget)" ]; then
    sudo wget -qO- ${1} > ${2}
  fi
}

downloadTo () {
  if [ -x "$(command -v curl)" ]; then
    curl -L ${1} > ${2}
  elif [ -x "$(command -v wget)" ]; then
    wget -qO- ${1} > ${2}
  fi
}

ensureGit () {
  echo -n "Git: "
  if ! [ -x "$(command -v git)" ]; then
    echo -e "${YELLOW}NOT FOUND${NOCOLOR}"
    installViaPackageManager git
  else
    echo -e "${GREEN}OK${NOCOLOR}"
  fi
}

ensureDocker () {
  echo -n "Docker: "
  if ! [ -x "$(command -v docker)" ]; then
    echo -e "${YELLOW}NOT FOUND${NOCOLOR}"
    echo -e "${YELLOW}We're going to need sudo access in order to install Docker.${NOCOLOR}"
    sudo true
    downloadExec https://get.docker.com/
  else
    echo -e "${GREEN}OK${NOCOLOR}"
  fi
}

ensureDockerCompose () {
  echo -n "Docker Compose: "
  if ! [ -x "$(command -v docker-compose)" ]; then
    echo -e "${YELLOW}NOT FOUND${NOCOLOR}"
    echo -e "${YELLOW}We're going to need sudo access in order to install Docker Compose.${NOCOLOR}"
    sudo true
    ensureGit
    COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | tail -n 1`
    downloadToSudo "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m`" "/usr/local/bin/docker-compose"
    sudo chmod +x /usr/local/bin/docker-compose
    downloadToSudo "https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose" "/etc/bash_completion.d/docker-compose"
  else
    echo -e "${GREEN}OK${NOCOLOR}"
  fi
}

ensureDocker
ensureDockerCompose
echo -e "${GREEN}Dependencies are OK${NOCOLOR}"

mkdir -p ~/.wptunnel
downloadTo "https://github.com/dsdenes/wptunnel/archive/v0.0.1.tar.gz" "~/.wptunnel/wptunnel.tar.gz"
tar -xzf ./wptunnel.tar.gz --strip 1 ~/.wptunnel
chmod +x ~/.wptunnel/bin/wptunnel
rm -rf ~/.wptunnel/wptunnel.tar.gz

echo -e "${GREEN}All done.${NOCOLOR}"