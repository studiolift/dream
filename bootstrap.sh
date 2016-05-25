#!/bin/bash

# Dream bootstrap
#
# Rest easy, we'll take it from here...

# Configuration
vm_name=${VM_NAME:-"default"}
resolver_tld=${DOCKER_TLD:-"docker"}

# Helpers
bold=`tput bold`
normal=`tput sgr0`

log () {
  echo "${bold}==> $@${normal}"
}

add_missing_line() {
  grep -q -F "${1}" ${2} || echo "${1}" >> ${2}
}

# And now the magic...
platform=$(uname)
runtime='native'

if [[ "$platform" == 'Darwin' ]]; then
  #runtime='toolbox'
  runtime='fakenative'
fi

if [[ $runtime == 'toolbox' ]]; then
  # Homebrew is a very convenient way to install packages
  # Homebrew Cask takes this further, allowing the install of OS X applications
  log 'Installing/updating homebrew'
  if hash brew 2>/dev/null; then
    brew update
  else
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  log 'Installing dockertoolbox'
  brew tap caskroom/cask
  brew cask install dockertoolbox

  # Pretty standard docker-machine stuff, but with one key flag:
  #
  # --virtualbox-host-dns-resolver=true
  #
  # This configures the VM to use the host machines DNS resolution, which means we
  # don't have to mess around with dns settings in the containers themselves
  log 'Booting Docker Dream machine'
  docker-machine create -d virtualbox --virtualbox-host-dns-resolver=true ${vm_name}
  docker-machine start ${vm_name}

  docker_ip=`docker-machine ip ${vm_name}`
else
  docker_ip='127.0.0.1'
fi

log "Adding ${resolver_tld} resolver"
# Since we confiure a resolver entry for $resolver_tld on the host machine, both
# the host and the containers can communicate with each other, if needed
sudo mkdir -p /etc/resolver
sudo sh -c "echo 'nameserver ${docker_ip}' > /etc/resolver/${resolver_tld}"

if [[ $runtime == 'toolbox' ]]; then
  env_line="eval \$(docker-machine env ${vm_name})"

  log 'Ensuring Dream env is in...'
  # Adding the env eval line to both bash_profile and zshrc to automatically prep
  # what is needed for docker/docker-compose to communicate with the correct VM

  # TODO check files exist?
  # TODO check for similar env line, to avoid conflict?

  echo '.bash_profile'
  add_missing_line "${env_line}" ~/.bash_profile

  echo '.zshrc'
  add_missing_line "${env_line}" ~/.zshrc

  eval `docker-machine env ${vm_name}`
fi

log 'Booting Dream services'
# It is essential this runs via bootstrap as we need to set DOCKER_IP so dnsmasq
# will accept requests from the host machine. Unfortunately couldn't find a way
# to make this simpler...
DOCKER_IP=${docker_ip} docker-compose up -d

if [[ $runtime == 'toolbox' ]]; then
  log 'Making sure Dream machine boots at login'
  # We don't want to have to remember to boot the machine and services!
  plist_path="Library/LaunchAgents/com.docker.machine.${vm_name}.plist"
  sed "s/%VM_NAME%/${vm_name}/g" template.plist > ~/${plist_path}
  launchctl load ~/${plist_path}
fi

log 'Bootstrapped! Welcome to dreamland...'
