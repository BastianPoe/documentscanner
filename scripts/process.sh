#!/bin/bash -e

INPUT_DIR="${1}"
OUTPUT_DIR="${2}"

if [ "${INPUT_DIR}" == "" ]; then
    echo Please provide input directory, aborting
    exit 1
fi

if [ ! -d "${INPUT_DIR}" ]; then
    echo "${INPUT_DIR}" does not exist, aborting
    exit 1
fi

if [ "${OUTPUT_DIR}" == "" ]; then
    echo Please provide output directory, aborting
    exit 1
fi

if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "${OUTPUT_DIR}" does not exist, aborting
    exit 1
fi

while [ 1 ]; do
    find "${INPUT_DIR}" -name "scan_*" -type d -exec ./create_pdf.sh {} "${OUTPUT_DIR}" \;
    sleep 10
done
