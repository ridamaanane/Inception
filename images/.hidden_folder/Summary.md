<details>
<summary><b>Docker containers and virtual machines solve isolation differently</b></summary><br>

# Virtual Machines (Hypervisor)

A VM has:

* Physical hardware
* Hypervisor
* Guest OS
* Applications

Each VM runs its **own kernel**, which is why VMs consume more RAM and CPU overhead.

```
Hardware
   |
Hypervisor
   |
+-------+  +-------+
| VM 1  |  | VM 2  |
|Kernel |  |Kernel |
+-------+  +-------+
```

## Where is the Hypervisor?

There are two types.

### Type 1 (Bare Metal)

Examples:

* VMware ESXi
* Microsoft Hyper-V
* Xen

```text
Hardware
   ↓
Hypervisor
   ↓
VM1  VM2  VM3
```

The hypervisor runs **directly on the hardware**.

It is loaded after the BIOS/UEFI boot process.

So it is **not inside a VM**.

---

### Type 2 (Hosted)

Examples:

* VirtualBox
* VMware Workstation

```text
Hardware
   ↓
Host OS
   ↓
Hypervisor
   ↓
VMs
```

The hypervisor is just a program running on the host OS.

---

# Docker Containers

Containers **share the host kernel**.

```
Hardware
   |
Host OS Kernel
   |
+-----------+ +-----------+
|Container 1| |Container 2|
|App + Libs | |App + Libs |
+-----------+ +-----------+
```

A container is not a VM. It is just a process (or group of processes) running on the host kernel with extra isolation mechanisms.

---

## How does Docker isolate containers?

Docker mainly relies on Linux features:

### 1. Namespaces (Isolation)

Namespaces make a process think it has its own environment.

Examples:

| Namespace | Isolates           |
| --------- | ------------------ |
| PID       | Process IDs        |
| NET       | Network interfaces |
| MNT       | Filesystem mounts  |
| UTS       | Hostname           |
| IPC       | Shared memory      |
| USER      | User IDs           |

For example:

Container A sees:

```bash
PID 1 nginx
PID 2 worker
```

Container B also sees:

```bash
PID 1 mysql
PID 2 helper
```

Both have a PID 1 because they are in different PID namespaces.

---

### 2. Cgroups (Resource Management)

Linux **Control Groups (cgroups)** tell the kernel:

* How much RAM a container can use
* How much CPU time it can consume
* How much disk I/O it gets
* How many processes it may create

Docker creates cgroup rules like:

```
Container A
RAM <= 512 MB
CPU <= 1 core
```

The kernel continuously enforces these limits.

---

## CPU Reservation

Suppose:

* Machine = 8 CPUs
* Container A = 2 CPUs
* Container B = 1 CPU
* Container C = unlimited

Docker configures cgroups.

The Linux scheduler then decides:

```
CPU time
├─ A gets up to 2 CPUs
├─ B gets up to 1 CPU
└─ C gets the remaining time
```
---

## RAM Reservation

Example:

```bash
docker run --memory=1g ubuntu
```

Docker creates a memory cgroup.

Kernel tracks every page allocated by processes inside that container.

```
Container Memory Usage
Current: 700 MB
Limit:   1024 MB
```

If usage exceeds 1 GB:

* The kernel may refuse allocations.
* The kernel may invoke the OOM Killer.
* A process inside the container may be terminated.

---

## How does the kernel know which process belongs to which container?

Every container has a cgroup.

Example:

```
/sys/fs/cgroup/
    container_A/
        pid 100
        pid 101

    container_B/
        pid 200
        pid 201
```

When a process allocates memory or uses CPU:

1. Kernel sees PID.
2. Kernel checks its cgroup.
3. Kernel applies that cgroup's limits.

---

## Why are containers lightweight?

Because there is only **one kernel**.

A server running 100 containers still has:

```
1 Linux Kernel
100 isolated process groups
```

while 100 VMs would have:

```
100 kernels
100 operating systems
```

which requires much more RAM and CPU.

---

# 1. How does cgroup decide who gets RAM?

It doesn't decide.

This is the most common misunderstanding.

You decide.

Example:

```bash
docker run --memory=2g nginx
```

and

```bash
docker run --memory=1g mysql
```

You told Docker:

```text
nginx -> max 2 GB
mysql -> max 1 GB
```

Docker writes those limits into cgroups.

The kernel enforces them.

# 2. What if I don't specify a limit?

Example:

```bash
docker run nginx
```

Then:

