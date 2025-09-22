# **************************************************************************** #
#                                   Makefile                                   #
# **************************************************************************** #

# Project Name
NAME = inception

# Paths
SRC_DIR = ./srcs
COMPOSE_FILE = srcs/docker-compose.yml
DB_DATA_DIRS = home/scharuka/data/mariadb home/scharuka/data/wordpress

# Docker Compose Commands

# Rules
all: up

up:
	./srcs/requirements/tools/setup.sh
	docker compose -f $(COMPOSE_FILE) up --build -d

build:
	docker compose -f $(COMPOSE_FILE) build --no-cache

down:
	docker compose -f $(COMPOSE_FILE) down --remove-orphans --volumes

# clean-all:
# 	docker compose -f $(COMPOSE_FILE) down --volumes

restart:
	docker compose -f $(COMPOSE_FILE) restart

logs:
	docker compose -f $(COMPOSE_FILE) logs -f --tail=100

clean-all:
	@echo "--- Stopping and removing all containers, networks, images, and orphans ---"
	docker compose -f $(COMPOSE_FILE) down --remove-orphans --volumes --rmi all
	@echo "--- Deleting host bind-mounted data for databases ---"
	@for dir in $(DB_DATA_DIRS); do \
		echo "Deleting $$dir"; \
		rm -rf $$dir; \
	done

prune:
	@echo "WARNING: This command will perform a system-wide cleanup of unused Docker objects."
	@echo "Press Ctrl+C to cancel."
	@sleep 5
	docker system prune -a --volumes --force

# Example: make shell service=web
shell:
	docker compose -f $(COMPOSE_FILE) exec $(service) /bin/bash

re: down clean-all up

wp:
	docker exec -it wordpress bash

db:
	docker exec -it mariadb bash

.PHONY:all up build start down restart logs re clean-all prune shell wp db
