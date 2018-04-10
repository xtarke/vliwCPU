; ModuleID = 'matmult.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@ArrayA = common global [20 x [20 x i32]] zeroinitializer, align 16
@ArrayB = common global [20 x [20 x i32]] zeroinitializer, align 16
@ResultArray = common global [20 x [20 x i32]] zeroinitializer, align 16
@Seed = common global i32 0, align 4

; Function Attrs: nounwind uwtable
define void @main() #0 {
  call void @InitSeed()
  call void @Test([20 x i32]* getelementptr inbounds ([20 x [20 x i32]]* @ArrayA, i32 0, i32 0), [20 x i32]* getelementptr inbounds ([20 x [20 x i32]]* @ArrayB, i32 0, i32 0), [20 x i32]* getelementptr inbounds ([20 x [20 x i32]]* @ResultArray, i32 0, i32 0))
  ret void
}

; Function Attrs: nounwind uwtable
define void @InitSeed() #0 {
  store i32 0, i32* @Seed, align 4
  ret void
}

; Function Attrs: nounwind uwtable
define void @Test([20 x i32]* %A, [20 x i32]* %B, [20 x i32]* %Res) #0 {
  %1 = alloca [20 x i32]*, align 8
  %2 = alloca [20 x i32]*, align 8
  %3 = alloca [20 x i32]*, align 8
  store [20 x i32]* %A, [20 x i32]** %1, align 8
  store [20 x i32]* %B, [20 x i32]** %2, align 8
  store [20 x i32]* %Res, [20 x i32]** %3, align 8
  %4 = load [20 x i32]** %1, align 8
  call void @Initialize([20 x i32]* %4)
  %5 = load [20 x i32]** %2, align 8
  call void @Initialize([20 x i32]* %5)
  %6 = load [20 x i32]** %1, align 8
  %7 = load [20 x i32]** %2, align 8
  %8 = load [20 x i32]** %3, align 8
  call void @Multiply([20 x i32]* %6, [20 x i32]* %7, [20 x i32]* %8)
  ret void
}

; Function Attrs: nounwind uwtable
define void @Initialize([20 x i32]* %Array) #0 {
  %1 = alloca [20 x i32]*, align 8
  %OuterIndex = alloca i32, align 4
  %InnerIndex = alloca i32, align 4
  store [20 x i32]* %Array, [20 x i32]** %1, align 8
  store i32 0, i32* %OuterIndex, align 4
  br label %2

; <label>:2                                       ; preds = %22, %0
  %3 = load i32* %OuterIndex, align 4
  %4 = icmp slt i32 %3, 20
  br i1 %4, label %5, label %25

; <label>:5                                       ; preds = %2
  store i32 0, i32* %InnerIndex, align 4
  br label %6

; <label>:6                                       ; preds = %18, %5
  %7 = load i32* %InnerIndex, align 4
  %8 = icmp slt i32 %7, 20
  br i1 %8, label %9, label %21

; <label>:9                                       ; preds = %6
  %10 = call i32 @RandomInteger()
  %11 = load i32* %InnerIndex, align 4
  %12 = sext i32 %11 to i64
  %13 = load i32* %OuterIndex, align 4
  %14 = sext i32 %13 to i64
  %15 = load [20 x i32]** %1, align 8
  %16 = getelementptr inbounds [20 x i32]* %15, i64 %14
  %17 = getelementptr inbounds [20 x i32]* %16, i32 0, i64 %12
  store i32 %10, i32* %17, align 4
  br label %18

; <label>:18                                      ; preds = %9
  %19 = load i32* %InnerIndex, align 4
  %20 = add nsw i32 %19, 1
  store i32 %20, i32* %InnerIndex, align 4
  br label %6

; <label>:21                                      ; preds = %6
  br label %22

; <label>:22                                      ; preds = %21
  %23 = load i32* %OuterIndex, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %OuterIndex, align 4
  br label %2

; <label>:25                                      ; preds = %2
  ret void
}

