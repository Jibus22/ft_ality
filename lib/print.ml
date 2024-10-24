let ( >>= ) = Result.bind

let print_km (k, m) =
  Printf.printf "(k:%s, m:%s)\n" k m;
  Ok ()

let print_mn (m, n) =
  m >>= fun moves_str ->
  List.iter (fun m -> Printf.printf "%s," m) moves_str;
  Printf.printf " - %s\n" n;
  Ok ()

let print_err = Result.iter_error (fun e -> print_endline @@ "error: " ^ e)
let process_result f r = r >>= f |> print_err
let print_k = List.iter (process_result print_km)
let print_m = List.iter (process_result print_mn)
