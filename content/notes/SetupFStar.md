+++
title = "Setup FStar in OCaml 4.14"
date = "2023-01-14"

[taxonomies]
tags=["F*"]
+++

## Steps

### Setup dependencies properly

- opam install ocamlbuild
- opam install ocamlfind
- sudo pacman -S libffi
- opam install ppx_deriving_yojson
- opam install -I +str ppx_deriving_yojson
- opam install str
- opam install ctypes ctypes-foreign
- opam uninstall integers
- opam install ctypes
- opam install ppx_deriving_yojson zarith pprint "menhir>=20161115" sedlex
  process fix "wasm>=2.0.0" visitors ctypes-foreign ctypes
- sudo pacman -S dotnet-sdk-6.0

### Actual Setup

- [Setup Link](https://fstarlang.github.io/lowstar/html/Setup.html)
- ./everest z3 opam
- You have to add path to .zshrc or .bashrc it'll show up in output
- ./everest pull FStar make karamel make (Idk but it might help to add -j at the
  end?)
- Put FStar as well in your path

## Better way

```bash
$ opam switch create fstar
$ opam pin add fstar --dev-repo
$ opam pin add karamel --dev-repo
```

Above, you may need to run `opam install fstar karamel`, but I don't exactly remember

To use the Fstar switch, do the following

```
$ opam switch fstar
$ eval $(opam env --switch=fstar)
```
