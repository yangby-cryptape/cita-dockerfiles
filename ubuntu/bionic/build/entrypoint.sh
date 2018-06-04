#!/usr/bin/env bash

set -Eeo pipefail

exec gosu cita "$@"
