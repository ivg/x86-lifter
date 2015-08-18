# Experimental x86 and x86-64 lifter

## Introduction

Currently [BAP][1] uses legacy x86 lifter, that has its own
disassembler. The disassembler understands less than one hundred
instructions and contains errors. Moreover, it has some mismatch
with LLVM in a way how prefixes are handled. LLVM handle prefixes
as it was a single instruction. As a result, the lifter doesn't
play well with out new LLVM-based infrastructure.

The best solution would be to rewrite x86 lifter, so that it will work
natively on the result of LLVM disassembler (in other words to throw
away the lifter's internal disassembler).

This is a proof of concept lifter. It handles only a small subset of
instructions, and falls back to a legacy lifter, if instruction is not
known. A set of instructions that lifter handles is defined in `Opcode.t`.

This lifter also tries to handle prefixes correctly. Although, I'm
still not sure, because sometimes LLVM emits a prefix, sometimes
ignores or sometimes it merges it with an instruction. This part needs
further investigation.

[1]: https://github.com/BinaryAnalysisPlatform/bap.git


## Playing

```sh
$ bapbuild main.native
$ echo "\x48\xc7\xc3\x02\x00\x00\x00" | ./main.native
```

## Adding new instruction

To add new instruction basically use `Blx` module as an example. 
The framework is the following:

1. Use `llvm-mc and `X86Instr*.td` files in LLVM distribution to
   reverse engineer the llvm disassembly of the instruction you're
   going to add.
2. For each LLVM opcode add equally named polymorphic
   variant. Finally, add the newly formed type to `Opcode.t`.
3. In function `lift` (see `lift.ml`) add a case that matches with your set of
   variants, and pass the arguments to your own lifter.
