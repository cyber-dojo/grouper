#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"

"${SH_DIR}/build_docker_images.sh"
"${SH_DIR}/docker_containers_up.sh"
"${SH_DIR}/run_tests_in_containers.sh" "$@"
"${SH_DIR}/docker_containers_down.sh"
