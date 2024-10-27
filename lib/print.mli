type transition = int * string * int
type keymap = string * string
type moves = string list
type combomapping = moves * (int * string)

val print_keymapping : keymap list -> unit
val print_verbose : transition list -> combomapping list -> unit
val combo_logger : bool -> combomapping -> transition -> unit
