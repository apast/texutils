#/bin/bash
WORKDIR=`dirname $0`
OUTPUTDIR="output"
echo "Starting char replacement"
sed -f ${WORKDIR}/resources/sed/replace.accent.toLatex.sed -i $1
echo "Char replaced successfully"
