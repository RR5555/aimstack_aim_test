SHELL := /bin/bash
.DEFAULT_GOAL := help
IMG_NAME ?= test_project


define fn_prompt_cmd
@ read -e -p " " -i "$(1)"  CMDtoEXECUTE; $$CMDtoEXECUTE
endef

bats-tests: ## Launch tests
	bats ./tests


docker-worker-build: ## [Host] Build aim worker image & tag it
	@. ./fcts.sh && docker_build aim_test_worker ./Docker/worker/Dockerfile

docker-server-build: ## [Host] Build aim server image & tag it
	@. ./fcts.sh && docker_build aim_server ./Docker/server/Dockerfile


aim-up: ## [Host] Aim Docker Compose up

	@echo "### Check host aim dir (existence) ###"
	@if [ ! -d /tmp/aim_RR ]; then\
		mkdir /tmp/aim_RR ;\
		echo -e "--- \e[2m/tmp/aim_RR\e[0m created ---";\
	fi

	@echo "### Check host aim dir (owner)###"
	@if [ ! "$$(stat -c '%U' /tmp/aim_RR)" = "$$(id -un)" ]; then\
		echo -e "\e[1;31mError:\e[0m Aim dir (\e[2m/tmp/aim_RR\e[0m) owner (\e[2m$$(stat -c '%U' /tmp/aim_RR)\e[0m) does not match current user (\e[2m$$(id -un)\e[0m)";\
		exit 1;\
	fi

	@echo -e "### \e[2maim_server\e[0m ###"
	@. ./fcts.sh && extended_conditional_docker_build aim_server ./Docker/server/Dockerfile docker_build ./supervisord.conf
	
	@echo -e "### \e[2maim_test_worker\e[0m ###"
	@. ./fcts.sh && extended_conditional_docker_build aim_test_worker ./Docker/worker/Dockerfile docker_build ./Docker/worker/aim_runs.py ./Docker/worker/test_aim_runs.py

	@echo "### Docker Compose ###"
	@docker compose -f ./Docker/docker-compose.yaml up --detach
	@echo -e "Head to \e[4mhttp://127.0.0.1:43800\e[0m"
	@echo -e "Explore container logs:\n\e[2mdocker compose -p aim_test logs\e[0m"


# aim-up-build: ## [Host] Aim Docker Compose up with forced docker img build
# 	DOCKER_USER=$$(id -un) \
#     DOCKER_USER_ID=$$(id -u) \
#     DOCKER_USER_GID=$$(id -g) \
# 	docker compose up --build


aim-down: ## [Host] Aim Docker Compose down
	docker compose -p aim_test down



remote_check:
	@echo -e "Go to \e[4mhttp://127.0.0.1:43800\e[0m"

###### Help ######

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

