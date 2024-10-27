let ( >>= ) = Result.bind
let find_duplicate l = List.(length @@ sort_uniq String.compare l != length l)
let is_difference l1 l2 = not @@ List.for_all (Fun.flip List.mem l1) l2

let sanitize_keymapping km =
  let k, m = List.split km in
  match (find_duplicate k, find_duplicate m) with
  | true, _ -> Error "keys must be unique"
  | _, true -> Error "key mapping names must be unique"
  | false, false -> Ok m

let sanitize_combos cb kmn =
  let combo_mv, _ = List.split cb in
  let m_lst = List.map (List.fold_left ( ^ ) "") combo_mv in
  if find_duplicate m_lst then Error "combo moves must be uniques"
  else
    let combo_diff = List.filter (Fun.negate @@ is_difference kmn) combo_mv in
    if List.(length combo_diff != length combo_mv) then
      Error "combo move name must match with key mapping names"
    else Ok ()

let sanitize_data (keymapping, combos) =
  match sanitize_keymapping keymapping >>= sanitize_combos combos with
  | Ok _ -> Ok ()
  | Error e -> Error ("Sanitize error: " ^ e)
