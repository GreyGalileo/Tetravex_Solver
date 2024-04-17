(*
In this entire program we have numbered our spaces from 0 to n*m-1
We take the integers (0, 1, 2, 3) to be (top, bottom, left, right)
for a value v in a quadrant q in a space s, the associated boolean variable will be:
36*s + q*9 + v
*)

(*
Clauses are represented as lists of integers, the integers being variables
We ill assemble a set of clauses as a list of lists and 
convert this to strings at the end of the program when we output to a file
*)
type clasue = int list;;
type set_clauses = int list list;;

(*--INPUT--*)
(*Reading the information from the import file*)

let length_board = 2;;
let height_board = 2;;



(*-- XOR clauses ( * ) --*)
(* Creating lists of clauses for the equation *, the xor in a single quadrant
These clauses should express the fact that only one value of a quadrant can be true at a time
*)


let rec auxiliary_2var_clauses firstvar secondvar =
  match (firstvar, secondvar) with
  | (x,_) when x>=0 -> []
  | (_,y) when y>=0 -> auxiliary_2var_clauses (firstvar+1) (firstvar+2)
  | _ -> [firstvar; secondvar] :: auxiliary_2var_clauses firstvar (secondvar+1);;

let negated_2var_clauses = auxiliary_2var_clauses (-9) (-8);;
(*clasues containing negation of 2 values for each choice of 2 variables between 1 and 9*)



let create_quadrant_clauses: int -> int -> set_clauses =
  fun space quadrant ->
  (* creates the set of clauses translating that the given quadrant can only have 1 value at a time*)
  let shift: int->int = fun i -> 9*(space*4+quadrant) + i in
  List.init 9 ( fun i -> shift i + 1 ) :: (List.map (List.map shift) negated_2var_clauses);;
  (*returns ^ the clause that tells us one of the variables must be true and ^
     the clause that says that no 2 of the variables can be true at the same time
  *)


List.iter (fun l -> (print_string "["); (List.iter (fun i -> print_int i; print_string ", ") l); (print_string "]\n")) (create_quadrant_clauses 0 0);;
