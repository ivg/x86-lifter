open Core_kernel.Std
open Bap.Std
open Types

val reg_from_dis32 : reg -> any32
val reg_from_dis64 : reg -> any64

(** returns a variable representing a big register that contains
    provided register *)
val real32 : any32 -> var
val real64 : any64 -> var

val reg32 : any32 -> exp
val reg64 : any64 -> exp
