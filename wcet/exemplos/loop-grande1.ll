; ModuleID = 'loop-grande1.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %k, align 4
  store i32 0, i32* %i, align 4
  br label %2

; <label>:2                                       ; preds = %22, %0
  %3 = load i32* %i, align 4
  %4 = icmp slt i32 %3, 5
  br i1 %4, label %5, label %25

; <label>:5                                       ; preds = %2
  %6 = load i32* %j, align 4
  %7 = add nsw i32 %6, 2
  store i32 %7, i32* %j, align 4
  %8 = load i32* %j, align 4
  %9 = add nsw i32 %8, 3
  store i32 %9, i32* %j, align 4
  %10 = load i32* %k, align 4
  %11 = add nsw i32 %10, 4
  store i32 %11, i32* %k, align 4
  %12 = load i32* %k, align 4
  %13 = add nsw i32 %12, 5
  store i32 %13, i32* %k, align 4
  %14 = load i32* %j, align 4
  %15 = add nsw i32 %14, 6
  store i32 %15, i32* %j, align 4
  %16 = load i32* %j, align 4
  %17 = add nsw i32 %16, 7
  store i32 %17, i32* %j, align 4
  %18 = load i32* %k, align 4
  %19 = add nsw i32 %18, 8
  store i32 %19, i32* %k, align 4
  %20 = load i32* %k, align 4
  %21 = add nsw i32 %20, 9
  store i32 %21, i32* %k, align 4
  br label %22

; <label>:22                                      ; preds = %5
  %23 = load i32* %i, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %i, align 4
  br label %2

; <label>:25                                      ; preds = %2
  %26 = load i32* %1
  ret i32 %26
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
