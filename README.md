### Introduction
This program is a reproduction of the training mode of a fighting game. A grammar file composed of keymapping and combos must be given as input and then the user can trigger certain combos by pressing the appropriate keys.

### Install and run:
```sh
$ opam switch create . # create a new environment isolated from the global one and install all required dependencies
$ make # build the program
$ ./ft_ality grammar/g2.gmr # execute ft_ality with a grammar file as input
# or
$ dune exec -- ft_ality grammar/g2.gmr
$ dune runtest # run tests
```

### Usage:
```sh
# ./ft_ality [-v] grammar_file
# -v is the optional verbose option, it displays more informations such as states and transitions
# grammar_file is the file which must be formated as shown in the next section
# example:
$ ./ft_ality grammar/g2.gmr
```

### Grammar file:
The grammar file can be empty otherwise it must contains at least a keymapping. Finally it can also contain a combomapping:
```
<keymapping>
[*
<combomapping>
]
```
keymapping:
```
<key>:<move>
...
```
`key` must match the keyname of a keyboard. The only special keys we can set otherwise are `left`, `right`, `up`, `down`.

combomapping:
```
<move>[,<move1>,...,<moveN>]:<comboname>
...
```

### Implementation
This program takes a grammar file to build a *deterministic finite-state machine* which is defined by a list of its states, its initial state, and the inputs that trigger each transition and recognize exactly the set of regular languages(1). The formal definition is a 5-tuple, (Q, Σ, δ, q0, F), consisting of
- a finite set of states Q
- a finite set of input symbols called the alphabet Σ
- a transition function δ : Q × Σ → Q
- an initial or start state q 0 ∈ Q
- a set of accept states F ⊆ Q

In our case, the alphabet is given in the grammar file by the moves `<move>` and the transitions are suggested in the `combomapping` part. It is the job of the program to build states and transitions given this data so that the behavior match with the grammar file.

(1) a regular language (also called a rational language) is a formal language that can be defined by a regular expression

#### example:
Let's say we have this grammar file:
```
left:Left
right:Right
up:Up
down:Down
q:HP
s:LP
*
HP,LP,Down:Backflip Kick
HP,HP,LP:Head Smash
```

If we break down combomapping this is what we want to have first as transitions:
```
HP,LP,Down -> (0 HP 1); (1 LP 2); (2 Down 3)
HP,HP,LP -> (0 HP 1); (1 HP 4); (4 LP 5)
```

We always start from state 0. If we press `q` (`HP` move) we then go to the state 1. In state 1, we can either  press `s` or `q` to go to state 2 or 4.
In state 4 if we do `LP` we go to state 5 and trigger the `Head Smash` combo.

*Note: if another key which is not mapped in `keymapping` or ever used in `combomapping` is pressed we go back to state 0 (that is not part of my FSM implementation but rather the run loop because it's useless to create transitions to every keys which aren't used in combos nor written in the grammar file).*

This gives us two final states: `3` and `5`.

That's good but now we must add some missing transitions. What if we are in state 5 and press `HP` ? What if we are in state 3 and press `HP` ? There's no transitions which begins with 3 or 5. We could imagine to implement a logic which find if we are in a final state (3 or 5 here) we reset the state to 0 instead of staying in this state, but it wouldn't work if we have a final state to 1 with a combo like this: `HP:Front Kick`. It's safer and a better design to stick with the state machine logic and create missing transitions like `(3, HP, 1)` Which would permit to begin a `Backflip Kick` combo or a `Head Smash` combo just after being in state `3`.


So after having created basic transitions we create the missing one as follow:

- we have all states: `[0; 1; 2; 3; 4; 5]`
- grouping them by moves: `(0, HP, 1); (1, HP, 4)` ->
- we group all inputs: `[0; 1]` of `HP`
- We add all missing inputs (`[2; 3; 4; 5]`) to the entry transition: `[(5, [HP], 1); (4, [HP], 1); (3, [HP], 1); (2, [HP], 1)]`
- `(1, LP, 2); (4, LP, 5)` -> Nothing to add as there is no entry transition (transition beginning with 0)
- `(2, Down, 3)` -> Nothing to add

We finally end up having these transitions:
```
[(5, [HP], 1); (4, [HP], 1); (3, [HP], 1); (2, [HP], 1); (0, [HP], 1); (1, [HP], 4); (1, [LP], 2); (4, [LP], 5); (2, [Down], 3)]
```


The run loop just has to find if a transition match with the pressed key by checking the current state with the move. If it find something, it can print a combo name if ever a final state had been reached (`{3 -> Backflip Kick}, {5 -> Head Smash}` in the example above) and go to the next state, otherwise nothing had been found and we go back to the initial state (`0`).

---

This codebase follows the functionnal programming principles, that is using immutable constructions, recursive functions and preferably tail recursive ones, short function implementations, avoid exceptions as mush as possible.

As a result to the last expectation I used a lot the Option/Result modules, in a monadic style using the bind operator `>>=` to avoid nested pattern matching.

Example:
https://github.com/Jibus22/ft_ality/blob/c63715c0ff90faac1856a9256406bb3162d2fb90/lib/sanitize.ml#L22-L25

I've written some unit tests in the `/test` directory with the `alcotest` library. They can be run using `dune runtest`

https://ocaml.org/docs/error-handling

https://ocaml.org/docs/monads

---

![ftality](https://github.com/user-attachments/assets/e82108d5-6d78-434c-b5f3-35d1659cd975)
