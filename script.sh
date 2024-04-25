#!/bin/bash

# Bash script to play Tetravex. 
# The dimensions of the board and the values of the 4 quadrants per tile are set on lines 156 and 158 to 161 of todimacs.ml.

# Production of a file example1.txt in DIMACS format that can be used by a SAT solver to find a solution
ocaml todimacs.ml

# Feeding the generated file to the SAT-solver.
minisat example1.txt result_sat.txt

# If the Sat-Solver evaluate the model as unsatisfiable :
if grep -q "UNSAT" example1.txt; then
    echo "UNSATIFIABLE"
# If the Sat-Solver finds that the model is satisfiable, we graphically display the solution :
else
    python3 dimacs2graphics.py
fi

# Deletion of example1.txt, to avoid overwriting
rm example1.txt
