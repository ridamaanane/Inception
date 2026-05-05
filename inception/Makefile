COMPOSE_DIR=srcs
COMPOSE_FILE=$(COMPOSE_DIR)/docker-compose.yml
DC=docker compose -f $(COMPOSE_FILE)

all: build

# Create data directories
setup:
	@echo "Setting up data directories..."
	@mkdir -p /home/rmaanane/data/mariadb
	@mkdir -p /home/rmaanane/data/wordpress

build: setup
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
	$(DC) down -v --remove-orphans

.PHONY: all up build setup down restart logs status clean fclean