open Bap.Std
open Core_kernel.Std
open Or_error
module Dis = Bap.Std.Disasm_expert.Basic
module Lifter : functor (Target : Target) -> sig
  module Btx : sig
    val lift : Opcode.btx_reg -> op array -> bil
  end
  val lift :
    mem -> Dis.full_insn -> bil t
  val lift_insns :
    (mem * Dis.full_insn option)
      list -> bil t list
end
module X32 : sig
  module Btx : sig
    val lift : Opcode.btx_reg -> op array -> bil
  end
  val lift :
    mem -> Dis.full_insn -> bil t
  val lift_insns :
    (mem * Dis.full_insn option)
      list -> bil t list
end
module X64 : sig
  module Btx : sig
    val lift : Opcode.btx_reg -> op array -> bil
  end
  val lift :
    mem -> Dis.full_insn -> bil t
  val lift_insns :
    (mem * Dis.full_insn option)
      list -> bil t list
  end
