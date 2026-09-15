SHELL := /bin/bash
.DEFAULT_GOAL := help
IMG_NAME ?= test_project


define fn_prompt_cmd
@ read -e -p " " -i "$(1)"  CMDtoEXECUTE; $$CMDtoEXECUTE
endef

bats-tests: ## Launch tests
	bats ./tests


docker-worker-build: ## [Host] Build aim worker image & tag it
	. ./fcts.sh && docker_build aim_test_worker ./Docker/worker/Dockerfile

docker-server-build: ## [Host] Build aim server image & tag it
	. ./fcts.sh && docker_build aim_server ./Docker/server/Dockerfile



aim-up: ## [Host] Aim Docker Compose up
	@echo "### aim_server ###"
	. ./fcts.sh && extended_conditional_docker_build aim_server ./Docker/server/Dockerfile docker_build ./supervisord.conf
	
	@echo "### aim_test_worker ###"
	. ./fcts.sh && extended_conditional_docker_build aim_test_worker ./Docker/worker/Dockerfile docker_build ./Docker/worker/aim_runs.py ./Docker/worker/test_aim_runs.py

	@echo "### Docker Compose ###"
	@docker compose -f ./Docker/docker-compose.yaml up --detach
	@echo "Head to http://127.0.0.1:43800"
	@echo -e "Explore container logs:\ndocker compose -p aim_test logs"


# aim-up-build: ## [Host] Aim Docker Compose up with forced docker img build
# 	DOCKER_USER=$$(id -un) \
#     DOCKER_USER_ID=$$(id -u) \
#     DOCKER_USER_GID=$$(id -g) \
# 	docker compose up --build


aim-down: ## [Host] Aim Docker Compose down
	docker compose -p aim_test down



remote_check:
	@echo "Go to http://127.0.0.1:43800"

###### Help ######

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

