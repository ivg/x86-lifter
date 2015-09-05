open Core_kernel.Std
open Bap.Std
open Or_error

module Dis = Disasm_expert.Basic

module Lifter (Target : Target) = struct
  open Target

  module Btx = Btx.Reg(Target)

  let lift mem insn = match Decode.opcode insn with
    | Some (#Opcode.btx_reg as op) ->
      Ok (Btx.lift op (Dis.Insn.ops insn))
    | Some op -> Ok [Bil.special "unsupported instruction"]
    | None -> lift mem insn

  let lift_insns insns : bil t list =
    let rec process acc = function
      | [] -> (List.rev acc)
      | (mem, Some x) :: xs -> (match Decode.prefix x with
        | None ->
          let bil = match lift mem x with
            | Error _ as err -> err
            | Ok bil -> Ok bil in
          process (bil::acc) xs
        | Some pre -> match xs with
          | []  ->
            let bil = error "trail prefix" pre Opcode.sexp_of_prefix in
            process (bil::acc) []
          | (mem, None) :: xs ->
            let bil = error "prefix to a nonexistant insn" pre Opcode.sexp_of_prefix in
            process (bil::acc) []
          | (mem, Some y) :: xs ->
            let bil = match lift mem y with
              | Error _ as err -> err
              | Ok bil -> match pre with
                | `REP_PREFIX ->
                  Ok [Bil.(while_ (var CPU.zf) bil)]
                | `REPNE_PREFIX ->
                  Ok [Bil.(while_ (lnot (var CPU.zf)) bil)]
                | `LOCK_PREFIX -> Ok (Bil.special "lock" :: bil)
                | `DATA16_PREFIX -> Ok (Bil.special "data16" :: bil)
                | `REX64_PREFIX -> Ok (Bil.special "rex64" :: bil) in
            process (bil::acc) xs)
      | (mem, None) :: _ ->
        let bil = error "No insn for mem; failed disasm " mem (fun m -> Sexp.Atom (Memory.hexdump m) ) in
        process (bil::acc) []
          in
    process [] insns
end


module X32 = Lifter(IA32)
module X64 = Lifter(AMD64)
