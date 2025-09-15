+++
title = "Postgres overview"
date = "2023-11-01"
draft = true
+++

Postgres source code study(as a compiler enthusiast lol)

More resource: https://youtube.com/playlist?list=PLJGJQlLY9VUx0a_SsS2-TJInsEcS-53QS&si=eHpWBXCFSefmyzDj

# Phases in Order as per (https://www.youtube.com/watch?v=OeKbL55OyL0)

## Parser
- All parser stuff at src/backend/parser

- See src/backend/nodes for parse tree nodes ig(seems to have a readme)

## Rewriter(???)

- Code at src/backend/rewrite
- I guess the major work is mostly just going to be converting views to queries(this seems to be
  a classic example that every available resource seems to be giving)

## Query Planner/Optimizer

- /src/backend/optimizer

Responsible for query tree -> execution plan

- explain command handled here ig(?)

- see readme 

## Execution

- src/backend/executor

- Again readme check

- I guess JIT also ties into this somewhere(see how? src/backend/jit)

## Access

- src/backend/access

- Not sure what this does

- This has some btree stuff too ig(and indexing related things)

- This is where we hit the disc it seems(interesting)

### Functions/Operators/Types

- See src/backend/catalog (this things seem to allow us to query types/procedures/opcodes etc)

## Storage manangement

- src/backend/storage (this might be a bit too much to handle)


## General doubts?

- Wtf is WAL?(Write ahead logging ig but why??) (WAL explained in
  src/backend/access/transam(transaction manager what is the relation with
  this??)/README, xlog.c) This also helpsn with replication it seems(how?)
- fsync??
- Check out src/backend/access/heap/README.hot
