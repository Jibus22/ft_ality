open Ft_ality.Token

let with_temp_file content f =
  let filename = Filename.temp_file "test_" ".txt" in
  let oc = open_out filename in
  output_string oc content;
  close_out oc;
  let result = f filename in
  Sys.remove filename;
  result

let test_valid_file () =
  let content = "left:Left\nright:Right\n*\nBK,BK,BK:Hello\nFP,BK:Hola\n" in
  with_temp_file content (fun filename ->
      match get filename with
      | Ok (keymapping, combos) ->
          Alcotest.(check int) "Keymapping count" 2 (List.length keymapping);
          Alcotest.(check int) "Combo count" 2 (List.length combos)
      | Error e -> Alcotest.failf "Expected Ok, got Error: %s" e)

let test_missing_keymapping () =
  let content = "left:\nright:Right\n*\nBK,BK,BK:Hello\n" in
  with_temp_file content (fun filename ->
      match get filename with
      | Ok _ -> Alcotest.fail "Expected Error, got Ok"
      | Error e ->
          Alcotest.(check string)
            "Error message" "Tokenization error: Empty rhs" e)

let test_invalid_delimiter () =
  let content = "left-Left\nright:Right\n*\nBK,BK,BK:Hello\n" in
  with_temp_file content (fun filename ->
      match get filename with
      | Ok _ -> Alcotest.fail "Expected Error, got Ok"
      | Error e ->
          Alcotest.(check string)
            "Error message"
            "Tokenization error: : delimiter is needed between 2 terms" e)

let test_empty_file () =
  let content = "" in
  with_temp_file content (fun filename ->
      match get filename with
      | Ok (keymapping, combos) ->
          Alcotest.(check int) "Keymapping count" 0 (List.length keymapping);
          Alcotest.(check int) "Combo count" 0 (List.length combos)
      | Error e -> Alcotest.failf "Expected Ok, got Error: %s" e)

let () =
  let open Alcotest in
  run "get tests"
    [
      ( "Parsing",
        [
          test_case "Valid file" `Quick test_valid_file;
          test_case "Missing keymapping" `Quick test_missing_keymapping;
          test_case "Invalid delimiter" `Quick test_invalid_delimiter;
          test_case "Empty file" `Quick test_empty_file;
        ] );
    ]
