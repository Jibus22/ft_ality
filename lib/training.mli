type transition = int * string * int
type moves = string list
type combomapping = moves * (int * string)

val train :
  (moves * string) list -> (transition list * combomapping list, string) result
