open Core_kernel.Std
open Bap.Std

type lifter = (mem * Disasm_expert.Basic.full_insn) list -> bil Or_error.t list


val x32 : lifter
val x64 : lifter
