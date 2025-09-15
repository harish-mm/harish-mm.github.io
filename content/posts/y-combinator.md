+++
title = "What is a Fixed Point Combinator?"
date = "2024-03-28"

[taxonomies] 
tags=["PL"]
+++

(Copy-pasting Wikipedia) A fixed-point combinator (or fixpoint combinator), is a
higher-order function that returns some fixed point (a value that is mapped to
itself) of its argument function, if one exists.


It has the following type(given in Haskell)

```hs
fix :: (a -> a) -> a
```

We'll assume it's defined somewhere already and move on for now.


Now, a classic example for showing it's usage is a factorial function(or any
recursive function would work).

Generally it would be written recursively like this:

```hs
fact:: Integer -> Integer
fact n = if n == 0 then 1 else n * (fact (n - 1))
```

But, let's assume we don't have recursion in our language. So, let's try to write it a bit differently.

```hs
fact':: (Integer -> Integer) -> Integer -> Integer
fact' f n = if n == 0 then 1 else n * (f (n - 1))
```

Now, using `fix`, we could define our `fact` to be something like this

```hs
-- fact:: Integer -> Integer
-- fix:: (a -> a) -> a
-- fact' :: (Integer -> Integer) -> Integer -> Integer
-- which can be rewritten as
-- fact' :: (Integer -> Integer) -> (Integer -> Integer)
--
-- in fix fact', a is substituted to be (Integer -> Integer)
-- so fix fact:: Integer -> Integer
fact n = fix fact'
```

But `fix` has been a blackbox for us till now. Let's see how we can define it.

```
fix:: (a -> a) -> a
fix f = <t>
```

Now what could go in for `t` expression there? If we think purely in terms of types, we have 
a function as parameter `f: a-> a` and we need result to be of type `a`. So, it's probably 
going to be achieved by applying `f`.

Now, what is something of type `a` we can apply to `f: a -> a`. We really only know of one thing 
whose result is type `a` i.e `fix`. So, it's just going to be

```
fix f = f (fix f)
```


andd, that's the definition of `fix`, the fixed-point combinator. 

> NOTE: Since, fix is defined recursively, it has to be a primitive provided by
> host language(language in which the interpreter is written), since we
> mentioned before we didn't support recursion.


>NOTE: Also this definition of fix works in a call by name language(lazy
>language) like Haskell, but will overflow the stack in something like OCaml.


### Let's try defining it in OCaml

#### Why do we need to do it differently in OCaml?

Issue arises due to strictness.  If you translate the program
to OCaml, it'll be like this:

```
let rec fix f = f (fix f)
```

The issue with this is, the moment you call `fix` with some `f`, it'll first try
to evaluate the `fix f` in RHS, which just keeps on going forever. Haskell
doesn't suffer from the issue because it only actually evaluates it when it's
needed.

```bash
ghci> fix f = f (fix f)
ghci> x y = 1:y
ghci> infinite1s = fix x
ghci> take 10 infinite1s
[1,1,1,1,1,1,1,1,1,1]
```

Using `fix`, we can define `x=1:x` like above. We basically took
`x::[Integer] -> [Integer]` and converted it to `[Integer]` with `fix`.

You can't do this in OCaml directly. This is of the form `a -> a` where
`a=[Integer]`. This form of fix with the signature `(a -> a) -> a` is possible
in Haskell because `a` whatever it is, is lazily evaluated. It's actually a
thunk which evaluates to `a`. In OCaml, `a` is always an evaluated value, so you
will end up needing some thunking mechanism to define `fix`.

We need to get laziness to do this in OCaml. So, we'll use partially
evaluated functions to get a definition of `fix`. We define it as follows:

```ocaml
val fix : (('a -> 'b) -> 'a -> 'b) -> 'a -> 'b
let rec fix f x = f (fix f) x
```

>(if you think about it, is sort of similar to `(a -> a)-> a` in Haskell,
>but `a` maps to `'a -> 'b` here.)

This doesn't blow up because the usage of fix in RHS is also partial, it
doesn't get fully evaluated until we actually use it. We end up creating lazy
semantics of our own here.

```bash
utop # let rec fix f x = f (fix f) x;;
val fix : (('a -> 'b) -> 'a -> 'b) -> 'a -> 'b = <fun>
─( 16:05:30 )─< command 7 >──────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # let fact f n = if n=0 then 1 else n * (f (n - 1));;
val fact : (int -> int) -> int -> int = <fun>
─( 16:05:34 )─< command 8 >──────────────────────────────────────────────────────────────────────────────────────────────{ counter: 0 }─
utop # (fix fact) 10;;
- : int = 3628800
```

That's pretty much it.

> This sort of clicked properly for me when I was watching [this excellent
> lecture by Robert Harper](https://youtu.be/8cXl2Tfhy_Q?si=pQGGg_4bum-NQAhZ),
> so I thought I'd write it out as a small blog
