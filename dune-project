(lang dune 3.16)

(name ft_ality)

(generate_opam_files true)

(source
 (github Jibus22/ft_ality))

(authors "jle-corr")

(maintainers "jle-corr")

(license GPL-3.0-or-later)

(documentation https://github.com/Jibus22/ft_ality)

(package
 (name ft_ality)
 (synopsis "Automaton")
 (description "Finite state machine taking a grammar file to be trained to respond to user commands")
 (depends ocaml dune)
 (tags
  (topics "functional programming, FSM" your project)))
