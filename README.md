# Dream

The Awesome-Docker-VM-Development-With-Resolving-Domains-Super-Fantastic Dream Machine (for OSX)

## Instructions

Clone and cd to this repo, then run the bootstrapper to get things going

`./bootstrap.sh`

This does the following:

* Install/update [Homebrew](http://brew.sh/) - used to install dockertoolbox
* Install [dockertoolbox](https://www.docker.com/products/docker-toolbox)
* Create the Docker machine instance
* Add a resolver entry, pointing at the new Docker machine
* Adds the Docker machine env to your bash_profile and zshrc
* Boots up two core service containers:
  * [nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/) for mapping host names to containers
  * [dnsmasq](https://hub.docker.com/r/andyshinn/dnsmasq/) for a simple DNS service
* Finally, configure `launchctl` to boot the Docker machine and services at login

## Usage

You can use this Docker machine like you would a standard Docker install, but the real magic comes from the DNS setup.

A container with the environment variable `VIRTUAL_HOST=hello.docker` will be accessible at `http://hello.docker`. This is due to nginx-proxy automatically proxying these virtual hosts and dnsmasq forwarding the requests on to the proxy. The resolver configuration on your host machine allows your browser/terminal to access them, and the docker machine is configured to use your host machine's DNS resolver - your docker containers can ping each other!

Basic example to demonstrate this:

In one terminal: `docker run --rm -e VIRTUAL_HOST=hello.docker -p 80 tutum/hello-world`

In another: `docker run -it --rm busybox` and then `wget -q -O - http://hello.docker`.

You'll see the request hit the hello-world container, and your busybox container will output the returned HTML.

Using `docker-compose` you can easily set pre-configured `VIRTUAL_HOST` settings for your applications using the `environment` key:

```
app:
  build: .
  command: bundle exec rails s -p 3000 -b '0.0.0.0'
  volumes:
    - .:/app
  ports:
    - "3000"
  environment:
    - VIRTUAL_HOST=myapp.docker
```

## Configuration

There are two config options, passed as environment variables when running `./bootstrap.sh`:

* `VM_NAME` - Set the name of the Docker machine (Default: default)
* `VM_TLD` - Set the TLD to be used for `VIRTUAL_HOST` entries (Default: docker)

Example: `VM_NAME=dev VM_TLD=banana ./bootstrap.sh` would create a VM named dev and accept `VIRTUAL_HOSTS` ending in `.banana`
