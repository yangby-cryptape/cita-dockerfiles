# [Unofficial] CITA Dockerfiles

Dockerfiles for [CITA][cita-repo-url].

## Dockers

All docker images can be found in [my page][my-docker-hub-url] at Docker Hub
Registry.

### CITA-Build

Build environment for [CITA][cita-repo-url].

Because I am dissatisfied with the official [`cita-build` docker][official-cita-build-url],
I create my own `Dockerfile` which is more clear, readableand, and follow
[Best Practices of Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/).
(More details can found [HERE](https://github.com/cryptape/cita-build/issues/8).)

Supported tags and respective `Dockerfile` links:
  - [`bionic`][bionic-url]

Start the docker as follows:

```bash
docker run --rm -it \
    --workdir "${DOCKER_DIR}" \
    --volume "${HOST_DIR}:${DOCKER_DIR}" \
    --volume "rust-registry:/opt/local/cargo/registry" \
    --volume "rust-git:/opt/local/cargo/git" \
    yangby0cryptape/cita-build:bionic \
    ${COMMANDS}
```

Put the source codes of [CITA][cita-repo-url] in `${HOST_DIR}` in the host
filesystem and mount it as `workdir` (default is `/cita`) in the docker
container.

Use `volumes` for `/opt/local/cargo/registry` and `/opt/local/cargo/git` can
cache files to make `cargo` command faster.

[cita-repo-url]: https://github.com/cryptape/cita
[my-docker-hub-url]: https://hub.docker.com/u/yangby0cryptape/
[official-cita-build-url]: https://github.com/cryptape/cita-build
[bionic-url]: https://github.com/yangby-cryptape/cita-dockerfiles/tree/master/ubuntu/bionic/build
