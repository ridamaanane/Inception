</details>

<details>
<summary><b>Why not virtual machine and why docker ?</b></summary><br>

![image](images/image.png)

</details>

<details>
<summary><b>What is docker and container and image</b></summary><br>

![image](images/image1.png)

A **Docker container** is a small, isolated environment that contains an application and all its dependencies, so it can run the same way on any system.

- **Container** = running app

A container is very similar to a process, but more powerful.

`Simple explanation:`
- A process = a running program on your system
- A container = an isolated process with its own environment

A **Docker image** is a read-only template (blueprint) that contains an application along with all its dependencies, such as code, runtime, libraries, and configuration, while a Docker container is a running instance of that image, providing a small and isolated environment where the application runs consistently on any system.

</details>

<details>
<summary><b>Virtualisation and hypervior</b></summary><br>

![alt text](images/image56.png)


# Virtualisation vs Containerization

![alt text](images/image546.png)

</details>

<details>
<summary><b>Client - Registry - Namespace - Daemon</b></summary><br>

### Docker Client: 
the tool (command line) you use to interact with Docker, like running commands to build or start containers.

### Docker Registry: 
a storage place where Docker images are saved and shared, like Docker Hub, is a storage system (usually remote) where Docker images are saved and shared.

**Docker Registry** is **not local by default**.

* It is a **remote storage** (on the internet) 
* Used to **save and share images**

example : **Docker Hub** a public registry.

But You can also have a **local registry** on your machine if you want

### Namespaces: 
a Linux feature used by Docker to isolate containers, so each container has its own separate view of resources like processes, network, and files, making them independent from each other.


### Docker Daemon** 
(dockerd) is the **core engine of Docker**.

**What it does:**

* Builds images 🧱
* Runs containers 🚀
* Stops / deletes containers
* Manages networks and volumes

**How it works:**

You type a command (like `docker run`) in the **Docker Client** →
the request goes to the **Docker Daemon** →
the daemon executes it.

</details>

<details>
<summary><b>Docker Commands</b></summary><br>

**To see all informations about your docker**

`docker info`

**To install image**

`docker run "name of image yo want to install"`

(If the image exists on your machine, Docker uses it directly; if not, it automatically pulls it from Docker Hub)

**Create and start a container**

`docker run -d -p 80:80 nginx` this is just example for nginx p 80:80

`-d` (detach) : run the container in the background
✔️ so your terminal stays free
❌ without it → the terminal gets “blocked”


`-p` 80:80 : connect ports
first 80 = your machine
second 80 = container


**NOTE :** once the container starts, `RUN` is no longer used

Why?

Because RUN is only for building the image, not running it, that's why we used scripts in runtime to install the rest of instructions

**To see containers you running on docker**

`docker ps -all`

or 

`docker container ls`

**To see containers running and stopped**

`docker ps -a`

**To remove container**

`docker rm "id of container"`

**To see images**

`docker images`

**To remove images**

`docker image rm "name of image or ID"`

**To shows the output of the container (what the app prints)**
(ex: errors, messages, print statements)

`docker logs` (name of app)

**To shows live resource usage of containers (CPU, memory, network)**

`docker stats`

___

**To run a command inside a running container**

`docker exec`

`docker exec -it n1 bash` (this well run bash inside image of ngninx name of it is n1)

`-i` → keep input open
`-t` → gives a terminal (TTY) 

**To build docker compose**

`docker-compose up --build` : tool that reads your docker-compose.yml

`up` : start everything
`--build` : rebuild images before starting
means:
- read Dockerfiles again
- build fresh images
- then start containers

It understands:
- services (nginx, wordpress, mariadb)
- networks
- volumes
- build paths

**This is the full idea**

`[docker-compose reads file → builds images → creates containers → connects everything → runs system]`

**Run container without dependencies in dockerfile**

`sudo docker compose up --no-deps nginx`

**To Stops and removes containers and Volumes:

`docker compose down -v`

`down` : shuts everything down 
`-v` : Removes volumes

It does NOT remove images by default — the Docker images themselves remain cached locally.

___

**Difference between CMD and ENTRYPOINT**

