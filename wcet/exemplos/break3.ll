; ModuleID = 'break3.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %m = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* %m, align 4
  store i32 5, i32* %n, align 4
  store i32 0, i32* %m, align 4
  br label %2

; <label>:2                                       ; preds = %7, %0
  %3 = load i32* %m, align 4
  %4 = icmp sge i32 %3, 4
  br i1 %4, label %5, label %6

; <label>:5                                       ; preds = %2
  br label %10

; <label>:6                                       ; preds = %2
  br label %7

; <label>:7                                       ; preds = %6
  %8 = load i32* %m, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %m, align 4
  br label %2

; <label>:10                                      ; preds = %5
  %11 = load i32* %1
  ret i32 %11
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
