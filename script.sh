#!/bin/bash

# Bash script to play Tetravex. 
# The dimensions of the board and the values of the 4 quadrants per tile are set in the file game_file.txt

if python3 verify_format.py ; then
    echo "Continue with the other programs..."

    # Production of a file example1.txt in DIMACS format that can be used by a SAT solver to find a solution
    ocaml todimacs.ml game_file.txt dimacs.txt

    # Feeding the generated file to the SAT-solver.
    minisat dimacs.txt result.txt


    if [ -f "dimacs.txt" ]; then
        # If the Sat-Solver evaluate the model as unsatisfiable :
        if grep -q "UNSAT" "result.txt"; then
            echo "There's no solution, please try with new tile values"
        else
            python3 dimacs2graphics.py
        fi
    else
        echo "The file dimacs.txt does not exist"
    fi
else
    echo "Error: Incorrect file format. Execution stopped."
    exit 1  # Sortir avec un code d'erreur
fi
