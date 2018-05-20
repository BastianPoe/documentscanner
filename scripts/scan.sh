#!/bin/bash -e

DEVICE="${1}"

if [ "${DEVICE}" == "" ]; then
    echo Please provide device, exiting
    exit 1
fi

MODE="${2}"

if [ "${MODE}" == "" ]; then
    echo Please provide mode, exiting
    exit 1
fi

BASEDIR="${3}"

if [ "${BASEDIR}" == "" ]; then
    BASEDIR=`dirname "${0}"`
fi

SCANDIR="${BASEDIR}"/scan_`date +%Y-%m-%d-%H-%M-%S`

echo Scanning into "${SCANDIR}"

if [ -d "${SCANDIR}" ]; then
  echo "${SCANDIR}" already exists, exiting
  exit 1
fi

# Create target directory
mkdir -p "${SCANDIR}"

# Scan into target directory
scanadf --df-action Stop --df-skew=yes --df-thickness=yes --df-length=yes -d "${DEVICE}" --page-height 297 -y 297 --page-width 210 -x 210 --swskip 2.5 --resolution 300 --mode "${MODE}" 0 0 --source "ADF Duplex" -o "${SCANDIR}"/page-%04d

# Mark scan as complete
# If previous steps aborts (e.g. due to ADF jam or multi-feed error, scan is ignored for postprocessing)
touch "${SCANDIR}"/complete
