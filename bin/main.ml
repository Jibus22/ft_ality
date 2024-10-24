open Unix

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
  let args = Sys.argv in
  let filename = args.(1) in
  let ic = open_in filename in
  let len = in_channel_length ic in
  let content = really_input_string ic len in
  close_in ic;
  let _ = Ft_ality.Parsing.parse_content content in
  flush Stdlib.stdout;
  loop ()