```text
Container A
limit = host memory
```

The container can use as much RAM as available.

---

# 3. CPU limits are similar

Example:

```bash
docker run --cpus=2 nginx
```

means:

```text
Container can consume
up to 2 CPUs worth of time
```

Again:

Docker doesn't invent the number.

You configured it.

---

# DIAGRAM of how docker works...

```text
Docker CLI
    ↓
Docker Daemon
    ↓
containerd
    ↓
runc
    ↓
Linux Kernel
```

Let's follow a real command.

You type:

```bash
docker run nginx
```

---

### Step 1: Docker CLI

The `docker` command is only a client.

```bash
docker run nginx
```

It sends a request.

Think:

```text
"Please create a container."
```

---

### Step 2: Docker Daemon

The daemon (`dockerd`) receives the request.

```text
docker CLI
    ↓
dockerd
```

The daemon is the brain of Docker.

It:

* pulls images
* creates networks
* manages volumes
* starts containers

---

### Step 3: containerd

Docker tells containerd:

```text
Create a new container.
```

containerd is a container manager.

---

### Step 4: runc

containerd tells runc:

```text
Actually create the container.
```

runc is very small.

Its job:

* create namespaces
* create cgroups
* start the process

---

### Step 5: Linux Kernel

runc makes system calls like:

```c
clone()
unshare()
setns()
```

The kernel creates:

```text
PID namespace
Network namespace
Mount namespace
...
```

and starts the process.

After that runc exits.

The kernel continues running the container.

---

# About PID 1 inside containers

Excellent question.

On the host:

```text
PID 1 = systemd
```

or

```text
PID 1 = init
```

depending on the distro.

This is the real PID 1.

---

Inside a container:

Suppose you run:

```bash
docker run nginx
```

Inside the container:

```bash
ps aux
```

shows:

```text
PID 1 nginx
```

Why?

Because the container has its own PID namespace.

---

Host sees:

```text
PID 5421 nginx
```

Container sees:

```text
PID 1 nginx
```

Same process.

Different namespace.

---

Example:

```text
HOST
----
PID 1      systemd
PID 5421   nginx
PID 5422   worker

CONTAINER
---------
PID 1      nginx
PID 2      worker
```

The container cannot see the host PIDs.

---

# 7. Why does PID 1 keep the container alive?

Docker's rule is simple:

> If PID 1 exits, the container stops.

Example:

```bash
docker run ubuntu
```

Ubuntu starts.

No foreground process exists.

PID 1 exits.

Container stops immediately.

---

That's why in the Inception project you'll often see:

```dockerfile
CMD ["nginx", "-g", "daemon off;"]
```

or another command that run in the background to make sure the container still alive


<details>

<details>
<summary><b>What means SSL and Where is the SSL “layer”?</b></summary><br>

- Secure Sockets Layer (SSL) is not a physical layer.

It’s a software layer in the network stack, exactly in presentation layer

![image](images_readme/osi_layers.png)

![image](images_readme/OSI-Model-Layers-1.jpg)

---


# Why we install OpenSSL

→ generates SSL certificate (key + crt)
    OpenSSL is just setup tool

---

# What's the difference between SSL and TLS?

* Secure Sockets Layer (SSL) = **old, outdated, not secure anymore**
* Transport Layer Security (TLS) = **new, secure version of SSL**

**Same purpose:**

* encrypt data
* secure connection (like HTTPS)

**Difference:**

* SSL ❌ has security problems
* TLS ✅ fixes them and is used today

**In Inception:**

* When they say **“SSL”**, they actually mean **TLS**
* You will configure **TLS 1.2 or TLS 1.3** (not old SSL)

**TLS 1.2 / 1.3 = what?**

These are **versions of TLS**, like:

* TLS 1.0 ❌ (old)
* TLS 1.1 ❌
* TLS 1.2 ✅
* TLS 1.3 ✅ (best)

---

**What is TLS Handshake?**

🔐 First: TLS = HTTPS security
🔥 Handshake = first contact

When browser connects:

```c
Browser → NGINX: "I want secure connection"
NGINX → Browser: "Here is my certificate"
Browser → NGINX: "OK, I trust you"
```

After that:
connection becomes encrypted 🔒

Without this  ---> encrypted connection cannot start


<details>
<summary><b>About the dockerfile of nginx - and the lines we set to install the certificate</b></summary><br>

NGINX is commonly used as a **reverse proxy**.

## What is a proxy?

A proxy = middle server between:

* client
* another server

## 🔹 Reverse proxy meaning

