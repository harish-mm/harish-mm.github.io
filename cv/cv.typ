#show heading: set text(font: "Linux Biolinum")

// Uncomment the following lines to adjust the size of text
// The recommend resume text size is from `10pt` to `12pt`
// #set text(
//   size: 12pt,
// )

#show link: set text(blue)

// Feel free to change the margin below to best fit your own CV
#set page(
  margin: (x: 0.9cm, y: 1.3cm),
)

// For more customizable options, please refer to official reference: https://typst.app/docs/reference/

#set par(justify: true)

#let chiline() = {v(-3pt); line(length: 100%); v(-5pt)}

= Dipesh Kafle

#link("mailto:dipesh.kaphle111@gmail.com")[dipesh.kaphle111\@gmail.com] |
#link("https://github.com/dipeshkaphle")[github.com/dipeshkaphle] |
#link("https://linkedin.com/in/dipeshk111/")[linkedin.com/in/dipeshk111] |
#link("https://dipeshkaphle.github.io")[dipeshkaphle.github.io]

Curious Software Engineer with a strong interest in Programming Languages, Formal Verification and Systems Programming.

== Education
#chiline()

*National Institute of Technology Tiruchirappalli* #h(1fr) 2019-2023 \
B.Tech in Computer Science and Engineering #h(1fr) CGPA: 8.84/10 \
- Studied algorithms and data structures, discrete mathematics, computer architecture, operating systems, computer networks, databases, theory of computation, and compilers.

== Work Experience
#chiline()

#link("https://uber.com")[*Uber*] #h(1fr) 07/2023 -- Present \
Software Engineer I | Software Engineer II (03/2025 -- Present) #h(1fr) Bengaluru, India \
- Primarily a backend engineer in the Trip Operations Platform team responsible for HITL (Human In The Loop) workflow orchestration and #link("https://www.uber.com/us/en/scaled-solutions/")[a platform for knowledge workers]. Working on improving platform reliability and enhancements, apart from the general feature additions.
- Working with *Java*, *gRPC*, in-house dependency injection framework (based on *Spring Boot*), *Cadence* (A durable workflow orchestration engine), *Kafka* and *distributed databases* in my day to day work. Ocassionally, contributing to the frontend side of things as well using *Typescript*, *React* and *GraphQL*.

#link("https://github.com/prismlab")[*IIT Madras*] #h(1fr) 07/2022 --  02/2024 \
Research Intern  #h(1fr) Remote \
- Worked with Dr. KC Sivaramakrishnan and Dr. Kartik Nagar alongside a PhD student on a project that aimed to verify an OCaml style garbage collector with F\*/Low\*.
- Helped with the integration of the extracted verified code with the #link("https://github.com/prismlab/ocaml-gc-hacking")[OCaml bytecode interpreter], ran real-world OCaml programs and ran benchmarks to analyze performance.
- Wrote a #link("https://github.com/kayceesrk/ocaml/tree/29e76177c304dfb9fd75440c35ba4fb2744d4d0b/runtime/verified_gc/allocator")[next-fit allocator in Rust] which would then be hooked with the generated verified stop-the-world mark and sweep code. Analyzed performance using this before the bytecode interpreter integration. (#link("https://link.springer.com/article/10.1007/s10817-025-09721-0")[Paper Link]).

#link("https://tarides.com")[*Tarides*] #h(1fr) 05/2023 -- 07/23 \
Software Engineering Intern #h(1fr) Remote \
- Worked on developing #link("https://github.com/ocaml-multicore/par_incr")[Par_incr], a library for incremental computation with support for freshly introduced parallelism constructs in OCaml.

#link("https://cdac.in/index.aspx?id=BL")[*CDAC Bangalore*] #h(1fr) 02/2023 -- 05/23 \
Research Intern #h(1fr) Remote \
- Developed a GCC plugin that transformed a familiar code snippet to highly optimized subroutines and another one that tuned loop unrolling heuristics based on linear regression model.
- Developed tool to visualize GCC's AST and filter out unnecessary information, to help with our program transformation experiments, and suggested potential ARM specific optimizations for future exploration.

