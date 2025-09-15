+++
title = "Brainfuck with LLVM Jit in Rust"
date = "2023-01-03"
draft = true

[taxonomies]
tags=["LLVM","Rust"]
+++

Some time ago, I stumbled upon
[this article/tutorial series](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-1-an-interpreter/).
I had went through the part 1 and part 2 of the series in Rust. The
[part 1](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-1-an-interpreter/)
builds a bytecode interpreter while the
[part-2](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-2-an-x64-jit/)
builds a jit. Following part 2 in Rust was quite fun as I learnt about
[dynasm-rs](https://github.com/CensoredUsername/dynasm-rs) and followed the
article. The code for jit lies
[here](https://github.com/dipeshkaphle/Programs/blob/master/bf_interpreter/src/optbytecode_jit.rs).
I didn't follow all of part 2 however, I left out some optimizations done there.

I was most excited about
[part-3](https://eli.thegreenplace.net/2017/adventures-in-jit-compilation-part-3-llvm/),
mainly because it used [LLVM](https://llvm.org/). I've always wanted to use LLVM
but never really got around it. The problem however is that the article uses
C++, while I'm following it in Rust. I'll have to do some research, see llvm
bindings in rust and then follow along with the article. So, I thought I'll
write this to share my findings.

## Boilerplate

I already have my parser ready
[here](https://github.com/dipeshkaphle/Programs/blob/master/bf_interpreter/src/parser.rs).
So what I essentially need to do is fill the following function in
[src/llvm_jit.rs](https://github.com/dipeshkaphle/Programs/blob/master/bf_interpreter/src/llvm_jit.rs).

Initially it'll look like this

```rust
pub struct LlvmJit {}

impl LlvmJit {
    pub fn parse_and_run(src_code: String) {
        let prog = Parser::parse_to_bytecode(src_code);

        // Write all the codegen stuff here
    }
}
```

## Finding crate for llvm bindings

After some(not a lot) research, I found
[inkwell](https://github.com/TheDan64/inkwell/) crate, which I reckon will serve
the purpose. We'll be doing a lot of documentation searching at
[Inkwell docs](https://thedan64.github.io/inkwell/inkwell/index.html) and
[LLVM Doxygen](https://llvm.org/doxygen/).

## Completing the parse_and_run function

### Setting up

> LLVMContext is an opaque class in the LLVM API which clients can use to
> operate multiple, isolated instances of LLVM concurrently within the same
> address space.

> Conceptually, LLVMContext provides isolation. Every LLVM entity (Modules,
> Values, Types, Constants, etc.) in LLVM’s in-memory IR belongs to an
> LLVMContext. Entities in different contexts cannot interact with each other:
> Modules in different contexts cannot be linked together, Functions cannot be
> added to Modules in different contexts, etc. What this means is that is safe
> to compile on multiple threads simultaneously, as long as no two threads
> operate on entities within the same context.

^^ taken from
[LLVM Programmer's Manual](https://llvm.org/docs/ProgrammersManual.html).

We start of with building
[`context`](https://thedan64.github.io/inkwell/inkwell/context/struct.Context.html)
and using it, we will instantiate a
[Module](https://thedan64.github.io/inkwell/inkwell/module/struct.Module.html)
and
[Builder](https://thedan64.github.io/inkwell/inkwell/builder/struct.Builder.html).

```rust
impl LlvmJit {
    pub fn parse_and_run(src_code: String) {
        //....

        let context = Context::create();
        let module = context.create_module("bf_module");
        let builder = context.create_builder();

        // ...
    }
}

```

### Creating function

```rust

impl LlvmJit {
    pub fn parse_and_run(src_code: String) {
        //Setting Up....

        // - Create function for the bf program
        let void_type = context.void_type();
        let fn_type = void_type.fn_type(&[], false);
        let function = module.add_function(JIT_FUNC_NAME, fn_type, Some(Linkage::External));
        let entry = context.append_basic_block(function, "entry");

        builder.position_at_end(entry);
        // ...
    }
}

```

### Initializing Memory

We now initialize `memory`(stack allocated with `build_array_alloca` call). We
will create a memset instruction to clear all of it to 0. We then make
allocation for `dataptr_addr` which keeps track of the current address in
`memory` of our program.

```rust
impl LlvmJit {
    pub fn parse_and_run(src_code: String) {
        //Creating function

        let memory = builder.build_array_alloca(context.i8_type(), MEMORY_SIZE, "memory");
        builder.build_memset(memory, context.i8_type().get_alignment(), 1, MEMORY_SIZE);

        let dataptr_addr =
            builder.build_array_alloca(context.i32_type(), std::ptr::null, "dataptr_addr");
        builder.build_store(dataptr_addr, context.i32_type().const_int(0, true));
        // ...
    }
}


```
