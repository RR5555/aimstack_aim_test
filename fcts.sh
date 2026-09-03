#!/bin/bash



# docker_build <tag_name> <Dockerfile_path>
function docker_build () {
	docker build -t "$1" -f "$2" --build-arg DOCKER_USER="$(id -un)" --build-arg DOCKER_USER_ID="$(id -u)" --build-arg DOCKER_USER_GID="$(id -g)" .
}

# docker_image_exists <tag_name>
function docker_image_exists () {
	docker image inspect "$1" >/dev/null 2>&1
}

# is_dockerfile_newer <tag_name> <Dockerfile_path> 
function is_dockerfile_newer () {
	# GNU Date: Run date `+%s.%N` to output seconds with nanoseconds (e.g., `1725375612.123456789`)
	# Date given in:
	# ```bash
	# docker image inspect "$1" --format='{{.Metadata.LastTagTime}}'
	# ```
	# Is in Golang format not comaptible with bash `date`
	# It can be turned into Unix epoch:
	# ```bash
	# docker image inspect "$1" --format='{{.Metadata.LastTagTime.Unix}}'
	# 1788439277
	# ```
	# To get the nanoseconds (format `%s%N`):
	# ```bash
	# docker image inspect "$1" --format='{{.Metadata.LastTagTime.UnixNano}}'
	# 1788439277244226334
	# ```
	# To only get the nanoseconds:
	# ```bash
	# docker image inspect "$1" --format='{{.Metadata.LastTagTime.Nanosecond}}'
	# 244226334
	# ```
	# Thus to get `%s%N`:
	# ```bash
	# docker image inspect "$1" --format='{{.Metadata.LastTagTime.Unix}}.{{.Metadata.LastTagTime.Nanosecond}}'
	# ```
	# For simple condition testing, sue:
	# ```bash
	# [[ 1 < 2 ]]; echo $?
	# ```

	[[ "$(stat -c '%y' "$2" | xargs -I {} date --date {} "+%s.%N")" > "$(docker image inspect "$1" --format='{{.Metadata.LastTagTime.Unix}}.{{.Metadata.LastTagTime.Nanosecond}}')" ]]
}


# conditional_docker_build <tag_name> <Dockerfile_path> <docker_build_fn>
function conditional_docker_build () {
    if [ $# != 3 ]; then
        echo "Error";
    fi

	if ! docker_image_exists "$1"; then
		echo "[NotExist] Build";
		$3 "$1" "$2";
    fi
	
	if is_dockerfile_newer "$1" "$2"; then
		echo "[OldBuild] Build";
		$3 "$1" "$2";
    fi
}




function test_echo () {
    echo "Hello $1";
}