#link("https://uber.com")[*Uber*] #h(1fr) 06/2022 --  07/2022 \
Software Engineering Intern #h(1fr) Bengaluru, India \
- Worked on improving reliability and observability of a service, involved setting up alerts and dashboards, integrating and collecting metrics, and error analysis.

== Technical Projects
#chiline()

#link("https://github.com/ocaml-multicore/par_incr")[*Par_incr*] #h(1fr)\
- A library for incremental computation with support for parallelism in *OCaml*. Other similar libraries lack parallelism constructs. The work is based on the paper #link("https://drive.google.com/file/d/130-sCY1YPzo4j3YAJ7EL9-MflK0l8RmJ/view?pli=1")[Efficient Parallel Self-Adjusting Computation]. [#link("https://dipeshkaphle.github.io/par_incr_presentation/presentation.pdf")[Slides]]
- Wrote the library from scratch and thoroughly tested it.
- Identified performance bottlenecks through profiling and applied various optimization techniques in OCaml.
- Wrote benchmarks, compared the performance with other similar libraries, and achieved similar if not better performance on average.

\

#link("https://github.com/orgs/delta/repositories?q=codecharacter&type=all&language=&sort=")[*Code Character*] #h(1fr)\
- A strategy-based programming game where you control troops in a turn-based game with the code you write in one of the multiple programming languages (C++, Python, Java) available in the game.
- Worked on the implementation of the #link("https://github.com/delta/codecharacter-simulator/")[simulator (*C++*)]
- Worked on the #link("https://github.com/delta/codecharacter-driver/")[game driver (*Rust*)]. Implemented the process orchestration, communication among the game processes, concurrent execution of games. Leveraged different system programming concepts, such as inter-process communication, unix processes, epoll, pipes, SPMC channels, etc in the implementation.

#link("https://github.com/dipeshkaphle/enma")[*Enma*] #h(1fr)\
- A programming language written in *C++* and *OCaml*.
- The language has a uni-directional type checker and can be compiled to bytecode or readable C++ code. The bytecode interpreter is written in OCaml.

#link("https://github.com/dipeshkaphle/brainfuck")[*BF JITs*] #h(1fr)\
- Implemented Just In Time compilers for Brainfuck language using Dynasm and Inkwell crate (provides LLVM bindings) in *Rust*.

#link("https://github.com/Jayashrri/PCTF21")[*Pragyan CTF*] #h(1fr)\
- Prepared challenges for Binary Exploitation/Reversing category, involving a small custom memory allocator, reversing SIMD instructions, and other common vulnerabilities.

== Talks and Writings
#chiline()

*Understanding Memory Management* #h(1fr)\
- #link("https://github.com/dipeshkaphle/hackertalk-mem-management")[Slides], #link("https://youtu.be/00Rk3o7Nv54")[Video]

*Personal Blog* #h(1fr)\
- #link("https://dipeshkaphle.github.io/posts/y-combinator/")[What is a Fixed Point Combinator?]
- #link("https://dipeshkaphle.github.io/posts/nonlocaljumps/")[Non Local Jumps with setjmp and longjmp]


== Positions of Responsibility
#chiline()

*Department of Training and Placement, NIT Trichy* #h(1fr)\
- As the Campus Placement Course (CPC) head, I lead a team dedicated to comprehensively preparing students for placements through mentoring, regular interviews, and coordinated training across various domains.

*Delta Force, NIT Trichy* #h(1fr)\
- As a member of the coding club, I actively mentored juniors, providing guidance on career, interests and software development while supporting the club's technical projects for college events and administration.

== Skills
#chiline()

*Programming:* C, C++, Rust, OCaml, Java, Typescript, Python \
*Areas:* Programming Languages, Systems Programming, Back-End Development, Databases

== Languages
#chiline()

- *Nepali*: Native proficiency
- *Hindi*: Native proficiency
- *English*: Fluent (Professionally)
