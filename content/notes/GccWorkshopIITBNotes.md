+++
title = "GCC Workshop IITB Notes"
date = "2023-02-27"
+++

> **NOTE** : This is still incomplete and I might add content as I see the
> videos more.

## Notes

> Variable Meanings
>
> - \$(SOURCE_D) = Source directory
> - \$(BUILD) = Build directory
> - \$(INSTALL) = Install directory

> The workshop was held in 2012, so a lot has changed code wise but the concept
> is pretty much same. One major thing is, most of the code is C++ code(.cc
> extension) but when this workshop was happening it was all C files(.c
> extension).

## Configuring GCC

![](/IITB-GCC/Configuring.png)

> Convention followed in the picture:
>
> 1. Box => Executable
> 2. Not in Box => File/Data'
> 3. Oval => Library

Gcc generates a lot of source code during the build step.

### Terminologies

- The sources of the compiler are compiled on `Build System`.
- The built compiler runs on `Host System`(host).
- The compiler compiles code for the `Target System`(target).

> - More on configure terminologies found
>   [here](https://gcc.gnu.org/onlinedocs/gccint/Configure-Terms.html#Configure-Terms)
> - All Configure Options found
>   [here](https://gcc.gnu.org/install/configure.html)

## What happens during build?

### Normal Build Steps

![](/IITB-GCC/build_steps.png)

### Native Build With Bootstrapping

![](/IITB-GCC/native_build_bootstrap.png)

### Build Stages

![](/IITB-GCC/stage_1_build.png)

- Stage 1 files created in \$(BUILD)/stage1-gcc
- Stage 2 files created in \$(BUILD)/prev-gcc
- Stage 2 files created in \$(BUILD)/gcc

> NOTE: Cross compilation is difficult and weird

> There's explanation of mechanism to add new target to gcc in the workshop. But
> since it's unlikely you'd want to do this, I'm skipping it. It starts at 3/4th
> of the video L3-B.

## Directory Structure

### Frontend Code

- Kept in `<source_directory>/gcc/<lang>` where `lang` can be language frontends
  c,cp,go,etc
- It contains parsing code, additional ast/generic nodes,if any. It also has
  interface to generic creation

### Optimizer Code and Backend Generator Code

- Kept in `<source_directory>/gcc`
- `<source_directory>/gcc/config/<target_dir>` has backend code. `<target>.md`
  and `<target>.h` files will be present. `<target>.cc` may also be there. It'll
  have more files than this though.

## Plugins

### Static Plugin

- Changes required in gcc/Makefile.in, some header and source files.
- Atleast cc1 may have to be rebuild and all other files that were affected by
  source change.

### Dynamic Plugin

- Supported on platforms that support -ldl -rdynamic.
- Loaded using dlopen and invoked at pre-determined locations in compilation
  process.
- Command line option: -fplugin=/path/to/name.so

- The compilers are also plugins. They are static plugins however and can be
  found in `$(SOURCE_D)/gcc/gcc.cc`. There's an array of them, called
  `static const struct compiler default_compilers[]`.
  > \# means default specs not availble in top level directory. Defined
  > somewhere else. @ means Aliased entry.
- `$(SOURCE_D)/gcc/<lang>/lang-specs.h` has more information about the compiler.
  Example: C++'s specs can be seen in `$(SOURCE_D)/gcc/cp/lang-specs.h` and for
  C, it's defined in the gcc.cc file itself(so it's @ implying it's aliased
  entry. For C++ it's in different directory, so it doesn't have default specs).
- Dynamic plugin mechanism just adds a node to the linked list of optimization
  passes.
- Passes are executed with `execute_pass_list` function defined in
  `$(SOURCE_D)/gcc/passes.cc` which is just a while loop running all the passes.

#### Interprocedural Pass

- `simple_ipa_opt_pass` => Works on functions in a translation unit, stored in
  variable `all_simple_ipa_passes`
- Regular IPA pass => Works across translation units. Used in link time
  optimization. `ipa_opt_pass_d` has details about ipa passes,which will be used
  in lto.

#### Predefined pass lists

- `all_lowering_passes`
- `all_small_ipa_passes`
- `all_regular_ipa_passes`
- `all_lto_gen_passes`
- `all_passes` => Intraprocedural passes on gimple and rtl

### Adding a static Pass

![](/IITB-GCC/add_static_pass.png)

## Control Flow

### GCC Driver Program

- control flow can be found in `$(SOURCE_D)/gcc/gcc.cc` in `driver::main`
  function definition.

### CC1 Top Level Control Flow

- can be found in toplev.cc `$(SOURCE_D)/gcc/toplev.cc` in `toplev::main`
  function definition.

> NOTE: Watch L5-A if more insights needed about the flow of program. It has
> many more things such as code gen flow, passes flow, lowering passes flow,
> etc.

> NOTE: Better to See L5-B by yourself as well, the LTO section is amazing.
> Skipping it because it's kind of an advanced topic. **TODO** : Make notes on
> this

## GENERIC, GIMPLE and RTL

### GENERIC

- Language independent IR for a complete function in the form of trees
- Obtained by removing language specific constructs from ASTs
- All tree codes defined in `$(SOURCE_D)/gcc/tree.def`
- With this, all language can have their own ASTs and they just have to emit
  GENERIC and gcc will take over from there.

### GIMPLE

- Language indepedent 3 address code representation
- It is simplified subset of GENERIC.
- It has 3 address codes, simplified scope(block begin and end), Control Flow
  Lowering, simplified and restricted grammar
- Easy to optimize

#### Manipulating GIMPLE

- A Basic Block contains a doubly linked list of GIMPLE statements
- The statements are represented as GIMPLE tuple and the operands are
  represented by a tree data structure.
- Processing of statements done through iterators.

> Many APIs for GIMPLE manipulation can be found in `$(SOURCE_D)/gcc/gimple.h`

#### Manipulating tree

- My friends found a great blog post about manipulating gimple from
  [Yonatan Goldschmidt](https://github.com/Jongy). The blog post is in 2 parts.
  It lies [here](https://jongy.github.io/2020/04/25/gcc-assert-introspect.html)
  and [here](https://jongy.github.io/2020/05/15/gcc-assert-introspect-2.html).
  The code is [here](https://github.com/Jongy/gcc_assert_introspect) and it's a
  great resource for learning ast manipulation in gcc.
