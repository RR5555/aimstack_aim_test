#!/usr/bin/env bats

# @test "addition using bc" {
#     result="$(echo 2+2 | bc)"
#     [ "$result" -eq 4 ]
# }



# setup() {
#     load 'test_helper/common-setup'
#     _common_setup

#     source "$PROJECT_ROOT/src/helper.sh"
# }

# teardown() {
#     rm -f "$NON_EXISTENT_FIRST_RUN_FILE"
#     rm -f "$EXISTING_FIRST_RUN_FILE"
# }

# @test "Check first run" {
#     NON_EXISTENT_FIRST_RUN_FILE=$(mktemp -u) # only create the name, not the file itself

#     assert _is_first_run "$NON_EXISTENT_FIRST_RUN_FILE"
#     refute _is_first_run "$NON_EXISTENT_FIRST_RUN_FILE"
#     refute _is_first_run "$NON_EXISTENT_FIRST_RUN_FILE"

#     EXISTING_FIRST_RUN_FILE=$(mktemp)
#     refute _is_first_run "$EXISTING_FIRST_RUN_FILE"
#     refute _is_first_run "$EXISTING_FIRST_RUN_FILE"
# }



# setup_test_docker_build
function setup_test_docker_build () {
    :
}

# fn_test_docker_build_teardown <tag_name>
function teardown_test_docker_build () {
	docker rmi $(1)
}



setup_file() {
    source ../fcts.sh
}

setup() {
    :
}


teardown() {
    :
}


teardown_file() {
    :
}




@test "test docker_build" {
    $(call fn_test_docker_build_setup)
	echo "--- Setup done ---"
	$(call fn_docker_build, $(TMP_TAG), ./tests/Docker/Dockerfile)
	echo "--- Build done ---"
	if ! docker image inspect $(TMP_TAG) >/dev/null 2>&1; then \
		echo "[NotExist] Build"; \
		exit 1; \
    fi
	echo "--- Docker img exists ---"
    # `\` is consumed by container cmd bash shell interpreter to save the `$$` for the Make interpreter
    # `-it` option might introduce extra trailing characters when using the following:
    #	echo "$$(docker run -it --rm --name tmp.docker_container tmp.docker_build bash -c "id | sed 's/,/ /g' | awk '{print \$$1,\$$2,\$$3}'")" | od -A n -t x1
    #	echo "$$(id | sed 's/,/ /g' | awk '{print $$1,$$2,$$3}')" | od -A n -t x1
    # `od`(octal dump): dump files in octal and other formats
    # `-x`: same as `-t x2`, select hexadecimal 2-byte units
    # `-t`, `--format=TYPE`: select output format or formats
    # `-A`, `--address-radix=RADIX`: output format for file offsets; RADIX is one of [`doxn`], for Decimal, Octal, Hex or None
	if [[ "$$(docker run --rm --name tmp.docker_container tmp.docker_build bash -c "id | sed 's/,/ /g' | awk '{print \$$1,\$$2,\$$3}'")" != "$$(id | sed 's/,/ /g' | awk '{print $$1,$$2,$$3}')" ]]; then \
		echo -e "\033[0;31mTEST FAIL\033[0m"; \
		exit 1; \
	fi
	echo "--- Container test done---"
	$(call fn_test_docker_build_teardown, $(TMP_TAG))
	echo "--- Teardown done ---"
}

TMP_TAG := tmp.docker_build

# fn_test_docker_build 
define fn_test_docker_build
	$(call fn_test_docker_build_setup)
	@echo "--- Setup done ---"
	$(call fn_docker_build, $(TMP_TAG), ./tests/Docker/Dockerfile)
	@echo "--- Build done ---"
	@if ! docker image inspect $(TMP_TAG) >/dev/null 2>&1; then \
		echo "[NotExist] Build"; \
		exit 1; \
    fi
	@echo "--- Docker img exists ---"
