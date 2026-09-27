; First milestone test. XFAIL until Boingus can select `add` and return.
; Once it passes, delete the XFAIL line and regenerate the CHECK lines with:
;   llvm/utils/update_llc_test_checks.py --llc-binary <build>/bin/llc \
;     llvm/test/CodeGen/Boingus/add.ll
; XFAIL: *
; RUN: llc -mtriple=boingus < %s | FileCheck %s

define i32 @add(i32 %a, i32 %b) {
; CHECK-LABEL: add:
; CHECK: add
  %r = add i32 %a, %b
  ret i32 %r
}
