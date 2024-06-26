; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -o - -verify-machineinstrs -mtriple=riscv64 -stop-after machine-sink %s | FileCheck %s --check-prefix=ISEL

define void @caller_meta_leaf() {
  ; ISEL-LABEL: name: caller_meta_leaf
  ; ISEL: bb.0.entry:
  ; ISEL-NEXT:   [[ADDI:%[0-9]+]]:gpr = ADDI $x0, 13
  ; ISEL-NEXT:   SD killed [[ADDI]], %stack.0.metadata, 0 :: (store (s64) into %ir.metadata)
  ; ISEL-NEXT:   ADJCALLSTACKDOWN 0, 0, implicit-def $x2, implicit $x2
  ; ISEL-NEXT:   STACKMAP 4, 0, 0, %stack.0.metadata, 0 :: (load (s64) from %stack.0.metadata)
  ; ISEL-NEXT:   ADJCALLSTACKUP 0, 0, implicit-def dead $x2, implicit $x2
  ; ISEL-NEXT:   PseudoRET
entry:
  %metadata = alloca i64, i32 3, align 8
  store i64 11, ptr %metadata
  store i64 12, ptr %metadata
  store i64 13, ptr %metadata
  call void (i64, i32, ...) @llvm.experimental.stackmap(i64 4, i32 0, ptr %metadata)
  ret void
}

declare void @llvm.experimental.stackmap(i64, i32, ...)
