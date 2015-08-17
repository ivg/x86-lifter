open Core_kernel.Std
open Bap.Std
open Opcode

module Dis = Disasm_expert.Basic

let decode_any read insn =
  Option.try_with (fun () -> read (Sexp.of_string (Dis.Insn.name insn)))

let opcode = decode_any t_of_sexp
let prefix = decode_any prefix_of_sexp
