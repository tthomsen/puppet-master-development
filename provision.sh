#!/bin/bash
## This script is only used by Vagrant for making our environment available
## with the right hostname resolutions and pre-downloads PE to share across
## the instances.  It's not used outside of Vagrant.
## Yeah, it's a BASH script. So what? Tool for the job, yo.

## The version of PE to make available to in our Vagrant environment
PE_VERSION="3.3.2"

###########################################################
ANSWERS=$1
PE_URL="https://s3.amazonaws.com/pe-builds/released/${PE_VERSION}/puppet-enterprise-${PE_VERSION}-el-6-x86_64.tar.gz"
FILENAME=${PE_URL##*/}
DIRNAME=${FILENAME%*.tar.gz}
PE_INSTALLER="bootstrap/pe"

## A reasonable PATH
echo "export PATH=$PATH:/usr/local/bin:/opt/puppet/bin" >> /etc/bashrc

## Add host entries for each system
cat > /etc/hosts <<EOH
127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain
::1 localhost localhost.localdomain localhost6 localhost6.localdomain
###############################################################################
192.168.137.10 master.vagrant.vm master
192.168.137.11 agent1.vagrant.vm agent1

###############################################################################
## CNAMEs for CA server
192.168.137.10 puppetca.vagrant.vm puppetca

EOH

## Download and extract the PE installer
cd /vagrant/puppet/pe || (echo "/vagrant/puppet/pe doesn't exist." && exit 1)
if [ ! -f $FILENAME ]; then
  curl -O ${PE_URL} || (echo "Failed to download ${PE_URL}" && exit 1)
else
  echo "${FILENAME} already present"
fi

if [ ! -d ${DIRNAME} ]; then
  tar zxf ${FILENAME} || (echo "Failed to extract ${FILENAME}" && exit 1)
else
  echo "${DIRNAME} already present"
fi

## Install PE with a specified answer file
if [ ! -d '/opt/puppet/' ]; then
  # Assume puppet isn't installed
  /vagrant/puppet/pe/${DIRNAME}/puppet-enterprise-installer \
  -a /vagrant/puppet/pe/answers/${ANSWERS}
else
  echo "/opt/puppet exists. Assuming it's already installed."
fi

## Bootstrap the master(s)
if [[ "$1" == *master.txt ]]; then

  #[ ! -z "$2" ] && role="$2" || role="role::puppet::master"

  ## Install some prerequisites
  yum install -y git

  echo "==> Installing r10k"
  /opt/puppet/bin/gem install r10k

  ## Use the control repo for bootstrapping
  #echo "==> Copying /vagrant/code/control to /tmp/control"
  #cp -r /vagrant/code/control /tmp/control
  #cd /tmp/control

  #echo "==> Initializing /tmp/control as a Git repository"
  #git init && git add . && git commit -m "Initial commit"

  #echo "==> Running r10k against /tmp/control/Puppetfile"
  #echo "    >> This might take several minutes..."
  #/opt/puppet/bin/r10k puppetfile install -v

  ## Run a Puppet apply against the role in the copy of the control repo so we
  ## can bootstrap
  #echo "======================================================================"
  #echo "Applying role: ${role}"
  #echo
  #/opt/puppet/bin/puppet apply -e "include ${role}" \
  #--modulepath=./modules:./site:/opt/puppet/share/puppet/modules

  if [ $? -eq 0 ]; then
    ## So we'll stub out the production environment until our gitlab server
    ## is ready.  We want the other vagrant instances to be able to come up and
    ## do a Puppet run cleanly
    echo "==> Copying /tmp/control to puppet/environments/production"
    cp -r /tmp/control /etc/puppetlabs/puppet/environments/production

    echo "==> Adding r10k cache to puppet/environments/production"
    git --git-dir /etc/puppetlabs/puppet/environments/production/.git \
    --work-tree /etc/puppetlabs/puppet/environments/production remote \
    add cache /var/cache/r10k/git@gitlab.vagrant.vm-puppet-control.git

    echo "==> Running 'puppet agent -t'"
    /opt/puppet/bin/puppet agent -t

    if [ -f "/root/.ssh/id_rsa.pub" ]; then
      echo "################################################################"
      echo "Copy the following SSH pubkey to your clipboard:"
      echo
      cat /root/.ssh/id_rsa.pub
      echo
      echo "################################################################"
      echo "This key should be added to Gitlab."
    fi
    echo "Now configure the Gitlab server"
  else
    echo "The master failed to apply its role."
  fi
fi
