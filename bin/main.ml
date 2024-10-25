let ( >>= ) = Result.bind

let rec loop () =
  let key = Ft_ality.Keyboard.detect_keypress () in
  Printf.printf "You pressed: %s\n" key;
  flush Stdlib.stdout;
  if key <> "q" then loop ()

let () =
  match Sys.argv with
  | [| _; filename |] -> (
      match
        Ft_ality.Token.get filename >>= fun (keymapping, combos) ->
        Ft_ality.Sanitize.sanitize_data (keymapping, combos) >>= fun _ ->
        Ft_ality.Training.train combos
        >>= fun (transitions, comboname_state_mapping) ->
        Ft_ality.Print.print_keymapping keymapping;
        Ft_ality.Print.print_verbose transitions comboname_state_mapping;
        flush stdout;
        Ok ()
      with
      | Ok _ -> loop ()
      | Error e -> print_endline e)
  | _ ->
      print_endline "wrong number of arguments ";
      exit 1
