#!/bin/sh
set -eu

exec busybox crond -f -l 2 -L /dev/stdout
