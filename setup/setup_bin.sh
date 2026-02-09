#!/bin/sh

TARGET_DIR="${HOME}/bin"
SCRIPT_PATH=$1

if [ -z "${SCRIPT_PATH}" ]; then
  echo "Usage: $0 /path/to/script"
  exit 1
fi

SCRIPT_PATH=$(realpath "${SCRIPT_PATH}")

ln -svf "${SCRIPT_PATH}" "${TARGET_DIR}/$(basename ${SCRIPT_PATH})"
