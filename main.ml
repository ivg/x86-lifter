open Core_kernel.Std
open Bap.Std
open Or_error
open Format


module Dis = Disasm_expert.Basic

let null = Addr.of_int64 0L
let arch = `x86_64


let disasm data =
  Bigstring.of_string (String.strip data) |>
  Memory.create LittleEndian null >>= fun mem ->
  Dis.create ~backend:"llvm" (Arch.to_string arch) >>|
  Dis.store_asm >>| Dis.store_kinds >>| fun dis ->
  Dis.run dis mem ~return:ident ~init:()
    ~stopped:(fun s () ->
        Dis.insns s |> List.filter_map ~f:(function
            | (mem,None) ->
              printf "Disasm failed: @.%a@." Memory.pp mem; None
            | (mem,Some insn) -> Some (mem,insn)) |> Lift.x64 |>
        List.iter ~f:(function
            | Error err -> printf "Lifter failed: @.%a@." Error.pp err
            | Ok bil -> printf "%a@." Bil.pp bil))


let () =
  at_exit (pp_print_flush err_formatter);
  at_exit (pp_print_flush std_formatter);
  In_channel.input_all stdin |> Scanf.unescaped |> disasm |> function
  | Ok () -> ()
  | Error err -> printf "Program failed with: %a@." Error.pp err;
    exit 1