cmd to run commands, and entrypoint to run scripts

___

**If you debbuging something and you need to see if container running you can run this**

`docker inspect my_container`

and look for this

```c
"State": {
  "Running": true
}
```

___

`docker compose up -d`

* **Purpose:** Start containers in detached (background) mode.
* **Behavior:**

  1. Checks if the container exists:

     * If yes → starts it.
     * If no → creates and starts it.
  2. Uses **existing images** unless `build:` says otherwise and the image doesn’t exist.
* **Does not rebuild images** automatically.
* **Good for:** Just starting your app when images are already built/pulled.

This command Fast because:

- It does not rebuild images.
- It does not reinstall anything inside the container; it just starts containers from existing images.

Think of it as “turning on a machine that’s already built.”

If the image already exists (pulled or built previously), it just creates and starts the container. That’s why it’s almost instant.
Result: You get running containers quickly, but any changes in Dockerfile or dependencies are ignored.


**Key difference in simple terms between it and the prev cmd**

| Command                     | Rebuild images? | Run containers in background?   |
| --------------------------- | --------------- | ------------------------------- |
| `docker compose up -d`      | ❌ No            | ✅ Yes                           |
| `docker compose up --build` | ✅ Yes           | ❌ By default, unless `-d` added |

`docker compose up -d`

- starts containers in detached mode
- uses existing images if available
- does NOT rebuild Dockerfiles automatically

`docker compose up --build -d`

- rebuilds images from the Dockerfiles first
- then starts containers in detached mode
- useful when you changed Dockerfile or source code used in the image


**Important note for WordPress + MariaDB**:

* If your `.env` changes (like DB credentials) but volumes already exist, **rebuilding the image won’t change the database**.
* To reapply `.env` to MariaDB, you need to **remove the old volume** (`docker compose down -v`) before starting.


___

**To see exactly where is the problem of container**

`docker compose logs adminer`

**example :** adminer  | 2026/04/22 20:05:43 [emerg] 1#1: host not found in upstream "wordpress" in /etc/nginx/sites-enabled/adminer:22


___

**volumes:**

for example mariadb :

```c
  mariadb_data: # volume name
    driver_opts: #don’t use default storage, I want custom behavior
      type: none #no special filesystem , just use a normal directory
      device: /home/rmaanane/data/mariadb #store the data here on the HOST
      o: bind #connect this folder directly to Docker, means (use my folder, not yours, that why it stores in my path)
```

</details>

<details>
<summary><b>How to build your Own Docker-Compose</b></summary><br>

Docker Compose is a tool that lets you define and run multi-container applications using a single configuration file.

Instead of manually starting containers one by one with Docker commands, you describe everything in a YAML file (usually called docker-compose.yml) and then bring it all up together with one command.

## services:

This is where you define your containers (apps), Each one = 1 container:

- nginx
- wordpress
- mariadb

## build:

It tells Docker Compose “don’t use a pre-made image, build it yourself from a Dockerfile.

When we pass a path that means ,Go to the folder and Find a Dockerfile and Build an image from it, Then run a container from that image

- If you use Docker Hub image you chose image directly from Docker Hub without build.

## container_name:

this only helps for fixing names for containes, If you removed Docker gives random name like srcs-nginx-1, (Not required but useful).

## depends_on:

start order only , example: nginx waits wordpress to start, does NOT wait for the container to be ready , It only waits for container to start (process is running)

- if you removed containers may start in wrong order → errors at startup
- It does NOT “go back and wait until ready", It only checks: is container running? yes/no

## volumes:

A volume is storage that lives outside the container. It lets data persist even if the container is deleted

Why we use it:
- WordPress files stay even if container is deleted
- MariaDB keeps database safe

If removed: everything resets every restart

**Example :**

```c
    volumes:
      - wordpress_data:/var/www/html
```
now we talk to the second line

It has 2 parts:
wordpress_data (LEFT side)

This is the volume name, like “storage box name”

- It’s just a label to Creat and manage by Docker and Stores data permanently
- Can be reused by other containers

/var/www/html (RIGHT side)

