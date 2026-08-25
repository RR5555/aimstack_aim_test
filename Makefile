SHELL := /bin/bash
.DEFAULT_GOAL := help
IMG_NAME ?= test_project


define fn_prompt_cmd
@ read -e -p " " -i "$(1)"  CMDtoEXECUTE; $$CMDtoEXECUTE
endef




scp-files: ## Copy files to ssh target [req: SSH_TARGET]
	@ echo -e "Please define SSH_TARGET & TARGET_DIR";\
	prompt_cmd("scp -r . SSH_TARGET:TARGET_DIR");



docker-worker-build: ## [Host] Build aim worker image & tag it
	$(call docker_build, aim_test_worker, ./Docker/worker/Dockerfile)
# docker build -t aim_test_worker -f ./Docker/worker/Dockerfile --build-arg DOCKER_USER=$$(id -un) --build-arg DOCKER_USER_ID=$$(id -u) --build-arg DOCKER_USER_GID=$$(id -g) .

docker-server-build: ## [Host] Build aim server image & tag it
	$(call docker_build, aim_server, ./Docker/server/Dockerfile)
# docker build -t aim_server -f ./Docker/server/Dockerfile --build-arg DOCKER_USER=$$(id -un) --build-arg DOCKER_USER_ID=$$(id -u) --build-arg DOCKER_USER_GID=$$(id -g) .

aim-up-integrated: ## [Host]
	@echo "### aim_server ###"
	$(call fn_conditional_docker_build, <tag_name>, <Dockerfile_path>, <docker_build_make_target>)
	@if ! docker image inspect aim_server >/dev/null 2>&1; then \
		echo "[NotExist] Build"; \
		$(MAKE) docker-server-build; \
    fi
	@if [ $$(stat -c '%Y' ./Docker/server/Dockerfile) -gt $$(docker image inspect aim_server --format='{{.Created}}' | xargs -I {} date --date {} +'%s') ]; then \
		echo "[OldBuild] Build"; \
		$(MAKE) docker-server-build; \
    fi
	@echo "### aim_test_worker ###"
	@if ! docker image inspect aim_test_worker >/dev/null 2>&1; then \
		echo "[NotExist] Build"; \
		$(MAKE) docker-worker-build; \
    fi
	@if [ $$(stat -c '%Y' ./Docker/worker/Dockerfile) -gt $$(docker image inspect aim_test_worker --format='{{.Created}}' | xargs -I {} date --date {} +'%s') ]; then \
		echo "[OldBuild] Build"; \
		$(MAKE) docker-worker-build; \
    fi
	@echo "### Docker Compose ###"
	@DOCKER_USER=$$(id -un) \
    DOCKER_USER_ID=$$(id -u) \
    DOCKER_USER_GID=$$(id -g) \
	docker compose up
	@echo "Head to "

aim-up: ## [Host] Aim Docker Compose up
	DOCKER_USER=$$(id -un) \
    DOCKER_USER_ID=$$(id -u) \
    DOCKER_USER_GID=$$(id -g) \
	docker compose up

aim-up-build: ## [Host] Aim Docker Compose up with forced docker img build
	DOCKER_USER=$$(id -un) \
    DOCKER_USER_ID=$$(id -u) \
    DOCKER_USER_GID=$$(id -g) \
	docker compose up --build

# Note that if Dockerfile is modified, you might to force the build with `--build`


aim-down: ## [Host] Aim Docker Compose down
	docker compose -p aim_test down





remote_check:
	@echo "Go to http://127.0.0.1:43800"

###### Help ######

# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

