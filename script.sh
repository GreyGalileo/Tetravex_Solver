#!/bin/bash

# Bash script to play Tetravex. 
# The dimensions of the board and the values of the 4 quadrants per tile are set on lines 156 and 158 to 161 of todimacs.ml.

# Production of a file example1.txt in DIMACS format that can be used by a SAT solver to find a solution
ocaml todimacs.ml

# Feeding the generated file to the SAT-solver.
minisat example1.txt result.txt


if [ -f "example1.txt" ]; then
    # If the Sat-Solver evaluate the model as unsatisfiable :
    if grep -q "UNSAT" "result.txt"; then
        echo "There's no solution, please try with new tile values"
    else
        python3 dimacs2graphics.py
    fi
else
    echo "The file example1.txt does not exist"
fi
