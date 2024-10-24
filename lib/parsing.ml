exception Parsing_error of string

let ( >>= ) = Result.bind
let str_of_char = String.make 1

let make_tuple ?(delimiter = '-') map_str =
  match String.split_on_char delimiter map_str with
  | [ lhs; rhs ] -> (
      match (lhs, rhs) with
      | "", _ -> Error "Empty lhs"
      | _, "" -> Error "Empty rhs"
      | keymap -> Ok keymap)
  | _ :: _ | [] ->
      Error (str_of_char delimiter ^ " delimiter is needed between 2 terms")

let strlines_to_tuplelst s =
  String.(split_on_char '\n' @@ trim s) |> List.map make_tuple

let make_move_lst (m, n) =
  let moves =
    match String.split_on_char ',' m with
    | _ :: _ as move_lst ->
        if List.exists (String.equal "") move_lst then Error "Empty move"
        else Ok move_lst
    | [] -> Error "Moves are missing"
  in
  Ok (moves, n)

let parse_keymapping = strlines_to_tuplelst

let parse_moves s =
  strlines_to_tuplelst s |> List.map (Fun.flip ( >>= ) make_move_lst)

let print_km (k, m) =
  Printf.printf "(k:%s, m:%s)\n" k m;
  Ok ()

let print_mn (m, n) =
  m >>= fun moves_str ->
  List.iter (fun m -> Printf.printf "%s," m) moves_str;
  Printf.printf " - %s\n" n;
  Ok ()

let print_err = Result.iter_error (fun e -> print_endline @@ "error: " ^ e)
let process_result f r = r >>= f |> print_err
let print_k = List.iter (process_result print_km)
let print_m = List.iter (process_result print_mn)

let parse_content s =
  match String.split_on_char '*' s with
  | [ keymapping; moves ] ->
      let k = parse_keymapping keymapping in
      let c = parse_moves moves in
      print_k k;
      print_m c
  | _ -> raise (Parsing_error "Grammar file must contain one '*' delimiter")
