# User Documentation

## Services Provided

This project provides a complete web application stack with the following services:

- **WordPress**: Content Management System for website creation and management
- **MariaDB**: Relational database for data storage
- **NGINX**: Web server with SSL/TLS encryption and reverse proxy
- **Redis**: Caching service for improved performance
- **Adminer**: Web-based database management interface
- **FTP Server**: File transfer service for content management
- **Static Website**: Personal portfolio/resume website
- **Database Backup**: Automated database backup service

## Starting and Stopping the Project

### Start the Project
```bash
make all
```
This command will:
- Update your hosts file (requires sudo)
- Create necessary data directories
- Build and start all Docker containers

### Stop the Project
```bash
make down
```

### Restart the Project
```bash
make restart
```

## Accessing the Website and Administration Panel

### Access Website
Open your browser and go to:
https://rmaanane.42.fr

The WordPress homepage should load.

---

### Admin Panel
To manage the website:

1. Go to:
   https://rmaanane.42.fr/wp-admin/

2. Login using credentials defined in the `.env` file.

3. After login, you can:
   - create posts
   - manage pages

---

### User Login
A normal user can log in from:
https://rmaanane.42.fr/wp-login.php

- Login using credentials defined in the `.env` file.

---

### Notes
- Make sure all containers are running before accessing the site:
  docker compose up -d

## Adminer (Database Management)

Adminer is used to manage the MariaDB database through a web interface.

- URL: https://rmaanane.42.fr/adminer/

### How to access

1. Open the Adminer page in your browser:
   https://rmaanane.42.fr/adminer/

2. Fill in the login form:

- System: MySQL / MariaDB
- Server: mariadb
- Username: (defined in the `.env` file)
- Password: (defined in the `.env` file)
- Database: (defined in the `.env` file)

---

## Static Website

- **URL**: https://rmaanane.42.fr/static-website/

---

## FTP Server

The FTP service is used to access and manage WordPress files.

### How to connect

1. You need to install FTP on your host:

```bash
sudo apt install ftp -y
```

2. After installation, run the following command:

```bash
ftp rmaanane.42.fr
```
3. Enter the credentials:

- Username: (defined in the .env file)
- Password: (defined in the .env file)

4. Once connected, you will be placed in the following directory:

/var/www/html (WordPress root directory)


### What you can do

Once connected, you can:
- upload WordPress files
- modify themes/plugins
- manage website content files

### Upload a file via FTP

1. Create a PHP file (example: test.php).  
   PHP files are used to verify execution in the browser, but you can upload any file type.

**for example:**

```php
<?php
// filepath: test.php
echo "Hello from FTP! Current time: " . date("Y-m-d H:i:s");
?>
```

2. Upload the file using FTP with the following command:

```bash
curl -u Username:Password -T test.php ftp://rmaanane.42.fr/
```

* `Username:Password` → defined in the .env file

3. access the file in the browsewr

`rmaanane.42.fr/test.php`

### Download a file via FTP

1. Connect to the FTP server:

```bash
ftp rmaanane.42.fr
```

2. Enter your credentials:

- Username: (defined in the .env file)
- Password: (defined in the .env file)

3. Navigate to the directory containing the file you want to download

4. Download the file using the `get` command:

```bash
get filename.php
```

Or use `mget` to download multiple files:

```bash
mget *.php
```

5. Exit FTP:

```bash
bye
```

The files will be downloaded to your current working directory on your host machine.

**Alternatively, using curl:**

```bash
curl -u Username:Password -O ftp://rmaanane.42.fr/filename.php
```

* `Username:Password` → defined in the .env file
* The file will be saved in your current directory with the same name

---

## Redis Cache Service

Redis is used internally to improve WordPress performance by caching frequently accessed data.

This helps:
- reduce database requests
- improve page loading speed
- optimize WordPress performance

The Redis service is automatically configured and started with the Docker stack.

No manual user configuration is required.

---

## Database Backup Service

The backup service is used to automatically create backups of the MariaDB database.

This helps:
- protect database data
- simplify recovery in case of failure
- preserve WordPress content and configuration

Backups are generated automatically while the Docker stack is running.

No manual user interaction is required.

---

## Locating and Managing Credentials

All credentials are stored in the `.env` file located in the `srcs/` directory:


### Important Security Notes
- The `.env` file contains sensitive information and should not be committed to version control
- SSL certificates are self-signed for development purposes

## Checking That Services Are Running Correctly

### Check Container Status
```bash
make status
```
or
```bash
docker compose -f srcs/docker-compose.yml ps
```
`ps` : process status

### View Service Logs
```bash
make logs
```
or
```bash
docker compose -f srcs/docker-compose.yml logs -f
```
`-f` : In the end it keeps listening for NEW logs in real time.

### Test Website Access
- Open https://rmaanane.42.fr in your browser
- Verify SSL certificate (accept self-signed warning)
- Check that WordPress loads properly
- Try logging into admin panel

### Test Database Connection
- Access Adminer at https://rmaanane.42.fr/adminer/
- Login with wp_user credentials
- Verify you can see wordpress_db database

### Test FTP Access
```bash
ftp rmaanane.42.fr
```

### Verify Data Persistence
- Create a test post in WordPress
- Stop services: `make down`
- Start services: `make up`
- Verify the post still exists
