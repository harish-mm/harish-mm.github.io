+++
title = "Notes on GCC"
date = "2023-02-24"
+++

> **NOTE** : This is still incomplete and I might add more content

- Takes about 50 minutes for clean build on my current machine
- X86-64 calling convention :
  [Link](https://en.wikipedia.org/wiki/X86_calling_conventions)
- [Inside CC1](https://gcc-newbies-guide.readthedocs.io/en/latest/inside-cc1.html)

## Setting Up Dev Environment

- [Useful Link](https://gcc.gnu.org/wiki/Regenerating_GCC_Configuration#fnref-1ac2645085d52b5887d132f08d57c97f6969ef7d)
  (Important to learn if you want to hack on gcc)
- Create a different build directory(convention followed). Build tree => build
  directory, Source tree => the root directory where source code lies.
- Install bear to generate compile_commands.json

```
$ ./contrib/download_prerequisites
$ mkdir build # create build tree/directory
$ cd build
$ ../configure --prefix=$PWD/GCC-INSTALL-DIR --enable-languages=c,c++ --disable-bootstrap # Disable bootstrap to make build fast
$ bear -- make -j$(nproc) # bear will generate compile_commands.json which will be used by development env for understanding about the repo
```

- See
  [this](https://gcc-newbies-guide.readthedocs.io/en/latest/getting-started.html)
  to learn more about when to enable bootstrap and when to use multiple copies
  of the repo and things like that.
- For cross compiling(this is just from my experience trying to compile for
  arm64 host and target, on my x86 machine)

```
$ sudo pacman -S aarch64-linux-gnu-gcc \\ install cross compilers(this is for aarch64)
$ mkdir build
$ cd build
$ ../configure --prefix=$PWD/GCC-12.2.0 --enable-languages=c,c++ --disable-bootstrap  --host=aarch64-linux-gnu --target=aarch64-linux-gnu
$ clear; make -j$(nproc)
$ make install
```

- [This](https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/) is
  more comprehensive guide for cross compiling.

### Tools used(Gcc hacker must learn properly)

- Autoconf ([ configure.ac ](https://en.wikipedia.org/wiki/Configure_script)
  files), Automake are used.
  [Link(has a nice diagram about how they work together)](https://en.wikipedia.org/wiki/Automake)
- Configure shell scripts and .in header templates
- Makefile is generated using Makefile.{def,tpl,in}(.in is generated from .def
  and .tpl using `autogen`) files present in source directory. This is done by
  the configure script and it should be generated in the build directory.
- There are two level of configurations, the topmost `$GCCTOP/configure` and the
  one in `$GCCTOP/gcc/configure` (`GCCTOP => source directory`). Some configure
  arguments are passed from the topmost to the lower, but the topmost --help
  don't mention them.

### Must Understand

- Source Directory and what they have .
  [Link](https://gcc.gnu.org/onlinedocs/gccint/Top-Level.html#Top-Level)
- Gcc subdirectory.
  [Link](https://gcc.gnu.org/onlinedocs/gccint/gcc-Directory.html#gcc-Directory)
- Passes

## General Notes

> In general, the names of macros are all in uppercase, while the names of
> functions are entirely in lowercase. There are rare exceptions to this rule.
> You should assume that any macro or function whose name is made up entirely of
> uppercase letters may evaluate its arguments more than once. You may assume
> that a macro or function whose name is made up entirely of lowercase letters
> will evaluate its arguments only once.

## Lexing

First the input source is “tokenized”, so that the stream of input characters is
divided into a stream of tokens. This is called “lexing”, and largely
implemented in gcc in libcpp(folder in gcc) (which also implements the
preprocessor - hence the name)

## Parsing

> `gcc -S <c-file> -O2 -fverbose-asm -fdump-tree-all -fdump-ipa-all -fdump-rtl-all`
> will generate dumps for every compiler pass that happened

Next the frontend parses the tokens from a flat stream into a tree-like
structure reflecting the grammar of the language (or complains about syntax
errors or type errors, and bails out). This stage uses gcc’s **tree** type.
There may be frontend-specific kinds of node, in the tree but the frontend will
convert these to a generic form. **Most warnings and lint things are implemented
in this phase**.

After each frontend the middle end “sees” a tree representation that we call
**generic**. **Generic** IR closely resembles the original C code, but sometimes
you will see control flow expressed via “goto” statements that go to numbered
labels, and temporary variables introduced by the frontend.

## Gimple

The tree-based IR can contain arbitrarily-complicated nested expressions, which
is relatively easy for the frontends to generate, but difficult for the
optimizer to work with, so GCC almost immediately converts it into a form named
“gimple”.
[Gimple Documentation](https://gcc.gnu.org/onlinedocs/gccint/GIMPLE.html)

## Gimple with CFG(Control Flow Graph)

**Gimple** is almost immediately converted to a CFG, a directed graph of "Basic
Blocks"(Sequences of instructions with no control flow). The control flow is
expressed as edges between the Basic Blocks.

> `gcc -S <c-file> -O2 -fverbose-asm -fdump-tree-all-graph -fdump-ipa-all-graph -fdump-rtl-all-graph`
> will generate dot graph dumps for every compiler pass that happened,in
> addition to normal dumps generated without the graph suffix in the flags

## Gimple SSA(Static Single Assignment)

SSA form is commonly used inside compilers, as it makes many kinds of
optimization much easier to implement. In SSA, every local variable is only ever
assigned to once; if there are multiple assignments to a local variable, it gets
split up into multiple versions. Pretty much any major compiler uses SSA form at
one point. Heavily used in LLVM as well. More
[here](https://en.wikipedia.org/wiki/Static_single-assignment_form). Involves
concept such as 'phi-nodes' and more.

GCC-Gimple-SSA documentation:
[here](https://gcc.gnu.org/onlinedocs/gccint/Tree-SSA.html)

In SSA form, almost 200 passes are there.

### Intraprocedural Passes

These work on one function at a time. They have a “t” code in their dump file.
For example, test.c.175t.switchlower is the dump file for an optimization pass
which converts gimple switch statements into lower-level gimple statements and
control flow (which doesn’t do anything in our example above, as it doesn’t have
any switch statements; try writing a simple C source file with a switch
statement and see what it does)

### Interprocedural Passes

Consider all of the functions at once, such as which functions call which other
functions. These have an “i” code in their dump file.

> All sets of optimizations can be found in `gcc/passes.def`.

## RTL

- Gimple is converted to Register Transfer Language (RTL), a much lower-level
  representation of the code, which will allow us to eventually go all the way
  to assembler.
- This conversion happens in an optimization pass called "expand".
- RTL form of the IR is much closer to assembler: whereas gimple works in terms
  of variables of specific data types, RTL instructions work in terms of
  low-level operations on an arbitrary number of registers of specific bit
  sizes.

### Optimization passes in RTL

- Implements calling convention of an ABI
- Does register allocation
- Uses actual instruction and addressing modes of CPU rather than assuming an
  ideal set of combinations
- Optimizations such as scheduling instructions, handling delay slot, etc to
  make it run efficiently on the machine.
- Converts the CFG that RTL inherited from gimple into a flat series of
  instructions connected by jumps (honoring constraints such as limitations on
  how many bytes a jump instruction can go)

- Final form of RTL is generated in a pass called "final". This form is suitable
  for output in assembler.

## GENERIC

- Union Crimes happening in codebase. Abusing union memory layout.. `tree_node`
  is a union, which has two fields that always need to exist. `TREE_CHAIN` and
  `TREE_TYPE` macros defined in `gcc/tree.h` need to access `common` and `typed`
  field of `tree_node`(in `gcc/tree-core.h`) and they'll always end up being
  valid because the minimum size of anything inside that union is
  `tree_typed`(which makes `TREE_TYPE` always valid because of union memory
  layout) and whenever they need to use `TREE_CHAIN`, many cases it's having
  `tree_common` as first field in struct and hence making it valid. I'm assuming
  this needs to be checked however as some type have `tree_typed` as member and
  not `tree_common` (maybe because they don't need the next pointer).

## GIMPLE

**INCOMPLETE**

## Passes

### Frontend Passes

- Language frontend is invoked only once.
- I think gcc/toplev.cc is the driver program? I'm not sure
- langs_hook.parse_file is invoked in `gcc/toplev.cc`. I'm not sure how this is
  working?
- Each front end provides its own lang hook initializer. Lang hook routines
  common to C++ and ObjC++ appear in cp/cp-objcp-common.cc
- Languages can use whatever intermediate language representation they want. (C
  uses GENERIC trees + some language specific tree codes, defined in
  c-common.def), while Fortran uses completely different private representation.
- C Frontend invokes the gimplifier manually on each function and uses the
  callbacks to convert language specific tree nodes directly to `GIMPLE`, before
  passing the function off to be compiled. Fortran however follows private repr
  => GENERIC => GIMPLE path.
- The call-graph is a data structure designed for inter-procedural optimization.
  It represents a multi-graph where nodes are functions (symbols within symbol
  table) and edges are call sites.
- The front end needs to pass all function definitions and top level
  declarations off to the middle-end so that they can be compiled and emitted to
  the object file.

### Gimplification Passes

- Tree lowering pass. This pass converts the GENERIC functions-as-trees tree
  representation into the GIMPLE form.
- The main entry point to this pass is `gimplify_function_tree` located in
  `gimplify.cc`. Processes entire function, gimplifying each of the statements.
  Main thing to look into is the `gimplify_expr`.
- See `gcc/cgraphunit.cc` which implements main driver of the compilation
  process. This is where `lower_nested_functions` (in cgraphnode::analyze) is
  called which I inside it calls `gimplify_function_tree` inside it on all the
  functions. Also look into the `cgraph_node` structure defined in
  `gcc/cgraph.h`. (The call-graph is a data structure designed for
  inter-procedural optimization. It represents a multi-graph where nodes are
  functions (symbols within symbol table) and edges are call sites)
- See `gimplify_stmt` and `gimplify_expr`(Has lots of comments to understand.
  TODO: understand this as I'm not clear with representation fully) in
  `gcc/gimplify.cc`.
- There's a language specific `gimplify_expr` that will be implemented as
  language hook. Called in `gimplify_expr` in `gcc/gimplify.cc` as
  `lang_hooks.gimplify_expr`

### Pass Manager

**INCOMPLETE**

## Vectorization Related Things

- Cost Model is described in `$(SOURCE_D)/gcc/tree-vect-loop.cc`
- More details [here](http://gcc.gnu.org/projects/tree-ssa/vectorization.html)
