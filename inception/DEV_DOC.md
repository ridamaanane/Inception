# Developer Documentation

## Setting Up the Environment from Scratch

### Prerequisites
- **Operating System**: Linux/Unix environment (Ubuntu/Debian recommended)
- **Domain Configuration**: Add `127.0.0.1 rmaanane.42.fr` to `/etc/hosts`
- **Permissions**: Sudo access for hosts file modification and chown command

### Configuration Files and Secrets
- **`.env` file**: Contains all environment variables and credentials
  - Database configuration (MYSQL_* variables)
  - WordPress credentials (WP_* variables)
  - Domain settings (DOMAIN_NAME)
  - FTP credentials (FTP_* variables)
- **Docker Compose**: `srcs/docker-compose.yml` defines service orchestration
- **NGINX Configuration**: `srcs/requirements/nginx/conf/nginx.conf`
- **WordPress Config**: `srcs/requirements/wordpress/conf/wp-config.php`

### Secrets Management
- All sensitive data is stored in the `.env` file
- The `.env` file should never be committed to version control
- Environment variables are used instead of hardcoded values in Dockerfiles
- Docker secrets could be used as an alternative for production deployments

## Building and Launching the Project

### Using Makefile
```bash
# Complete setup (recommended for first run)
make all

# Individual steps
make update_hosts    # Update /etc/hosts file
make setup          # Create data directories
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
docker compose exec mariadb mysql -u wp_user -p

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
docker volume inspect inception_mariadb_data
docker volume inspect inception_wordpress_data

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

# Connect to network manually (if needed)
docker network connect inception [container_name]
```

## Project Data Storage and Persistence

### Data Locations
- **MariaDB Data**: `/home/rmaanane/data/mariadb/` (bind mount)
  - Contains database files, tables, and user data
  - Persists across container restarts and recreations
- **WordPress Data**: `/home/rmaanane/data/wordpress/` (bind mount)
  - Contains WordPress core files, themes, plugins, uploads
  - Shared between nginx, wordpress, and ftp containers
- **Static Website**: Docker volume `inception_static_website`
  - Contains portfolio website files
  - Managed by Docker volume system

### Data Persistence Mechanism
- **Bind Mounts**: Direct host filesystem access for MariaDB and WordPress
  - Advantages: Direct access, easy backup, host filesystem tools
  - Disadvantages: Host-dependent paths, less portable
- **Docker Volumes**: Managed storage for static website
  - Advantages: Portable, Docker-managed, better isolation
  - Disadvantages: Less direct access, requires Docker commands

### Backup and Recovery
- **Database Backup**: Automated via backup-db service
  - Creates SQL dumps in container `/backup/` directory
  - Runs on container startup with timestamped filenames
- **Manual Backup**:
  ```bash
  # Backup database
  docker compose exec mariadb mysqldump -u wp_user -p wordpress_db > backup.sql

  # Backup WordPress files
  cp -r /home/rmaanane/data/wordpress /path/to/backup/

  # Backup volumes
  docker run --rm -v inception_static_website:/data -v $(pwd):/backup alpine tar czf /backup/static-website.tar.gz -C /data .
  ```

### Data Migration
- **Between Environments**: Copy data directories and recreate containers
- **Volume Transfer**: Use `docker volume create` and copy operations
- **Database Migration**: Use mysqldump and mysql import commands

## Development Workflow

### Modifying Services
1. Edit Dockerfile or configuration files
2. Rebuild affected services: `docker compose up --build [service]`
3. Test changes
4. Commit configuration changes

### Debugging
```bash
# Check service health
docker compose ps

# View recent logs
docker compose logs --tail=100

# Debug container
docker compose exec [service] bash

# Test connectivity
docker compose exec wordpress ping mariadb
```

### Environment Variables
- Modify `.env` file for configuration changes
- Restart services to apply new environment variables
- Use `docker compose up --build` if Dockerfile changes are needed

### Scaling Services
```bash
# Scale specific service
docker compose up -d --scale wordpress=2

# Note: Database services typically shouldn't be scaled horizontally
# without additional configuration (clustering, load balancing)
```

## Security Considerations

### Container Security
- Non-root user execution where possible
- Minimal base images (Debian Bookworm)
- No privileged containers
- Proper file permissions

### Network Security
- Isolated Docker network
- SSL/TLS encryption on external access
- No host network mode
- Service discovery via container names

### Secrets Management
- Environment variables for development
- Consider Docker secrets for production
- Never commit `.env` files to version control
- Rotate credentials regularly

## Troubleshooting Common Issues

### Service Startup Failures
- Check Docker daemon: `systemctl status docker`
- Verify ports availability: `netstat -tlnp | grep :443`
- Check disk space: `df -h`
- Review logs: `docker compose logs`

### Database Connection Issues
- Verify MariaDB container is running
- Check network connectivity: `docker compose exec wordpress ping mariadb`
- Validate credentials in `.env`
- Check database initialization logs

### WordPress Issues
- Clear browser cache
- Check PHP-FPM status
- Verify Redis connectivity
- Check file permissions on WordPress directory

### SSL/TLS Problems
- Accept self-signed certificate warnings
- Verify domain in `/etc/hosts`
- Check NGINX SSL configuration
- Test certificate validity: `openssl s_client -connect localhost:443`

### Performance Issues
- Monitor resource usage: `docker stats`
- Check Redis cache status
- Optimize PHP-FPM configuration
- Review NGINX access logs