- This is the path inside the container
- This is where the app stores files (WordPress files, uploads, themes)

## networks:

- all containers can talk to each other, (inside container CONNECTS container to that network)
- We write network twice (in bottom part) to CREATES the network.

Example:
```
nginx → wordpress
wordpress → mariadb
```

- If you removed:  containers cannot connect → project breaks.

- If you remove bottom part Docker will: either auto-create it , OR give error (depending config)


`- inception` vs `inception:`

**🔹 Inside service:**

```yaml
networks:
  - inception
```

This is a **list (array)**
Means:

* this container connects to **one or more networks**

Example:

```yaml
networks:
  - inception
  - another_network
```
**🔹 Bottom:**

```yaml
networks:
  inception:
```

This is a **definition (object/dictionary)**
Means:

* create a network named `inception`

You can also configure it:

```yaml
networks:
  inception:
    driver: bridge (if you use it inside this project the containers still works)
```
- bridge → internal communication (containers)
- ports → external access (browser)


**If you mix them wrong:**

❌ this is WRONG:

```yaml
networks:
  inception
```

## env_file:

We use it to loads variables from file

- we can also write variables in docker-compose directly

but inside the file :

- ✔ clean
- ✔ secure (passwords not in compose)
- ✔ used in 42 subject

</details>

<details>
<summary><b>How to write Dockerfile</b></summary><br>

Dockerfile It’s just a set of instructions to build an image.

Choose a base image (FROM)

You always start with **FROM**

Before your app runs, it needs:

- system (Linux)
- tools (Node, Python, gcc…)
- libraries (dependencies)
- your code


<details>
<summary><b>Some infos</b></summary><br>

**Every image already has a minimal OS (like Ubuntu, Alpine) , What means that ???:**

Example 

`FROM node:18`

You are NOT starting from nothing.

Inside node:18 there is already:

- a Linux OS (usually Debian)
- Node.js installed
- basic system tools

**What is a “minimal OS”?**

It’s just a very small Linux system without extra stuff.

Examples:

Ubuntu (big)
- full OS, many tools ,heavier

Alpine (small)
- super lightweight, only essentials ,faster

**How capacity works**

Docker uses something called:  **layers**

Example :
```
FROM debian:bookworm
RUN apt update
RUN apt install -y curl
```

Each step creates a layer:

- Layer 1 → Debian OS
- Layer 2 → apt update
- Layer 3 → curl installed

if you don't manage the layers with minimalizing method , that can give you this problems

- bigger image size
- more layers to manage
- slower image pull (download)
- less efficient caching

</details>

</details>

<details>
<summary><b>Script of wordpress</b></summary><br>

`until mysql -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT VERSION();" > /dev/null 2>&1; do`

`until ... do`
-  repeat until command works

while NOT condition → keep looping

if everything okey (condition become true), we done

`"SELECT VERSION();"` : this show the version of DB if it's work so the DB installed correctly

_______

`wp core download`

This means:

“Download the WordPress core files”

What it actually does:

It downloads:

WordPress PHP files
folders like:

```c
wp-admin/
wp-includes/
wp-content/
```
basically: full WordPress system
_______

`--allow-root`

WordPress blocks root user by default

**BUT in Docker:**

- everything runs as root inside container, So we must allow it.

_______

we creates file with : `wp config create` using values we passed

name of file : `wp-config.php`


**How?**

It generates a PHP config file like:

```c
define('DB_NAME', ...);
define('DB_USER', ...);
define('DB_PASSWORD', ...);
```

we need --dbhost=mariadb:3306 , to tells WordPress:

```c
DB host = mariadb container
port = 3306
```

_______

`wp core install`

> means : “Initialize WordPress inside the database and create the admin site”

**Step-by-step what happens**

#### 1- Connects to database

It reads `wp-config.php`:

* DB name
* user
* password
* host

connects to MariaDB

---

#### 2- Creates database structure

It creates tables like:

* `wp_users`
* `wp_posts`
* `wp_options`
* `wp_comments`

now WordPress has storage

---

#### 3- three: Sets your website URL

```bash id="u2k8m1"
--url="$DOMAIN_NAME"
```

