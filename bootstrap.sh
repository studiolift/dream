#!/bin/bash

# Dream bootstrap
#
# Rest easy, we'll take it from here...

# Configuration
resolver_tld='docker'
docker_ip='0.0.0.0'

# Helpers
bold=`tput bold`
normal=`tput sgr0`

log () {
  echo "${bold}==> $@${normal}"
}

add_missing_line() {
  grep -q -F "${1}" ${2} || echo "${1}" >> ${2}
}


if ! hash docker 2>/dev/null; then
  echo "You do not have Docker installed. Please install the appropriate runtime:"
  echo "  https://www.docker.com/products/overview"
  exit 1
fi

# And now the magic...
log "Adding ${resolver_tld} resolver"

# Since we confiure a resolver entry for $resolver_tld on the host machine, both
# the host and the containers can communicate with each other, if needed
sudo mkdir -p /etc/resolver
sudo sh -c "echo 'nameserver ${docker_ip}' > /etc/resolver/${resolver_tld}"

log 'Booting Dream services'
# It is essential this runs via bootstrap as we need to set DOCKER_IP so dnsmasq
# will accept requests from the host machine. Unfortunately couldn't find a way
# to make this simpler...
docker-compose up -d

log 'Bootstrapped! Welcome to dreamland...'
