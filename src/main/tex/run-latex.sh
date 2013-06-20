#!/bin/bash

BIN_DIR=`dirname $0`
BIN_DIR="${BIN_DIR}/"

input_latexsource=""
output_directory=""
runtime_executable=""

OUTPUTBASEDIR=""
OUTPUTDIR=""
FILENAMEPREFIX=""
TEXFILENAME=""
TEXFILETMPPATH=""


function show_error(){
	local MSG=$1
	echo "An error occured on $0"
	echo "Message: $MSG"
}

function prepare_environment(){
	runtime_executable_default="latex"
	if [ "$runtime_executable" = ""	]; then
		runtime_executable="$runtime_executable_default"
	fi	

	OUTPUTBASEDIR="${output_directory}"
	FILENAMEPREFIX=`echo $input_latexsource|sed - -r -e"s/(.+)\.tex$/\1/g"`
	OUTPUTDIR="${OUTPUTBASEDIR}/${FILENAMEPREFIX}/"

	TEXFILENAME="${FILENAMEPREFIX}.tex"
	TEXFILETMPPATH="${OUTPUTDIR}${TEXFILENAME}"

	mkdir -pv $OUTPUTDIR
	cp ${TEXFILENAME} ${TEXFILETMPPATH}
}

function flush_environment(){
	echo "input_latexsource: $input_latexsource"
    echo "output_directory:  $output_directory"
	echo "OUTPUTBASEDIR:     $OUTPUTBASEDIR"
	echo "OUTPUTDIR:         $OUTPUTDIR"
	echo "FILENAMEPREFIX:    $FILENAMEPREFIX"
	echo "TEXFILETMPPATH:    $TEXFILETMPPATH"
}

function run_latex(){
	$runtime_executable -output-directory=${OUTPUTDIR} -shell-escape $TEXFILETMPPATH
	sleep 1
	bibtex8 ${OUTPUTDIR}${FILENAMEPREFIX}
	sleep 1
	makeindex ${OUTPUTDIR}${FILENAMEPREFIX}
	sleep 1
	$runtime_executable -output-directory=${OUTPUTDIR} -shell-escape $TEXFILETMPPATH
	sleep 1
	$runtime_executable -output-directory=${OUTPUTDIR} -shell-escape $TEXFILETMPPATH
}

function run_all(){
	prepare_environment

	${BIN_DIR}run-cleanup-accent.sh $TEXFILETMPPATH

	run_latex
}

function validate_parameters(){
	if [ ! -f "$input_latexsource" ]; then
		show_error "Invalid input file $input_latexsource"
		exit 1
	fi

	if [ "$output_directory" = "" ]; then
		show_error "Invalid output directory value. It cannot be empty."
		exit 1
	fi
}

function show_usage(){
	echo "-i : Input LaTeX document"
	echo "-o : Output staging directory"
}

while [[ $1 ]]
do
	case "$1" in
		-i )
			shift
			input_latexsource=$1
			;;
		-o )
			shift
			output_directory=$1
			;;
		-rt | --runtime)
			shift
			runtime_executable=$1
			;;

		-h | --help)
			show_usage
			exit 0
			;;
		*)
			show_error "Invalid parameter: $1"
			show_usage
			exit 1
			;;
	esac
	shift
done

validate_parameters
prepare_environment
flush_environment
run_all
