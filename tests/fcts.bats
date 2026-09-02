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

:

load ../fcts.sh

# setup_test_docker_build
function setup_test_docker_build () {
    :
}

# teardown_docker_image <tag_name>
function teardown_docker_image () {
	docker rmi "$1" 1>&3 2>&3
}


# shellcheck disable=2329
setup_file() {
    :
}

# shellcheck disable=2329
setup() {
	bats_load_library bats-assert
    bats_load_library bats-support

    echo "# --- Test Name: ${BATS_TEST_NAME} ---" >&3

	# test docker_build
	if [[ "${BATS_TEST_NAME}" == "test_test_docker-2d5fbuild" ]]; then
		TMP_TAG=tmp.docker_build
	fi

	# test docker_image_exists
	if [[ "${BATS_TEST_NAME}" == "test_test_docker-2d5fimage-2d5fexists" ]]; then
		TMP_TAG=tmp.docker_image_exists
	fi

	# test is_dockerfile_older
	if [[ "${BATS_TEST_NAME}" == "test_test_is-2d5fdockerfile-2d5folder" ]]; then
		# echo "# --- Name okay ---" >&3
		TMP_TAG=tmp.is_dockerfile_older
		TMP_DIR=$(mktemp -d)
	fi

	# test conditional_docker_build
	if [[ "${BATS_TEST_NAME}" == "test_test_conditional-2d5fdocker-2d5fbuild" ]]; then
		# echo "# --- Name okay ---" >&3
		TMP_TAG=tmp.conditional_docker_build
		TMP_DIR=$(mktemp -d)
	fi
	echo "# --- Setup done ---" >&3
}

# shellcheck disable=2329
teardown() {
	# test docker_build
    if [[ "${BATS_TEST_NAME}" == "test_test_docker-2d5fbuild" ]]; then
		teardown_docker_image "$TMP_TAG"
    fi

	# test docker_image_exists
    if [[ "${BATS_TEST_NAME}" == "test_test_docker-2d5fimage-2d5fexists" ]]; then
		teardown_docker_image "$TMP_TAG"
    fi

	# test docker_image_exists
    if [[ "${BATS_TEST_NAME}" == "test_test_is-2d5fdockerfile-2d5folder" ]]; then
		# echo "# --- Name okay ---" >&3
		rm -rf "$TMP_DIR"
		teardown_docker_image "$TMP_TAG"
    fi


	# test conditional_docker_build
	if [[ "${BATS_TEST_NAME}" == "test_test_conditional-2d5fdocker-2d5fbuild" ]]; then
		# echo "# --- Name okay ---" >&3
		rm -rf "$TMP_DIR"
		teardown_docker_image "$TMP_TAG"
	fi
	echo "# --- Teardown done ---" >&3
}

# shellcheck disable=2329
teardown_file() {
    :
}




@test "test docker_build" {
	run docker_build "$TMP_TAG" ./tests/Docker/Dockerfile
	echo "# --- Build done ---" >&3
	if ! docker image inspect "$TMP_TAG" >/dev/null 2>&1; then
		echo "# [NotExist] Build";
		exit 1;
    fi
	echo "# --- Docker img exists ---" >&3
    # `\` is consumed by container cmd bash shell interpreter to save the `$$` for the Make interpreter
    # `-it` option might introduce extra trailing characters when using the following:
    #	echo "$$(docker run -it --rm --name tmp.docker_container tmp.docker_build bash -c "id | sed 's/,/ /g' | awk '{print \$$1,\$$2,\$$3}'")" | od -A n -t x1
    #	echo "$$(id | sed 's/,/ /g' | awk '{print $$1,$$2,$$3}')" | od -A n -t x1
    # `od`(octal dump): dump files in octal and other formats
    # `-x`: same as `-t x2`, select hexadecimal 2-byte units
    # `-t`, `--format=TYPE`: select output format or formats
    # `-A`, `--address-radix=RADIX`: output format for file offsets; RADIX is one of [`doxn`], for Decimal, Octal, Hex or None
	assert_equal "$(docker run --rm --name tmp.docker_container tmp.docker_build bash -c "id | sed 's/,/ /g' | awk '{print $1,$2,$3}'")" "$(id | sed 's/,/ /g' | awk '{print \$1,\$2,\$3}')"
	echo "# --- Container test done---" >&3
}


@test "test docker_image_exists" {
	run docker_build "$TMP_TAG" ./tests/Docker/Dockerfile
	echo "# --- Build done ---" >&3
	run docker_image_exists "$TMP_TAG"
	assert_output ""
	assert_success
	run docker_image_exists "This is not an image name"
	assert_failure
}


@test "test is_dockerfile_older" {
	echo -e "\nFROM python:3.14-slim\n\nCMD [\"echo\", \"before\"]\n" > "$TMP_DIR/Dockerfile"
	echo "# --- Dockerfile Created ---" >&3
	sleep 1
	run docker_build "$TMP_TAG" "$TMP_DIR/Dockerfile"
	echo "# --- Image Created ---" >&3
	run is_dockerfile_older "$TMP_TAG" "$TMP_DIR/Dockerfile"
	# echo "# --- Status: $status ---" >&3
	# echo -e "# ---\n$output\n---" >&3
	assert_success
	sleep 1
	echo -e "\nFROM python:3.14-slim\n\nCMD [\"echo\", \"after\"]\n" > "$TMP_DIR/Dockerfile"
	run is_dockerfile_older "$TMP_TAG" "$TMP_DIR/Dockerfile"
	# echo "# --- Status: $status ---" >&3
	# echo -e "# ---\n$output\n---" >&3
	assert_failure
}


function mock_docker_build () {
	:
}

@test "test conditional_docker_build" {
	:
	# echo -e "\nFROM python:3.14-slim\n\nCMD [\"echo\", \"before\"]\n" > "$TMP_DIR/Dockerfile"
	# echo "# --- Dockerfile Created ---" >&3
    # run conditional_docker_build "$TMP_TAG" "$TMP_DIR/Dockerfile" mock_docker_build
	# refute_output --partial "Error"
	# assert_output --partial "\[NotExist\] Build"
	# refute_output --partial "\[OldBuild\] Build"
	# echo "# --- Image Created ---" >&3
	
	
	# if [ "$(docker run --rm --name tmp.docker_container "$TMP_TAG")" != "before" ]; then \
	# 	echo -e "\033[0;31mTEST FAIL\033[0m"; \
	# 	exit 1; \
	# fi
	# echo "--- Container Run (before) ---"
	# echo -e "\nFROM python:3.14-slim\n\nCMD [\"echo\", \"after\"]\n" > ./tests/tmp/Dockerfile
	# echo "--- Dockerfile Created ---"
	# conditional_docker_build "$TMP_TAG" ./tests/tmp/Dockerfile mock_docker_build
	# echo "--- Image Created ---"
	# if [ "$(docker run --rm --name tmp.docker_container "$TMP_TAG"" != "after" ]; then \
	# 	echo -e "\033[0;31mTEST FAIL\033[0m"; \
	# 	exit 1; \
	# fi
	# echo "--- Container Run (after) ---"
	# conditional_docker_build tmp.docker_build ./tests/tmp/Dockerfile mock_docker_build
	# echo "--- Already built & up-to-date ---"
}
