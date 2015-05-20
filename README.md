# VAIO CentOS 7 Setup

This is a guide and scripts to setup my old **Sony VAIO VGN-FW139E** with CentOS 7 which I use as for development and DevOps playground.

## Requirements

* VAIO VGN-FW139E
* Internet Access

## Install CentOS 7

I will a USB Flash drive to install CentOS 7 and I'm using a Mac OS X 10.10 to download and setup the USB. In any Unix-like computer download Centos 7 ISO. You may go to http://centos.org/download/ to get the latest version.

```
wget http://mirrors.unifiedlayer.com/centos/7/isos/x86_64/CentOS-7-x86_64-DVD-1503-01.iso 
```

If you are in Mac OS X convert the ISO to DMG create the USB. You may skip this step if you are in Linux. The first command is to identify where the USB is mounted, in this case it is /dev/disk2. So, replace it for the disk that is mounted in your Mac.

``` 
diskutil list
diskutil umountDisk /dev/disk2
sudo dd if=CentOS-7-x86_64-DVD-1503-01.dmg of=/dev/disk2

```
Once it is done you can unplug the USB Flash drive, plug it in the VAIO to start the install of CentOS 7.

A few notes about the install:

* Press the F11 key when the computer is powered on, this is to boot from the USB.
* Setup the Wireless Internet Access first, before setup the time, so you can sync with a Network Time Server.
* Assign a host name, better now than before.
* In Software Selection I selected:
	* Minimal Install
		* Debugging Tools
	* GNOME Desktop
		* GNOME Applications
		* Internet Applications
		* Office Suite and Productivity
	* Development and Creative workstation
		* Development Tools
		* File and Storage Server
		* Graphics Creation Tools
		* PHP Support
		* Perl for Web
		* Python


## Wireless setup

The CentOS 7 installer is able to connect to my WiFi network. However, once CentOS 7 is installed the WiFi is not recognized. To fix this, install NetworkManager-WiFi package from the USB Flash and restart the service. 

```
sudo yum --disablerepo=\* install /run/media/$USER/CentOS\ 7\ x86_64/Packages/NetworkManager-wifi-*
sudo service NetworkManager restart
```

Or you may have to plug a network cable from your router to the VAIO in order to have Internet Access temporally to download and install NetworkManager-WiFi package. 

```
sudo yum install -y NetworkManager-wifi
```
[source](https://www.centos.org/forums/viewtopic.php?f=50&t=52222&start=10)

If this do not work for you, a few things you can try are:

* Identify your network controller and module to load:

```
$ lspci -nn | grep Wireless
06:00.0 Network controller: Qualcomm Atheros AR928X Wireless Network Adapter (PCI-Express) (rev 01)
$ grep -i 168c /lib/modules/*/modules.alias | grep -i 002a
/lib/modules/3.10.0-229.4.2.el7.x86_64/modules.alias:alias pci:v0000168Cd0000002Asv*sd*bc*sc*i* ath9k
.....
```

* My driver for AR928X is ath9k, so I load it and enable NetworkManager:

```
modprobe ath9k
chkconfig NetworkManager on
service NetworkManager start
```
* If you use other driver such as ath5, load it in the same way bou you may have to do more. Check [here](http://wiki.centos.org/HowTos/Laptops/Wireless)

* Update everything:

```
sudo yum -y update
```
## Setup

Git is installed by default so just clone this repository and execute the setup.sh script:

```
git clone 
cd vaio_centos_setup
./setup.sh
```

This script - check code [here]() - will do:

1. Install Cisco AnyConnect VPN Client 
2. Install VMWare Horizon Client
3. Install Desktop MATE 
4. Install Puppet to automate installs

The Puppet Manifest will make sure:

1. Install Docker
2. Install Packer and Vagrant
3. Sublime Text 3
4. 






