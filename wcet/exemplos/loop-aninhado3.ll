; ModuleID = 'loop-aninhado3.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %l = alloca i32, align 4
  %m = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %k, align 4
  store i32 0, i32* %l, align 4
  store i32 0, i32* %m, align 4
  store i32 0, i32* %i, align 4
  br label %2

; <label>:2                                       ; preds = %22, %0
  %3 = load i32* %i, align 4
  %4 = icmp slt i32 %3, 10
  br i1 %4, label %5, label %25

; <label>:5                                       ; preds = %2
  store i32 0, i32* %j, align 4
  br label %6

; <label>:6                                       ; preds = %10, %5
  %7 = load i32* %j, align 4
  %8 = icmp slt i32 %7, 10
  br i1 %8, label %9, label %13

; <label>:9                                       ; preds = %6
  br label %10

; <label>:10                                      ; preds = %9
  %11 = load i32* %j, align 4
  %12 = add nsw i32 %11, 1
  store i32 %12, i32* %j, align 4
  br label %6

; <label>:13                                      ; preds = %6
  store i32 0, i32* %k, align 4
  br label %14

; <label>:14                                      ; preds = %18, %13
  %15 = load i32* %k, align 4
  %16 = icmp slt i32 %15, 10
  br i1 %16, label %17, label %21

; <label>:17                                      ; preds = %14
  br label %18

; <label>:18                                      ; preds = %17
  %19 = load i32* %k, align 4
  %20 = add nsw i32 %19, 1
  store i32 %20, i32* %k, align 4
  br label %14

; <label>:21                                      ; preds = %14
  br label %22

; <label>:22                                      ; preds = %21
  %23 = load i32* %i, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %i, align 4
  br label %2

; <label>:25                                      ; preds = %2
  store i32 0, i32* %l, align 4
  br label %26

; <label>:26                                      ; preds = %30, %25
  %27 = load i32* %l, align 4
  %28 = icmp slt i32 %27, 10
  br i1 %28, label %29, label %33

; <label>:29                                      ; preds = %26
  br label %30

; <label>:30                                      ; preds = %29
  %31 = load i32* %l, align 4
  %32 = add nsw i32 %31, 1
  store i32 %32, i32* %l, align 4
  br label %26

; <label>:33                                      ; preds = %26
  %34 = load i32* %m, align 4
  %35 = add nsw i32 %34, 1
  store i32 %35, i32* %m, align 4
  %36 = load i32* %m, align 4
  %37 = add nsw i32 %36, 1
  store i32 %37, i32* %m, align 4
  %38 = load i32* %m, align 4
  %39 = add nsw i32 %38, 2
  store i32 %39, i32* %m, align 4
  %40 = load i32* %1
  ret i32 %40
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
