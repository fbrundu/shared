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

# Just in case aws is not already in the path
export PATH="/root/.local/bin:$PATH"

############################################################
## Echo contents of MANIFEST for sanity check/ basic job info:

echo "workspace: ${WORKSPACE}"
echo "reference: ${REF}"
echo "matrix: ${MAT}"
echo "labels: ${LABELS}"
echo "prediction out filename: ${PRED}"
echo "min cells for subsampling: ${MIN_CELLS}"
echo "n iterations for subsampling: ${N_ITER}"
echo "label ID: ${LABEL_ID}"
echo "confidence out filename: ${CONF}"

############################################################
## Download the data

cd /home/ubuntu/

mkdir data
aws s3 cp s3://${WORKSPACE}/${REF} data/
aws s3 cp s3://${WORKSPACE}/${MAT} data/
aws s3 cp s3://${WORKSPACE}/${LABELS} data/

############################################################
## Run the script

Rscript script.R \
    data/${REF} data/${MAT} data/${LABELS} ${PRED} ${MIN_CELLS} \
    ${N_ITER} ${LABEL_ID} ${CONF}
    > out.log 2> error.log

############################################################
## Upload results and logs

aws s3 cp ${PRED} s3://${WORKSPACE}/
aws s3 cp ${CONF} s3://${WORKSPACE}/
aws s3 cp out.log s3://${WORKSPACE}/
aws s3 cp error.log s3://${WORKSPACE}/