This defines:

* your site address

Example:

```text id="x9d3p7"
https://localhost
http://mywebsite.com
```

WordPress uses it for:

* links
* redirects
* admin panel URL

---

#### 4- Sets website title

```bash id="v4n6q8"
--title="inception"
```

This is your site name:

* shown in browser tab
* WordPress dashboard title

---

#### 5- Creates admin user

```bash id="c7r2t5"
--admin_user="$WP_ADMIN"
```

creates the main login account

Example:

```text id="m8k1z3"
username: admin
```

---

#### 6- Sets admin password

```bash id="p0x9h4"
--admin_password="$WP_ADMIN_PASSWORD"
```

password for admin login

---

#### 7- Sets admin email

```bash id="n3s7w2"
--admin_email="$WP_ADMIN_EMAIL"
```

used for:

* recovery
* notifications
* WordPress alerts

---

#### 8- `--allow-root`

allows running as root inside container

Without it:
:x: WP-CLI refuses to run

_______

`mkdir -p /run/php`

This folder is used by PHP-FPM to store its socket file.

* Folder for **PHP-FPM socket file**
* Example: `/run/php/php8.2-fpm.sock`

Used for communication between **Nginx** and PHP

**Why create it?**

* `/run` is temporary (may not exist in Docker)
* If missing ❌ → PHP-FPM won’t start

_______

`exec php-fpm8.2 -F`

`exec` replaces the current process with another process

Instead of:

`bash (shell) → runs php-fpm`

exec does:

`bash is replaced by php-fpm`

`-F` : run in foreground

**What is the “main process”?**

In a container:

```c
PID 1 = main process
If PID 1 stops → container stops
```

**without exec?**

If you do directly:

php-fpm8.2 -F

```c
shell stays as PID 1
php-fpm becomes a child process
```


**NOTE :**  Order of installing wp matters

- WordPress CLI commands depend on previous steps being completed.

Think of it like a chain:

```c
download → config → install
Each step prepares something needed for the next.
```

(**if you remove it , the containers works but setuping of the website doesn't finish of setuping the wordpress**)

</details>


<details>
<summary><b>.env file</b></summary><br>

### `.env` + `$VARIABLE`

* `.env` is a file that stores key-value pairs (e.g. `MYSQL_USER=admin`).
* Docker Compose reads `.env` using `env_file` and injects them into containers as **environment variables**.
* Inside containers, variables are accessed using `$VARIABLE` (e.g. `$MYSQL_USER`).
* The script does NOT read `.env` directly — it reads values from the container environment.
* Flow: `.env → docker-compose → environment variables → `$VARIABLE` in scripts`.

`$VAR` means “replace with the value stored in environment”.



### 1. How variables are set in the OS (Linux)

In Linux, environment variables are stored inside a process using something like:

```c id="a1"
key=value
```

Example:

```bash id="a2"
export MYSQL_USER=admin
```

This tells the OS:

* “attach this variable to the current process”


#### 2. What Docker does AFTER docker-compose

When you run:

```bash id="a5"
docker compose up
```

___

#### Step 1: Compose reads config

* reads `docker-compose.yml`
* reads `.env`


#### Step 2: Docker Engine creates container

Docker creates a **Linux process (container)** using:

* namespaces (isolation)
* cgroups (resources)


#### Step 3: Docker sets environment (IMPORTANT PART)

Before starting your script, Docker calls something like:

```c id="a6"
setenv("MYSQL_USER", "admin");
setenv("MYSQL_PASSWORD", "1234");
```

This is OS-level injection



#### Step 4: container process starts

Now Docker starts your entry process:

```bash id="a7"
bash script.sh
```

#### Step 5: Bash reads environment

Inside bash:

```bash id="a8"
echo $MYSQL_USER
```

OS replaces it from process memory


#### FULL FLOW

```text id="flow"
.env file
   ↓
docker compose reads it
   ↓
Docker Engine creates Linux container (process)
   ↓
Docker sets environment variables in process memory
   ↓
bash starts inside container
   ↓
$VAR is resolved from OS environment table
```


</details>
