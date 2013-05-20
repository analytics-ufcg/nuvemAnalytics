#!/bin/bash
# ATTENTION: Run from the project root directory

TRACE_DIR="data/traces/"
OUTPUT_DIR="data/output2/"
FIRST_VM_ID=251
LAST_VM_ID=500
PERC_FAIL_COLLECT=0.01
PERC_FAIL_METRIC=0.05

Rscript src/rCode/data_generator.R $TRACE_DIR $OUTPUT_DIR $FIRST_VM_ID $LAST_VM_ID $PERC_FAIL_COLLECT $PERC_FAIL_METRIC
