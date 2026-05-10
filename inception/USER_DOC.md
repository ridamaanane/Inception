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

### WordPress Website
- **URL**: https://rmaanane.42.fr
- **Admin Panel**: https://rmaanane.42.fr/wp-admin/
- **Admin Login**: administrator / admin123
- **User Login**: user / user123

### Adminer (Database Management)
- **URL**: https://rmaanane.42.fr/adminer/
- **System**: mariadb
- **Server**: mariadb:3306
- **Username**: wp_user
- **Password**: wp_pass
- **Database**: wordpress_db

### Static Website
- **URL**: https://rmaanane.42.fr/static-website/

### FTP Server
- **Host**: localhost
- **Port**: 21
- **Username**: rmaanane
- **Password**: password
- **Directory**: /var/www/html (WordPress files)

## Locating and Managing Credentials

All credentials are stored in the `.env` file located in the `srcs/` directory:


### Important Security Notes
- Change default passwords after initial setup
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
ftp localhost
```

### Verify Data Persistence
- Create a test post in WordPress
- Stop services: `make down`
- Start services: `make up`
- Verify the post still exists

### Troubleshooting
- If services don't start, check Docker daemon is running
- If website shows "connection refused", check NGINX container is running
- If WordPress shows installation page, check database connection
- If SSL errors occur, ensure domain is properly configured in hosts file