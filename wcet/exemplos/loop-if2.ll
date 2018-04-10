; ModuleID = 'loop-if2.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store i32 0, i32* %1
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  store i32 1, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %j, align 4
  br label %4

; <label>:4                                       ; preds = %29, %0
  %5 = load i32* %j, align 4
  %6 = icmp slt i32 %5, 5
  br i1 %6, label %7, label %32

; <label>:7                                       ; preds = %4
  %8 = load i32* %i, align 4
  %9 = icmp slt i32 %8, 6
  br i1 %9, label %10, label %19

; <label>:10                                      ; preds = %7
  %11 = load i32* %i, align 4
  %12 = add nsw i32 %11, 1
  store i32 %12, i32* %i, align 4
  %13 = load i32* %i, align 4
  %14 = add nsw i32 %13, 1
  store i32 %14, i32* %i, align 4
  %15 = load i32* %i, align 4
  %16 = add nsw i32 %15, 2
  store i32 %16, i32* %i, align 4
  %17 = load i32* %i, align 4
  %18 = add nsw i32 %17, 3
  store i32 %18, i32* %i, align 4
  br label %28

; <label>:19                                      ; preds = %7
  %20 = load i32* %i, align 4
  %21 = add nsw i32 %20, -1
  store i32 %21, i32* %i, align 4
  %22 = load i32* %i, align 4
  %23 = sub nsw i32 %22, 1
  store i32 %23, i32* %i, align 4
  %24 = load i32* %i, align 4
  %25 = sub nsw i32 %24, 2
  store i32 %25, i32* %i, align 4
  %26 = load i32* %i, align 4
  %27 = sub nsw i32 %26, 3
  store i32 %27, i32* %i, align 4
  br label %28

; <label>:28                                      ; preds = %19, %10
  br label %29

; <label>:29                                      ; preds = %28
  %30 = load i32* %j, align 4
  %31 = add nsw i32 %30, 1
  store i32 %31, i32* %j, align 4
  br label %4

; <label>:32                                      ; preds = %4
  %33 = load i32* %1
  ret i32 %33
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
