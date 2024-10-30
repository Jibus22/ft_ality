open Ft_ality.Sanitize
open Alcotest

let expect_error res expected_msg =
  match res with
  | Ok () -> fail "Expected Error, but got Ok"
  | Error e -> check string "Error message" expected_msg e

let test_valid_data () =
  let keymapping = [ ("a", "KM1"); ("b", "KM2") ] in
  let combos = [ ([ "KM1" ], "Combo1"); ([ "KM2" ], "Combo2") ] in
  match sanitize_data (keymapping, combos) with
  | Ok () -> () (* Pass *)
  | Error e -> failf "Expected Ok, but got Error: %s" e

let test_duplicate_keys () =
  let keymapping = [ ("a", "KM1"); ("a", "KM2") ] in
  let combos = [ ([ "KM2" ], "Combo1") ] in
  expect_error
    (sanitize_data (keymapping, combos))
    "Sanitize error: keys must be unique"

let test_duplicate_mapping_names () =
  let keymapping = [ ("a", "KM1"); ("b", "KM1") ] in
  let combos = [ ([ "KM1" ], "Combo1") ] in
  expect_error
    (sanitize_data (keymapping, combos))
    "Sanitize error: key mapping names must be unique"

let test_duplicate_combo_moves () =
  let keymapping = [ ("a", "KM1"); ("b", "KM2") ] in
  let combos = [ ([ "KM1" ], "Combo1"); ([ "KM1" ], "Combo1") ] in
  expect_error
    (sanitize_data (keymapping, combos))
    "Sanitize error: combo moves must be uniques"

let test_invalid_combo_move_names () =
  let keymapping = [ ("a", "KM1"); ("b", "KM2") ] in
  let combos = [ ([ "KM3" ], "Combo1") ] in
  expect_error
    (sanitize_data (keymapping, combos))
    "Sanitize error: combo move name must match with key mapping names"

(* Register the test suite *)
let () =
  let open Alcotest in
  run "Sanitize Data Tests"
    [
      ( "sanitize_data",
        [
          test_case "Valid data" `Quick test_valid_data;
          test_case "Duplicate keys" `Quick test_duplicate_keys;
          test_case "Duplicate mapping names" `Quick
            test_duplicate_mapping_names;
          test_case "Duplicate combo moves" `Quick test_duplicate_combo_moves;
          test_case "Invalid combo move names" `Quick
            test_invalid_combo_move_names;
        ] );
    ]
