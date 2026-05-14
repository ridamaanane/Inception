# Developer Documentation

## Setting Up the Environment from Scratch

### Prerequisites
- **Operating System**: Linux/Unix environment (Ubuntu/Debian recommended)
- **Domain Configuration**: Add `127.0.0.1 rmaanane.42.fr` to `/etc/hosts`
- **Permissions**: Sudo access for hosts file modification and chown command

### Configuration Files
- **`.env` file**: Contains all environment variables and credentials
  - Database configuration (MYSQL_* variables)
  - WordPress credentials (WP_* variables)
  - Domain settings (DOMAIN_NAME)
  - FTP credentials (FTP_* variables)

- **Docker Compose**: `srcs/docker-compose.yml`
  - Defines and manages all project services, networks, and volumes

- **NGINX Configuration**: `srcs/requirements/nginx/conf/nginx.conf`
  - Configures HTTPS, reverse proxy, and website routing

- **WordPress**: `srcs/requirements/wordpress/`
  - Main CMS used to host the website and manage content

- **MariaDB**: `srcs/requirements/mariadb/`
  - Database service used by WordPress to store all data

- **Adminer**: `srcs/requirements/bonus/adminer/`
  - Web interface used to manage the MariaDB database

- **Static Website**: `srcs/requirements/bonus/static-website/`
  - Simple website served by NGINX without PHP or database

- **FTP Configuration**: `srcs/requirements/bonus/ftp/conf/vsftpd.conf`
  - Configures the FTP server and user access permissions

- **Redis**: `srcs/requirements/bonus/redis/`
  - Provides caching for WordPress to improve performance

- **Backup Service**: `srcs/requirements/bonus/backup-db/`
  - Automatically creates backups of the MariaDB database

### Secrets
- All sensitive data is stored in the `.env` file
- The `.env` file should never be committed to version control
- Docker loads these variables at runtime
- No credentials are hardcoded in Dockerfiles or scripts

## Building and Launching the Project

### Using Makefile
```bash
# Complete setup (recommended for first run)
make all

# Individual steps
make update_hosts   # Update /etc/hosts file
make setup          # Create data directories
make setup2         # Set permission for wordpress folder
make build          # Build and start containers
make up             # Start services
make down           # Stop services
make restart        # Restart all services
make logs           # View container logs
make status         # Show container status
make clean          # Stop and remove containers
make fclean         # Full cleanup including data
```

### Using Docker Compose Directly
```bash
# Navigate to srcs directory
cd srcs

# Build and start all services
docker compose up --build -d

# View running containers
docker compose ps

# View logs
docker compose logs -f

# Stop services
docker compose down

# Stop and remove volumes
docker compose down -v
```

## Managing Containers and Volumes

### Container Management Commands
```bash
# List all containers
docker compose ps

# View container logs
docker compose logs [service_name]
docker compose logs -f [service_name]  # Follow logs

# Execute commands in running containers
docker compose exec wordpress bash
docker compose exec mariadb mysql -u MYSQL_USER -p

Note: Replace MYSQL_USER with the user defined in the .env file, and also use the corresponding password from the .env file.

# Restart specific service
docker compose restart nginx

# Rebuild specific service
docker compose up --build wordpress
```

### Volume Management
```bash
# List all volumes
docker volume ls

# Inspect volume details
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data

# View volume contents (bind mounts)
ls -la /home/rmaanane/data/mariadb/
ls -la /home/rmaanane/data/wordpress/

# Remove specific volume
docker volume rm inception_mariadb_data

# Remove all unused volumes
docker volume prune
```

### Network Management
```bash
# List networks
docker network ls

# Inspect network
docker network inspect inception
```

## Project Data Storage and Persistence

### Data Locations
- **MariaDB Data**: `/home/rmaanane/data/mariadb/` (bind mount)
  - Contains database files, tables, and user data
  - Persists across container restarts and recreations
- **WordPress Data**: `/home/rmaanane/data/wordpress/` (bind mount)
  - Contains WordPress core files, themes, plugins, uploads
  - Shared between nginx, wordpress, and ftp containers

