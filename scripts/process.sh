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

# Find the number of CPU cores
CORES=`nproc`

# Use all but one core for document processing
PROCESSES=`echo ${CORES} / 2 | bc`

# Ensure to run with at least one thread
if [ ${PROCESSES} -lt 1 ]; then
    PROCESSES=1
fi

echo Scan Processor running with ${PROCESSES} threads

while [ 1 ]; do
    # Ignore errors
    set +e
    find "${INPUT_DIR}" -maxdepth 1 -name "scan_*" -type d | xargs -n 1 -L 1 -I FILE --max-procs=${PROCESSES} sh -c "echo Processing FILE; ./create_pdf.sh 'FILE' '${OUTPUT_DIR}' >> 'FILE'/process.log 2>&1"
    set -e
    sleep 10
done
