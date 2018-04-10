; ModuleID = 'fibcall.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @fib(i32 %n) #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  %Fnew = alloca i32, align 4
  %Fold = alloca i32, align 4
  %temp = alloca i32, align 4
  %ans = alloca i32, align 4
  store i32 %n, i32* %1, align 4
  store i32 1, i32* %Fnew, align 4
  store i32 0, i32* %Fold, align 4
  store i32 2, i32* %i, align 4
  br label %2

; <label>:2                                       ; preds = %17, %0
  %3 = load i32* %i, align 4
  %4 = icmp sle i32 %3, 30
  br i1 %4, label %5, label %9

; <label>:5                                       ; preds = %2
  %6 = load i32* %i, align 4
  %7 = load i32* %1, align 4
  %8 = icmp sle i32 %6, %7
  br label %9

; <label>:9                                       ; preds = %5, %2
  %10 = phi i1 [ false, %2 ], [ %8, %5 ]
  br i1 %10, label %11, label %20

; <label>:11                                      ; preds = %9
  %12 = load i32* %Fnew, align 4
  store i32 %12, i32* %temp, align 4
  %13 = load i32* %Fnew, align 4
  %14 = load i32* %Fold, align 4
  %15 = add nsw i32 %13, %14
  store i32 %15, i32* %Fnew, align 4
  %16 = load i32* %temp, align 4
  store i32 %16, i32* %Fold, align 4
  br label %17

; <label>:17                                      ; preds = %11
  %18 = load i32* %i, align 4
  %19 = add nsw i32 %18, 1
  store i32 %19, i32* %i, align 4
  br label %2

; <label>:20                                      ; preds = %9
  %21 = load i32* %Fnew, align 4
  store i32 %21, i32* %ans, align 4
  %22 = load i32* %ans, align 4
  ret i32 %22
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %a = alloca i32, align 4
  store i32 0, i32* %1
  store i32 30, i32* %a, align 4
  %2 = load i32* %a, align 4
  %3 = call i32 @fib(i32 %2)
  %4 = load i32* %a, align 4
  ret i32 %4
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
