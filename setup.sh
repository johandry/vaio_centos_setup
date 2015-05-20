#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Setup my Sony VAIO VGN-FW139E with CentOS 7
# Description: Will install several programs required for Development and DepOps activities. It will install Puppet to provision and manage the content of the computer.
#=======================================================================================================

declare -r ANYCONNECT_URL=https://www.auckland.ac.nz/content/dam/uoa/central/for/current-students/postgraduate-students/documents/anyconnect-predeploy-linux-64-3.1.04072-k9.tar

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

install_EPEL () {
  # Source: http://www.cyberciti.biz/faq/installing-rhel-epel-repo-on-centos-redhat-7-x/
  sudo yum install epel-release
}

install_Cisco_AnyConnect_VPN_Client () {
  # Download the client 64-bits version
  # Source: https://www.auckland.ac.nz/en/for/current-students/cs-current-pg/cs-current-pg-support/vpn/cs-cisco-vpn-client-for-linux.html
  wget "${ANYCONNECT_URL}" -O /tmp/anyconnect.tar

  # Install Pangox libraries
  # Source: http://oit.ua.edu/wp-content/uploads/2014/08/Linux.pdf
  # Dependency: install_EPEL
  sudo yum install pangox‐compat pangox‐devel

  # Untar and install
  # Source: http://oit.ua.edu/wp-content/uploads/2014/08/Linux.pdf
  # Source: https://www.auckland.ac.nz/en/for/current-students/cs-current-pg/cs-current-pg-support/vpn/cs-cisco-vpn-client-for-linux.html
  mkdir -p /tmp/anyconnect
  sudo tar xf /tmp/anyconnect.tar -C /tmp/anyconnect
  cd /tmp/anyconnect/*/vpn/
  sudo ./vpn_install.sh
  cd
  sudo rm -rf /tmp/anyconnect 

  # Start service
  sudo systemctl start vpnagentd.service
  sudo systemctl status vpnagentd.service

  info "Open a browser to the VPN page"
  # ./vpnui

  # Comments:
  #   Useful commands:
  #   * yum provides <program>: List packages that provides a program or library
  #   * yum list | grep xml: List installed programs
  #   * ldconfig -p | grep xml: List installed libraries and where they are located.
  #   * ldd vpnagentd | grep xml: Show libraries of the program and where they are linked to
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
  install_EPEL
  install_Cisco_AnyConnect_VPN_Client
  cleanup
}

init
setup
finish
