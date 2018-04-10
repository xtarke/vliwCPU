; ModuleID = 'if1.c'
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
  %4 = load i32* %i, align 4
  %5 = icmp slt i32 %4, 2
  br i1 %5, label %6, label %9

; <label>:6                                       ; preds = %0
  %7 = load i32* %i, align 4
  %8 = add nsw i32 %7, 1
  store i32 %8, i32* %i, align 4
  br label %12

; <label>:9                                       ; preds = %0
  %10 = load i32* %i, align 4
  %11 = add nsw i32 %10, -1
  store i32 %11, i32* %i, align 4
  br label %12

; <label>:12                                      ; preds = %9, %6
  %13 = load i32* %1
  ret i32 %13
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
