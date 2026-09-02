#!/bin/bash



# docker_build <tag_name> <Dockerfile_path>
function docker_build () {
	docker build -t "$1" -f "$2" --build-arg DOCKER_USER="$(id -un)" --build-arg DOCKER_USER_ID="$(id -u)" --build-arg DOCKER_USER_GID="$(id -g)" .
}

# docker_image_exists <tag_name>
function docker_image_exists () {
	docker image inspect "$1" >/dev/null 2>&1
}

# is_dockerfile_older <tag_name> <Dockerfile_path> 
function is_dockerfile_older () {
	# stat -c '%Y' "$2"
	# docker image inspect "$1" --format='{{.Metadata.LastTagTime.Unix}}'
	[[ "$(stat -c '%Y' "$2")" < "$(docker image inspect "$1" --format='{{.Metadata.LastTagTime.Unix}}')" ]]
}


# conditional_docker_build <tag_name> <Dockerfile_path> <docker_build_fn>
function conditional_docker_build () {
    if [ $# != 3 ]; then \
        echo "Error"; \
    fi
	if ! docker image inspect "$1" >/dev/null 2>&1; then \
		echo "[NotExist] Build"; \
		$3 ; \
    fi
	if [ "$(stat -c '%Y' "$2")" -gt "$(docker image inspect "$1" --format='{{.Created}}' | xargs -I {} date --date {} +'%s')" ]; then \
		echo "[OldBuild] Build"; \
		$3 ; \
    fi
}




function test_echo () {
    echo "Hello $1";
}

