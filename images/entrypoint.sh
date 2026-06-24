#!/bin/sh
set -e
exec /sbin/tini -- /usr/local/bin/tf-runner "$@"
