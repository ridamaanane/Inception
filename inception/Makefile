COMPOSE_DIR=srcs
COMPOSE_FILE=$(COMPOSE_DIR)/docker-compose.yml
DC=docker compose -f $(COMPOSE_FILE)


all: update_hosts setup build setup2

update_hosts:
	@if grep "localhost" /etc/hosts; then \
		sudo sed -i 's/localhost/rmaanane.42.fr/g' /etc/hosts; \
	fi

# Create data directories
setup:
	@echo "Setting up data directories..."
	@mkdir -p $(HOME)/data/mariadb
	@mkdir -p $(HOME)/data/wordpress

setup2:
	@sudo chown -R $(USER):$(USER) $$HOME/data/wordpress

build:
	@echo "Building Docker images..."
	$(DC) up --build -d


up:
	@echo "Starting services..."
	$(DC) up -d


down:
	@echo "Cleaning up..."
	$(DC) down -v

restart: down up

logs:
	$(DC) logs -f

status:
	$(DC) ps

clean: down

fclean: clean
	@echo "Removing volumes and data..."
	@sudo rm -rf $(HOME)/data/
	$(DC) down -v --remove-orphans

.PHONY: all update_hosts setup setup2 build up down restart logs status clean fclean