; ModuleID = 'break1.c'
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

; <label>:2                                       ; preds = %16, %0
  %3 = load i32* %m, align 4
  %4 = icmp slt i32 %3, 5
  br i1 %4, label %5, label %9

; <label>:5                                       ; preds = %2
  %6 = load i32* %m, align 4
  %7 = load i32* %n, align 4
  %8 = icmp slt i32 %6, %7
  br label %9

; <label>:9                                       ; preds = %5, %2
  %10 = phi i1 [ false, %2 ], [ %8, %5 ]
  br i1 %10, label %11, label %19

; <label>:11                                      ; preds = %9
  %12 = load i32* %m, align 4
  %13 = icmp sgt i32 %12, 3
  br i1 %13, label %14, label %15

; <label>:14                                      ; preds = %11
  br label %19

; <label>:15                                      ; preds = %11
  br label %16

; <label>:16                                      ; preds = %15
  %17 = load i32* %m, align 4
  %18 = add nsw i32 %17, 1
  store i32 %18, i32* %m, align 4
  br label %2

; <label>:19                                      ; preds = %14, %9
  %20 = load i32* %1
  ret i32 %20
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
