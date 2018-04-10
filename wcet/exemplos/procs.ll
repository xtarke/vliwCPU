; ModuleID = 'procs.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @proc1() #0 {
  ret i32 1
}

; Function Attrs: nounwind uwtable
define i32 @proc2() #0 {
  %1 = call i32 @proc1()
  %2 = call i32 @proc1()
  ret i32 %2
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = call i32 @proc1()
  %2 = call i32 @proc2()
  %3 = call i32 @proc2()
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