Instead of client talking directly to backend:

```text id="r1"
Client → Backend
```

it becomes:

```text id="r2"
Client → NGINX → Backend
```

NGINX receives request first,
then forwards it to:

* PHP-FPM
* WordPress
* Node.js
* etc.

---


What we do here , to enables HTTPS (port 443)

`openssl req -x509 -nodes -days 365 \`

* **openssl** → tool for security (SSL certificates)
* **req** → create a certificate request
* **-x509** → make a self-signed certificate (not from a CA)
* **-nodes** → no password on the private key
* **-days 365** → certificate valid for 365 days

* **CA (Certificate Authority)**
  → A trusted company that gives certificates
  (like a “digital police” that says: this site is legit)
  Examples: Let’s Encrypt, DigiCert

* **req (request)**
  → Short for **certificate request (CSR)**
  → It’s like a form you create and send to a CA to ask for a certificate

* **no password on the private key (-nodes)**
  → Normally, your private key is protected with a password
  → With **-nodes**, it removes that protection


```c
-newkey rsa:2048 \
-keyout /etc/nginx/ssl/nginx.key \
-out /etc/nginx/ssl/nginx.crt \
-subj "/C=MA/ST=Casa/L=Casa/O=1337/OU=student/CN=localhost"
```


* **`-newkey rsa:2048`**
  → creates a **new private key + certificate** using RSA encryption (2048-bit = secure level)

* **`-keyout /etc/nginx/ssl/nginx.key`**
  → where to save the **private key file**

* **`-out /etc/nginx/ssl/nginx.crt`**
  → where to save the **certificate file**

* **`-subj "/C=MA/ST=Casa/L=Casa/O=1337/OU=student/CN=localhost"`**
  → info inside the certificate:

  * **C** = country (Morocco)
  * **ST** = state (Casablanca)
  * **L** = city
  * **O** = organization (1337)
  * **OU** = department (student)
  * **CN** = domain name (localhost → your local server)


in the end, we listens on port 443 , uses the certificate for HTTPS

- OpenSSL → creates certificate files
- NGINX → uses those files
- Browser → connects to NGINX on 443 (HTTPS)

---

**EXPOSE : 443**

```c
# EXPOSE does NOT publish or open any port.
# It is only metadata that documents which port the container listens on.
# Removing it does NOT affect the container or networking.
# Actual port mapping is handled by docker-compose (ports section).
EXPOSE 443
```
**`CMD ["nginx", "-g", "daemon off;"]`**

Start nginx in frontend required for Docker (otherwise container stops)

`-g`: allows you to pass a configuration rule to nginx at startup., (the rule  here is daemon off)

`daemon off:`  means “don’t run in background

</details>


</details>

<details>
<summary><b>Config File of Nginx</b></summary><br>

## server {}

This defines a virtual server

Meaning:

- one website config
- handles requests for a domain

## listen 443 ssl;

NGINX opens socket on:
- port 443
- expects HTTPS (SSL)

Internally:
- OS gives nginx port 443
- nginx waits for connections

## server_name localhost(or domain name);

When request comes:

Browser sends:

`Host: localhost`

NGINX:

- matches it with server_name

## SSL lines

```c
ssl_certificate ...
ssl_certificate_key ...
```
Internally:

- TLS handshake happens

nginx uses:

- private key
- certificate

1) `root /var/www/html` 

**What means root :**

- `root` is an Nginx directive that defines the base directory of the website.
- It is not related to Linux privileges.
- Nginx uses it to map a URL request to a file path by appending the request URI to that directory.

- The path : This tells Nginx -->  “All files I serve are located in this folder inside the container”

**Example**

User opens:

```
https://localhost/about.html
```

Nginx will look for:

```text
/var/www/html/about.html
```
Why `/var/www/html` specifically?

It’s just a **convention**, not magic

* Most web servers use it by default
* Official images (nginx, wordpress, php) expect this path

✔ You **can change it**, but:

* then you must make sure files exist there

2) `index index.php index.html;`

this files It comes from Nginx default config (by default )

When user accesses a folder like:

```
https://localhost/
```

Nginx will look for:

```text
1. index.php
2. index.html
```

first one found is used

**Example**

Request:

```
https://localhost/
```

Nginx tries:

```text
/var/www/html/index.php   ✔ (exists → used)
/var/www/html/index.html  (ignored)
```

##  location / ...

```js
    location / 
    {
        try_files $uri $uri/ /index.php?$args;
    }
