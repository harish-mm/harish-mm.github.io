+++
title = "Tips for optimizing OCaml code"
date = "2023-07-21"
draft = false
+++

> NOTE: This is a Work In Progress post, I'll update this as I learn more.

- Try to reduce `caml_modify` calls
- Reduce allocations, avoiding something like `'a option` can help with
  performance quite a lot.
- Use higher order functions sparingly. For example: see
  [here](https://github.com/janestreet/base/blob/master/src/list.ml#L702). That
  kind of goes on to show the cost of indirect calls(which means inlining can't
  possibly happen)
- Looking into the assembly generated is your friend.
  [Link which tells you how to do that](https://discuss.ocaml.org/t/viewing-generated-assembly-from-ocaml-source-files/6858)
- This [Profiling section for ocaml.org](https://ocaml.org/docs/profiling) and
  [Compiler Backend section Real World OCaml](https://dev.realworldocaml.org/compiler-backend.html)
  gives overview of profiling and some information on generated assembly.
- Useful links for knowing more about internals :
  [1](https://stackoverflow.com/questions/11322163/ocaml-calling-convention-is-this-an-accurate-summary),
  [2](https://rwmj.wordpress.com/2009/08/04/ocaml-internals/https://rwmj.wordpress.com/2009/08/04/ocaml-internals/)
