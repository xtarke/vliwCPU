; ModuleID = 'cnt.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@Array = common global [10 x [10 x i32]] zeroinitializer, align 16
@Seed = common global i32 0, align 4
@Postotal = common global i32 0, align 4
@Poscnt = common global i32 0, align 4
@Negtotal = common global i32 0, align 4
@Negcnt = common global i32 0, align 4

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  store i32 0, i32* %1
  %2 = call i32 @InitSeed()
  %3 = call i32 @Test([10 x i32]* getelementptr inbounds ([10 x [10 x i32]]* @Array, i32 0, i32 0))
  ret i32 1
}

; Function Attrs: nounwind uwtable
define i32 @InitSeed() #0 {
  store i32 0, i32* @Seed, align 4
  ret i32 0
}

; Function Attrs: nounwind uwtable
define i32 @Test([10 x i32]* %Array) #0 {
  %1 = alloca [10 x i32]*, align 8
  %StartTime = alloca i64, align 8
  %StopTime = alloca i64, align 8
  store [10 x i32]* %Array, [10 x i32]** %1, align 8
  %2 = load [10 x i32]** %1, align 8
  %3 = call i32 @Initialize([10 x i32]* %2)
  store i64 1000, i64* %StartTime, align 8
  %4 = load [10 x i32]** %1, align 8
  call void @Sum([10 x i32]* %4)
  store i64 1500, i64* %StopTime, align 8
  ret i32 0
}

; Function Attrs: nounwind uwtable
define i32 @Initialize([10 x i32]* %Array) #0 {
  %1 = alloca [10 x i32]*, align 8
  %OuterIndex = alloca i32, align 4
  %InnerIndex = alloca i32, align 4
  store [10 x i32]* %Array, [10 x i32]** %1, align 8
  store i32 0, i32* %OuterIndex, align 4
  br label %2

; <label>:2                                       ; preds = %22, %0
  %3 = load i32* %OuterIndex, align 4
  %4 = icmp slt i32 %3, 10
  br i1 %4, label %5, label %25

; <label>:5                                       ; preds = %2
  store i32 0, i32* %InnerIndex, align 4
  br label %6

; <label>:6                                       ; preds = %18, %5
  %7 = load i32* %InnerIndex, align 4
  %8 = icmp slt i32 %7, 10
  br i1 %8, label %9, label %21

; <label>:9                                       ; preds = %6
  %10 = call i32 @RandomInteger()
  %11 = load i32* %InnerIndex, align 4
  %12 = sext i32 %11 to i64
  %13 = load i32* %OuterIndex, align 4
  %14 = sext i32 %13 to i64
  %15 = load [10 x i32]** %1, align 8
  %16 = getelementptr inbounds [10 x i32]* %15, i64 %14
  %17 = getelementptr inbounds [10 x i32]* %16, i32 0, i64 %12
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
  ret i32 0
}

; Function Attrs: nounwind uwtable
define void @Sum([10 x i32]* %Array) #0 {
  %1 = alloca [10 x i32]*, align 8
  %Outer = alloca i32, align 4
  %Inner = alloca i32, align 4
  %Ptotal = alloca i32, align 4
  %Ntotal = alloca i32, align 4
  %Pcnt = alloca i32, align 4
  %Ncnt = alloca i32, align 4
  store [10 x i32]* %Array, [10 x i32]** %1, align 8
  store i32 0, i32* %Ptotal, align 4
  store i32 0, i32* %Ntotal, align 4
  store i32 0, i32* %Pcnt, align 4
  store i32 0, i32* %Ncnt, align 4
  store i32 0, i32* %Outer, align 4
  br label %2

; <label>:2                                       ; preds = %50, %0
  %3 = load i32* %Outer, align 4
  %4 = icmp slt i32 %3, 10
  br i1 %4, label %5, label %53

; <label>:5                                       ; preds = %2
  store i32 0, i32* %Inner, align 4
  br label %6

; <label>:6                                       ; preds = %46, %5
  %7 = load i32* %Inner, align 4
  %8 = icmp slt i32 %7, 10
  br i1 %8, label %9, label %49

; <label>:9                                       ; preds = %6
  %10 = load i32* %Inner, align 4
  %11 = sext i32 %10 to i64
  %12 = load i32* %Outer, align 4
  %13 = sext i32 %12 to i64
  %14 = load [10 x i32]** %1, align 8
  %15 = getelementptr inbounds [10 x i32]* %14, i64 %13
  %16 = getelementptr inbounds [10 x i32]* %15, i32 0, i64 %11
  %17 = load i32* %16, align 4
  %18 = icmp slt i32 %17, 0
  br i1 %18, label %19, label %32

; <label>:19                                      ; preds = %9
  %20 = load i32* %Inner, align 4
  %21 = sext i32 %20 to i64
  %22 = load i32* %Outer, align 4
  %23 = sext i32 %22 to i64
  %24 = load [10 x i32]** %1, align 8
  %25 = getelementptr inbounds [10 x i32]* %24, i64 %23
  %26 = getelementptr inbounds [10 x i32]* %25, i32 0, i64 %21
  %27 = load i32* %26, align 4
  %28 = load i32* %Ptotal, align 4
  %29 = add nsw i32 %28, %27
  store i32 %29, i32* %Ptotal, align 4
  %30 = load i32* %Pcnt, align 4
  %31 = add nsw i32 %30, 1
  store i32 %31, i32* %Pcnt, align 4
  br label %45

; <label>:32                                      ; preds = %9
  %33 = load i32* %Inner, align 4
  %34 = sext i32 %33 to i64
  %35 = load i32* %Outer, align 4
  %36 = sext i32 %35 to i64
  %37 = load [10 x i32]** %1, align 8
  %38 = getelementptr inbounds [10 x i32]* %37, i64 %36
  %39 = getelementptr inbounds [10 x i32]* %38, i32 0, i64 %34
  %40 = load i32* %39, align 4
  %41 = load i32* %Ntotal, align 4
  %42 = add nsw i32 %41, %40
  store i32 %42, i32* %Ntotal, align 4
  %43 = load i32* %Ncnt, align 4
  %44 = add nsw i32 %43, 1
  store i32 %44, i32* %Ncnt, align 4
  br label %45

; <label>:45                                      ; preds = %32, %19
  br label %46

; <label>:46                                      ; preds = %45
  %47 = load i32* %Inner, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, i32* %Inner, align 4
  br label %6

; <label>:49                                      ; preds = %6
  br label %50

; <label>:50                                      ; preds = %49
  %51 = load i32* %Outer, align 4
  %52 = add nsw i32 %51, 1
  store i32 %52, i32* %Outer, align 4
  br label %2

; <label>:53                                      ; preds = %2
  %54 = load i32* %Ptotal, align 4
  store i32 %54, i32* @Postotal, align 4
  %55 = load i32* %Pcnt, align 4
  store i32 %55, i32* @Poscnt, align 4
  %56 = load i32* %Ntotal, align 4
  store i32 %56, i32* @Negtotal, align 4
  %57 = load i32* %Ncnt, align 4
  store i32 %57, i32* @Negcnt, align 4
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
