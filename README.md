A little makefile that you can include in your docker projects. Originally written
as part of [github.com/go-make/make](https://github.com/go-make/make) - see that
project for more general info about using this.

| Target(s)       | Description                                                                                                                                                                                                                             |
|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `docker-build`  | Builds a docker image, tagged with `$(IMAGE_NAME)`.<br>By default, the image version will be set to the git tag.                                                                                                                        |
| `docker-push`   | Pushes to a docker registry                                                                                                                                                                                                             |
| `docker-clean`  | Cleans the myriad untagged docker images that build up during development                                                                                                                                                               |
| `docker-tar`    | Exports container image to a tar file - possibly useful for backing up                                                                                                                                                                  |
| `ca-bundle.crt` | Downloads a trusted list of certificates from [mkcert.org](https://mkcert.org/).<br>Useful for a `SCRATCH` container that needs to contact HTTPS APIs etc.<br>Use in Dockerfile as `ADD ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt` |
| `clobber::`     | Removes previously-built images                                                                                                                                                                                                         |

Optionally-defined variables (only added if not already defined):

| Variable            | Description                                       | Default Value    |
|---------------------|---------------------------------------------------|------------------|
| `$(DOCKERFILE)`     | Used to build the image                           | `Dockerfile`     |
| `$(IMAGE_VERSION)`  | Used to tag the image                             | (git tag)        |
| `$(CONTAINER_NAME)` | Used to tag the image                             | (directory name) |
| `$(DOCKER_SHELL)`   | Used for `docker-shell` and `docker-entry` above. | `/bin/bash`      |

Defined variables:

| Variable        | Description           | Default Value                                                                                          |
|-----------------|-----------------------|--------------------------------------------------------------------------------------------------------|
| `$(IMAGE_NAME)` | Used to tag the image | `[ $(DOCKER_REGISTRY)/ ]` <br> `[ $(DOCKER_ORGANISATION)/ ]` <br> `$(CONTAINER_NAME):$(IMAGE_VERSION)` |

### Extras

Some additional rules that can be useful to run a container with some default options:

| Target(s)      | Description                                                                                            |
|----------------|--------------------------------------------------------------------------------------------------------|
| `docker-run`   | Run container with `$(EXPOSE_PORTS)`, `$(BIND_VOLUMES)` <br> and `$(EXTRA_RUN_OPTS)`                   |
| `docker-shell` | Does `docker exec` with `$(DOCKER_SHELL)` in the container                                             |
| `docker-entry` | Runs a container but with entrypoint set to `$(DOCKER_SHELL)`, <br> useful for debugging entry scripts |

Optionally-defined variables (only added if not already defined):

| Variable          | Description                                      | Default Value                                       |
|-------------------|--------------------------------------------------|-----------------------------------------------------|
| `$(EXPOSE_PORTS)` | Option passed to `docker-run` and `docker-entry` | (maps all `EXPOSE` ports defined in the Dockerfile) |

