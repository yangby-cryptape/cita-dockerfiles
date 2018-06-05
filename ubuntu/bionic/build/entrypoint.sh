#!/usr/bin/env bash

set -Eeo pipefail

RUN_AS="$(stat --format='%u:%g' .)"
DEFAULT_COMMAND="/bin/bash"

function usage () {
    echo "
Usage:

    $(basename $0) [--run_as UID:GID] [COMMAND [ARG1 [ARG2 [...]]]]

        UID:
                The user id used to run your command.
                Do not use user name.
                Default: the user id of current directory.
        GID:
                The group id used to run your command.
                Do not use group name.
                Default: the user id of current directory.

        COMMAND:
                If no command provided, the default is '${DEFAULT_COMMAND}'.
"
    exit $1
}

function main () {

    if [ $# -ge 2 ] && [ "${1}" = "--run_as" ]; then
        if [[ "${2}" =~ ^[0-9]{1,}:[0-9]{1,}$ ]]; then
            RUN_AS="${2}"
            shift 2
        else
            usage 1
        fi
    fi

    chown -R ${RUN_AS} \
        "${CARGO_HOME}/git" \
        "${CARGO_HOME}/registry"

    if [ $# -eq 0 ]; then
        echo "[Debug] Run command [${DEFAULT_COMMAND}] as ${RUN_AS}."
        exec gosu ${RUN_AS} "${DEFAULT_COMMAND}"
    else
        echo "[Debug] Run command [$*] as ${RUN_AS}."
        exec gosu ${RUN_AS} "$@"
    fi
}

main "$@"
