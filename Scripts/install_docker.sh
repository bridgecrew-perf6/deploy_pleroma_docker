#!/usr/bin/env bash

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. "${DIR}/util.sh"

ilogger "Checking if docker is installed ..."
which docker >/dev/null 2>&1
if [ $? -eq 0 ];
then
    ilogger "Docker is already installed on this host."
else
    chk_krl_ver="$(uname -r)"
    if [ "${chk_krl_ver}" == '5.3.0-52-generic' ];
    then
        ilogger 'err' "Your linux kernel version is ${chk_krl_ver} , DO NOT try to install docker on this kernel. Upgrade the kernel version !!!"
        exit 1
    fi

    ilogger 'warn' "Docker is not installed on this host, Start installing ..."
    sudo apt-get remove docker docker-engine docker.io containerd runc
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    ilogger 'warn' "Docker installation is done."
    ilogger "Verifying docker installation ..."
    sudo docker run hello-world
    if [ $? -ne 0 ];
    then
        ilogger 'suc' "docker-ce is installed successfully !"
    else
        ilogger 'err' "Failed to install docker-ce."
    fi
fi


which docker-compose >/dev/null 2>&1
if [ $? -eq 0 ];
then
    ilogger "Docker-compose is already installed on this host."
else
    ilogger 'warn' "Docker-compose is not installed on this host, Start installing ..."

    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o "/tmp/docker-compose-$(uname -s)-$(uname -m)"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m).sha256" -o "/tmp/docker-compose-$(uname -s)-$(uname -m).sha256"
    pushd /tmp
    sha256sum -c "docker-compose-$(uname -s)-$(uname -m).sha256"
    if [ $? -eq 0 ];
    then
        sudo mv "docker-compose-$(uname -s)-$(uname -m)" '/usr/local/bin/docker-compose'
        sudo chmod +x '/usr/local/bin/docker-compose'
    else
        ilogger 'err' "Downloaded /tmp/docker-compose-$(uname -s)-$(uname -m) may be broken, download it from https://github.com/docker/compose/releases/latest again !"
    fi
    popd
fi
