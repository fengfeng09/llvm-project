; RUN: opt -S --passes="print-dx-shader-flags" 2>&1 %s | FileCheck %s
; RUN: llc %s --filetype=obj -o - | obj2yaml | FileCheck %s --check-prefix=DXC

target triple = "dxil-pc-shadermodel6.7-library"

;CHECK: ; Combined Shader Flags for Module
;CHECK-NEXT: ; Shader Flags Value: 0x00000004
;CHECK-NEXT: ;
;CHECK-NEXT: ; Note: shader requires additional functionality:
;CHECK-NEXT: ;       Double-precision floating point
;CHECK-NEXT: ; Note: extra DXIL module flags:
;CHECK-NEXT: ;
;CHECK-NEXT: ; Shader Flags for Module Functions
;CHECK-NEXT: ; Function add : 0x00000004

define double @add(double %a, double %b) #0 {
  %sum = fadd double %a, %b
  ret double %sum
}

attributes #0 = { convergent norecurse nounwind "hlsl.export"}

; DXC: - Name:            SFI0
; DXC-NEXT:     Size:            8
; DXC-NEXT:     Flags:
; DXC-NEXT:       Doubles:         true
; DXC-NOT:   {{[A-Za-z]+: +true}}
; DXC:       NextUnusedBit:   false
; DXC: ...
