PROJECT = inception_project
COMPOSE_FILE = ./srcs/docker-compose.yml
ENV_FILE = srcs/.env
DATA_WP_DIR = ~/data/wordpress/*
DATA_DB_DIR = ~/data/mariadb/*
RM = rm -rf 
COMPOSE = docker-compose -f

# colors

RESET = \e[0m
PURPLE = \033[0;35m
CYAN = \033[0;36m
YELLOW = \033[1;33m
RED = \033[0;31m
BLUE = \033[0;34m

all:
	@echo "${CYAN}*Initializing ${PROJECT} setup...* ${RESET}"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@${COMPOSE} ${COMPOSE_FILE} --env-file ${ENV_FILE} up -d

build:
	@echo "${PURPLE}*Building ${PROJECT} environment...* ${RESET}"
	@bash srcs/requirements/wordpress/tools/make_dir.sh
	@${COMPOSE} ${COMPOSE_FILE} --env-file ${ENV_FILE} up -d --build
	@docker volume create portainer_data
	@docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

down:
	@echo "${YELLOW}*Shutting down ${PROJECT}...* ${RESET}"
	@${COMPOSE} ${COMPOSE_FILE} --env-file ${ENV_FILE} down

re: down
	@echo "${BLUE}* Rebuilding ${PROJECT}...* ${RESET}"
	@${COMPOSE} ${COMPOSE_FILE} --env-file ${ENV_FILE} up -d --build

clean: down
	@echo "${RED}* Removing ${PROJECT} data...* ${RESET}"
	@docker system prune -a
	@sudo ${RM} ${DATA_WP_DIR}
	@sudo ${RM} ${DATA_DB_DIR}

fclean:
	@echo "${RED}* Performing complete clean-up...* ${RESET}"
	@docker stop $$(docker ps -qa)
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force
	@sudo ${RM} ${DATA_WP_DIR}
	@sudo ${RM} ${DATA_DB_DIR}

.PHONY: all build down re clean fclean

