open Core_kernel.Std
open Bap.Std
open Types


let gr = Bil.var
let low n r = Bil.(cast low n (var r))
let l8 = low 8
let l16 = low 16
let l32 = low 32
let h8 r = Bil.(extract 8 15 (var r))

module Env(CPU : X86) = struct
  open CPU

  let var (reg : any) = match reg with
    | `AL | `AH | `AX | `EAX | `RAX -> rax
    | `DL | `DH | `DX | `EDX | `RDX -> rdx
    | `CL | `CH | `CX | `ECX | `RCX -> rcx
    | `BL | `BH | `BX | `EBX | `RBX -> rbx
    | `DIL | `DI | `EDI | `RDI -> rdi
    | `BPL | `BP | `EBP | `RBP -> rbp
    | `SPL | `SP | `ESP | `RSP -> rsp
    | `SIL | `SI | `ESI | `RSI -> rsi
    | `R8B | `R8W | `R8D | `R8 -> r.(8)
    | `R9B | `R9W | `R9D | `R9 -> r.(9)
    | `R10B | `R10W | `R10D | `R10 -> r.(10)
    | `R11B | `R11W | `R11D | `R11 -> r.(11)
    | `R12B | `R12W | `R12D | `R12 -> r.(12)
    | `R13B | `R13W | `R13D | `R13 -> r.(13)
    | `R14B | `R14W | `R14D | `R14 -> r.(14)
    | `R15B | `R15W | `R15D | `R15 -> r.(15)

  let exp (code : any64) = match code with
    | `AL -> l8 rax | `AH -> h8 rax | `AX -> l16 rax | `EAX -> l32 rax
    | `DL -> l8 rdx | `DH -> h8 rdx | `DX -> l16 rdx | `EDX -> l32 rdx
    | `CL -> l8 rcx | `CH -> h8 rcx | `CX -> l16 rcx | `ECX -> l32 rcx
    | `BL -> l8 rbx | `BH -> h8 rbx | `BX -> l16 rbx | `EBX -> l32 rbx
    | `DIL -> l8 rdi | `DI -> l16 rdi | `EDI -> l32 rdi
    | `BPL -> l8 rbp | `BP -> l16 rbp | `EBP -> l32 rbp
    | `SPL -> l8 rsp | `SP -> l16 rsp | `ESP -> l32 rsp
    | `SIL -> l8 rsi | `SI -> l16 rsi | `ESI -> l32 rsi
    | `R8B -> l8 r.(8) | `R8W -> l16 r.(8) | `R8D -> l32 r.(8)
    | `R9B -> l8 r.(9) | `R9W -> l16 r.(9) | `R9D -> l32 r.(9)
    | `R10B -> l8 r.(10) | `R10W -> l16 r.(10) | `R10D -> l32 r.(10)
    | `R11B -> l8 r.(11) | `R11W -> l16 r.(11) | `R11D -> l32 r.(11)
    | `R12B -> l8 r.(12) | `R12W -> l16 r.(12) | `R12D -> l32 r.(12)
    | `R13B -> l8 r.(13) | `R13W -> l16 r.(13) | `R13D -> l32 r.(13)
    | `R14B -> l8 r.(14) | `R14W -> l16 r.(14) | `R14D -> l32 r.(14)
    | `R15B -> l8 r.(15) | `R15W -> l16 r.(15) | `R15D -> l32 r.(15)
    | `RAX -> gr rax | `RDX -> gr rdx | `RCX -> gr rcx | `RBX -> gr rbx
    | `RDI -> gr rdi | `RBP -> gr rbp | `RSP -> gr rsp | `RSI -> gr rsi
    | `R8 -> gr r.(8)   | `R9 -> gr r.(9)
    | `R10 -> gr r.(10) | `R11 -> gr r.(11)
    | `R12 -> gr r.(12) | `R13 -> gr r.(13)
    | `R14 -> gr r.(14) | `R15 -> gr r.(15)

end

let reg_from_dis typ reg = typ (Sexp.of_string (Reg.name reg))
let reg_from_dis32 = reg_from_dis any32_of_sexp
let reg_from_dis64 = reg_from_dis any64_of_sexp

module X32 = Env(IA32.CPU)
module X64 = Env(AMD64.CPU)

let real32 (r : any32) = X32.var (r :> any64)
let real64 = X64.var
let reg32 (r : any32) = X32.exp (r :> any64)
let reg64 = X64.exp
