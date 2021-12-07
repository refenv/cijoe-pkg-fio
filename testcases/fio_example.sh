#!/bin/bash

CIJ_TEST_NAME=$(basename "${BASH_SOURCE[0]}")
export CIJ_TEST_NAME
# shellcheck source=modules/cijoe.sh
source "$CIJ_ROOT/modules/cijoe.sh"

test.enter

: "${FIO_FILENAME?Must be set and non-empty}"
: "${FIO_BIN:=fio}"
: "${FIO_SIZE:=256M}"
: "${FIO_IODEPTH:=8}"
: "${FIO_BS:=64k}"
: "${FIO_NUMJOBS:=4}"
: "${FIO_IOENG_NAME:=io_uring}"
: "${FIO_RW:=write}"
: "${FIO_IODIRECT:=1}"
: "${FIO_TEST_NAME:=${CIJ_TEST_NAME}}"
: "${FIO_STATUS_INTERVAL:=20}"
: "${FIO_USE_OFFSET_INCREMENT:=0}"
: "${FIO_OFFSET_INCREMENT:=25%}"
: "${FIO_USE_WRITE_RATE:=0}"
: "${FIO_WRITE_RATE:=250m}"
: "${FIO_OUTPUT_FILE:=/tmp/fio_example.output}"
: "${FIO_OUTPUT_FORMAT:=json}"
: "${FIO_RUNTIME:=50}"

LOCAL_FIO_OUTPUT_FILE="${CIJ_TEST_AUX_ROOT}/fio-output-$(basename $FIO_OUTPUT_FILE)"

cij.cmd "rm -rfv ${FIO_OUTPUT_FILE}"
RET=${?}
if [ ${RET} -ne 0 ] ; then
  cij.err "rm -rfv ${FIO_OUTPUT_FILE}"
  test.fail
fi

cij.cmd "${FIO_BIN} -filename=${FIO_FILENAME} \
  --size=${FIO_SIZE} \
  --direct=${FIO_IODIRECT} \
  --ioengine=${FIO_IOENGINE} \
  --name=${FIO_TEST_NAME} \
  --rw=${FIO_RW} \
  --bs=${FIO_BS} \
  --iodepth=${FIO_IODEPTH} \
  --numjobs=${FIO_NUMJOBS} \
  --status-interval=${FIO_STATUS_INTERVAL} \
  --output-format=${FIO_OUTPUT_FORMAT} \
  --output=${FIO_OUTPUT_FILE} \
  --runtime=${FIO_RUNTIME}"
RET=${?}
if [ ${RET} -ne 0 ] ; then
  cij.err "${FIO_BIN} failed!"
  test.fail
fi

# Fetch the fio output file to local storage such that we can
# extract data from it using cij_extractor
cij.pull ${FIO_OUTPUT_FILE} "${LOCAL_FIO_OUTPUT_FILE}"

test.pass
