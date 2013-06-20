#/bin/bash
BIN_DIR=`dirname $0`
BIN_DIR="${BIN_DIR}/"

OUTPUTDIR="./output"
if [ ! -d "$OUTPUTDIR" ]; then
	mkdir "$OUTPUTDIR"
fi
OUTPUTDIR=`realpath ${OUTPUTDIR}`

INPUT_LATEX_SOURCE=$1
FILENAMEPREFIX=`echo ${INPUT_LATEX_SOURCE}|sed - -r -e"s/(.+)\.tex$/\1/g"`

LATEX_RUNTIME="latex"
${BIN_DIR}/run-latex.sh -i ${INPUT_LATEX_SOURCE} -o ${OUTPUTDIR} -rt $LATEX_RUNTIME

LATEX_RUNTIME="pdflatex"
${BIN_DIR}/run-latex.sh -i ${INPUT_LATEX_SOURCE} -o ${OUTPUTDIR} -rt $LATEX_RUNTIME

sleep 1

xdvi -s 4 ${OUTPUTDIR}/${FILENAMEPREFIX}/${FILENAMEPREFIX}
