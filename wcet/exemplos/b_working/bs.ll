; ModuleID = 'bs.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

%struct.DATA = type { i32, i32 }

@data = global [15 x %struct.DATA] [%struct.DATA { i32 1, i32 100 }, %struct.DATA { i32 5, i32 200 }, %struct.DATA { i32 6, i32 300 }, %struct.DATA { i32 7, i32 700 }, %struct.DATA { i32 8, i32 900 }, %struct.DATA { i32 9, i32 250 }, %struct.DATA { i32 10, i32 400 }, %struct.DATA { i32 11, i32 600 }, %struct.DATA { i32 12, i32 800 }, %struct.DATA { i32 13, i32 1500 }, %struct.DATA { i32 14, i32 1200 }, %struct.DATA { i32 15, i32 110 }, %struct.DATA { i32 16, i32 140 }, %struct.DATA { i32 17, i32 133 }, %struct.DATA { i32 18, i32 10 }], align 16

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = call i32 @binary_search(i32 8)
  ret i32 0
}

; Function Attrs: nounwind uwtable
define i32 @binary_search(i32 %x) #0 {
  %1 = alloca i32, align 4
  %fvalue = alloca i32, align 4
  %mid = alloca i32, align 4
  %up = alloca i32, align 4
  %low = alloca i32, align 4
  store i32 %x, i32* %1, align 4
  store i32 0, i32* %low, align 4
  store i32 14, i32* %up, align 4
  store i32 -1, i32* %fvalue, align 4
  br label %2

; <label>:2                                       ; preds = %41, %0
  %3 = load i32* %low, align 4
  %4 = load i32* %up, align 4
  %5 = icmp sle i32 %3, %4
  br i1 %5, label %6, label %42

; <label>:6                                       ; preds = %2
  %7 = load i32* %low, align 4
  %8 = load i32* %up, align 4
  %9 = add nsw i32 %7, %8
  %10 = ashr i32 %9, 1
  store i32 %10, i32* %mid, align 4
  %11 = load i32* %mid, align 4
  %12 = sext i32 %11 to i64
  %13 = getelementptr inbounds [15 x %struct.DATA]* @data, i32 0, i64 %12
  %14 = getelementptr inbounds %struct.DATA* %13, i32 0, i32 0
  %15 = load i32* %14, align 4
  %16 = load i32* %1, align 4
  %17 = icmp eq i32 %15, %16
  br i1 %17, label %18, label %26

; <label>:18                                      ; preds = %6
  %19 = load i32* %low, align 4
  %20 = sub nsw i32 %19, 1
  store i32 %20, i32* %up, align 4
  %21 = load i32* %mid, align 4
  %22 = sext i32 %21 to i64
  %23 = getelementptr inbounds [15 x %struct.DATA]* @data, i32 0, i64 %22
  %24 = getelementptr inbounds %struct.DATA* %23, i32 0, i32 1
  %25 = load i32* %24, align 4
  store i32 %25, i32* %fvalue, align 4
  br label %41

; <label>:26                                      ; preds = %6
  %27 = load i32* %mid, align 4
  %28 = sext i32 %27 to i64
  %29 = getelementptr inbounds [15 x %struct.DATA]* @data, i32 0, i64 %28
  %30 = getelementptr inbounds %struct.DATA* %29, i32 0, i32 0
  %31 = load i32* %30, align 4
  %32 = load i32* %1, align 4
  %33 = icmp sgt i32 %31, %32
  br i1 %33, label %34, label %37

; <label>:34                                      ; preds = %26
  %35 = load i32* %mid, align 4
  %36 = sub nsw i32 %35, 1
  store i32 %36, i32* %up, align 4
  br label %40

; <label>:37                                      ; preds = %26
  %38 = load i32* %mid, align 4
  %39 = add nsw i32 %38, 1
  store i32 %39, i32* %low, align 4
  br label %40

; <label>:40                                      ; preds = %37, %34
  br label %41

; <label>:41                                      ; preds = %40, %18
  br label %2

; <label>:42                                      ; preds = %2
  %43 = load i32* %fvalue, align 4
  ret i32 %43
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
