; ModuleID = 'bsort100.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@Array = common global [101 x i32] zeroinitializer, align 16
@factor = common global i32 0, align 4
@Seed = common global i32 0, align 4

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %StartTime = alloca i64, align 8
  %StopTime = alloca i64, align 8
  %1 = call i32 @Initialize(i32* getelementptr inbounds ([101 x i32]* @Array, i32 0, i32 0))
  %2 = call i32 @BubbleSort(i32* getelementptr inbounds ([101 x i32]* @Array, i32 0, i32 0))
  ret i32 0
}

; Function Attrs: nounwind uwtable
define i32 @Initialize(i32* %Array) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32*, align 8
  %Index = alloca i32, align 4
  %fact = alloca i32, align 4
  store i32* %Array, i32** %2, align 8
  store i32 -1, i32* @factor, align 4
  %3 = load i32* @factor, align 4
  store i32 %3, i32* %fact, align 4
  store i32 1, i32* %Index, align 4
  br label %4

; <label>:4                                       ; preds = %14, %0
  %5 = load i32* %Index, align 4
  %6 = icmp sle i32 %5, 100
  br i1 %6, label %7, label %17

; <label>:7                                       ; preds = %4
  %8 = load i32* %Index, align 4
  %9 = sub nsw i32 500, %8
  %10 = load i32* %Index, align 4
  %11 = sext i32 %10 to i64
  %12 = load i32** %2, align 8
  %13 = getelementptr inbounds i32* %12, i64 %11
  store i32 %9, i32* %13, align 4
  br label %14

; <label>:14                                      ; preds = %7
  %15 = load i32* %Index, align 4
  %16 = add nsw i32 %15, 1
  store i32 %16, i32* %Index, align 4
  br label %4

; <label>:17                                      ; preds = %4
  %18 = load i32* %1
  ret i32 %18
}

; Function Attrs: nounwind uwtable
define i32 @BubbleSort(i32* %Array) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32*, align 8
  %Sorted = alloca i32, align 4
  %Temp = alloca i32, align 4
  %LastIndex = alloca i32, align 4
  %Index = alloca i32, align 4
  %i = alloca i32, align 4
  store i32* %Array, i32** %2, align 8
  store i32 0, i32* %Sorted, align 4
  store i32 1, i32* %i, align 4
  br label %3

; <label>:3                                       ; preds = %60, %0
  %4 = load i32* %i, align 4
  %5 = icmp sle i32 %4, 99
  br i1 %5, label %6, label %63

; <label>:6                                       ; preds = %3
  store i32 1, i32* %Sorted, align 4
  store i32 1, i32* %Index, align 4
  br label %7

; <label>:7                                       ; preds = %52, %6
  %8 = load i32* %Index, align 4
  %9 = icmp sle i32 %8, 99
  br i1 %9, label %10, label %55

; <label>:10                                      ; preds = %7
  %11 = load i32* %Index, align 4
  %12 = load i32* %i, align 4
  %13 = sub nsw i32 100, %12
  %14 = icmp sgt i32 %11, %13
  br i1 %14, label %15, label %16

; <label>:15                                      ; preds = %10
  br label %55

; <label>:16                                      ; preds = %10
  %17 = load i32* %Index, align 4
  %18 = sext i32 %17 to i64
  %19 = load i32** %2, align 8
  %20 = getelementptr inbounds i32* %19, i64 %18
  %21 = load i32* %20, align 4
  %22 = load i32* %Index, align 4
  %23 = add nsw i32 %22, 1
  %24 = sext i32 %23 to i64
  %25 = load i32** %2, align 8
  %26 = getelementptr inbounds i32* %25, i64 %24
  %27 = load i32* %26, align 4
  %28 = icmp sgt i32 %21, %27
  br i1 %28, label %29, label %51

; <label>:29                                      ; preds = %16
  %30 = load i32* %Index, align 4
  %31 = sext i32 %30 to i64
  %32 = load i32** %2, align 8
  %33 = getelementptr inbounds i32* %32, i64 %31
  %34 = load i32* %33, align 4
  store i32 %34, i32* %Temp, align 4
  %35 = load i32* %Index, align 4
  %36 = add nsw i32 %35, 1
  %37 = sext i32 %36 to i64
  %38 = load i32** %2, align 8
  %39 = getelementptr inbounds i32* %38, i64 %37
  %40 = load i32* %39, align 4
  %41 = load i32* %Index, align 4
  %42 = sext i32 %41 to i64
  %43 = load i32** %2, align 8
  %44 = getelementptr inbounds i32* %43, i64 %42
  store i32 %40, i32* %44, align 4
  %45 = load i32* %Temp, align 4
  %46 = load i32* %Index, align 4
  %47 = add nsw i32 %46, 1
  %48 = sext i32 %47 to i64
  %49 = load i32** %2, align 8
  %50 = getelementptr inbounds i32* %49, i64 %48
  store i32 %45, i32* %50, align 4
  store i32 0, i32* %Sorted, align 4
  br label %51

; <label>:51                                      ; preds = %29, %16
  br label %52

; <label>:52                                      ; preds = %51
  %53 = load i32* %Index, align 4
  %54 = add nsw i32 %53, 1
  store i32 %54, i32* %Index, align 4
  br label %7

; <label>:55                                      ; preds = %15, %7
  %56 = load i32* %Sorted, align 4
  %57 = icmp ne i32 %56, 0
  br i1 %57, label %58, label %59

; <label>:58                                      ; preds = %55
  br label %63

; <label>:59                                      ; preds = %55
  br label %60

; <label>:60                                      ; preds = %59
  %61 = load i32* %i, align 4
  %62 = add nsw i32 %61, 1
  store i32 %62, i32* %i, align 4
  br label %3

; <label>:63                                      ; preds = %58, %3
  %64 = load i32* %1
  ret i32 %64
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
