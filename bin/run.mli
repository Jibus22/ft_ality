type transition = int * string * int
type keymap = string * string
type moves = string list
type combomapping = moves * (int * string)

val evaluate :
  transition list * combomapping list * keymap list ->
  (combomapping -> transition -> unit) ->
  unit
