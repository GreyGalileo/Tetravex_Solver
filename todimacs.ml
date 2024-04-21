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



type clause = int list;;
type set_clauses = int list list;;

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



let create_quadrant_clauses_one_quadrant: int -> int -> set_clauses =
(* creates the clauses for a given quadrant (s,q) where s is the number of a space on the board and q in in [1,4]*)
  fun space quadrant ->
  (* creates the set of clauses translating that the given quadrant can only have 1 value at a time*)
  let shift: int =  9*(space*4+quadrant) in
  List.init 9 ( fun i -> shift + i + 1 ) :: (List.map (List.map (fun i -> i - shift)) negated_2var_clauses);;
  (*returns ^ the clause that tells us one of the variables must be true and ^
     the clause that says that no 2 of the variables can be true at the same time
     both are shifted by our constant "shift", which encodes which space and quadrant we are considering
  *)

let create_quadrant_clauses_one_space: int -> set_clauses =
    (*creates all quadrant clauses for one space on the board, which always contains top,bottom,left,right = 0,1,2,3*)
    fun space ->
    let f_clauses = create_quadrant_clauses_one_quadrant space in
    f_clauses 0 @ f_clauses 1 @ f_clauses 2 @ f_clauses 3;;

    

let rec create_quadrant_clauses: int -> set_clauses =
  (*Takes the size of the board [in number of spaces] and creates correspondingly many clauses for each quadrant*)
  fun num_spaces ->
    match num_spaces with
    |s when s<0 -> []
    |0 -> create_quadrant_clauses_one_space 0 
    |n -> (create_quadrant_clauses_one_space n) @ create_quadrant_clauses (n-1);;




(* --ADJACENCY CLAUSES ( ** )-- *)
(* Creating lists of clauses for the equation *, the euivqlence between adjacent quadrants, 
i.e. top and bottom and leeft and right of spaces that are next to each other
*)
let rec bottom_adjacency_clauses_aux: int -> int -> int -> set_clauses =
  (*creates the adjacency clauses that posit that *)
  fun index line_length space ->
    let bottomq = space*36 + 10 and topq = (space + line_length)*36 + 1 in
    match index with
    |n when n<0 -> []
    |n -> [[bottomq + n; (-1)*(topq + n)];[(-1)*(bottomq + n); (topq + n)]] @ bottom_adjacency_clauses_aux (index-1) line_length space;;


let bottom_adjacency_clauses: int -> int -> set_clauses = bottom_adjacency_clauses_aux 9;;

let rec right_adjacency_clauses_aux: int -> int -> set_clauses =
  fun index space -> 
    let rightq = space*36 + 3 * 9 + 1 and leftq = (space + 1) * 36 + 2 * 9 + 1 in
    match index with
    |n when n<0 -> []
    |n -> [[rightq + n; (-1)*(leftq + n)];[(-1)*(rightq + n); (leftq + n)]] @ right_adjacency_clauses_aux (index-1) space;;

let right_adjacency_clauses: int -> set_clauses = right_adjacency_clauses_aux 9;;

let create_adjacency_clauses: int -> int -> set_clauses =
  fun lines columns ->
    let create_adj_clauses_one_space: int -> set_clauses = fun space ->
      match space with
      |n when (n >= lines*columns - 1) -> []
      |n when (n mod lines == lines-1 ) -> bottom_adjacency_clauses lines space
      |n when (n >= lines*(columns - 1) - 1) -> right_adjacency_clauses space
      |n -> (bottom_adjacency_clauses lines space) @ (right_adjacency_clauses space)
    in 
    let rec create_adj_clauses_from: int -> set_clauses =
      fun index ->
        match index with
        |n when (n >= lines * columns - 1) -> []
        |n -> create_adj_clauses_one_space index @ create_adj_clauses_from (index+1)
    in
    create_adj_clauses_from 0 ;;


(*--TILE CLAUSES ( *** )--*)
type tile = {top: int; bottom:int; left:int; right:int};;

let create_clauses_single_tile (n:int) (t:tile) =
  (* creates CNF clauses for a single tile and for all n spaces on the board *)
  let variables_for_space s = 
    let v = s*36 in
     (v+t.top, v+9+t.bottom, v+18+t.left, v+27+t.right)
  in
  let variables = List.init n variables_for_space in
  let add_space_variables  (lst: int list list) (a,b,c,d) =
    List.fold_left (fun acc sublst -> acc @ [a::sublst ; b::sublst ; c::sublst ; d::sublst]) [] lst
  in
  List.fold_left add_space_variables ([[]]:int list list) variables;;



let create_tile_clauses (num_spaces: int) (tiles: tile list) =
  List.fold_left (fun acc ti -> acc @ create_clauses_single_tile num_spaces ti) [] tiles;;
(*takes a list of tiles and a number of spaces 
and gives a cnf expressinhg that each tile mush be present on on of th spaces*)


(*--INPUT--*)
(*Reading the information from the import file*)

let length_board = 2;;
let height_board = 2;;

(*--OUTPUT--*)
(*Outputting list of clauses to a dimacs file*)

let rec add_clause_to_string (s:string) (c:clause) = 
  match c with
  |[] -> s ^ " 0\n"
  |var::res -> add_clause_to_string (s ^ " " ^ (string_of_int var)) res;;

let create_dimacs_file (file:string) (num_spaces:int) (clauses:set_clauses)  =
  let oc = open_out file in
  let numvar = num_spaces * 36 and numclauses = List.length clauses in 
  let firstline = "p cnf " ^ (string_of_int numvar) ^ " " ^ (string_of_int numclauses) ^ "\n" in
  let body_of_text = List.fold_left add_clause_to_string firstline clauses in
  Printf.fprintf oc "%s" body_of_text;;


(*MAIN function*)
let main =
  let file = "example1.txt" in
  let t:tile list = [
    {top = 2; bottom = 1; left = 3; right = 1}; 
    {top = 2; bottom = 1; left = 1; right = 2}; 
    {top = 1; bottom = 3; left = 3; right = 1};  
    {top = 1; bottom = 3; left = 1; right = 2};
  ] in
  let num_columns = 2 and num_lines = 2 in
  let num_spaces = num_columns*num_lines in
  let adj_clauses = create_adjacency_clauses num_columns num_lines 
  and qud_clauses = create_quadrant_clauses (num_spaces-1)
  and tile_clauses = create_tile_clauses num_spaces t in
  let all_clauses = adj_clauses @ qud_clauses @ tile_clauses in
  create_dimacs_file file num_spaces all_clauses;;



(* Printing a list of lists for testing*)

(*
print_string "\nAdjacency clauses:\n";;

List.iter (fun l -> (print_string "["); (List.iter (fun i -> print_int i; print_string ", ") l); (print_string "]\n")) (create_adjacency_clauses 2 2);;

print_string "\nQuadrant clauses:\n";;

List.iter (fun l -> (print_string "["); (List.iter (fun i -> print_int i; print_string ", ") l); (print_string "]\n")) (create_quadrant_clauses 3);;

print_string "\nTile clauses:\n";;
List.iter (fun l -> (print_string "["); (List.iter (fun i -> print_int i; print_string ", ") l); (print_string "]\n")) (create_clauses_single_tile 4 t);;
*)