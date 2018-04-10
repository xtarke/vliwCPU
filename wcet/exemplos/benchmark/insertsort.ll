; ModuleID = 'insertsort.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@a = common global [11 x i32] zeroinitializer, align 16

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %temp = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 0), align 4
  store i32 11, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 1), align 4
  store i32 10, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 2), align 4
  store i32 9, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 3), align 4
  store i32 8, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 4), align 4
  store i32 7, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 5), align 4
  store i32 6, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 6), align 4
  store i32 5, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 7), align 4
  store i32 4, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 8), align 4
  store i32 3, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 9), align 4
  store i32 2, i32* getelementptr inbounds ([11 x i32]* @a, i32 0, i64 10), align 4
  store i32 2, i32* %i, align 4
  br label %2

; <label>:2                                       ; preds = %38, %0
  %3 = load i32* %i, align 4
  %4 = icmp sle i32 %3, 10
  br i1 %4, label %5, label %41

; <label>:5                                       ; preds = %2
  %6 = load i32* %i, align 4
  store i32 %6, i32* %j, align 4
  br label %7

; <label>:7                                       ; preds = %18, %5
  %8 = load i32* %j, align 4
  %9 = sext i32 %8 to i64
  %10 = getelementptr inbounds [11 x i32]* @a, i32 0, i64 %9
  %11 = load i32* %10, align 4
  %12 = load i32* %j, align 4
  %13 = sub nsw i32 %12, 1
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds [11 x i32]* @a, i32 0, i64 %14
  %16 = load i32* %15, align 4
  %17 = icmp ult i32 %11, %16
  br i1 %17, label %18, label %38

; <label>:18                                      ; preds = %7
  %19 = load i32* %j, align 4
  %20 = sext i32 %19 to i64
  %21 = getelementptr inbounds [11 x i32]* @a, i32 0, i64 %20
  %22 = load i32* %21, align 4
  store i32 %22, i32* %temp, align 4
  %23 = load i32* %j, align 4
  %24 = sub nsw i32 %23, 1
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds [11 x i32]* @a, i32 0, i64 %25
  %27 = load i32* %26, align 4
  %28 = load i32* %j, align 4
  %29 = sext i32 %28 to i64
  %30 = getelementptr inbounds [11 x i32]* @a, i32 0, i64 %29
  store i32 %27, i32* %30, align 4
  %31 = load i32* %temp, align 4
  %32 = load i32* %j, align 4
  %33 = sub nsw i32 %32, 1
  %34 = sext i32 %33 to i64
  %35 = getelementptr inbounds [11 x i32]* @a, i32 0, i64 %34
  store i32 %31, i32* %35, align 4
  %36 = load i32* %j, align 4
  %37 = add nsw i32 %36, -1
  store i32 %37, i32* %j, align 4
  br label %7

; <label>:38                                      ; preds = %7
  %39 = load i32* %i, align 4
  %40 = add nsw i32 %39, 1
  store i32 %40, i32* %i, align 4
  br label %2

; <label>:41                                      ; preds = %2
  ret i32 1
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
