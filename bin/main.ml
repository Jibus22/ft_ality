open Unix

let ( >>= ) = Result.bind

let set_raw_mode () =
  let term_io = tcgetattr stdin in
  let raw_mode = { term_io with c_icanon = false; c_echo = false } in
  tcsetattr stdin TCSANOW raw_mode

let restore_terminal_mode original_term_io =
  tcsetattr stdin TCSANOW original_term_io

let detect_keypress () =
  let original_term_io = tcgetattr stdin in
  set_raw_mode ();
  let key =
    let c1 = input_char Stdlib.stdin in
    if c1 = '\027' then
      let c2 = input_char Stdlib.stdin in
      if c2 = '[' then
        let c3 = input_char Stdlib.stdin in
        match c3 with
        | 'A' -> "up"
        | 'B' -> "down"
        | 'C' -> "right"
        | 'D' -> "left"
        | _ -> ""
      else ""
    else String.make 1 c1
  in
  restore_terminal_mode original_term_io;
  key

let rec loop () =
  let key = detect_keypress () in
  Printf.printf "You pressed: %s\n" key;
  flush Stdlib.stdout;
  if key <> "q" then loop ()

let () =
  match Sys.argv with
  | [| _; filename |] -> (
      match
        Ft_ality.Token.get filename >>= fun p ->
        Ft_ality.Sanitize.sanitize_data p >>= fun _ -> Ok ()
      with
      | Ok _ -> loop ()
      | Error e -> print_endline e)
  | _ ->
      print_endline "wrong number of arguments ";
      exit 1
