type section = Keymapping | Combos

let ( >>= ) = Result.bind
let str_of_char = String.make 1

let make_pair ?(delimiter = ':') map_str =
  match String.split_on_char delimiter map_str with
  | [ lhs; rhs ] -> (
      match (String.trim lhs, String.trim rhs) with
      | "", _ -> Error "Empty lhs"
      | _, "" -> Error "Empty rhs"
      | keymap -> Ok keymap)
  | _ :: _ | [] ->
      Error (str_of_char delimiter ^ " delimiter is needed between 2 terms")

let make_move_lst (m, n) =
  let moves =
    match String.split_on_char ',' m with
    | _ :: _ as move_lst ->
        if List.exists (String.equal "") move_lst then Error "Empty move"
        else Ok (move_lst |> List.map String.trim)
    | [] -> Error "Moves are missing"
  in
  Ok (moves, n)

let strlines_to_tuplelst s = String.trim s |> make_pair
let tokenize_keymapping = strlines_to_tuplelst
let tokenize_moves s = strlines_to_tuplelst s |> Fun.flip ( >>= ) make_move_lst

let get filename =
  try
    let ic = open_in filename in
    let rec read_all_lines s (keymapping, combos) =
      try
        let line = input_line ic |> String.trim in
        if line = "*" then read_all_lines Combos (keymapping, combos)
        else if line = "" then read_all_lines s (keymapping, combos)
        else tokenize s line (keymapping, combos)
      with End_of_file ->
        close_in ic;
        Ok (List.rev keymapping, List.rev combos)
    and tokenize s line (keymapping, combos) =
      match s with
      | Keymapping ->
          tokenize_keymapping line >>= fun km ->
          read_all_lines s (km :: keymapping, combos)
      | Combos ->
          tokenize_moves line >>= fun (m, n) ->
          m >>= fun mv -> read_all_lines s (keymapping, (mv, n) :: combos)
    in
    match read_all_lines Keymapping ([], []) with
    | Ok p -> Ok p
    | Error e ->
        close_in ic;
        Error ("Tokenization error: " ^ e)
  with Sys_error msg -> Error ("get " ^ filename ^ " error: " ^ msg)
