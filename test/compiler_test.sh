#!/bin/bash

NC='\033[0m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'

INPUT_FILES="compiler/*.sq"
ERROR_FILES="compiler/fail-*.sq"
printf "${CYAN}Running compiler tests...\n${NC}"

for input_file in $INPUT_FILES; do
    llfile=${input_file/.sq/.ll}
    tmpfile=${input_file/.sq/.tempout}
    output_file=${input_file/.sq/.out}

    # compile stockq program to llvm file
    ../compiler/stockq.sh $input_file -c $llfile

    lli "$llfile" > "$tmpfile"
    echo '' >> "$tmpfile"

    # if test output file exists, compare compiled output to it
    if [ -e "$output_file" ]; then
        cmp -s $tmpfile $output_file
        if [ "$?" -ne 0 ]; then
            printf "%-65s ${RED}ERROR\n${NC}" "  - checking $output_file..." 1>&2
            rm -f $llfile $tmpfile
            exit 1
        fi
    fi

    printf "%-65s ${GREEN}SUCCESS\n${NC}" "  - checking $input_file..."
    rm -f $llfile $tmpfile
done

for input_file in $ERROR_FILES; do
    tmpfile=${input_file/.err/.tempout}
    output_file=${input_file/.err/.out}

    # compile stockq program to llvm file
    ../compiler/stockq -c &> $tmpfile < $input_file

    # if test output file exists, compare compiled output to it
    if [ -e "$output_file" ]; then
        cmp -s $tmpfile $output_file
        if [ "$?" -ne 0 ]; then
            printf "%-65s ${RED}ERROR\n${NC}" "  - checking $output_file..." 1>&2
            rm -f $llfile $tmpfile
            exit 1
        fi
    fi

    printf "%-65s ${GREEN}SUCCESS\n${NC}" "  - checking $input_file..."
    rm -f $llfile $tmpfile
done

exit 0
