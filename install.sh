#!/usr/bin/env bash
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NOCOLOR='\033[0m'

echo -e "===================="
echo -e "| Install WPTunnel |"
echo -e "===================="

trap ctrl_c INT

ctrl_c() {
  errorInstall
}

error () {
  echo -e "${RED}${1}${NOCOLOR}"
  exit 1
}

errorInstall () {
  error "Failed to install."
}

installViaPackageManager () {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    ensureHomebrew
    sh -c "brew install ${1}"
  elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    if [ -x "$(command -v apt-get)" ]; then
      sh -c "sudo apt-get install ${1}"
    elif [ -x "$(command -v yum)" ]; then
      sh -c "sudo yum install ${1}"
    else
      error "Cannot find package manager."
    fi
  fi
  if [ $? -ne 0 ]; then errorInstall; fi
}

downloadExec () {
  if [ -x "$(command -v curl)" ]; then
    sh -c "curl -sL $1 | sh"
  elif [ -x "$(command -v wget)" ]; then
    sh -c "wget -qO- $1 | sh"
  fi
  if [ $? -ne 0 ]; then errorInstall; fi
}

downloadToSudo () {
  if [ -x "$(command -v curl)" ]; then
    sudo sh -c "curl -sL $1 > $2"
  elif [ -x "$(command -v wget)" ]; then
    sudo sh -c "wget -qO- $1 > $2"
  fi
  if [ $? -ne 0 ]; then errorInstall; fi
}

downloadTo () {
  if [ -x "$(command -v curl)" ]; then
    sh -c "curl -sL $1 > $2"
  elif [ -x "$(command -v wget)" ]; then
    sh -c "wget -qO- $1 > $2"
  fi
  if [ $? -ne 0 ]; then errorInstall; fi
}

ensureHomebrew () {
  echo -n "Homebrew: "
  if ! [ -x "$(command -v brew)" ]; then
    echo -e "${YELLOW}NOT FOUND${NOCOLOR}"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [ $? -ne 0 ]; then errorInstall; fi
  else
    echo -e "${GREEN}OK${NOCOLOR}"
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
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo -e "${YELLOW}Docker can't automatically be installed on Mac. Please install it manually: https://docs.docker.com/docker-for-mac/install/${NOCOLOR}"
      errorInstall
    else
      echo -e "${YELLOW}We're going to need sudo access in order to install Docker.${NOCOLOR}"
      sudo true
      downloadExec https://get.docker.com/
    fi
  else
    echo -e "${GREEN}OK${NOCOLOR}"
  fi
}

ensureDockerCompose () {
  echo -n "Docker Compose: "
  if ! [ -x "$(command -v docker-compose)" ]; then
    echo -e "${YELLOW}NOT FOUND${NOCOLOR}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo -e "${YELLOW}Docker Compose can't automatically be installed on Mac. Please install it manually: https://docs.docker.com/docker-for-mac/install/${NOCOLOR}"
      errorInstall
    else
      echo -e "${YELLOW}We're going to need sudo access in order to install Docker Compose.${NOCOLOR}"
      sudo true
      if [ $? -ne 0 ]; then errorInstall; fi
      COMPOSE_VERSION=`git ls-remote https://github.com/docker/compose | grep refs/tags | grep -oP "[0-9]+\.[0-9][0-9]+\.[0-9]+$" | tail -n 1`
      downloadToSudo "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m`" "/usr/local/bin/docker-compose"
      sudo chmod +x /usr/local/bin/docker-compose
      downloadToSudo "https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose" "/etc/bash_completion.d/docker-compose"
    fi
  else
    echo -e "${GREEN}OK${NOCOLOR}"
  fi
}

ensureGit
ensureDocker
ensureDockerCompose

mkdir -p ~/.wptunnel
WPTUNNEL_VERSION=""
if [[ "$OSTYPE" == "darwin"* ]]; then
  WPTUNNEL_VERSION=`git ls-remote https://github.com/dsdenes/wptunnel | grep refs/tags | grep -oE "[0-9]+\.[0-9]+\.[0-9]+$" | tail -n 1`
else
  WPTUNNEL_VERSION=`git ls-remote https://github.com/dsdenes/wptunnel | grep refs/tags | grep -oP "[0-9]+\.[0-9]+\.[0-9]+$" | tail -n 1`
fi
downloadTo "https://github.com/dsdenes/wptunnel/archive/${WPTUNNEL_VERSION}.tar.gz" "/tmp/wptunnel.tar.gz"
tar -xzf /tmp/wptunnel.tar.gz --strip 1 -C ~/.wptunnel
if [ $? -ne 0 ]; then errorInstall; fi
chmod +x ~/.wptunnel/bin/wptunnel
rm -rf /tmp/wptunnel.tar.gz

if [ -f ~/.bash_profile ]; then 
  cp ~/.bash_profile ~/.bash_profile_$(ls ~/.bash_profile*.bak | wc -l).bak
  sed -i /wptunnel/d ~/.bash_profile
fi

echo "export PATH=\$PATH:$HOME/.wptunnel/bin" >> ~/.bash_profile
source ~/.bash_profile

echo -e "${GREEN}All done.${NOCOLOR}"