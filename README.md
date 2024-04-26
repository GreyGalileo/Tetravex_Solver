This is project with the goal of using a DIMACS SAT-Solver to solve a game of tetravex in the context of the 2024 INF432 course at Universite Grenoble Alpes.

We define our own file format containg on the first line the length and height of the tetravex board we're playing on. 
On each subsequent line we give the configuration of a tile by giving the values in its "quadrants" (the triangles holding values) in order: top bottom left right.

It is assumed that none of the tiles provided are identical, i.e. they are all pairwise distinct. If a game is entered with identical tiles the solution will most likely be fallacious.

Note that memory and time complexity are exponential with respect to the size of the board, entering games bigger than 3x3 is strongly discouraged.

The bash script script.sh takes one file argument and runs the solver (the various programs) on the game in thee file.
script.sh takes a file input and streamlines the process of looking for a model and representing it in a readable fashion, the script calls several other programs:

We have a program written in Python, verify_format.py, in order to check that the format of the file to be used as input by the Ocaml program (todimacs.ml) is correct.

We have a program written in Ocaml which transforms this into a DIMACS file where our propositional variables represent whether or not a given quadrant contains a given value.

We then call minisat on the dimacs file to get the satisfiability and a model.

If we have a model the python script "dimacs2graphics.py" represents this model in the terminal (stdout) as the blocs and tiles that it contains.
