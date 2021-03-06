#/bin/env bash

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  Setup my Sony VAIO VGN-FW139E with CentOS 7
# Description: Will install several programs required for Development and DepOps activities. It will install Puppet to provision and manage the content of the computer.
#=======================================================================================================

declare -r ANYCONNECT_URL=https://www.auckland.ac.nz/content/dam/uoa/central/for/current-students/postgraduate-students/documents/anyconnect-predeploy-linux-64-3.1.04072-k9.tar
declare -r VMWARE_HORIZON_CLIENT_URL=https://download3.vmware.com/software/view/viewclients/CART14Q4/VMware-Horizon-Client-3.2.0-2331566.x86.bundle 

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
  echo "Press Enter when ready"
  read

  ok "SSH Key created"
}

create_Workspace () {
  [[ -d /home/$USER/Workspace/vaio_centos_setup ]] && info "Workspace exists therefore was not created" && return 1

  info "Creating Workspace"
  mkdir -p /home/$USER/Workspace

  info "Cloning the VAIO CentOS Setup project"
  git clone git@github.com:johandry/vaio_centos_setup.git /home/$USER/Workspace/vaio_centos_setup && cd !$

  git config --global user.name "Johandry Amador"
  git config --global user.email johandry@gmail.com

  ok "Workspace directory created and git was setup"
}

install_EPEL () {
  info "Installing EPEL repository"
  # Source: http://www.cyberciti.biz/faq/installing-rhel-epel-repo-on-centos-redhat-7-x/
  sudo yum install -y epel-release
  ok "EPEL repository installed"
  # Set [priority=5]
  if grep -q 'priority=5' /etc/yum.repos.d/epel.repo
    then 
    info "Priority 5 set for EPEL"
  else
    sudo sed -i -e "s/\]$/\]\npriority=5/g" /etc/yum.repos.d/epel.repo 
  fi
  # For another way, change to [enabled=0] and use it only when needed
  sudo sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo 
  # Install packages from EPEL with:
  # yum --enablerepo=epel install [Package] 
}

update_OS () {
  info "Updating CentOS 7"
  sudo yum -y update
  ok "CentOS 7 is updated"
}

install_Cisco_AnyConnect_VPN_Client () {
  if [[ -e /opt/cisco/anyconnect/bin/vpnui ]]
    then
    info "Cisco AnyConnect VPN Client installed therefore was not installed" 
  else
    info "Installing Cisco AnyConnect VPN Client"
    # Download the client 64-bits version
    # Source: https://www.auckland.ac.nz/en/for/current-students/cs-current-pg/cs-current-pg-support/vpn/cs-cisco-vpn-client-for-linux.html
    wget "${ANYCONNECT_URL}" -O /tmp/anyconnect.tar

    # Install Pangox libraries
    # Source: http://oit.ua.edu/wp-content/uploads/2014/08/Linux.pdf
    # Source: https://pario.no/2014/09/30/fix-cisco-anyconnect-on-centos-7/
    # Dependency: install_EPEL
    sudo yum --enablerepo=epel install -y pangox‐compat 

    # Untar and install
    # Source: http://oit.ua.edu/wp-content/uploads/2014/08/Linux.pdf
    # Source: https://www.auckland.ac.nz/en/for/current-students/cs-current-pg/cs-current-pg-support/vpn/cs-cisco-vpn-client-for-linux.html
    mkdir -p /tmp/anyconnect
    sudo tar xf /tmp/anyconnect.tar -C /tmp/anyconnect
    cd /tmp/anyconnect/*/vpn/
    sudo ./vpn_install.sh
    cd
    sudo rm -rf /tmp/anyconnect 
    ok "Cisco AnyConnect VPN Client installed"
  fi

  info "Starting Cisco AnyConnect VPN Service"
  # Start service
  sudo systemctl start vpnagentd.service
  sudo systemctl status vpnagentd.service

  info "Open a browser to the VPN page"
  /opt/cisco/anyconnect/bin/vpnui

  # Comments:
  #   Useful commands:
  #   * yum provides <program>: List packages that provides a program or library
  #   * yum list | grep xml: List installed programs
  #   * ldconfig -p | grep xml: List installed libraries and where they are located.
  #   * ldd vpnagentd | grep xml: Show libraries of the program and where they are linked to
}

install_Cinnamon () {
  info "Installing Cinnammon Desktop"
  # Install Cinnamon packages
  # Dependency: install_EPEL
  sudo yum --enablerepo=epel install -y cinnamon*
  ok "Cinnammon Desktop installed"
}

install_MATE () {
  info "Installing MATE Desktop"
  # Install MATE Desktop group of packages
  # Dependency: install_EPEL
  sudo yum --enablerepo=epel groups install -y "MATE Desktop"
  ok "MATE Desktop installed"
}

install_VMWare_Horizon_Client () {
  # Install dependencies. These packages are 32-bit version
  sudo yum install -y glibc.i686 libgcc.i686 gtk2-engines.i686 PackageKit-gtk-module.i686 libpng12.i686 libXScrnSaver.i686 openssl-libs.i686 openssl-devel.i686 libxml2.i686 atk-devel.i686 gtk2-devel.i686 libxml2-devel.i686 libcanberra-gtk2.i686
  cd /usr/lib
  sudo ln -s /usr/lib/libcrypto.so.1.0.1e libssl.so.1.0.1
  sudo ln -s /usr/lib/libcrypto.so.1.0.1e libcrypto.so.1.0.1

  # Downloading VMWare Horizon Client
  wget ${VMWARE_HORIZON_CLIENT_URL} -O /tmp/VMware-Horizon-Client.bundle

  info "Do NOT select USB, Printing or any other extra feature. Just the basics"
  chmod +x /tmp/VMware-Horizon-Client.bundle
  sudo /tmp/VMware-Horizon-Client.bundle

  # Source: http://www.davemalpass.com/install-vmware-horizon-view-client-on-fedora-21-64bit/
}

install_Chrome () {
  sudo cp "${SCRIPT_DIR}/files/google-chrome.repo" /etc/yum.repos.d/
  sudo yum install -y google-chrome-stable
}

install_Multimedia () {
  sudo yum -y install http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
  sudo yum -y install http://linuxdownload.adobe.com/linux/x86_64/adobe-release-x86_64-1.0-1.noarch.rpm

  sudo yum -y install flash-plugin icedtea-web vlc smplayer ffmpeg HandBrake-{gui,cli} libdvdcss gstreamer{,1}-plugins-ugly gstreamer-plugins-bad-nonfree gstreamer1-plugins-bad-freeworld

}

setup_Windows_Access () {
  info "Setup NTFS Access from CentOS"
  sudo yum --enablerepo epel -y install fuse ntfs-3g ntfsprogs ntfsprogs-gnomevfsntfsprogs ntfsprogs-gnomevfs
  sudo echo "/dev/sda1       /mnt/win   ntfs-3g  rw,umask=0000,defaults 0 0" >> /etc/fstab  

  info "Setup dual boot with Windows 8.1"
  sudo grub2-mkconfig -o /boot/grub2/grub.cfg
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
  update_OS
  install_Cisco_AnyConnect_VPN_Client
  install_VMWare_Horizon_Client
  install_Chrome
  install_Multimedia
  # install_Cinnamon
  # install_MATE
  cleanup
}

init
#setup
finish