```

1) location is a rule that matches a URL It tells Nginx:

> “If the request URL matches this pattern → apply these instructions”

`/` means:

match everything that starts with `/`

2) What is `try_files`?

> “Try these options in order, and use the first one that exists”

**Example :**

When a request comes:

```text
GET /something
```

Nginx will test:

**1️⃣ `$uri`**

exact file

Ex:

```text
/something → /var/www/html/something
```

✔ If file exists → serve it directly

**2️⃣ `$uri/`**

check if it’s a folder

Ex:

```text
/something → /var/www/html/something/
```

✔ If folder exists → serve it (maybe index inside)

**3️⃣ `/index.php?$args`**

we call it fallback, refers to a backup strategy or alternative route that takes effect when a primary method, system, or plan fails, It acts as a final safety net to maintain continuity and prevent total system failure or service

If nothing found:
➡ send request to:

```text
/index.php
```

with query parameters (`$args`)

**What is `$args`?**

query string from URL

Ex:

```text
?page=home&user=rida
```

So:

```text
/index.php?page=home&user=rida
```


##  location ~ \.php$....
```js 
    location ~ \.php$ {
        include fastcgi.conf;
        fastcgi_pass wordpress:9000;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
```

1) `location ~ \.php$`

Means Match all requests that end with .php

- `~` → regex (pattern matching)
- `\.php` → .php (escaped dot)
- `$` → end of string

✔ Matches:

```js
/index.php
/test.php
/blog/index.php
```

❌ Does NOT match:
```js
/index.php/test
/file.html
```
2) `include fastcgi.conf;`

fastcgi.conf already exists inside Nginx after installing, You did NOT create it manually.

This loads a predefined config file

What’s inside it?

Important things like:

```js
fastcgi_param QUERY_STRING $query_string;
fastcgi_param REQUEST_METHOD $request_method;
fastcgi_param CONTENT_TYPE $content_type;
```

* `QUERY_STRING` → sends URL part after `?` (GET data)
* `REQUEST_METHOD` → sends request type (GET / POST / etc.)
* `CONTENT_TYPE` → tells format of request body (ex: application/json ...)

- They just pass HTTP request info from NGINX to PHP-FPM.

Why needed?? --> Because: "PHP needs request info (GET, POST, headers, etc.)"

**means :**

- take GET or POST from HTTP request
- send it to PHP-FPM

3) `fastcgi_pass wordpress:9000;`

this line means Send this request to PHP-FPM server

- `wordpress` → Docker service name
- `9000` → port where PHP-FPM listens

In Docker:
```js
services:
  wordpress:
```
Docker creates internal DNS:

`wordpress → container IP`

So Nginx does:

`send PHP request → wordpress container → port 9000`

4) `fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;`

tells PHP which file to execute

- `$document_root` = value of `root /var/www/html;` -> /document_root = /var/www/html
- `$fastcgi_script_name` = requested file

Example -> `/index.php`

Combined:

```js
/var/www/html + /index.php
= /var/www/html/index.php 
```
This is sent to PHP:

> “execute THIS file”

</details>

<details>
<summary><b>What happened in every request - and what means fastcgi and php and php-fpm and scoket</b></summary><br>


# When a user opens your site:

```text
https://yourdomain.com/index.php
```

**behind the scenes**

```text
Client → NGINX → (FastCGI) → PHP-FPM → PHP → response → NGINX → Client
```

---

<details>
<summary><b>1. PHP</b></summary><br>

PHP is: A **programming language executed on the server**

Example:

```php
<?php echo "Hello"; ?>
```

- The browser **cannot understand PHP**
- It must be **executed first**, then returns HTML

**Who executes PHP?**

- PHP code is executed by: PHP-FPM (which uses the PHP engine)

- NGINX sends it via FastCGI to PHP-FPM
- PHP-FPM:
    - takes the file
    - runs it using PHP interpreter

- PHP interpreter = a program that reads and executes PHP code line by line

    - return result immediately
    - Interpreter allows this:
    - no compilation step
    - run instantly for each request

**Compare with compiled languages**

Example like C:

- compile first → create binary
- then run

❌ Not practical for web pages that change per request

</details>

<details>
<summary><b>2. Why NGINX cannot run PHP</b></summary><br>

NGINX is designed to:

* serve static files (HTML, CSS, images)
* handle HTTP requests

- It is **not built to execute code like PHP**

So when it sees:

```text
/index.php
```

It says:

> “I don’t know how to run this — I need another program”


</details>


<details>
<summary><b>3. FastCGI (the bridge)</b></summary><br>

FastCGI is: A **protocol (rules)** for communication between:

* web server (NGINX)
* application (PHP-FPM)

### What it does exactly:

Instead of:

* starting PHP every time ❌ (slow)

It:

* sends request to an already running PHP process ✅

- It passes:

    * file name (`index.php`)
    * request data (GET/POST)
    * headers


</details>


<details>
<summary><b>4. PHP-FPM (the engine)</b></summary><br>

PHP-FPM = **PHP runtime + process manager**

### What it really does:

- It runs **multiple PHP workers** (processes)

So instead of:

```text
1 request → start PHP → stop ❌
```

You get:

```text
many workers always running ✅
```

### Inside PHP-FPM:

* pool of workers
* each worker executes PHP scripts
* manages memory & performance

That’s why it's fast.

</details>

<details>
<summary><b>5. Socket</b></summary><br>

Socket = **a door between two programs**

Two ways to communicate:

### 1. Unix socket (file) 📁

```bash
/run/php/php-fpm.sock
```

* it’s a **file**
* used locally (same machine/container)


### 2. TCP socket 🌐

```text
wordpress:9000
```

* uses **IP + port**
* used between containers

</details>

<details>
<summary><b>6. Socket file</b></summary><br>

```bash
/run/php/php-fpm.sock
```

is:

- A **special file used for local communication**

### Why use it?

* faster than TCP
* no network stack
* secure (file permissions)

</details>

<details>
<summary><b>7. What actually happens step-by-step in every request</b></summary><br>

### 1. Client request

```text
GET /index.php
```

---

### 2. NGINX receives it

It checks config:

```nginx
location ~ \.php$ {
    fastcgi_pass unix:/run/php/php-fpm.sock;
}
```

It sees:

* “this is PHP”
* “send to PHP-FPM using FastCGI”

in our inception , we don't use the file because we are not in the same container each one seprated so they can't talk , instead of that we use the container of wordpress directly

- Same container → use file (.sock) 📁
- Different containers → use network (wordpress:9000) 🌐


**The file:**

`/run/php/php-fpm.sock`

is created automatically by: PHP-FPM

---

### 3. FastCGI request

NGINX sends:

* the full path to the PHP file inside the container (ex: `/var/www/html/index.php`)
* request data
* headers

- via socket

---

### 4. PHP-FPM receives it

* picks a free worker
* executes:

```php
index.php
```

---

### 5. PHP runs

Example:

```php
echo "Hello";
```

- returns:

```html
Hello
```

---

### 6. Response goes back

FastCGI is used again to send back:

- HTML content
- headers (like Content-Type)

- FastCGI is a bridge both ways

`NGINX ⇄ FastCGI ⇄ PHP-FPM`



</details>


### 🔹 What does FPM mean?

PHP-FPM : **FPM = FastCGI Process Manager**

---

### 🔹 What does that actually mean?

Break it:

* **FastCGI** → way to communicate with server
* **Process Manager** → manages multiple running PHP processes

So:

**PHP-FPM = a system that runs and manages PHP processes using FastCGI**

---

### 🔹 Relation with PHP

PHP alone:

❌ Cannot handle many requests efficiently
❌ No process management

- PHP-FPM adds:

* multiple workers (processes)
* better performance
* request handling


</details>

<details>
<summary><b>dockerfile and script of mariadb</b></summary><br>

# Dockerfile

`mariadb-server` : server here means,  program that runs in background and listens for requests

Example:

```js
WordPress → asks → database server → returns data
```

`chown -R mysql:mysql /run/mysqld`

* `chown` → change owner of files/folders
* `-R` → recursive (apply to all files inside folder)
* `mysql:mysql` →

  * first `mysql` = user
  * second `mysql` = group
* `/run/mysqld` → folder used by MariaDB at runtime

`/run/mysqld`

* `/run` → Linux directory for temporary runtime files (cleared on reboot)
* `/mysqld` → folder used by MariaDB

It is a runtime directory used by MariaDB while running.

It stores:

* **PID file** → identifies the running MariaDB process
* **socket file (`mysql.sock`)** → used for internal communication between applications and MariaDB

**That’s what the folder looks like**

- drwxr-xr-x 1 mysql mysql 4096 May  6 17:43 mysqld

(first mysql is user , second for group mysql)


- We use `mysql:mysql` so the **MariaDB process (running as `mysql` user)** has ownership of `/run/mysqld` and can:

* create the socket file (`mysqld.sock`)
* write the PID/runtime files
* start correctly without permission errors

❌ Without it: directory is usually root-owned → `mysql` user cannot write → server fails to start.

---

`mysqld --user=mysql --bind-address=0.0.0.0 &`

# mysqld → starts MariaDB server
# --user=mysql → runs as mysql user (not root), mysql user exists in container OS created during install of MariaDB package, 
# shortly means Run database process with limited privileges , If database runs as root and gets exploited: attacker gains full system access ,
# because we bind all ip addresses so anyone can reach the port can TRY to connect
# --bind-address=0.0.0.0 → accept connections from anywhere
# & → run in background

#give MariaDB time to start
`sleep 5`

```bash

`if ! mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "USE ${MYSQL_DATABASE};" 2>/dev/null; then`
    echo "Initializing database..."

    #Set root password, alter means change root password only for local root account (host =  only local machine (inside container db))
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" 
    
    #Create database
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE ${MYSQL_DATABASE};"

    #Create user, '%' = allow connection from anywhere
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

    #allow user to fully control the DB
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
fi
```

#stop temporary DB, (we need to restart it)
`mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown`

`exec mysqld --user=mysql --bind-address=0.0.0.0`
#exec runs MariaDB in foreground , because before we run it in background that why we stop it and run it in foregound

</details>

<details>
<summary><b>Dockerfile of wordpress</b></summary><br>

<details>
<summary><b>Dockerfile</b></summary><br>

`php-mysql` : is the bridge that lets PHP talk to the MariaDB database.

`php-fpm` : Runs and manages PHP code for NGINX using FastCGI.

Without it: ❌ NGINX cannot execute PHP.

`mariadb-client` : Command-line tool to connect to MariaDB server.

**Example:**

`mysql -u root -p`


`RUN sed -i 's|listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf`

- By default, PHP-FPM listens only on a local socket file:

```ini id="n1"
listen = /run/php/php-fpm.sock
```

This works only if:

* NGINX and PHP-FPM are in the same container/server.

In Inception:

* NGINX container ≠ WordPress/PHP-FPM container

So we change it to:

```ini id="n2"
listen = 0.0.0.0:9000
```

Meaning:

* PHP-FPM opens port `9000`
* accepts network connections from other containers
* NGINX can now connect using:

```nginx id="n3"
fastcgi_pass wordpress:9000;
```

### Structure of `sed`

```bash id="s1"
sed -i 's|old|new|' file
```

Meaning:

* `s` → substitute (replace)
* `old` → text to search
* `new` → replacement
* `-i` → Edit files in-place (overwrites the original file).

you can also add `g` means 

`g` → global , not Only the first match in the line changes, it change the whole file


</details>


</details>

<details>
<summary><b>Bonus</b></summary><br>

<details>
<summary><b>Redis</b></summary><br>

* **Redis** = in-memory database (stores data in RAM → very fast)


### Storage

* Data is stored **in RAM (instant)**
* Saving to disk is **NOT automatic**, it depends on config


### Persistence modes

1. **RAM only**

   * No disk save
   * Data lost if server stops ❌

2. **RDB (Snapshot)**

   * Saves data **periodically**
   * Possible small data loss

3. **AOF (Append Only File)**

   * Saves every operation
   * Safer (almost no data loss)


**to check what's type you used to save**

```bash
root@35023acc95ec:/# redis-cli
127.0.0.1:6379> CONFIG GET save
1) "save"
2) "3600 1 300 100 60 10000"
```

that means it store in RDB snapshot configuration.

**How to read it**

Format is:

```text id="r2"
save <seconds> <changes>
```

So your config means:

| Time     | Changes       | Meaning                         |
| -------- | ------------- | ------------------------------- |
| 3600 sec | 1 change      | save if ≥1 change in 1 hour     |
| 300 sec  | 100 changes   | save if ≥100 changes in 5 min   |
| 60 sec   | 10000 changes | save if ≥10000 changes in 1 min |



# Config file

### 🔹 `bind 0.0.0.0`

- Redis listens on **all network interfaces**

Meaning:

* other containers can connect
* not only localhost

---

### 🔹 `port 6379`

- Redis listens on port:

```text id="r1"
6379
```

This is Redis default port.

---

### 🔹 `protected-mode no`

By default Redis protects itself if exposed publicly.

Setting:

```ini id="r2"
protected-mode no
```

- disables that protection.

Why?

* because in Docker containers need to communicate
* otherwise external/container connections may be blocked

# What i added in wordpress dockerfile for redis

`php-redis` : is a PHP extension that allows PHP / WordPress to connect and communicate with Redis for caching data in memory (because php doesn't now redis so that the reason why we install it)

`redis-tools` : for command line interface (cli)

### Difference between mariadb-client and php-redis

### What is mariadb-client really?

It is just a **command-line tool**

Used for:

* testing DB manually
* running SQL inside containers
* scripts (like your entrypoint)

Example:

```bash id="sql1"
mysql -u user -p -h mariadb
```

That’s it.

---

## What about php-redis?

```text id="flow2"
WordPress (PHP)
   ↓
php-redis extension
   ↓
Redis server
```

- php-redis is NOT a server
- it is a **bridge inside PHP**



---

# Commands to test if redis work perfectly

```bash
root@35023acc95ec:/# redis-cli
127.0.0.1:6379> SET testkey "hello"
OK

to get it back

127.0.0.1:6379> GET testkey
"hello"
```

```bash
root@35023acc95ec:/# redis-cli PING
PONG
```


```bash
root@35023acc95ec:/# redis-cli monitor
and you will see here the cache
```
- prints every command it receives in real time

So when you refresh WordPress, you see things like:

```bash
GET
SET
EXPIRE
```
(It shows what PHP/WordPress is doing with Redis)

### 🔹 `SET`

Redis command:

Stores data in memory

Example:

```bash id="s1"
SET user "reda"
```

Means:

* key = `user`
* value = `reda`

---

### 🔹 `EXPIRE`

Sets a **time limit (TTL)** for a key

Example:

```bash id="s2"
EXPIRE user 60
```

Means:

* delete `user` after **60 seconds**

---

### 🔹 Why used together?

Example:

```bash id="s3"
SET session "abc123"
EXPIRE session 3600
```

session stored for 1 hour only

---

### 🔹 In WordPress context

WordPress uses this for:

* cache data
* sessions
* temporary objects



</details>


<details>
<summary><b>Adminer</b></summary><br>

**We set inside the adminer the creadintals of .env file**

the server name we means :

- Server = machine running the database

in our project :

- MariaDB container = database server


---

**How we can reach the webserver we run by php inside container of adminer**

In Adminer container:

```bash
php -S 0.0.0.0:8080
```

This means:

```text
“Start a web server listening on port 8080 inside the container”
```


**How NGINX connects to it**

In your NGINX config:

```nginx
proxy_pass http://adminer:8080/;
```

**What happens here**

1. NGINX sees request `/adminer`
2. It sends it to:

```text
adminer:8080
```

- “adminer” = container name
- “8080” = port where PHP server is listening

**Why this works**

Docker network gives:

```text
adminer → IP address of Adminer container
```

So internally:

```text
NGINX → (Docker network) → adminer:8080
```

---

```text
Browser (HTTPS 443)
   ↓
NGINX
   ↓ proxy_pass
Adminer container (php -S :8080)
   ↓
index.php (Adminer)
```


___

## Dockerfile

`CMD ["php", "-S", "0.0.0.0:8080"]` starts a **built-in PHP web server** inside the container.

* `php` → run PHP
* `-S` → start simple development web server
* `0.0.0.0` → listen on all network interfaces (so Docker/NGINX can access it)
* `8080` → port where Adminer is served


**php -S** Yes it *is* a “server”, but not the same type as NGINX.


**What it is**

```text id="t1"
php -S = built-in PHP development server
```

- it’s a server, but **very lightweight and limited**

---

**Difference vs NGINX**

| Feature          | NGINX                 | PHP -S             |
| ---------------- | --------------------- | ------------------ |
| Type             | Production web server | Development server |
| Speed            | High                  | Basic              |
| Routing          | Yes (advanced)        | No real routing    |
| HTTPS            | Yes                   | No                 |
| Use in Inception | Main entrypoint       | Internal tool      |




## config file of nginx-- what i added

`location /adminer/`
- If URL starts with /adminer/, handle it here

`proxy_pass http://adminer:8080/;`

Send request to Adminer container using Docker DNS name adminer

- ✔ adminer = container name
- ✔ 8080 = internal port

`proxy_set_header Host $host;`

Keep original domain

- tells the adminer the request come from rmaanane.42.fr”

Important for correct URL generation

`proxy_set_header X-Real-IP $remote_addr;`

- gives Adminer the real user IP

**Simplify it with example:**

You open:

```text
https://rmaanane.42.fr/adminer
```

Request goes like this:

```text
YOU → NGINX → Adminer
```

---

**Problem**

Adminer does NOT see you directly.

It only sees:

```text
request coming from NGINX
```

**So what we do?**

We tell NGINX:

> “when you send request to Adminer, also send info about the real user”


**the line we added with variables:**

```nginx
proxy_set_header Host $host;
```

means:

```text
Send the domain (rmaanane.42.fr) to Adminer
```

---

```nginx
proxy_set_header X-Real-IP $remote_addr;
```

means:

```text
Send user's IP to Adminer
```

**Where `$host` and `$remote_addr` come from?**

- NGINX gets them from your request automatically (You don’t create them).


</details>

<details>
<summary><b>Ftp</b></summary><br>

WordPress container ──────► /var/www/html ◄────── FTP container
         │                         │                      │
         └──────── wordpress_data (shared volume) ────────┘


**after finishing the setup we test with this:**

**step 0:** you need to install ftp , to connect with your localhost 

**step 1:** you need to create the file inside ur host 

**step 2:** upload the file

before upload the file you need to run

`sudo chown -R rmaanane:rmaanane /home/rmaanane/data/wordpress`

- Because host bind mounts use HOST filesystem permissions.

So if your FTP or Docker interacts with:

`/home/rmaanane/data`

Linux checks:

- who owns folder
- who can write

If owner is your user:

- ✔️ easier access
- ✔️ no permission problems

**then run this**

`curl -u rmaanane:password -T test.php ftp://rmaanane.42.fr/`

this upload file using ftp service (so the file now inside the shared file of wordpress)

* `curl` → send request tool
* `-u user:pass` → login to FTP
* `-T test.php` → upload this file
* `ftp://localhost/` → FTP server on your machine (port 21)


**Note:** You need to use file of php extension because txt doesn't work on nginx (block them by default)

**step 3:** access the file from the browser

**you can also use ftp tool to test**

```bash
➜  srcs git:(main) ✗ ftp localhost
Connected to localhost.
220 (vsFTPd 3.0.3)
Name (localhost:rmaanane): rmaanane
331 Please specify the password.
Password: 
```

----

## config file of ftp

`umask` = “automatic permission filter for new files”

When a file is created, Linux does:

```text id="u1"
final_permission = default_permission - umask
```

**Why it matters**

Because files are NOT created manually with `chmod`.

They are created by:

* FTP upload
* PHP (WordPress)
* system processes
* scripts

**Example without umask control**

FTP uploads file → system default applies:

```text id="u2"
666 - 077 = 600
```

Result:

```text id="u3"
rw------- ❌ (website breaks)
```

---

**Example with `umask=022`**

```text id="u4"
666 - 022 = 644 ✔
```

Result:

```text id="u5"
rw-r--r-- ✔ (website works)
```

---

## Dockerfile

```bash id="u1"
RUN useradd -m -d /var/www/html -s /bin/bash rmaanane && \
    echo "rmaanane:password" | chpasswd
```

1. `useradd -m -d /var/www/html -s /bin/bash rmaanane`

creates a user:**

* `rmaanane` → username
* `-m` → create home folder
* `-d /var/www/html` → home is WordPress folder
* `-s /bin/bash` → allow login shell

**why we used the shell**

- allows normal login ✔
- user can execute commands ✔
- avoids login issues ✔

---

2. `echo "rmaanane:password" | chpasswd`

sets password:

* user = rmaanane
* password = password

---

## docker compose

- **port 21** to connect with ftp in terminal
- **ports 21000-21010** are used for file transfer , 11 ports randomly is enough , bcs if we need to open multiple tabs or upload multiple files

**LEFT** : your machine (host)

**RIGHT**: container (FTP server)

- host ports → container ports

1. What if `/var/www/html` doesn’t exist?

- Docker will **create it automatically** inside the container ✔

BUT in your case:

```yaml
volumes:
  - wordpress_data:/var/www/html
```

this volume is **shared with WordPress**

So:

```text
WordPress creates files → FTP sees them
FTP uploads files → WordPress sees them
```

2. Which container runs first?

By default:

```text
Docker Compose does NOT guarantee order ❌
```

Containers start **almost at the same time**

**Important**

This does NOT matter for FTP

Because:

```text
FTP does NOT depend on WordPress ❌
it only uses the volume ✔
```

3. What if WordPress is not ready yet?

No problem:

* volume exists ✔
* folder exists ✔
* FTP still runs ✔

Later:

```text
WordPress fills the folder
```


</details>

</details>



