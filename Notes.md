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

___

**Difference between CMD and ENTRYPOINT**

cmd to run commands, and entrypoint to run scripts

</details>

<details>
<summary><b>Docker-Compose</b></summary><br>

Docker Compose is a tool that lets you define and run multi-container applications using a single configuration file.

Instead of manually starting containers one by one with Docker commands, you describe everything in a YAML file (usually called docker-compose.yml) and then bring it all up together with one command.

### Services

This is where you define your containers (apps), Each one = 1 container:

- nginx
- wordpress
- mariadb

### Services

</details>