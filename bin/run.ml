type transition = int * string * int
type keymap = string * string
type moves = string list
type combomapping = moves * (int * string)

let ( >>= ) = Option.bind
let move_eq curr_k (k, _) = curr_k = k
let transition_eq (cm, cs) (i, m, _) = cm = m && cs = i
let state_eq curr_st (_, (st, _)) = curr_st = st
let find f curr = List.find_opt (f curr)
let find_move key keymapping = find move_eq key keymapping
let find_transition curr transitions = find transition_eq curr transitions
let find_final_state curr combo_st_map = find state_eq curr combo_st_map

let log_combo log ((_, _, next_state) as transition) mapping =
  match find_final_state next_state mapping with
  | Some combo_map -> log combo_map transition
  | None -> ()

let evaluate (transitions, comboname_state_mapping, keymapping) combo_logger =
  let rec loop current_state () =
    let key = Ft_ality.Keyboard.detect_keypress () in

    if key <> "esc" then
      match
        find_move key keymapping >>= fun (_, move) ->
        find_transition (move, current_state) transitions
      with
      | Some ((_, _, next_state) as transition) ->
          log_combo combo_logger transition comboname_state_mapping;
          loop next_state ()
      | None -> loop 0 ()
  in
  loop 0 ()