; Function Attrs: nounwind uwtable
define void @Multiply([20 x i32]* %A, [20 x i32]* %B, [20 x i32]* %Res) #0 {
  %1 = alloca [20 x i32]*, align 8
  %2 = alloca [20 x i32]*, align 8
  %3 = alloca [20 x i32]*, align 8
  %Outer = alloca i32, align 4
  %Inner = alloca i32, align 4
  %Index = alloca i32, align 4
  store [20 x i32]* %A, [20 x i32]** %1, align 8
  store [20 x i32]* %B, [20 x i32]** %2, align 8
  store [20 x i32]* %Res, [20 x i32]** %3, align 8
  store i32 0, i32* %Outer, align 4
  br label %4

; <label>:4                                       ; preds = %57, %0
  %5 = load i32* %Outer, align 4
  %6 = icmp slt i32 %5, 20
  br i1 %6, label %7, label %60

; <label>:7                                       ; preds = %4
  store i32 0, i32* %Inner, align 4
  br label %8

; <label>:8                                       ; preds = %53, %7
  %9 = load i32* %Inner, align 4
  %10 = icmp slt i32 %9, 20
  br i1 %10, label %11, label %56

; <label>:11                                      ; preds = %8
  %12 = load i32* %Inner, align 4
  %13 = sext i32 %12 to i64
  %14 = load i32* %Outer, align 4
  %15 = sext i32 %14 to i64
  %16 = load [20 x i32]** %3, align 8
  %17 = getelementptr inbounds [20 x i32]* %16, i64 %15
  %18 = getelementptr inbounds [20 x i32]* %17, i32 0, i64 %13
  store i32 0, i32* %18, align 4
  store i32 0, i32* %Index, align 4
  br label %19

; <label>:19                                      ; preds = %49, %11
  %20 = load i32* %Index, align 4
  %21 = icmp slt i32 %20, 20
  br i1 %21, label %22, label %52

; <label>:22                                      ; preds = %19
  %23 = load i32* %Index, align 4
  %24 = sext i32 %23 to i64
  %25 = load i32* %Outer, align 4
  %26 = sext i32 %25 to i64
  %27 = load [20 x i32]** %1, align 8
  %28 = getelementptr inbounds [20 x i32]* %27, i64 %26
  %29 = getelementptr inbounds [20 x i32]* %28, i32 0, i64 %24
  %30 = load i32* %29, align 4
  %31 = load i32* %Inner, align 4
  %32 = sext i32 %31 to i64
  %33 = load i32* %Index, align 4
  %34 = sext i32 %33 to i64
  %35 = load [20 x i32]** %2, align 8
  %36 = getelementptr inbounds [20 x i32]* %35, i64 %34
  %37 = getelementptr inbounds [20 x i32]* %36, i32 0, i64 %32
  %38 = load i32* %37, align 4
  %39 = mul nsw i32 %30, %38
  %40 = load i32* %Inner, align 4
  %41 = sext i32 %40 to i64
  %42 = load i32* %Outer, align 4
  %43 = sext i32 %42 to i64
  %44 = load [20 x i32]** %3, align 8
  %45 = getelementptr inbounds [20 x i32]* %44, i64 %43
  %46 = getelementptr inbounds [20 x i32]* %45, i32 0, i64 %41
  %47 = load i32* %46, align 4
  %48 = add nsw i32 %47, %39
  store i32 %48, i32* %46, align 4
  br label %49

; <label>:49                                      ; preds = %22
  %50 = load i32* %Index, align 4
  %51 = add nsw i32 %50, 1
  store i32 %51, i32* %Index, align 4
  br label %19

; <label>:52                                      ; preds = %19
  br label %53

; <label>:53                                      ; preds = %52
  %54 = load i32* %Inner, align 4
  %55 = add nsw i32 %54, 1
  store i32 %55, i32* %Inner, align 4
  br label %8

; <label>:56                                      ; preds = %8
  br label %57

; <label>:57                                      ; preds = %56
  %58 = load i32* %Outer, align 4
  %59 = add nsw i32 %58, 1
  store i32 %59, i32* %Outer, align 4
  br label %4

; <label>:60                                      ; preds = %4
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @RandomInteger() #0 {
  %1 = load i32* @Seed, align 4
  %2 = mul nsw i32 %1, 133
  %3 = add nsw i32 %2, 81
  %4 = srem i32 %3, 8095
  store i32 %4, i32* @Seed, align 4
  %5 = load i32* @Seed, align 4
  ret i32 %5
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
