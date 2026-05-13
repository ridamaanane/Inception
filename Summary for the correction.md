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

