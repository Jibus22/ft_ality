let set_raw_mode () =
  let term_io = Unix.tcgetattr Unix.stdin in
  let raw_mode = { term_io with Unix.c_icanon = false; c_echo = false } in
  Unix.tcsetattr Unix.stdin TCSANOW raw_mode

let restore_terminal_mode original_term_io =
  Unix.tcsetattr Unix.stdin TCSANOW original_term_io

let detect_keypress () =
  let original_term_io = Unix.tcgetattr Unix.stdin in
  set_raw_mode ();
  let key =
    let c1 = input_char stdin in
    if c1 = '\027' then
      let c2 = input_char stdin in
      if c2 = '[' then
        let c3 = input_char stdin in
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
