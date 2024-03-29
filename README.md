This is project with the goal of using a DIMACS SAT-Solver to solve a game of tetravex in the context of the 2024 INF432 course at Universite Grenoble Alpes.

We define our own file format containg on the first line the length and height of the tetravex board we're playing on. 
On each subsequent line we give the configuration of a tile by giving the values in its "quadrants" (the triangles holding values) in order: top bottom left right.

We have a program written in Ocaml which trasforms this into a DIMACS file where our propositional variables represent whether or not a given quadrant contains a given value.
