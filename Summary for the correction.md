# How Docker and docker compose work ?

### Docker

Docker creates containers from images.

Flow:

- Dockerfile → build image
- image → run container

Container = isolated environment with your app and dependencies.

---

# Docker Compose

Docker Compose manages multiple containers together using `docker-compose.yml`.

It:

* builds images
* starts containers
* creates networks
* creates volumes
* connects services together

Example:

```bash
docker compose up
```

starts all services together.

---

# Difference between Docker image with and without Docker Compose

### Without compose

You run containers manually:

```bash
docker build -t nginx .
docker run -p 443:443 nginx
```

You manage:

* networks manually
* volumes manually
* container linking manually

---

### With compose

Everything is centralized in:

```txt
docker-compose.yml
```

One command:

```bash
docker compose up
```

starts entire infrastructure.

Better for multi-service projects like Inception.

---

# Benefit of Docker compared to VMs

### Docker

* lightweight
* fast startup
* shares host kernel
* less RAM/CPU usage
* containers start in seconds

---

# What they means by stack in the subject

A stack = all services working together

Stack = your full Docker setup started with docker-compose

---

# Docker network

is A virtual network that allows containers to communicate with each other.

in Docker Compose you can create:

- 1 network
- 2 networks
- many networks

There is no limit conceptually.

## What is bridge ?

- bridge is the default Docker network driver.

It creates:

a private internal virtual network between containers.

Containers connected to the same bridge network can:

- communicate using service names
- stay isolated from other networks

## Why NOT host in Inception ?

host means:

- container shares your machine network directly

This breaks:

- isolation
- Docker abstraction

And the subject forbids it.

```bash
container
   ↓
same network stack as host
   ↓
host machine
   ↓
internet
```

## Why bridge is safer

Because:

- containers separated from host
- avoids conflicts
- more secure
- better isolation

That’s why Inception forbids host.

```bash
container
   ↓
bridge network
   ↓
docker
   ↓
host machine
   ↓
internet
```

So:

- container does NOT directly use host network
- Docker translates/routes traffic

---

# what is “host” in docker concept?

Normally on real networks:

* a host = machine/computer/server

Example:

```txt id="x2"
google.com
```

is a hostname.

DNS converts:

```txt id="x3"
google.com → IP address
```

## Docker does SAME idea internally

When you create:

```yaml id="x4"
services:
  mariadb:
```

Docker automatically creates:

* hostname = `mariadb`
* internal IP for container

Example internally:

```txt id="x5"
mariadb → 172.18.0.2
```

## when backup container runs:

```bash id="x6"
mysqldump -h mariadb
```

Docker says:

```txt id="x7"
"Oh, mariadb is this container IP"
```

then connects to it.

* service name becomes hostname

NOT necessarily `container_name`.

---

