let max_w = 80
let soi = string_of_int
let get_transition_s (s, m, e) = "(" ^ soi s ^ ", [" ^ m ^ "], " ^ soi e ^ ")"
let get_move_s ?(nl = "\n") movename = "[" ^ movename ^ "]" ^ nl
let get_keymapping_s (key, movename) = key ^ " -> " ^ get_move_s movename
let get_verbose_s fs name = "found end state for '" ^ name ^ "' at: " ^ soi fs

let get_combomap_s (finale_state, combo_name) =
  "{" ^ soi finale_state ^ " -> " ^ combo_name ^ "}"

let get_last_line s =
  match List.rev @@ String.split_on_char '\n' s with
  | [] -> ""
  | last_line :: _ -> last_line

let concat f acc tr =
  let s = f tr in
  if String.length (get_last_line acc) + String.length s > max_w then
    acc ^ "\n" ^ s
  else acc ^ s

let concat_transitions acc tr = concat get_transition_s acc tr
let concat_combomap acc combomap = concat get_combomap_s acc combomap
let concat_keymapping acc keymapping = concat get_keymapping_s acc keymapping
let print f title a = print_endline @@ List.fold_left f title a
let print_transitions = print concat_transitions "Transitions:\n"
let print_combomap = print concat_combomap "Final states -> combo name:\n"
let print_keymapping = print concat_keymapping "key mapping:\n"
let log_move m = print_endline @@ get_move_s ~nl:"" m
let log_combo_name cbn = print_endline @@ cbn
let log_verbose fs name = print_endline @@ get_verbose_s fs name

let print_verbose tr cb =
  print_transitions tr;
  print_combomap cb
