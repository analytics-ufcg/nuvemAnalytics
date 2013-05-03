#!/bin/bash
# ATTENTIO: Run from the project root directory

TRACE_DIR="data/traces/"
OUTPUT_DIR="data/output/"
FIRST_VM_ID=1
LAST_VM_ID=100

Rscript src/rCode/data_generator.R $TRACE_DIR $OUTPUT_DIR $FIRST_VM_ID $LAST_VM_ID
