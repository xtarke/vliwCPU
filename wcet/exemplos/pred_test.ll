; ModuleID = 'pred_test.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define zeroext i8 @equal(i32 %n, i32 %m) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 %n, i32* %1, align 4
  store i32 %m, i32* %2, align 4
  %3 = load i32* %1, align 4
  %4 = load i32* %2, align 4
  %5 = icmp eq i32 %3, %4
  %6 = zext i1 %5 to i32
  %7 = trunc i32 %6 to i8
  ret i8 %7
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = call zeroext i8 @equal(i32 5, i32 6)
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
