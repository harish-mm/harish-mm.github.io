+++
title = "Setup Coq"
date = "2024-06-29"

[taxonomies]
tags=["Coq/Rocq"]
+++

## Install

```sh
$ opam switch create with-coq 4.10.2

$ opam repo add coq-released https://coq.inria.fr/opam/released

$ opam pin add coq 8.19.2 # opam pin add coq $VERSION (can be used to upgrade by mentioning new version)
```

## Use

To use the switch, do the following

```
$ opam switch with-coq
$ eval $(opam env --switch=with-coq)
```
