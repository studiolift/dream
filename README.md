# Dream

The Awesome-Docker-Development-Environment-With-Resolving-Domains-Super-Fantastic Dream Machine (for OSX)

## Requirements

You must install an appropriate Docker runtime before running the bootstrap.

Visit https://www.docker.com/products/overview for more details.

## Instructions

Clone and cd to this repo, then run the bootstrapper to get things going

`./bootstrap.sh`

This does the following:

* Add a resolver entry, pointing at the local Docker install
* Boots up two core service containers:
  * [nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/) for mapping host names to containers
  * [dnsmasq](https://hub.docker.com/r/andyshinn/dnsmasq/) for a simple DNS service

## Usage

A container with the environment variable `VIRTUAL_HOST=hello.docker` will be accessible at `http://hello.docker`. This is due to nginx-proxy automatically proxying these virtual hosts and dnsmasq forwarding the requests on to the proxy. The resolver configuration on your host machine allows your browser/terminal to access them.

Basic example to demonstrate this:

`docker run --rm -e VIRTUAL_HOST=hello.docker -p 80 tutum/hello-world`

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