### Data Persistence Mechanism
- **Bind Mounts**: Direct host filesystem access for MariaDB and WordPress
  Advantages: 
      - You can see files directly on your host
      - Easy to debug
      - Easy manual backup
      - Real-time sync between host and container
  Disadvantages: 
      - Depends on your machine paths
      - Not portable (won't work the same on another PC)
      - Breaks isolation (bad practice in production)
      - Can cause permission issues

---

## Core Services Configuration

### Overview
The three core services — NGINX, WordPress, and MariaDB — form the backbone of the project. They are mandatory and must all be running for the website to work. Each runs in its own Docker container and communicates over the internal `inception` Docker network.

### Core Services

#### 1. **NGINX** (Web Server / Reverse Proxy)
- **Purpose**: Entry point for all incoming traffic. Handles HTTPS termination and forwards requests to WordPress via FastCGI.
- **Port**: `443` (HTTPS only — HTTP on port 80 is not exposed)
- **URL**: `https://rmaanane.42.fr`
- **Configuration File**: `srcs/requirements/nginx/conf/nginx.conf`
- **TLS**: Uses a self-signed SSL certificate stored inside the container (generated at build time). The certificate covers the domain `rmaanane.42.fr`.
- **How it works**:
  - Listens on port `443` with TLSv1.2 / TLSv1.3
  - Passes `.php` requests to the WordPress container over FastCGI (port `9000`)
  - Serves static WordPress files directly from the shared volume
- **Connecting / Testing**:
  ```bash
  # Check NGINX is running
  docker compose ps nginx

  # View live access logs
  docker compose logs -f nginx

  # Open a shell inside the container
  docker compose exec nginx sh

  # Test config syntax (inside the container)
  nginx -t

    you should see something like that:

      nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
      nginx: configuration file /etc/nginx/nginx.conf test is successful
  ```

- **Troubleshooting**:
  ```bash
  # Certificate or TLS errors → verify cert was generated during build
  docker compose exec nginx ls /etc/nginx/ssl/

  # 502 Bad Gateway → WordPress container is not reachable
  docker compose ps wordpress
  docker compose logs wordpress
  ```

---

#### 2. **WordPress** (Content Management System / PHP Application)
- **Purpose**: Content management system that powers the website. Runs PHP-FPM and listens for FastCGI connections from NGINX.
- **Port**: `9000` (FastCGI — internal only, not exposed to the host)
- **URL**: `https://rmaanane.42.fr` (accessed through NGINX)
- **Files Location**: `/home/rmaanane/data/wordpress/` (bind-mounted into the container)
- **Configuration**: `wp-config.php` is generated automatically at container startup using environment variables from `.env`
- **Environment Variables** (from `.env`):
  - `MYSQL_DATABASE`: Database name WordPress connects to
  - `MYSQL_USER`: Database user
  - `MYSQL_PASSWORD`: Database user password
  - `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD` / `WP_ADMIN_EMAIL`: WordPress admin credentials
  - `WP_USER` / `WP_USER_PASSWORD` / `WP_USER_EMAIL`: Additional WordPress user
  - `DOMAIN_NAME`: The domain used for the WordPress site URL
- **Setup Script**: `srcs/requirements/wordpress/tools/script.sh`
  - Waits for MariaDB to be ready
  - Downloads and configures WordPress core using `wp-cli`
  - Creates the admin and regular user accounts
  - Installs and activates the Redis cache plugin
- **Connecting / Managing**:
  ```bash
  # Open a shell inside the WordPress container
  docker compose exec wordpress bash

  # Run WP-CLI commands
  docker compose exec wordpress wp --allow-root plugin list
  docker compose exec wordpress wp --allow-root user list
  docker compose exec wordpress wp --allow-root cache flush

  # View WordPress logs (PHP-FPM errors)
  docker compose logs -f wordpress
  ```
- **Troubleshooting**:
  ```bash
  # White screen / PHP errors → check PHP-FPM logs
  docker compose logs wordpress

  # Cannot connect to database → verify MariaDB is up and .env credentials match
  docker compose ps mariadb

  # WordPress files missing → check bind mount
  ls -la /home/rmaanane/data/wordpress/
  ```

---

#### 3. **MariaDB** (Database)
- **Purpose**: Relational database that stores all WordPress content (posts, users, settings, etc.).
- **Port**: `3306` (internal only — not exposed to the host)
- **Data Location**: `/home/rmaanane/data/mariadb/` (bind-mounted into the container)
- **Environment Variables** (from `.env`):
  - `MYSQL_ROOT_PASSWORD`: Root password for MariaDB
  - `MYSQL_DATABASE`: Database created at startup for WordPress
  - `MYSQL_USER`: Non-root user granted access to the WordPress database
  - `MYSQL_PASSWORD`: Password for the non-root user
- **Setup Script**: `srcs/requirements/mariadb/tools/script.sh`
  - Initialises the database if it does not already exist
  - Creates the WordPress database and user
  - Sets root password and flushes privileges
- **Connecting to the Database**:
  ```bash
  # Connect as the WordPress user
  docker compose exec mariadb mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"

  # Connect as root
  docker compose exec mariadb mysql -u root -p"$MYSQL_ROOT_PASSWORD"

  # Useful SQL commands once connected:
  SHOW DATABASES;
  USE wordpress;
  SHOW TABLES;
  SELECT user, host FROM mysql.user;
  ```
- **Monitoring**:
  ```bash
  # View database logs
  docker compose logs -f mariadb

  # Check MariaDB is listening
  docker compose exec mariadb mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" status
  ```
- **Troubleshooting**:
  ```bash
  # Container exits immediately → check startup logs for permission/init errors
  docker compose logs mariadb

  # WordPress cannot reach MariaDB → confirm both containers are on the inception network
  docker network inspect inception

  # Data directory permission issues → ensure host directory is owned by the correct UID
  ls -la /home/rmaanane/data/mariadb/
  ```

---

## Bonus Services Configuration

### Overview
The project includes optional bonus services that extend core functionality. All bonus services are defined in `srcs/requirements/bonus/` and can be enabled or disabled via Docker Compose configuration.

### Bonus Services

#### 1. **Adminer** (Database Management UI)
- **Purpose**: Web-based interface for managing MariaDB database
- **Port**: `8080`
- **URL**: `https://rmaanane.42.fr/adminer`
- **Access**: Login with MariaDB credentials from `.env` file
- **Use Cases**:
  - Browse and manage database tables
  - Execute SQL queries
  - Create/drop databases
  - View user access logs
- **Configuration**: Runs in standalone container, no additional config needed

#### 2. **FTP Service** (File Transfer Protocol)
- **Purpose**: Secure file upload/download for WordPress files
- **Port**: `21` (standard FTP)
- **Configuration File**: `srcs/requirements/bonus/ftp/conf/vsftpd.conf`
- **Environment Variables** (from `.env`):
  - `FTP_USER`: FTP account username
  - `FTP_PASSWORD`: FTP account password
- **Setup Script**: `srcs/requirements/bonus/ftp/tools/script.sh`
  - Creates FTP user
  - Sets permissions for `/home/rmaanane/data/wordpress/`
  - Configures vsftpd service
- **Connecting via FTP**:
  ```bash
  ftp rmaanane.42.fr
  # Enter FTP_USER and FTP_PASSWORD from .env
  # Upload/download WordPress files directly
  ```

#### 3. **Redis** (Caching System)
- **Purpose**: In-memory cache to improve WordPress performance
- **Port**: `6379`
- **Integration**: WordPress container configured to connect and use Redis
- **Benefits**:
  - Faster page load times
  - Reduced database queries
  - Session caching
- **Dockerfile**: `srcs/requirements/bonus/redis/Dockerfile`
- **Configuration**: Uses default Redis settings optimized for WordPress
- **Monitoring**:
  ```bash
  docker compose exec redis redis-cli
  # Common commands:
  # PING - verify connection
  # KEYS * - list cached keys
  # FLUSHALL - clear all cache
  # MONITOR - displays all Redis commands in real time as they are executed (live stream of operations)
  ```

#### 4. **Backup Service** (Database Backup Automation)

- **Purpose**: Automatically backs up the MariaDB databases every 5 minutes using `mysqldump` and cron jobs.
- **Backup Location**: Backup files are stored inside the `backup-db` directory in the container with the filename `alldb.sql`.
- **Backup Script**: `srcs/requirements/bonus/backup-db/tools/backup.sh`

- **Features**:
  - Automatic scheduled backups using cron
  - Database backup using `mysqldump`
  - Uses the Docker network to connect to the MariaDB service

  ```bash
  # Restore a backup

  # 1. Copy the backup file from the container to the host
  docker cp backup-db:/backup-db/alldb.sql .

  # 2. Restore the backup into MariaDB
  docker compose exec -T mariadb mysql -u MYSQL_USER -pMYSQL_PASSWORD MYSQL_DATABASE < alldb.sql


#### 5. **Static Website** (Additional Web Content)
- **Purpose**: Serve static HTML/CSS website alongside WordPress
- **Port**: Served via NGINX on port `443`
- **Route**: Configure in `srcs/requirements/nginx/conf/nginx.conf`
- **Files**: `srcs/requirements/bonus/static-website/tools/`
  - `index.html`: Main page content
  - `style.css`: Styling
- **Use Cases**:
  - Host documentation
  - Landing pages
  - Simple informational websites
  - Separate from WordPress

### Enabling/Disabling Bonus Services

#### Enable All Bonus Services
1. Ensure Docker Compose includes all bonus services in `srcs/docker-compose.yml`
2. Build and start all services:
   ```bash
   docker compose up --build -d
   ```

#### Disable Specific Bonus Services
1. Comment out unwanted services in `srcs/docker-compose.yml`
2. Rebuild:
   ```bash
   docker compose up --build -d
   ```

---

## Development Workflow

### Modifying Services
1. Edit Dockerfile or configuration files
2. Rebuild affected services: `docker compose up --build [service]`
3. Test changes
4. Commit configuration changes

## Debugging
```bash
# Check service health
docker compose ps

# View recent logs
docker compose logs --tail=100

# Debug container
docker compose exec [service] bash
```
---

### Troubleshooting Bonus Services

#### FTP Connection Issues
```bash
# Check FTP container logs
docker compose logs ftp

# Verify FTP user exists and permissions are correct
docker compose exec ftp bash
# Inside container: ls -la /home/
```

#### Redis Not Caching
```bash
# Verify Redis connectivity
docker compose exec redis redis-cli ping

# Check WordPress Redis plugin configuration
docker compose exec wordpress bash
# Inside: grep REDIS_HOST wp-config.php
```

#### Backup Not Running
```bash
# Check backup container logs
docker compose logs backup-db

# Verify backup directory permissions
ls -la /home/rmaanane/data/backup/

# Check available disk space
df -h /home/rmaanane/data/

# Enter the backup container
docker compose exec backup-db bash

# Verify that cron is running
ps aux | grep cron

# Check registered cron jobs
crontab -l

# Verify backup script permissions
ls -la /backup-db/backup.sh

# Test backup script manually
/bin/bash /backup-db/backup.sh

# Verify backup file creation
ls -la /backup-db/

# Check mysqldump errors
cat /tmp/mysqldump-error.log
```


#### Adminer Connection Failed
```bash
# Check Adminer logs
docker compose logs adminer

# Verify MariaDB is running
docker compose ps mariadb
```

---

### Environment Variables
- Modify `.env` file for configuration changes
- Restart services to apply new environment variables 
  `docker compose up --build`


### Bonus Services Environment Variables
Add these to `.env` file for bonus services:

```bash
# FTP Configuration
FTP_USER=ftpuser
FTP_PASSWORD=ftppassword

```