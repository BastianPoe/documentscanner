#!/bin/bash -e

INPUT_DIR="${1}"
OUTPUT_DIR="${2}"
FILENAME=`basename ${INPUT_DIR}`

# Skip documents that are aborted and where a preview already exists
if [ -f "${INPUT_DIR}"/aborted ] && [ -f "${INPUT_DIR}"/preview.pdf ]; then
    exit 0
fi

echo `date` Creating PDF for ${INPUT_DIR}

# Check if input directory exists
if [ ! -d "${INPUT_DIR}" ]; then
    echo "${INPUT_DIR}" does not exist, exiting
    exit 1
fi

# Check if input scan is complete
if [ ! -f "${INPUT_DIR}"/complete ] && [ ! -f "${INPUT_DIR}"/aborted ]; then
    echo "${INPUT_DIR}" is not done, exiting
    exit 1
fi

# Check if output directory exists
if [ ! -d "${OUTPUT_DIR}" ]; then
    echo "${OUTPUT_DIR}" does not exist, exiting
    exit 1
fi

# Check if output PDF already exists
if [ -f "${OUTPUT_DIR}"/"${FILENAME}.pdf" ]; then
    echo "${FILENAME}".pdf already exists, exiting
    exit 0
fi

# Iterate through all pages
for PAGE in `ls "${INPUT_DIR}"/page*`; do
    FILE=`basename "${PAGE}"`
   
    # Determine standard deviation 
    STDDEV=`identify -verbose "${INPUT_DIR}"/"${FILE}" | grep -i deviation | tail -n 1 | awk -F '(' ' { print $2 } ' | awk -F ')' ' { print $1 } '`
    # If standard deviation for all channels is too low, page is empty
    if [ `echo ${STDDEV}'>'0.09 | bc -l` == "0" ]; then
        echo Page ${PAGE} empty, skipping
        continue
    fi

    # Run unpaper on the images
    unpaper --overwrite --dpi 300 "${INPUT_DIR}"/"${FILE}" "${INPUT_DIR}"/unpaper-"${FILE}"

    # Convert to PDF and perform OCR
    tesseract "${INPUT_DIR}"/unpaper-"${FILE}" "${INPUT_DIR}"/ocred-"${FILE}" -l deu pdf
done

# Check if at least one page is ready
if [ -f "${INPUT_DIR}"/ocred-*.pdf ]; then
    # Yes: Join PDFs
    pdfunite "${INPUT_DIR}"/ocred-*.pdf "${INPUT_DIR}"/preview.pdf
fi

# Remove temporary directory
if [ -f "${INPUT_DIR}"/complete ]; then
    if [ -f "${INPUT_DIR}"/preview.pdf ]; then
        mv "${INPUT_DIR}"/preview.pdf "${OUTPUT_DIR}"/"${FILENAME}.pdf"
        rm -Rf "${INPUT_DIR}"
        echo Done. Created output: "${OUTPUT_DIR}"/"${FILENAME}.pdf"
    else
        echo All input files were empty, aborting
    fi
else
    echo Scan aborted. Created output: "${INPUT_DIR}"/preview.pdf
fi
