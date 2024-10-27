let pick_nested_move_lst pair_lst =
  let _, tr_lstlst = List.split pair_lst in
  List.flatten tr_lstlst

let pick_nested_maxstate pair_lst =
  let max_lst, _ = List.split pair_lst in
  max_lst

let tr_compare (i1, m1, o1) (i2, m2, o2) =
  Int.(compare i1 i2 + compare o1 o2) + String.compare m1 m2

let tr_eq_partial (i1, m1) (i2, m2, _) = i1 = i2 && m1 = m2
let concat_tr_lists pair_lst tr_lst = pick_nested_move_lst pair_lst @ tr_lst

let find_current pair_lst p =
  pick_nested_move_lst pair_lst |> List.find_opt (tr_eq_partial p)

let concat_in_out acc (i, _, o) = i :: o :: acc
let concat_in acc (i, _, _) = i :: acc
let sort_uniq = List.sort_uniq Int.compare
let get_all_states tr_lst = List.fold_left concat_in_out [] tr_lst |> sort_uniq
let get_all_input_st tr_lst = List.fold_left concat_in [] tr_lst |> sort_uniq

let get_maxstate tr_lst =
  Option.value ~default:0
    List.(get_all_states tr_lst |> rev |> Fun.flip nth_opt 0)

let build_transition pair_lst (st_in, tr_lst) move =
  match find_current pair_lst (st_in, move) with
  | Some (st_in, move, st_out) -> (st_out, (st_in, move, st_out) :: tr_lst)
  | None ->
      let next_state = (get_maxstate @@ concat_tr_lists pair_lst tr_lst) + 1 in
      (next_state, (st_in, move, next_state) :: tr_lst)

let get_transition_list pair_lst l =
  let final_st, tr_lst = List.fold_left (build_transition pair_lst) (0, []) l in
  (final_st, List.rev tr_lst) :: pair_lst

let el_equal e1 e2 = Int.compare e1 e2 = 0
let is_member l e = List.exists (el_equal e) l

let add_el l2 acc a =
  match is_member l2 a with true -> acc | false -> a :: acc

let difference l1 l2 = List.fold_left (add_el l2) [] l1

let create_assoc_lst acc (in_st, m, out_st) =
  match List.assoc_opt m acc with
  | Some tr_lst -> (m, (in_st, m, out_st) :: tr_lst) :: List.remove_assoc m acc
  | None -> (m, [ (in_st, m, out_st) ]) :: acc

let create_missing_transitions all_states (move_name, tr) =
  let input_state = get_all_input_st tr in
  let diff = difference all_states input_state in
  match List.find_opt (tr_eq_partial (0, move_name)) tr with
  | Some (_, _, o) -> List.map (fun st -> (st, move_name, o)) diff @ tr
  | None -> tr

let get_missing_transitions transitions =
  let all_states = get_all_states transitions in
  List.fold_left create_assoc_lst [] transitions
  |> List.map (create_missing_transitions all_states)
  |> List.flatten

let train combos =
  let combo_moves, combo_names = List.split combos in
  let final_states, transitions_lst =
    List.(fold_left get_transition_list [] combo_moves |> rev |> split)
  in
  let comboname_state_mapping =
    List.combine final_states combo_names |> List.combine combo_moves
  and transitions =
    List.flatten transitions_lst
    |> List.sort_uniq tr_compare |> get_missing_transitions
  in
  Ok (transitions, comboname_state_mapping)
