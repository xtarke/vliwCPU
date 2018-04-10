; ModuleID = 'loop2.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %ii = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* %ii, align 4
  store i32 10, i32* %j, align 4
  br label %2

; <label>:2                                       ; preds = %6, %0
  %3 = load i32* %j, align 4
  %4 = add nsw i32 %3, -1
  store i32 %4, i32* %j, align 4
  %5 = icmp sgt i32 %3, 0
  br i1 %5, label %6, label %9

; <label>:6                                       ; preds = %2
  %7 = load i32* %ii, align 4
  %8 = add nsw i32 %7, 1
  store i32 %8, i32* %ii, align 4
  br label %2

; <label>:9                                       ; preds = %2
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
