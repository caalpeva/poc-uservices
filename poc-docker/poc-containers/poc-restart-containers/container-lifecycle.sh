#!/bin/bash

EXIT_CODE=$1

echo ">> STARTED >>"
sleep 1
echo "== STOPPED == ($EXIT_CODE)"
exit $EXIT_CODE
