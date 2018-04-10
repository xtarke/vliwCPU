; ModuleID = 'loop-aninhado7.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @bar() #0 {
  %k = alloca i32, align 4
  store i32 0, i32* %k, align 4
  store i32 0, i32* %k, align 4
  br label %1

; <label>:1                                       ; preds = %5, %0
  %2 = load i32* %k, align 4
  %3 = icmp slt i32 %2, 1
  br i1 %3, label %4, label %8

; <label>:4                                       ; preds = %1
  br label %5

; <label>:5                                       ; preds = %4
  %6 = load i32* %k, align 4
  %7 = add nsw i32 %6, 1
  store i32 %7, i32* %k, align 4
  br label %1

; <label>:8                                       ; preds = %1
  ret i32 0
}

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
  store i32 0, i32* %m, align 4
  br label %2

; <label>:2                                       ; preds = %41, %0
  %3 = load i32* %m, align 4
  %4 = icmp slt i32 %3, 1
  br i1 %4, label %5, label %44

; <label>:5                                       ; preds = %2
  store i32 0, i32* %i, align 4
  br label %6

; <label>:6                                       ; preds = %28, %5
  %7 = load i32* %i, align 4
  %8 = icmp slt i32 %7, 1
  br i1 %8, label %9, label %31

; <label>:9                                       ; preds = %6
  store i32 0, i32* %j, align 4
  br label %10

; <label>:10                                      ; preds = %15, %9
  %11 = load i32* %j, align 4
  %12 = icmp slt i32 %11, 1
  br i1 %12, label %13, label %18

; <label>:13                                      ; preds = %10
  %14 = call i32 @bar()
  br label %15

; <label>:15                                      ; preds = %13
  %16 = load i32* %j, align 4
  %17 = add nsw i32 %16, 1
  store i32 %17, i32* %j, align 4
  br label %10

; <label>:18                                      ; preds = %10
  store i32 0, i32* %k, align 4
  br label %19

; <label>:19                                      ; preds = %24, %18
  %20 = load i32* %k, align 4
  %21 = icmp slt i32 %20, 1
  br i1 %21, label %22, label %27

; <label>:22                                      ; preds = %19
  %23 = call i32 @bar()
  br label %24

; <label>:24                                      ; preds = %22
  %25 = load i32* %k, align 4
  %26 = add nsw i32 %25, 1
  store i32 %26, i32* %k, align 4
  br label %19

; <label>:27                                      ; preds = %19
  br label %28

; <label>:28                                      ; preds = %27
  %29 = load i32* %i, align 4
  %30 = add nsw i32 %29, 1
  store i32 %30, i32* %i, align 4
  br label %6

; <label>:31                                      ; preds = %6
  store i32 0, i32* %l, align 4
  br label %32

; <label>:32                                      ; preds = %37, %31
  %33 = load i32* %l, align 4
  %34 = icmp slt i32 %33, 1
  br i1 %34, label %35, label %40

; <label>:35                                      ; preds = %32
  %36 = call i32 @bar()
  br label %37

; <label>:37                                      ; preds = %35
  %38 = load i32* %l, align 4
  %39 = add nsw i32 %38, 1
  store i32 %39, i32* %l, align 4
  br label %32

; <label>:40                                      ; preds = %32
  br label %41

; <label>:41                                      ; preds = %40
  %42 = load i32* %m, align 4
  %43 = add nsw i32 %42, 1
  store i32 %43, i32* %m, align 4
  br label %2

; <label>:44                                      ; preds = %2
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
