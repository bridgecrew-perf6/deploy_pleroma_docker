# Deploy a pleroma instance with docker

WARNING: It is still in WIP. Don't use it.

This project is for my personal usage only. It is modified on [this repository](https://github.com/angristan/docker-pleroma) .

## Prerequisites

- A amd64 machine running on Ubuntu18.04+ with Linux kernel 3.10+
- bash, make and git installed
- 1GB+ of Memory
- ~1GB of free HDD space


## Installation

1. Create a user on Ubuntu, make sure it can run sudo without password.
2. Clone this repository and `cd` to it.
3. Do some configurations. See section "Configuration" below.
4. Run `make build`.


## Configuration

1. Change values in `conf/env.sh` .
2. Edit file `pleroma_config/prod.secret.exs` if needed.
3. Replace uploads directory with your old `pleroma/uploads` .
4. Change `COPY` commands in Dockerfile if needed.
5. If you want to use an existing PostgreSQL data, use `pgdump -d pleroma -Fc pleroma.pgdump` to get the data file, then put it to `export/pleroma.pgdump`.


## Usage

To launch your instance, run command in this directory:

```sh
make run
```

Check if things went well:

```sh
docker logs -f pleroma_web
```

update pleroma instance need to rebuild a new docker image.

```sh
make update
```
