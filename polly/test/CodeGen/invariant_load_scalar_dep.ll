; RUN: opt %loadNPMPolly  -passes=polly-codegen -polly-invariant-load-hoisting=true -polly-ignore-aliasing -polly-process-unprofitable -S < %s | FileCheck %s
;
; CHECK-LABEL: polly.preload.begin:
; CHECK:    %polly.access.B = getelementptr i32, ptr %B, i64 0
; CHECK:    %polly.access.B.load = load i32, ptr %polly.access.B
;
; CHECK-LABEL: polly.stmt.bb2.split:
; CHECK-NEXT:    %[[offset:.*]] = shl nuw nsw i64 %polly.indvar, 2
; CHECK-NEXT:    %scevgep = getelementptr i8, ptr %A, i64 %[[offset]]
; CHECK:    store i32 %polly.access.B.load, ptr %scevgep, align 4
;
;    void f(int *restrict A, int *restrict B) {
;      for (int i = 0; i < 1024; i++)
;        auto tmp = *B;
;        // Split BB
;        A[i] = tmp;
;    }
;
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define void @f(ptr noalias %A, ptr noalias %B) {
bb:
  br label %bb1

bb1:                                              ; preds = %bb4, %bb
  %indvars.iv = phi i64 [ %indvars.iv.next, %bb4 ], [ 0, %bb ]
  %exitcond = icmp ne i64 %indvars.iv, 1024
  br i1 %exitcond, label %bb2, label %bb5

bb2:                                              ; preds = %bb1
  %tmp = load i32, ptr %B, align 4
  br label %bb2.split

bb2.split:
  %tmp3 = getelementptr inbounds i32, ptr %A, i64 %indvars.iv
  store i32 %tmp, ptr %tmp3, align 4
  br label %bb4

bb4:                                              ; preds = %bb2
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %bb1

bb5:                                              ; preds = %bb1
  ret void
}
