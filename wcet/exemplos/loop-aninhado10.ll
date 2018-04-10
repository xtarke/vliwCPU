; ModuleID = 'loop-aninhado10.c'
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
define i32 @foo() #0 {
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
  %m = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* %m, align 4
  store i32 0, i32* %n, align 4
  store i32 0, i32* %m, align 4
  br label %2

; <label>:2                                       ; preds = %33, %0
  %3 = load i32* %m, align 4
  %4 = icmp slt i32 %3, 2
  br i1 %4, label %5, label %36

; <label>:5                                       ; preds = %2
  %6 = load i32* %n, align 4
  %7 = icmp eq i32 %6, 0
  br i1 %7, label %8, label %26

; <label>:8                                       ; preds = %5
  %9 = load i32* %n, align 4
  %10 = add nsw i32 %9, 1
  store i32 %10, i32* %n, align 4
  %11 = load i32* %n, align 4
  %12 = add nsw i32 %11, -1
  store i32 %12, i32* %n, align 4
  %13 = load i32* %n, align 4
  %14 = add nsw i32 %13, 1
  store i32 %14, i32* %n, align 4
  %15 = load i32* %n, align 4
  %16 = add nsw i32 %15, -1
  store i32 %16, i32* %n, align 4
  %17 = load i32* %n, align 4
  %18 = add nsw i32 %17, 1
  store i32 %18, i32* %n, align 4
  %19 = load i32* %n, align 4
  %20 = add nsw i32 %19, -1
  store i32 %20, i32* %n, align 4
  %21 = load i32* %n, align 4
  %22 = add nsw i32 %21, 1
  store i32 %22, i32* %n, align 4
  %23 = load i32* %n, align 4
  %24 = add nsw i32 %23, -1
  store i32 %24, i32* %n, align 4
  %25 = call i32 @bar()
  br label %32

; <label>:26                                      ; preds = %5
  %27 = load i32* %n, align 4
  %28 = add nsw i32 %27, 1
  store i32 %28, i32* %n, align 4
  %29 = load i32* %n, align 4
  %30 = add nsw i32 %29, -1
  store i32 %30, i32* %n, align 4
  %31 = call i32 @foo()
  br label %32

; <label>:32                                      ; preds = %26, %8
  br label %33

; <label>:33                                      ; preds = %32
  %34 = load i32* %m, align 4
  %35 = add nsw i32 %34, 1
  store i32 %35, i32* %m, align 4
  br label %2

; <label>:36                                      ; preds = %2
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
