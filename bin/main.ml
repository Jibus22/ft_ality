let ( >>= ) = Result.bind
let usage = "Usage: ft_ality [-v] <gmr-file>"
let emptylogger _ _ = ()

let exit_usage ?(opt = "") () =
  prerr_endline @@ opt ^ usage;
  exit 1

let start ?(v = false) filename =
  match
    Ft_ality.Token.get filename >>= fun (keymapping, combos) ->
    Ft_ality.Sanitize.sanitize_data (keymapping, combos) >>= fun _ ->
    Ft_ality.Training.train combos
    >>= fun (transitions, comboname_state_mapping) ->
    Ok (transitions, comboname_state_mapping, keymapping)
  with
  | Ok ((transitions, comboname_state_mapping, keymapping) as triple) ->
      Ft_ality.Print.print_keymapping keymapping;
      if v then Ft_ality.Print.print_verbose transitions comboname_state_mapping;
      Run.evaluate triple
        ( Ft_ality.Print.log_move,
          Ft_ality.Print.log_combo_name,
          if v then Ft_ality.Print.log_verbose else emptylogger )
  | Error e -> prerr_endline e

let () =
  match Sys.argv with
  | [| _; filename |] -> start filename
  | [| _; opt; filename |] ->
      if opt = "-v" then start ~v:true filename
      else exit_usage ~opt:("Unknown option: '" ^ opt ^ "'\n") ()
  | _ -> exit_usage ()
