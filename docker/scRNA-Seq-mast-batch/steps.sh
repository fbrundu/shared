#!/bin/bash -x

############################################################
## This script should be run using 'bash' in order to parse
## ENVIRONMENT VARIABLES using 'source'

## MANIFEST is the only required input. It is assumed to be a
## full s3 path (s3://-) to a text file that will be downloaded.

############################################################

MANIFEST=$1

cd /home/ubuntu/
aws s3 cp ${MANIFEST} /home/ubuntu/manifest.txt

# Will fail if not a bash shell
source /home/ubuntu/manifest.txt

############################################################

# Removing whitespaces from formula
MODEL=$(echo ${MODEL} | tr -d ' ')

############################################################

# Just in case aws is not already in the path
export PATH="/root/.local/bin:$PATH"

############################################################
## Echo contents of MANIFEST for sanity check/ basic job info:

echo "workspace: ${WORKSPACE}"
echo "out name: ${OUT_NAME}"
echo "cdat: ${CDAT}"
echo "mat: ${MAT}"
echo "group ${GROUP}"
echo "model ${MODEL}"

############################################################
## Download the data

cd /home/ubuntu/

mkdir data
aws s3 cp s3://${WORKSPACE}/${CDAT} data/
aws s3 cp s3://${WORKSPACE}/${MAT} data/

############################################################
## Run the script

Rscript script.R \
	data/${MAT} data/${CDAT} ${GROUP} ${MODEL} ${OUT_NAME} \
    > out.log 2> error.log

############################################################
## Upload results and logs

aws s3 cp ${OUT_NAME} s3://${WORKSPACE}/
aws s3 cp out.log s3://${WORKSPACE}/
aws s3 cp error.log s3://${WORKSPACE}/
