#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <model> <message>" >&2
    exit 1
fi

exec ollama run "$1" "$2" </dev/null
