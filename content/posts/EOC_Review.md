+++
title = "Things I learnt from reading Essentials of Compilation"
date = "2023-08-28"
draft = true
+++

It is a super fast paced book.

## Open Recursion

The book nicely shows what `Open Recursion` is and why it can be super helpful.
Although I had heard the terminology before, it wasn't super clear to me.

### Additional references:

- [What is open recursion?](https://stackoverflow.com/questions/6089086/what-is-open-recursion)
- [What is open recursion?(By Bob Nystorm)](https://journal.stuffwithstuff.com/2013/08/26/what-is-open-recursion/)

## Some tidbits about X86 and things to keep in mind

- The stack pointer `rsp` must be divisible by 16 bytes prior to the execution
  of any `callq` instruction. (This explains why so many times I've seen more
  memory than required would be allocated for the stack frame)
- (I sort of always realized this but this still feels weird for some reason. I
  guess this is kind of lacking explicitness that you'd expect from assembly)
  `push` and `pop` actually decrement and increment `rsp` and then push/pop data
- Variables/function parameters are accessed with respect to `rbp`
- `callq <pc>` pushes the return address to the stack and the jumps to `<pc>`,
  `retq` pops the return address and jumps there. So both of them internally
  manipulate `rsp`
- X86 requires that an instruction must have at most one memory reference
  ([why isn't movl from memory to memory allowed?](https://stackoverflow.com/questions/33794169/why-isnt-movl-from-memory-to-memory-allowed))

### Additional resources:

- [X86 Assembly guide(short)](https://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html)
