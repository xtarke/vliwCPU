; ModuleID = 'loop-aninhado1-1.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  %c = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %k, align 4
  store i32 0, i32* %a, align 4
  store i32 0, i32* %b, align 4
  store i32 0, i32* %c, align 4
  store i32 0, i32* %i, align 4
  br label %2

; <label>:2                                       ; preds = %27, %0
  %3 = load i32* %i, align 4
  %4 = icmp slt i32 %3, 5
  br i1 %4, label %5, label %30

; <label>:5                                       ; preds = %2
  store i32 0, i32* %j, align 4
  br label %6

; <label>:6                                       ; preds = %23, %5
  %7 = load i32* %j, align 4
  %8 = icmp slt i32 %7, 6
  br i1 %8, label %9, label %26

; <label>:9                                       ; preds = %6
  store i32 0, i32* %k, align 4
  br label %10

; <label>:10                                      ; preds = %19, %9
  %11 = load i32* %k, align 4
  %12 = icmp slt i32 %11, 7
  br i1 %12, label %13, label %22

; <label>:13                                      ; preds = %10
  %14 = load i32* %k, align 4
  store i32 %14, i32* %a, align 4
  %15 = load i32* %j, align 4
  store i32 %15, i32* %b, align 4
  %16 = load i32* %a, align 4
  %17 = load i32* %b, align 4
  %18 = add nsw i32 %16, %17
  store i32 %18, i32* %c, align 4
  br label %19

; <label>:19                                      ; preds = %13
  %20 = load i32* %k, align 4
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %k, align 4
  br label %10

; <label>:22                                      ; preds = %10
  br label %23

; <label>:23                                      ; preds = %22
  %24 = load i32* %j, align 4
  %25 = add nsw i32 %24, 1
  store i32 %25, i32* %j, align 4
  br label %6

; <label>:26                                      ; preds = %6
  br label %27

; <label>:27                                      ; preds = %26
  %28 = load i32* %i, align 4
  %29 = add nsw i32 %28, 1
  store i32 %29, i32* %i, align 4
  br label %2

; <label>:30                                      ; preds = %2
  %31 = load i32* %1
  ret i32 %31
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
