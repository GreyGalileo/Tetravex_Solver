#!/bin/bash

# Function to print a colored separator line
print_separator() {
    printf "\n\e[1;35m-------------------------------------------------------------------------------\e[0m\n\n"
}


# Set of relevant test
print_separator

# Tests verify_format.py
echo -e "\e[1;35mTest on a 2x2 board, format error expected : file 2x2_pb_format1.txt \e[0m\n"
./script.sh ./TEST_FILES/2x2_pb_format1.txt 
print_separator

echo -e "\e[1;35mTest on a 2x2 board, format error expected : file 2x2_pb_format2.txt \e[0m\n"
./script.sh ./TEST_FILES/2x2_pb_format2.txt 
print_separator

echo -e "\e[1;35mTest on a 2x2 board, format error expected : file 2x2_pb_format3.txt \e[0m\n"
./script.sh ./TEST_FILES/2x2_pb_format3.txt 
print_separator

echo -e "\e[1;35mTest on a 2x2 board, format error expected : file 2x2_pb_format4.txt \e[0m\n"
./script.sh ./TEST_FILES/2x2_pb_format4.txt 
print_separator


# Test on a 2x2 board (no solution)
echo -e "\e[1;35mTest on a 2x2 board, no solution expected : file 2x2_no_sol.txt \e[0m\n"
./script.sh ./TEST_FILES/2x2_no_sol.txt
print_separator

# Test on a 2x2 board
echo -e "\e[1;35mTest on a 2x2 board : file 2x2.txt \e[0m\n"
./script.sh ./TEST_FILES/2x2.txt
print_separator

echo -e "\e[1;35mTest on a 2x2 board : file 2x2_bis.txt \e[0m\n"
./script.sh ./TEST_FILES/2x2_bis.txt
print_separator

# Test on a 3x3 board
echo -e "\e[1;35mTest on a 3x3 board : file 3x3.txt \e[0m\n"
./script.sh ./TEST_FILES/3x3.txt
print_separator
