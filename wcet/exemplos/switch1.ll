; ModuleID = 'switch1.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %i = alloca i32, align 4
  store i32 0, i32* %1
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  store i32 1, i32* %i, align 4
  %4 = load i32* %i, align 4
  switch i32 %4, label %23 [
    i32 1, label %5
    i32 2, label %8
    i32 3, label %11
    i32 4, label %14
    i32 5, label %17
    i32 6, label %20
  ]

; <label>:5                                       ; preds = %0
  %6 = load i32* %i, align 4
  %7 = add nsw i32 %6, 1
  store i32 %7, i32* %i, align 4
  br label %24

; <label>:8                                       ; preds = %0
  %9 = load i32* %i, align 4
  %10 = add nsw i32 %9, -1
  store i32 %10, i32* %i, align 4
  br label %24

; <label>:11                                      ; preds = %0
  %12 = load i32* %i, align 4
  %13 = add nsw i32 %12, 3
  store i32 %13, i32* %i, align 4
  br label %24

; <label>:14                                      ; preds = %0
  %15 = load i32* %i, align 4
  %16 = add nsw i32 %15, 4
  store i32 %16, i32* %i, align 4
  br label %24

; <label>:17                                      ; preds = %0
  %18 = load i32* %i, align 4
  %19 = add nsw i32 %18, 5
  store i32 %19, i32* %i, align 4
  br label %24

; <label>:20                                      ; preds = %0
  %21 = load i32* %i, align 4
  %22 = add nsw i32 %21, 6
  store i32 %22, i32* %i, align 4
  br label %24

; <label>:23                                      ; preds = %0
  br label %24

; <label>:24                                      ; preds = %23, %20, %17, %14, %11, %8, %5
  %25 = load i32* %1
  ret i32 %25
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
