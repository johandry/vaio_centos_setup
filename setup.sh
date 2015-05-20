#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Setup my Sony VAIO VGN-FW139E with CentOS 7
# Description: Will install several programs required for Development and DepOps activities. It will install Puppet to provision and manage the content of the computer.
#=======================================================================================================

create_SSH_Key () {
  [[ -e ~/.ssh/id_rsa ]] && info "SSH Key exists" && return 1

  rm -f ~/.ssh/id_rsa*
  ssh-keygen -N "" -f ~/.ssh/id_rsa -t rsa -b 4096 -C "Johandry's Sony VAIO CentOS 7"
  echo "Go to: https://github.com/settings/ssh"
  echo "Click on 'Add SSH key'. Set the title 'Git - Sony VAIO Centos 7' and copy the following key:"
  cat ~/.ssh/id_rsa.pub
  echo
  echo "click on 'Add key' and delete any previous key from Johandry's Sony VAIO CentOS 7"
}

create_Workspace () {
  [[ -d /home/$USER/Workspace/vaio_centos_setup ]] && info "Workspace exists" && return 1

  mkdir -p /home/$USER/Workspace
  git clone git@github.com:johandry/vaio_centos_setup.git /home/$USER/Workspace/vaio_centos_setup && cd !$

  git config --global user.name "Johandry Amador"
  git config --global user.email johandry@gmail.com
}

cleanup () {
  cd
  rm -rf ~/Setup
}

setup () {
  create_SSH_Key
  create_Workspace
  cleanup
}

setup
