open Core_kernel.Std
open Bap.Std
open Or_error

module Dis = Disasm_expert.Basic

type lifter = (mem * Dis.full_insn) list -> bil Or_error.t list


module Lifter (Target : Target) = struct
  open Target

  module Btx = Btx.Reg(Target)

  type obil = bil Or_error.t

  let lift mem insn = match Decode.opcode insn with
    | Some (#Opcode.btx_reg as op) ->
      Ok (Btx.lift op (Dis.Insn.ops insn))
    | Some op -> Ok [Bil.special "unsupported instruction"]
    | None -> lift mem insn

  let lift insns : obil list =
    let rec process acc = function
      | [] -> (List.rev acc)
      | (mem,x) :: xs -> match Decode.prefix x with
        | None ->
          let bil = match lift mem x with
            | Error _ as err -> [err]
            | Ok bil -> [Ok bil] in
          process bil xs
        | Some pre -> match xs with
          | [] ->
            let bil = [error "trail prefix" pre Opcode.sexp_of_prefix] in
            process bil []
          | (mem',y) :: xs ->
            let bil = match Memory.merge mem mem' with
              | Error _ ->
                [error "lost a stem after" pre Opcode.sexp_of_prefix]
              | Ok mem -> match lift mem y with
                | Error _ as err -> [err]
                | Ok bil -> match pre with
                  | `REP_PREFIX -> [Ok [Bil.(while_ (var CPU.zf) bil)]]
                  | `REPNE_PREFIX ->
                    [Ok [Bil.(while_ (lnot (var CPU.zf)) bil)]]
                  | `LOCK_PREFIX -> [Ok (Bil.special "lock" :: bil)]
                  | `DATA16_PREFIX -> [Ok (Bil.special "data16" :: bil)]
                  | `REX64_PREFIX -> [Ok (Bil.special "rex64" :: bil)] in
            process bil xs in
    process [] insns
end


module X32 = Lifter(IA32)
module X64 = Lifter(AMD64)

let x32 = X32.lift
let x64 = X64.lift
