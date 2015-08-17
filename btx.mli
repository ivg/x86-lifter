open Bap.Std
open Opcode

module Reg(Target : Target) : sig
  val lift : btx_reg -> op array -> bil
end
