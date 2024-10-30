open Ft_ality.Training
open Alcotest

let equal_transition (i, m, o) (i2, m2, o2) =
  Int.(equal i i2 && equal o o2) && String.equal m m2

let pp_transition fmt (i, m, o) = Format.fprintf fmt "(%d, %s, %d)" i m o
let transitions_testable = Alcotest.testable pp_transition equal_transition

let equal_combomapping (moves, (final_state, name))
    (moves2, (final_state2, name2)) =
  let l_eq = List.for_all2 String.equal moves moves2 in
  l_eq && final_state = final_state2 && name = name2

let pp_combomapping fmt (moves, (final_state, name)) =
  let move_lst = List.fold_left (fun acc s -> acc ^ s ^ "; ") "" moves in
  Format.fprintf fmt "([%s], %d, %s)" (String.trim move_lst) final_state name

let combomapping_testable = Alcotest.testable pp_combomapping equal_combomapping

let check_transition actual expected =
  check (list transitions_testable) "Transitions" expected actual

let check_mapping actual expected =
  check (list combomapping_testable) "Combo State Mapping" expected actual

let test_empty_input () =
  match train [] with
  | Ok (transitions, mapping) ->
      check_transition transitions [];
      check_mapping mapping []
  | Error e -> failf "Expected Ok, but got Error: %s" e

let test_single_combo_single_move () =
  let combos = [ ([ "move1" ], "Combo1") ] in
  match train combos with
  | Ok (transitions, mapping) ->
      check_transition transitions [ (1, "move1", 1); (0, "move1", 1) ];
      check_mapping mapping [ ([ "move1" ], (1, "Combo1")) ]
  | Error e -> failf "Expected Ok, but got Error: %s" e

let test_single_combo_multiple_moves () =
  let combos = [ ([ "move1"; "move2" ], "Combo1") ] in
  match train combos with
  | Ok (transitions, mapping) ->
      check_transition transitions
        [ (2, "move1", 1); (1, "move1", 1); (0, "move1", 1); (1, "move2", 2) ];
      check_mapping mapping [ ([ "move1"; "move2" ], (2, "Combo1")) ]
  | Error e -> failf "Expected Ok, but got Error: %s" e

let test_multiple_combos_overlapping_moves () =
  let combos =
    [ ([ "move1"; "move2" ], "Combo1"); ([ "move1"; "move3" ], "Combo2") ]
  in
  match train combos with
  | Ok (transitions, mapping) ->
      let expected_transitions =
        [
          (3, "move1", 1);
          (2, "move1", 1);
          (1, "move1", 1);
          (0, "move1", 1);
          (1, "move2", 2);
          (1, "move3", 3);
        ]
      in
      let expected_mapping =
        [
          ([ "move1"; "move2" ], (2, "Combo1"));
          ([ "move1"; "move3" ], (3, "Combo2"));
        ]
      in
      check_transition transitions expected_transitions;
      check_mapping mapping expected_mapping
  | Error e -> failf "Expected Ok, but got Error: %s" e

let test_missing_transitions_filled () =
  let combos = [ ([ "move1" ], "Combo1"); ([ "move2" ], "Combo2") ] in
  match train combos with
  | Ok (transitions, mapping) ->
      let expected_transitions =
        [
          (2, "move1", 1);
          (1, "move1", 1);
          (0, "move1", 1);
          (2, "move2", 2);
          (1, "move2", 2);
          (0, "move2", 2);
        ]
      in
      let expected_mapping =
        [ ([ "move1" ], (1, "Combo1")); ([ "move2" ], (2, "Combo2")) ]
      in
      check_transition transitions expected_transitions;
      check_mapping mapping expected_mapping
  | Error e -> failf "Expected Ok, but got Error: %s" e

let () =
  run "Train Function Tests"
    [
      ( "train",
        [
          test_case "Empty input" `Quick test_empty_input;
          test_case "Single combo, single move" `Quick
            test_single_combo_single_move;
          test_case "Single combo, multiple moves" `Quick
            test_single_combo_multiple_moves;
          test_case "Multiple combos with overlapping moves" `Quick
            test_multiple_combos_overlapping_moves;
          test_case "Missing transitions filled" `Quick
            test_missing_transitions_filled;
        ] );
    ]
