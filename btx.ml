open Core_kernel.Std
open Bap.Std
open Types
open Opcode

module Dis = Disasm_expert.Basic


module Reg (Target : Target) = struct
  module CPU = Target.CPU

  let zero = Word.of_int64 0L
  let one width = Word.of_int64 ~width 1L

  let (%:) n width = Bil.(int (Word.of_int ~width n))

  let of_code s =
    try Some (btx_of_sexp (Sexp.of_string s)) with exn -> None

  let set_cf width x typ off =
    Bil.(CPU.cf := cast low 1 (x lsr (typ width off)))

  let imm width x = match Imm.to_word ~width:8 x with
    | None -> invalid_arg "imm8 must fit into 8 bits"
    | Some x -> Bil.(cast unsigned width (int x mod (width %: 8)))

  let reg width x =
    let x = match width with
      | 64 -> Env.(reg64 (reg_from_dis64 x))
      | 32 -> Env.(reg32 (reg_from_dis32 x))
      | _  -> invalid_arg "Btx.reg: expect (32 | 64)" in
    Bil.(x mod (width %: width))

  let bit width typ off =
    Bil.(int (one width) lsl (typ width off))

  let nothing = None
  let flipped = Some (fun x bit -> Bil.(x lxor bit))
  let one = Some (fun x bit -> Bil.(x lor bit))
  let zero = Some (fun x bit -> Bil.(x land (lnot bit)))

  (* set one 32 r imm x *)
  let set how width reg typ x =
    let exp, set =
      let lhs,rhs = match width with
        | 64 -> let r = Env.reg_from_dis64 reg in
          Env.(real64 r, reg64 r)
        | 32 -> let r = Env.reg_from_dis32 reg in
          Env.(real32 r, reg32 r)
        | _ -> invalid_arg "Btx.set: expect (32 | 64)" in
      match how with
      | None -> rhs, []
      | Some set -> rhs, [Bil.(lhs := set rhs (bit width typ x))] in
    set_cf width exp typ x :: set

  let lift (op : btx_reg) ops =
    let open Op in
    match op,ops with
    | `BT64rr,   [|Reg b; Reg off|] -> set nothing 64 b reg off
    | `BT32rr,   [|Reg b; Reg off|] -> set nothing 32 b reg off
    | `BT16rr,   [|Reg b; Reg off|] -> set nothing 16 b reg off
    | `BT64ri8,  [|Reg b; Imm off|] -> set nothing 64 b imm off
    | `BT32ri8,  [|Reg b; Imm off|] -> set nothing 32 b imm off
    | `BT16ri8,  [|Reg b; Imm off|] -> set nothing 16 b imm off
    | `BTS64rr,  [|Reg b; Reg off|] -> set one 64 b reg off
    | `BTS32rr,  [|Reg b; Reg off|] -> set one 32 b reg off
    | `BTS16rr,  [|Reg b; Reg off|] -> set one 16 b reg off
    | `BTS64ri8, [|Reg b; Imm off|] -> set one 64 b imm off
    | `BTS32ri8, [|Reg b; Imm off|] -> set one 32 b imm off
    | `BTS16ri8, [|Reg b; Imm off|] -> set one 16 b imm off
    | `BTC64rr,  [|Reg b; Reg off|] -> set flipped 64 b reg off
    | `BTC32rr,  [|Reg b; Reg off|] -> set flipped 32 b reg off
    | `BTC16rr,  [|Reg b; Reg off|] -> set flipped 16 b reg off
    | `BTC64ri8, [|Reg b; Imm off|] -> set flipped 64 b imm off
    | `BTC32ri8, [|Reg b; Imm off|] -> set flipped 32 b imm off
    | `BTC16ri8, [|Reg b; Imm off|] -> set flipped 16 b imm off
    | `BTR64rr,  [|Reg b; Reg off|] -> set zero 64 b reg off
    | `BTR32rr,  [|Reg b; Reg off|] -> set zero 32 b reg off
    | `BTR16rr,  [|Reg b; Reg off|] -> set zero 16 b reg off
    | `BTR64ri8, [|Reg b; Imm off|] -> set zero 64 b imm off
    | `BTR32ri8, [|Reg b; Imm off|] -> set zero 32 b imm off
    | `BTR16ri8, [|Reg b; Imm off|] -> set zero 16 b imm off
    | (op,ops) -> invalid_arg "invalid operation signature"
end
