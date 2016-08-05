# vagrant-kibi
Vagrant File for Kibi

## Overview

I an image I uploaded. That image was forked from the official puppet-centos7.1 which I think is just a minimum install.

__I modified the image in the following ways:__
  * Replaced puppet 4 with puppet 3.8
  * Installed git-1.8.3.1-6
  * Disabled selinux

## Provisioning

Provisioning is working only for Demo versions of Kibi on my CentOS 7.1 image, it would probably work on any EL based image though.

__What provisioning effects:__
  * Disables firewalld
  * Installs Java 8 openjdk
  * Installs epel without gpg or from using epel-release package
  * Installs nodejs
  * Installs unzip
  * Adds user Kibi w/ nologin
  * Downloads and installs kibi Demo (version based on arguments commented out in Vagrantfile) ```default: lite```
  * Configures Kibi and elasticsearch to listen on primary IP
  * Installs the elastic HQ plugin with latest version at the time of this publication

## Todo

  1. Add support for ES Cluster
  2. Add support for kibi source (non-demo version)
  3. Add support for alternative OSs in Provisioning 
  4. Add firewall and selinux support
