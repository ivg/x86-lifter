open Bap.Std

val opcode : Disasm_expert.Basic.full_insn -> Opcode.t option
val prefix : Disasm_expert.Basic.full_insn -> Opcode.prefix option
