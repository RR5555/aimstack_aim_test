#!/bin/bash



# docker_build <tag_name> <Dockerfile_path>
function docker_build () {
	docker build -t "$1" -f "$2" --build-arg DOCKER_USER="$(id -un)" --build-arg DOCKER_USER_ID="$(id -u)" --build-arg DOCKER_USER_GID="$(id -g)" .
}






# conditional_docker_build <tag_name> <Dockerfile_path> <docker_build_fn>
function conditional_docker_build () {
    if [ $# != 3 ]; then \
        echo "Error"; \
    fi
	if ! docker image inspect $1 >/dev/null 2>&1; then \
		echo "[NotExist] Build"; \
		$3 ; \
    fi
	if [ $(stat -c '%Y' $2) -gt $(docker image inspect $1 --format='{{.Created}}' | xargs -I {} date --date {} +'%s') ]; then \
		echo "[OldBuild] Build"; \
		$3 ; \
    fi
}


function test_conditional_docker_build () {
	if docker image inspect tmp.docker_build >/dev/null 2>&1; then \
		echo "[AlreadyExist] Please Clean-up"; \
		exit 1; \
    fi
	echo "--- [Clean] ---"
	echo -e "\nFROM python:3.14-slim\n\nCMD [\"echo\", \"before\"]\n" > ./tests/tmp/Dockerfile
	echo "--- Dockerfile Created ---"
    conditional_docker_build tmp.docker_build ./tests/tmp/Dockerfile mock_docker_build | tee >(cat) | grep -q "\[OldBuild\] Build" >/dev/null
	# if [ conditional_docker_build tmp.docker_build ./tests/tmp/Dockerfile mock_docker_build | grep -q "\[OldBuild\] Build" ]; then \
	# 	echo -e "\033[0;31mTEST FAIL\033[0m"; \
	# 	exit 1; \
	# fi
	echo "--- Image Created ---"
	if [ "$(docker run --rm --name tmp.docker_container tmp.docker_build)" != "before" ]; then \
		echo -e "\033[0;31mTEST FAIL\033[0m"; \
		exit 1; \
	fi
	echo "--- Container Run (before) ---"
	echo -e "\nFROM python:3.14-slim\n\nCMD [\"echo\", \"after\"]\n" > ./tests/tmp/Dockerfile
	echo "--- Dockerfile Created ---"
	conditional_docker_build tmp.docker_build ./tests/tmp/Dockerfile mock_docker_build
	echo "--- Image Created ---"
	if [ "$(docker run --rm --name tmp.docker_container tmp.docker_build)" != "after" ]; then \
		echo -e "\033[0;31mTEST FAIL\033[0m"; \
		exit 1; \
	fi
	echo "--- Container Run (after) ---"
	conditional_docker_build tmp.docker_build ./tests/tmp/Dockerfile mock_docker_build
	echo "--- Already built & up-to-date ---"
	rm ./tests/tmp/Dockerfile
	docker rmi tmp.docker_build
	echo "--- Clean-up done ---"
}

function test_echo () {
    echo "Hello $1";
}

