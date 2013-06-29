#/usr/bin/env python

#"""
#function run_latex(){
#	$runtime_executable -output-directory=${OUTPUTDIR} -shell-escape $TEXFILETMPPATH
#	sleep 1
#	bibtex8 ${OUTPUTDIR}${FILENAMEPREFIX}
#	sleep 1
#	makeindex ${OUTPUTDIR}${FILENAMEPREFIX}
#	sleep 1
#	$runtime_executable -output-directory=${OUTPUTDIR} -shell-escape $TEXFILETMPPATH
#	sleep 1
#	$runtime_executable -output-directory=${OUTPUTDIR} -shell-escape $TEXFILETMPPATH
#}
#
#function run_all(){
#	prepare_environment
#
#	${BIN_DIR}run-cleanup-accent.sh $TEXFILETMPPATH
#
#	run_latex
#}
#"""

import argparse
import os
import re
import shutil
import subprocess
import time

import logging
logging.basicConfig()
LOG = logging.getLogger(__name__)
LOG.setLevel(logging.DEBUG)

class LatexUI():
    def __init__(self):
        self.builddir = None
        self.name = None
        self.runtime = "latex"
        self.source = None

    def run(self):
        LOG.info("Running LaTeX")
        subprocess.call([self.runtime, "-output-directory", self.builddir, "-shel-escape", self.source])

        LOG.info("Running BiBTeX8")
        subprocess.call(["bibtex8", os.path.relpath(os.path.join(self.builddir, "%s.aux"%self.name))])

        LOG.info("Making Indexes")
        subprocess.call(["makeindex", self.builddir])

        LOG.info("Running LaTeX")
        subprocess.call([self.runtime, "-output-directory", self.builddir, "-shel-escape", self.source])

        LOG.info("Running BiBTeX8")
        subprocess.call(["bibtex8", os.path.relpath(os.path.join(self.builddir, "%s.aux"%self.name))])

        LOG.info("Running LaTeX")
        subprocess.call([self.runtime, "-output-directory", self.builddir, "-shel-escape", self.source])

        LOG.info("Opening Viewer")
        subprocess.call([self.viewer, os.path.join(self.builddir, self.name+".dvi")])

    def prepareEnvironment(self, parameters):
        artifactname = parameters.input
        artifactPath = os.path.abspath(artifactname)
        nameRegex = re.match("^(.+)\.tex$", artifactname)

        self.name = nameRegex.group(1)
        self.builddir = os.path.join(os.getcwd(), parameters.outdir, self.name)

        if os.path.exists(self.builddir):
            LOG.info("\n"*8)
            LOG.info("###### Cleaning up: %s" % self.builddir)
            LOG.info("\n"*8)
            shutil.rmtree(self.builddir)

        os.makedirs(self.builddir)
        self.source = os.path.join(self.builddir, artifactname)

        shutil.copyfile(artifactname, self.source)

        targetResourcesPath = os.path.join(self.builddir, "resources")
        if os.path.isdir(targetResourcesPath):
            shutil.rmtree(targetResourcesPath)
        shutil.copytree(os.path.join(os.path.dirname(artifactPath), "resources"), targetResourcesPath)

        self.viewer = parameters.viewer

    def validateParameters(self, parameters):
        if not os.path.isfile(parameters.input):
            raise ValueError("Invalid Input File")

        if not os.path.isdir(parameters.outdir):
            raise ValueError("Invalid Output Directory")

    def main(self, args):
        parser = argparse.ArgumentParser()
        parser.add_argument("-i", "--input", dest="input", help="Source LaTeX file", required=True)
        parser.add_argument("-o", "--outdir", dest="outdir", help="Output Directory", required=True)
        parser.add_argument("-r", "--runtime", dest="runtime", help="Runtime Environment", default="latex")
        parser.add_argument("-v", "--viewer", dest="viewer", help="Viewer", default="xdvi")
        parser.add_argument("-s", "--runviewer", dest="runviewer", help="Open Output File on Viewer", default=False)

        values = parser.parse_args(args=args)
        self.validateParameters(values)
        self.prepareEnvironment(values)
        self.run()


if __name__ == "__main__":
    import sys
    LatexUI().main(sys.argv[1:])
