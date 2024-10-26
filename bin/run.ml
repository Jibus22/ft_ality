let ( >>= ) = Option.bind
let move_eq curr_k (k, _) = curr_k = k
let transition_eq (cm, cs) (i, m, _) = cm = m && cs = i
let state_eq curr_st (st, _) = curr_st = st
let find f curr = List.find_opt (f curr)
let find_move key keymapping = find move_eq key keymapping
let find_transition curr transitions = find transition_eq curr transitions
let find_final_state curr combo_st_map = find state_eq curr combo_st_map

let evaluate (transitions, comboname_state_mapping, keymapping)
    (log_move, log_combo_name, log_verbose) =
  let rec loop current_state () =
    (match find_final_state current_state comboname_state_mapping with
    | Some (fs, name) ->
        log_verbose fs name;
        log_combo_name name
    | None -> ());

    let key = Ft_ality.Keyboard.detect_keypress () in

    if key <> "esc" then
      match
        find_move key keymapping >>= fun (_, move) ->
        log_move move;
        find_transition (move, current_state) transitions
        >>= fun (_, _, next_state) -> Some next_state
      with
      | Some next_state -> loop next_state ()
      | None -> loop 0 ()
  in
  loop 0 ()
