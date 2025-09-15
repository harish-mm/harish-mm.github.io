+++
title = "Non Local Jumps with setjmp and longjmp"
date = "2023-11-01"
draft = false

[taxonomies]
tags=["C","Low-Level"]
+++


While going through Postgres source code, I found a really cool way technique
they were using to do non local jumps(acting sort of as an exception handling
mechanism). Postgres is written in C and C doesn't really have a construct for
exceptions, so how would they do something like this?

One very common functionality we observe in any interactive shell is when we
press `Ctrl-c`, that operation gets cancelled. You can take python repl as an example.
When I pressed `Ctrl-c` it aborted and printed `KeyboardInterrupt`.

```bash
λ python
Python 3.11.5 (main, Sep  2 2023, 14:16:33) [GCC 13.2.1 20230801] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> print(
KeyboardInterrupt
>>>
```

Postgres also offers a similar interactive environment in the form of `psql`
binary which lets us run db operations interactively. They also obviously offer
similar functionality of aborting when you press `Ctrl-c`.

To understand how this functionality would be implemented, we need to know a few
things. When we press `Ctrl-c`, we are sending something called an interrupt.
That interrupt is handled by the kernel by sending a signal to the running
process([1](#references-1)). Our `Ctrl-c` keypress will trigger a `SIGINT` signal. And we have mechanism to handle signals([2](#references-2)) ourselves in user
code. Using that, we can use that to do a lot of powerful things.


Let's take a look into the postgres(`psql` to be specific) code to figure out
how they do this. 

The directory for `psql` code lies at `src/bin/psql`. The entrypoint(main
function) is inside `startup.c`, which internally calls `MainLoop` function in
`mainloop.c`(aptly named). 

- In `startup.c`, there's a call to `psql_setup_cancel_handler`(which is a
oneliner `setup_cancel_handler(psql_cancel_callback)`) which eventually ends up
calling `setup_cancel_handler()` in `src/fe_utils/cancel.c`(there signal handler
for SIGINT is registered, and also a callback function is registered). The
`handle_sigint` function is registered for handling `SIGINT`, inside which it
calls `cancel_callback` function if it's not NULL(which it won't be for our
particular codepath). 

<a id="setup_cancel_handler"> </a>
![setup_cancel_handler](/nonlocaljumps/setup_cancel_handler.png)
<a id="handle_sigint"> </a>
![handle_sigint](/nonlocaljumps/handle_sigint.png)

<a id="signal_conclusion"></a>
So, basically `psql_cancel_callback` function is run as part of the signal handler (`handle_sigint`).

- Now, let's look at the main loop. The `MainLoop` function does a bunch of
  stuff at the start(which I have no clue about) but the actual loop is mainly
  the following code. It's a huge function which does a lot of things(expected
  since it's what drives the whole program). If you scroll through it you'll
  find that it's getting line and executing it(handling exits,clearing,etc.
  too), it's quite involved really. 

I came across this particular code snippet(where I have my cursor in the
screenshot). I had heard about something called `setjmp/longjmp` before but
hadn't really encountered them in real world code(Could be that I haven't seen a
lot of real world code). 

<a id="sigsetjmp"></a>
![MainLoop](/nonlocaljumps/main_loop.png)

## Short primer on non local jump construct in C

- `setjmp` : Marks the point where this was called as somewhat of a checkpoint
  by saving the execution state
- `longjmp`: We jump to the checkpoint from wherever we are. This can be across
  functions (of course locally too).

An example (taken straight from
[Wikipedia](https://en.wikipedia.org/wiki/Setjmp.h)) will make it a bit more
clearer. The wikipedia page does a great job of showing how it can be used.


```c
#include <stdio.h>
#include <setjmp.h>

static jmp_buf buf;

void second() {
    printf("second\n");         // prints
    longjmp(buf,1);             // jumps back to where setjmp was called - making setjmp now return 1
}

void first() {
    second();
    printf("first\n");          // does not print
}

int main() {
    if (!setjmp(buf))
        first();                // when executed, setjmp returned 0
    else                        // when longjmp jumps back, setjmp returns 1
        printf("main\n");       // prints

    return 0;
}
```


Postgres doesn't use `setjmp/longjmp` but uses `sigsetjmp/siglongjmp` because
they're supposed to be used if you're using them in signal handling context it
seems(again a piece of knowledge from the linked wikipedia page). 

> Something fun to do: Look into if `setjmp/longjmp` allow us to implement
> delimited continuations(TODO: I need to understand them better)

## Tying together all the pieces

We saw the `sigsetjmp` call to establish a checkpoint([here](#sigsetjmp)). Now we need to find where `siglongjmp` call is coming from. Well, that's easy, it's probably coming somewhere from the signal handler. 

Seeing [setup_cancel_handler](#setup_cancel_handler), we see a callback
function(i.e `query_cancel_callback`, which is basically `psql_cancel_callback`)
being assigned to `cancel_callback` variable and that is called in the
[handle_sigint](#handle_sigint) function. I had already mentioned this
[before](#signal_conclusion)).

<a id="psql_cancel_callback"></a>
![psql_cancel_callback](/nonlocaljumps/psql_cancel_callback.png)

Voila, We see the `siglongjmp` call here.

So, all of the stuff above is responsible for this small functionality.

![Interruption handler](/nonlocaljumps/interruption_before.png)


## Verifying what I figured out above isn't a load of crap

Let's make change to [psql_cancel_callback](#psql_cancel_callback) and add a new print statement.

![printing_callback](/nonlocaljumps/printing_cancel_callback.png)

And let's also add a print after `sigsetjmp` in `MainLoop`

![printing_mainloop](/nonlocaljumps/printing_mainloop.png)

After I compile with these changes, the behaviour of `Ctrl-c` changes slightly in `psql`. Now I get this

![After modification](/nonlocaljumps/interruption_after.png)

So, I guess it wasn't incorrect. 

## References

1. <a id="references-1"></a> [Signals and
   Interrupts](https://stackoverflow.com/questions/13341870/signals-and-interrupts-a-comparison)
1. <a id="references-2"></a> [Signal Handling](https://beej.us/guide/bgc/html/split/signal-handling.html)
1. <a id="set-jmp"></a> [Setjmp Wikipedia](https://en.wikipedia.org/wiki/Setjmp.h)