@# `\` is consumed by container cmd bash shell interpreter to save the `$$` for the Make interpreter
@# `-it` option might introduce extra trailing characters when using the following:
@#	echo "$$(docker run -it --rm --name tmp.docker_container tmp.docker_build bash -c "id | sed 's/,/ /g' | awk '{print \$$1,\$$2,\$$3}'")" | od -A n -t x1
@#	echo "$$(id | sed 's/,/ /g' | awk '{print $$1,$$2,$$3}')" | od -A n -t x1
@# `od`(octal dump): dump files in octal and other formats
@# `-x`: same as `-t x2`, select hexadecimal 2-byte units
@# `-t`, `--format=TYPE`: select output format or formats
@# `-A`, `--address-radix=RADIX`: output format for file offsets; RADIX is one of [`doxn`], for Decimal, Octal, Hex or None
	@if [[ "$$(docker run --rm --name tmp.docker_container tmp.docker_build bash -c "id | sed 's/,/ /g' | awk '{print \$$1,\$$2,\$$3}'")" != "$$(id | sed 's/,/ /g' | awk '{print $$1,$$2,$$3}')" ]]; then \
		echo -e "\033[0;31mTEST FAIL\033[0m"; \
		exit 1; \
	fi
	@echo "--- Container test done---"
	$(call fn_test_docker_build_teardown, $(TMP_TAG))
	@echo "--- Teardown done ---"
endef


test-docker-test: ## Test the Makefile fcts
	$(call fn_test_docker_build)
	@echo -e "\033[0;32mTEST SUCESS\033[0m"




mock_docker_build: ## Not to be called directly
	$(call fn_docker_build, tmp.docker_build, ./tests/tmp/Dockerfile)
	@echo "--- Mock Build ---"

define fn_test_conditional_docker_build
	@if docker image inspect tmp.docker_build >/dev/null 2>&1; then \
		echo "[AlreadyExist] Please Clean-up"; \
		exit 1; \
    fi
	@echo "--- [Clean] ---"
	@echo -e "\nFROM python:3.14-slim\n\nCMD [\"echo\", \"before\"]\n" > ./tests/tmp/Dockerfile
	@echo "--- Dockerfile Created ---"
	@if [ $$($(call fn_conditional_docker_build, tmp.docker_build, ./tests/tmp/Dockerfile, mock_docker_build)) | grep -q "[OldBuild] Build" ]; then \
		echo -e "\033[0;31mTEST FAIL\033[0m"; \
		exit 1; \
	fi
	@echo "--- Image Created ---"
	@ docker run --rm --name tmp.docker_container tmp.docker_build | batcat -A
	@if [ "$$(docker run --rm --name tmp.docker_container tmp.docker_build)" != "before" ]; then \
		echo -e "\033[0;31mTEST FAIL\033[0m"; \
		exit 1; \
	fi
	@echo "--- Container Run (before) ---"
	@echo -e "\nFROM python:3.14-slim\n\nCMD [\"echo\", \"after\"]\n" > ./tests/tmp/Dockerfile
	@echo "--- Dockerfile Created ---"
	$(call fn_conditional_docker_build, tmp.docker_build, ./tests/tmp/Dockerfile, mock_docker_build)
	@echo "--- Image Created ---"
	@if [ "$$(docker run --rm --name tmp.docker_container tmp.docker_build)" != "after" ]; then \
		echo -e "\033[0;31mTEST FAIL\033[0m"; \
		exit 1; \
	fi
	@echo "--- Container Run (after) ---"
	@$(call fn_conditional_docker_build, tmp.docker_build, ./tests/tmp/Dockerfile, mock_docker_build)
	@echo "--- Already built & up-to-date ---"
	rm ./tests/tmp/Dockerfile
	docker rmi tmp.docker_build
	@echo "--- Clean-up done ---"
endef

test-conditional-docker-build: ## test `fn_test_conditional_docker_build`
	$(call fn_test_conditional_docker_build)
	@echo -e "\033[0;32mTEST SUCESS\033[0m"