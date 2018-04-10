; ModuleID = 'janne_complex.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @complex(i32 %a, i32 %b) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 %a, i32* %1, align 4
  store i32 %b, i32* %2, align 4
  br label %3

; <label>:3                                       ; preds = %33, %0
  %4 = load i32* %1, align 4
  %5 = icmp slt i32 %4, 30
  br i1 %5, label %6, label %38

; <label>:6                                       ; preds = %3
  br label %7

; <label>:7                                       ; preds = %32, %6
  %8 = load i32* %2, align 4
  %9 = load i32* %1, align 4
  %10 = icmp slt i32 %8, %9
  br i1 %10, label %11, label %33

; <label>:11                                      ; preds = %7
  %12 = load i32* %2, align 4
  %13 = icmp sgt i32 %12, 5
  br i1 %13, label %14, label %17

; <label>:14                                      ; preds = %11
  %15 = load i32* %2, align 4
  %16 = mul nsw i32 %15, 3
  store i32 %16, i32* %2, align 4
  br label %20

; <label>:17                                      ; preds = %11
  %18 = load i32* %2, align 4
  %19 = add nsw i32 %18, 2
  store i32 %19, i32* %2, align 4
  br label %20

; <label>:20                                      ; preds = %17, %14
  %21 = load i32* %2, align 4
  %22 = icmp sge i32 %21, 10
  br i1 %22, label %23, label %29

; <label>:23                                      ; preds = %20
  %24 = load i32* %2, align 4
  %25 = icmp sle i32 %24, 12
  br i1 %25, label %26, label %29

; <label>:26                                      ; preds = %23
  %27 = load i32* %1, align 4
  %28 = add nsw i32 %27, 10
  store i32 %28, i32* %1, align 4
  br label %32

; <label>:29                                      ; preds = %23, %20
  %30 = load i32* %1, align 4
  %31 = add nsw i32 %30, 1
  store i32 %31, i32* %1, align 4
  br label %32

; <label>:32                                      ; preds = %29, %26
  br label %7

; <label>:33                                      ; preds = %7
  %34 = load i32* %1, align 4
  %35 = add nsw i32 %34, 2
  store i32 %35, i32* %1, align 4
  %36 = load i32* %2, align 4
  %37 = sub nsw i32 %36, 10
  store i32 %37, i32* %2, align 4
  br label %3

; <label>:38                                      ; preds = %3
  ret i32 1
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  %answer = alloca i32, align 4
  store i32 0, i32* %1
  store i32 1, i32* %a, align 4
  store i32 1, i32* %b, align 4
  store i32 0, i32* %answer, align 4
  %2 = load i32* %a, align 4
  %3 = load i32* %b, align 4
  %4 = call i32 @complex(i32 %2, i32 %3)
  store i32 %4, i32* %answer, align 4
  %5 = load i32* %answer, align 4
  ret i32 %5
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
