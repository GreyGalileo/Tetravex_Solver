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
(*#include <unistd.h>*)


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
    let bottomq = space*36 + 9 and topq = (space + line_length)*36 in
    match index with
    |n when n<=0 -> []
    |n -> [[bottomq + n; (-1)*(topq + n)];[(-1)*(bottomq + n); (topq + n)]] @ bottom_adjacency_clauses_aux (index-1) line_length space;;


let bottom_adjacency_clauses: int -> int -> set_clauses = bottom_adjacency_clauses_aux 9;;

let rec right_adjacency_clauses_aux: int -> int -> set_clauses =
  fun index space -> 
    let rightq = space*36 + 3 * 9 and leftq = (space + 1) * 36 + 2 * 9 in
    match index with
    |n when n<=0 -> []
    |n -> [[rightq + n; (-1)*(leftq + n)];[(-1)*(rightq + n); (leftq + n)]] @ right_adjacency_clauses_aux (index-1) space;;

let right_adjacency_clauses: int -> set_clauses = right_adjacency_clauses_aux 9;;

let create_adjacency_clauses: int -> int -> set_clauses =
    (*
    takes height and length of board in spaces 
    and produces CNF clauses translating the conditions 
    that 2 adjacent clauses must have the sam value
    using the CNF form of equivalences between the variables
    *)
  fun lines columns ->
    let create_adj_clauses_one_space: int -> set_clauses = fun space ->
      match space with
      |n when (n >= lines*columns - 1) -> []
      |n when (n mod lines == lines-1 ) -> bottom_adjacency_clauses lines space
      |n when (n >= lines*(columns - 1) - 1) -> right_adjacency_clauses space
      |n -> (bottom_adjacency_clauses lines space) @ (right_adjacency_clauses space)
    in 
    let rec create_adj_clauses_from: int -> set_clauses =
      (*auxiliary recursive function*)
      fun index ->
        match index with
        |n when (n >= lines * columns - 1) -> []
        |n -> create_adj_clauses_one_space index @ create_adj_clauses_from (index+1)
    in
    create_adj_clauses_from 0 ;;


(*--TILE CLAUSES ( *** )--*)
type tile = {top: int; bottom:int; left:int; right:int};;

let tseytin_tile_clauses_1tile (n:int) (t:tile) (tile_index:int) = 
  let start_index = (36 + tile_index) * n + 1 in
  let tsey_var_disjunction = List.init n (fun s -> start_index + s) in
  let clauses_space (s:int) = 
    let clause_num = s*36
    and tseytin_var = start_index+s in
    let val_vars = [clause_num + t.top; clause_num + 9 + t.bottom; clause_num + 18+t.left; clause_num + 27+t.right] in
    (tseytin_var :: (List.map (fun x -> -x) val_vars)) :: (List.map (fun v -> [-tseytin_var; v]) val_vars)
  in
  let rec create_all (i:int) =
    match i with
    |i when i >= n -> [tsey_var_disjunction]
    |_ -> (clauses_space i) @ create_all (i+1)
  in
  create_all 0;;


let create_tile_clauses_tseytin (n:int) (tiles: tile list) = 
  let rec create_all (tiles: tile list) (index:int) =
    match tiles with
    |[] -> []
    |t::res -> tseytin_tile_clauses_1tile n t index @ create_all res (index+1)
  in
  create_all tiles 0;;

(*PRINTS DIRECTLY WITH NAIVE CNF EXPANSION*)
(*
let int_exp x y = (float_of_int x) ** (float_of_int y) |> int_of_float;;

let direct_print_1tile_clauses (n:int) (t:tile) oc =
  let tile_array = Array.of_list [t.top; 9+t.bottom; 18+t.left; 27+t.right]
  and spaces_array = Array.init n (fun x -> 36*x) in
  let num_clauses = int_exp 4 n in(*4^n clauses total for n spaces and n tiles*)
  let rec print_clause (depth:int) (index:int)=
    match depth with
    |d when d >= n -> ()
    |_ -> Printf.fprintf oc "%d " (spaces_array.(depth) + tile_array.(index mod 4)); (print_clause (depth + 1) (index / 4))
  in
  for i = 0 to num_clauses-1 do
    print_clause 0 i;
    Printf.fprintf oc "0\n";
  done;;
  

let print_tile_clauses (num_spaces: int) (tiles: tile list) oc =
  (*This function prints the tile clauses directly to OC because there are too many to be handeled by create_dimacs function*)
  (* creates CNF clauses for the number of spaces on the board and for every tile in the list passed as an argument*)
  List.fold_left (fun _ ti -> direct_print_1tile_clauses num_spaces ti oc) () tiles;;
(*takes a list of tiles and a number of spaces 
and gives a cnf expressinhg that each tile mush be present on on of th spaces*)
*)

(*--INPUT--*)
(*Reading the information from the import file*)
exception WrongFileFormat;;

let get_digit (i:char) =
  (*Converts a character to a digit (int) provided it is between '0' and '9'*) 
  Char.code (i) - Char.code '0';;

let read_input (filename:string) = 
  (*
    Takes the name of a file as an argument and outputs: 
    the number of lines and columns, defined on the first line of the file
    a list of tiles, each defined on each subsequent line of the input file
  *)
  let input = open_in filename in
  let first_line = input_line input in
  let num_lines = get_digit (first_line.[0])
  and num_cols = get_digit (first_line.[2]) in
  let spaces = num_lines * num_cols in
  let t_array = Array.make spaces ({top = 1; bottom = 1; left = 1 ; right = 1}) in
  for i = 0 to spaces-1 do
    let line_text = input_line input in
    t_array.(i) <- {top = get_digit (line_text.[0]) ; bottom = get_digit (line_text.[2]) ; left = get_digit (line_text.[4]) ; right = get_digit (line_text.[6]) }
  done;
  (num_lines, num_cols, Array.to_list t_array);;


(*--OUTPUT--*)
(*Outputting list of clauses to a dimacs file*)

let rec add_clause_to_string (s:string) (c:clause) = 
  match c with
  |[] -> s ^ " 0\n"
  |var::res -> add_clause_to_string (s ^ " " ^ (string_of_int var)) res;;

let create_dimacs_file (file:string) (num_spaces:int) (clauses:set_clauses)  =
  let oc = open_out file in
  let numvar = num_spaces * (36 + num_spaces) and numclauses = (List.length clauses) in 
  let firstline = "p cnf " ^ (string_of_int numvar) ^ " " ^ (string_of_int numclauses) ^ "\n" in
  let body_of_text = List.fold_left add_clause_to_string firstline clauses in
  Printf.fprintf oc "%s" body_of_text;
  oc;;


(*MAIN function*)
let main =
  (*Takes 2 files as arguments
     The first being a file specifying the configuration of thee game
     This function takes this game and creates propositional clasues that allow it to be solved,
     Then puts these clauss in dimacs format and writes them to the second file
  *)
  let input_file = Sys.argv.(1) 
  and output_file = Sys.argv.(2) in
  let (num_columns, num_lines, t) = read_input input_file in
  let num_spaces = num_columns*num_lines in



  let adj_clauses = create_adjacency_clauses num_columns num_lines 
  and qud_clauses = create_quadrant_clauses (num_spaces-1)
  and tile_clauses =  create_tile_clauses_tseytin num_spaces t in

  let all_clauses = adj_clauses @ qud_clauses @ tile_clauses in
  create_dimacs_file output_file num_spaces all_clauses;;


(*
  let adj_clauses = create_adjacency_clauses num_columns num_lines 
  and qud_clauses = create_quadrant_clauses (num_spaces-1) in
  let non_tile_clauses = adj_clauses @ qud_clauses in 
  let oc = create_dimacs_file output_file num_spaces non_tile_clauses in
  print_tile_clauses num_spaces t oc;;
*)