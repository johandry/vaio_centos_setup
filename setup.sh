#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Setup my Sony VAIO VGN-FW139E with CentOS 7
# Description: Will install several programs required for Development and DepOps activities. It will install Puppet to provision and manage the content of the computer.
#=======================================================================================================

declare -r SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
declare -r LOG_FILE=/tmp/vaio_centos_setup.log

log () {
  msg="\e[${3};1m[${1}]\e[0m\t${2}\n"
  log="$(date +'%x - %X')\t[${1}]\t${2}\n"
  echo -ne $msg
  echo -ne $log >> "${LOG_FILE}"
}

error () {
  # Red [ERROR]
  log "ERROR" "${1}" 91
}

ok () {
  # Green [ OK ]
  log " OK " "${1}" 92  
}

warn () {
  # Yellow [WARN]
  log "WARN" "${1}" 93
}

info () {
  # Blue [INFO]
  log "INFO" "${1}" 94
}

debug () {
  # Purple [DBUG]
  log "DBUG" "${1}" 92
}

init () {
  > "${LOG_FILE}"
  info "Starting setup"
  START_T=$(date +%s)
}

create_SSH_Key () {
  [[ -e ~/.ssh/id_rsa ]] && info "SSH Key exists therefore was not created" && return 1

  rm -f ~/.ssh/id_rsa*
  ssh-keygen -N "" -f ~/.ssh/id_rsa -t rsa -b 4096 -C "Johandry's Sony VAIO CentOS 7"
  echo "Go to: https://github.com/settings/ssh"
  echo "Click on 'Add SSH key'. Set the title 'Git - Sony VAIO Centos 7' and copy the following key:"
  cat ~/.ssh/id_rsa.pub
  echo
  echo "click on 'Add key' and delete any previous key from Johandry's Sony VAIO CentOS 7"

  ok "SSH Key created"
}

create_Workspace () {
  [[ -d /home/$USER/Workspace/vaio_centos_setup ]] && info "Workspace exists therefore was not created" && return 1

  mkdir -p /home/$USER/Workspace
  git clone git@github.com:johandry/vaio_centos_setup.git /home/$USER/Workspace/vaio_centos_setup && cd !$

  git config --global user.name "Johandry Amador"
  git config --global user.email johandry@gmail.com

  ok "Workspace directory created and git was setup"
}



cleanup () {
  [[ ! -d ~/Setup ]] && info "Setup directory does not exists therefore was not deleted" && return 1
  cd
  rm -rf ~/Setup
  ok "~/Setup directory deleted"
}

finish () {
  END_T=$(date +%s)
  ok "Setup completed in $(($END_T - $START_T)) seconds"
}

setup () {
  create_SSH_Key
  create_Workspace
  cleanup
}

init
setup
finish
