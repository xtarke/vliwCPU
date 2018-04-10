; ModuleID = 'edn.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@a = global [200 x i16] [i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024, i16 0, i16 2047, i16 3072, i16 2048, i16 512, i16 -2048, i16 -3328, i16 1024], align 16
@b = global [200 x i16] [i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096, i16 3168, i16 3136, i16 3104, i16 3072, i16 -2560, i16 -3072, i16 -3584, i16 -4096], align 16
@main.e = private unnamed_addr constant [1 x i32] [i32 61166], align 4

; Function Attrs: nounwind uwtable
define void @vec_mpy1(i16* %y, i16* %x, i16 signext %scaler) #0 {
  %1 = alloca i16*, align 8
  %2 = alloca i16*, align 8
  %3 = alloca i16, align 2
  %i = alloca i64, align 8
  store i16* %y, i16** %1, align 8
  store i16* %x, i16** %2, align 8
  store i16 %scaler, i16* %3, align 2
  store i64 0, i64* %i, align 8
  br label %4

; <label>:4                                       ; preds = %24, %0
  %5 = load i64* %i, align 8
  %6 = icmp slt i64 %5, 150
  br i1 %6, label %7, label %27

; <label>:7                                       ; preds = %4
  %8 = load i16* %3, align 2
  %9 = sext i16 %8 to i32
  %10 = load i64* %i, align 8
  %11 = load i16** %2, align 8
  %12 = getelementptr inbounds i16* %11, i64 %10
  %13 = load i16* %12, align 2
  %14 = sext i16 %13 to i32
  %15 = mul nsw i32 %9, %14
  %16 = ashr i32 %15, 15
  %17 = load i64* %i, align 8
  %18 = load i16** %1, align 8
  %19 = getelementptr inbounds i16* %18, i64 %17
  %20 = load i16* %19, align 2
  %21 = sext i16 %20 to i32
  %22 = add nsw i32 %21, %16
  %23 = trunc i32 %22 to i16
  store i16 %23, i16* %19, align 2
  br label %24

; <label>:24                                      ; preds = %7
  %25 = load i64* %i, align 8
  %26 = add nsw i64 %25, 1
  store i64 %26, i64* %i, align 8
  br label %4

; <label>:27                                      ; preds = %4
  ret void
}

; Function Attrs: nounwind uwtable
define i64 @mac(i16* %a, i16* %b, i64 %sqr, i64* %sum) #0 {
  %1 = alloca i16*, align 8
  %2 = alloca i16*, align 8
  %3 = alloca i64, align 8
  %4 = alloca i64*, align 8
  %i = alloca i64, align 8
  %dotp = alloca i64, align 8
  store i16* %a, i16** %1, align 8
  store i16* %b, i16** %2, align 8
  store i64 %sqr, i64* %3, align 8
  store i64* %sum, i64** %4, align 8
  %5 = load i64** %4, align 8
  %6 = load i64* %5, align 8
  store i64 %6, i64* %dotp, align 8
  store i64 0, i64* %i, align 8
  br label %7

; <label>:7                                       ; preds = %39, %0
  %8 = load i64* %i, align 8
  %9 = icmp slt i64 %8, 150
  br i1 %9, label %10, label %42

; <label>:10                                      ; preds = %7
  %11 = load i64* %i, align 8
  %12 = load i16** %2, align 8
  %13 = getelementptr inbounds i16* %12, i64 %11
  %14 = load i16* %13, align 2
  %15 = sext i16 %14 to i32
  %16 = load i64* %i, align 8
  %17 = load i16** %1, align 8
  %18 = getelementptr inbounds i16* %17, i64 %16
  %19 = load i16* %18, align 2
  %20 = sext i16 %19 to i32
  %21 = mul nsw i32 %15, %20
  %22 = sext i32 %21 to i64
  %23 = load i64* %dotp, align 8
  %24 = add nsw i64 %23, %22
  store i64 %24, i64* %dotp, align 8
  %25 = load i64* %i, align 8
  %26 = load i16** %2, align 8
  %27 = getelementptr inbounds i16* %26, i64 %25
  %28 = load i16* %27, align 2
  %29 = sext i16 %28 to i32
  %30 = load i64* %i, align 8
  %31 = load i16** %2, align 8
  %32 = getelementptr inbounds i16* %31, i64 %30
  %33 = load i16* %32, align 2
  %34 = sext i16 %33 to i32
  %35 = mul nsw i32 %29, %34
  %36 = sext i32 %35 to i64
  %37 = load i64* %3, align 8
  %38 = add nsw i64 %37, %36
  store i64 %38, i64* %3, align 8
  br label %39

; <label>:39                                      ; preds = %10
  %40 = load i64* %i, align 8
  %41 = add nsw i64 %40, 1
  store i64 %41, i64* %i, align 8
  br label %7

; <label>:42                                      ; preds = %7
  %43 = load i64* %dotp, align 8
  %44 = load i64** %4, align 8
  store i64 %43, i64* %44, align 8
  %45 = load i64* %3, align 8
  ret i64 %45
}

; Function Attrs: nounwind uwtable
define void @fir(i16* %array1, i16* %coeff, i64* %output) #0 {
  %1 = alloca i16*, align 8
  %2 = alloca i16*, align 8
  %3 = alloca i64*, align 8
  %i = alloca i64, align 8
  %j = alloca i64, align 8
  %sum = alloca i64, align 8
  store i16* %array1, i16** %1, align 8
  store i16* %coeff, i16** %2, align 8
  store i64* %output, i64** %3, align 8
  store i64 0, i64* %i, align 8
  br label %4

; <label>:4                                       ; preds = %37, %0
  %5 = load i64* %i, align 8
  %6 = icmp slt i64 %5, 50
  br i1 %6, label %7, label %40

; <label>:7                                       ; preds = %4
  store i64 0, i64* %sum, align 8
  store i64 0, i64* %j, align 8
  br label %8

; <label>:8                                       ; preds = %28, %7
  %9 = load i64* %j, align 8
  %10 = icmp slt i64 %9, 50
  br i1 %10, label %11, label %31

; <label>:11                                      ; preds = %8
  %12 = load i64* %i, align 8
  %13 = load i64* %j, align 8
  %14 = add nsw i64 %12, %13
  %15 = load i16** %1, align 8
  %16 = getelementptr inbounds i16* %15, i64 %14
  %17 = load i16* %16, align 2
  %18 = sext i16 %17 to i32
  %19 = load i64* %j, align 8
  %20 = load i16** %2, align 8
  %21 = getelementptr inbounds i16* %20, i64 %19
  %22 = load i16* %21, align 2
  %23 = sext i16 %22 to i32
  %24 = mul nsw i32 %18, %23
  %25 = sext i32 %24 to i64
  %26 = load i64* %sum, align 8
  %27 = add nsw i64 %26, %25
  store i64 %27, i64* %sum, align 8
  br label %28

; <label>:28                                      ; preds = %11
  %29 = load i64* %j, align 8
  %30 = add nsw i64 %29, 1
  store i64 %30, i64* %j, align 8
  br label %8

; <label>:31                                      ; preds = %8
  %32 = load i64* %sum, align 8
  %33 = ashr i64 %32, 15
  %34 = load i64* %i, align 8
  %35 = load i64** %3, align 8
  %36 = getelementptr inbounds i64* %35, i64 %34
  store i64 %33, i64* %36, align 8
  br label %37

; <label>:37                                      ; preds = %31
  %38 = load i64* %i, align 8
  %39 = add nsw i64 %38, 1
  store i64 %39, i64* %i, align 8
  br label %4

; <label>:40                                      ; preds = %4
  ret void
}

; Function Attrs: nounwind uwtable
define void @fir_no_red_ld(i16* %x, i16* %h, i64* %y) #0 {
  %1 = alloca i16*, align 8
  %2 = alloca i16*, align 8
  %3 = alloca i64*, align 8
  %i = alloca i64, align 8
  %j = alloca i64, align 8
  %sum0 = alloca i64, align 8
  %sum1 = alloca i64, align 8
  %x0 = alloca i16, align 2
  %x1 = alloca i16, align 2
  %h0 = alloca i16, align 2
  %h1 = alloca i16, align 2
  store i16* %x, i16** %1, align 8
  store i16* %h, i16** %2, align 8
  store i64* %y, i64** %3, align 8
  store i64 0, i64* %j, align 8
  br label %4

; <label>:4                                       ; preds = %86, %0
  %5 = load i64* %j, align 8
  %6 = icmp slt i64 %5, 100
  br i1 %6, label %7, label %89

; <label>:7                                       ; preds = %4
  store i64 0, i64* %sum0, align 8
  store i64 0, i64* %sum1, align 8
  %8 = load i64* %j, align 8
  %9 = load i16** %1, align 8
  %10 = getelementptr inbounds i16* %9, i64 %8
  %11 = load i16* %10, align 2
  store i16 %11, i16* %x0, align 2
  store i64 0, i64* %i, align 8
  br label %12

; <label>:12                                      ; preds = %71, %7
  %13 = load i64* %i, align 8
  %14 = icmp slt i64 %13, 32
  br i1 %14, label %15, label %74

; <label>:15                                      ; preds = %12
  %16 = load i64* %j, align 8
  %17 = load i64* %i, align 8
  %18 = add nsw i64 %16, %17
  %19 = add nsw i64 %18, 1
  %20 = load i16** %1, align 8
  %21 = getelementptr inbounds i16* %20, i64 %19
  %22 = load i16* %21, align 2
  store i16 %22, i16* %x1, align 2
  %23 = load i64* %i, align 8
  %24 = load i16** %2, align 8
  %25 = getelementptr inbounds i16* %24, i64 %23
  %26 = load i16* %25, align 2
  store i16 %26, i16* %h0, align 2
  %27 = load i16* %x0, align 2
  %28 = sext i16 %27 to i32
  %29 = load i16* %h0, align 2
  %30 = sext i16 %29 to i32
  %31 = mul nsw i32 %28, %30
  %32 = sext i32 %31 to i64
  %33 = load i64* %sum0, align 8
  %34 = add nsw i64 %33, %32
  store i64 %34, i64* %sum0, align 8
  %35 = load i16* %x1, align 2
  %36 = sext i16 %35 to i32
  %37 = load i16* %h0, align 2
  %38 = sext i16 %37 to i32
  %39 = mul nsw i32 %36, %38
  %40 = sext i32 %39 to i64
  %41 = load i64* %sum1, align 8
  %42 = add nsw i64 %41, %40
  store i64 %42, i64* %sum1, align 8
  %43 = load i64* %j, align 8
  %44 = load i64* %i, align 8
  %45 = add nsw i64 %43, %44
  %46 = add nsw i64 %45, 2
  %47 = load i16** %1, align 8
  %48 = getelementptr inbounds i16* %47, i64 %46
  %49 = load i16* %48, align 2
  store i16 %49, i16* %x0, align 2
  %50 = load i64* %i, align 8
  %51 = add nsw i64 %50, 1
  %52 = load i16** %2, align 8
  %53 = getelementptr inbounds i16* %52, i64 %51
  %54 = load i16* %53, align 2
  store i16 %54, i16* %h1, align 2
  %55 = load i16* %x1, align 2
  %56 = sext i16 %55 to i32
  %57 = load i16* %h1, align 2
  %58 = sext i16 %57 to i32
  %59 = mul nsw i32 %56, %58
  %60 = sext i32 %59 to i64
  %61 = load i64* %sum0, align 8
  %62 = add nsw i64 %61, %60
  store i64 %62, i64* %sum0, align 8
  %63 = load i16* %x0, align 2
  %64 = sext i16 %63 to i32
  %65 = load i16* %h1, align 2
  %66 = sext i16 %65 to i32
  %67 = mul nsw i32 %64, %66
  %68 = sext i32 %67 to i64
  %69 = load i64* %sum1, align 8
  %70 = add nsw i64 %69, %68
  store i64 %70, i64* %sum1, align 8
  br label %71

; <label>:71                                      ; preds = %15
  %72 = load i64* %i, align 8
  %73 = add nsw i64 %72, 2
  store i64 %73, i64* %i, align 8
  br label %12

; <label>:74                                      ; preds = %12
  %75 = load i64* %sum0, align 8
  %76 = ashr i64 %75, 15
  %77 = load i64* %j, align 8
  %78 = load i64** %3, align 8
  %79 = getelementptr inbounds i64* %78, i64 %77
  store i64 %76, i64* %79, align 8
  %80 = load i64* %sum1, align 8
  %81 = ashr i64 %80, 15
  %82 = load i64* %j, align 8
  %83 = add nsw i64 %82, 1
  %84 = load i64** %3, align 8
  %85 = getelementptr inbounds i64* %84, i64 %83
  store i64 %81, i64* %85, align 8
  br label %86

; <label>:86                                      ; preds = %74
  %87 = load i64* %j, align 8
  %88 = add nsw i64 %87, 2
  store i64 %88, i64* %j, align 8
  br label %4

; <label>:89                                      ; preds = %4
  ret void
}

; Function Attrs: nounwind uwtable
define i64 @latsynth(i16* %b, i16* %k, i64 %n, i64 %f) #0 {
  %1 = alloca i16*, align 8
  %2 = alloca i16*, align 8
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  %i = alloca i64, align 8
  store i16* %b, i16** %1, align 8
  store i16* %k, i16** %2, align 8
  store i64 %n, i64* %3, align 8
  store i64 %f, i64* %4, align 8
  %5 = load i64* %3, align 8
  %6 = sub nsw i64 %5, 1
  %7 = load i16** %1, align 8
  %8 = getelementptr inbounds i16* %7, i64 %6
  %9 = load i16* %8, align 2
  %10 = sext i16 %9 to i32
  %11 = load i64* %3, align 8
  %12 = sub nsw i64 %11, 1
  %13 = load i16** %2, align 8
  %14 = getelementptr inbounds i16* %13, i64 %12
  %15 = load i16* %14, align 2
  %16 = sext i16 %15 to i32
  %17 = mul nsw i32 %10, %16
  %18 = sext i32 %17 to i64
  %19 = load i64* %4, align 8
  %20 = sub nsw i64 %19, %18
  store i64 %20, i64* %4, align 8
  %21 = load i64* %3, align 8
  %22 = sub nsw i64 %21, 2
  store i64 %22, i64* %i, align 8
  br label %23

; <label>:23                                      ; preds = %61, %0
  %24 = load i64* %i, align 8
  %25 = icmp sge i64 %24, 0
  br i1 %25, label %26, label %64

; <label>:26                                      ; preds = %23
  %27 = load i64* %i, align 8
  %28 = load i16** %1, align 8
  %29 = getelementptr inbounds i16* %28, i64 %27
  %30 = load i16* %29, align 2
  %31 = sext i16 %30 to i32
  %32 = load i64* %i, align 8
  %33 = load i16** %2, align 8
  %34 = getelementptr inbounds i16* %33, i64 %32
  %35 = load i16* %34, align 2
  %36 = sext i16 %35 to i32
  %37 = mul nsw i32 %31, %36
  %38 = sext i32 %37 to i64
  %39 = load i64* %4, align 8
  %40 = sub nsw i64 %39, %38
  store i64 %40, i64* %4, align 8
  %41 = load i64* %i, align 8
  %42 = load i16** %1, align 8
  %43 = getelementptr inbounds i16* %42, i64 %41
  %44 = load i16* %43, align 2
  %45 = sext i16 %44 to i64
  %46 = load i64* %i, align 8
  %47 = load i16** %2, align 8
  %48 = getelementptr inbounds i16* %47, i64 %46
  %49 = load i16* %48, align 2
  %50 = sext i16 %49 to i64
  %51 = load i64* %4, align 8
  %52 = ashr i64 %51, 16
  %53 = mul nsw i64 %50, %52
  %54 = ashr i64 %53, 16
  %55 = add nsw i64 %45, %54
  %56 = trunc i64 %55 to i16
  %57 = load i64* %i, align 8
  %58 = add nsw i64 %57, 1
  %59 = load i16** %1, align 8
  %60 = getelementptr inbounds i16* %59, i64 %58
  store i16 %56, i16* %60, align 2
  br label %61

; <label>:61                                      ; preds = %26
  %62 = load i64* %i, align 8
  %63 = add nsw i64 %62, -1
  store i64 %63, i64* %i, align 8
  br label %23

; <label>:64                                      ; preds = %23
  %65 = load i64* %4, align 8
  %66 = ashr i64 %65, 16
  %67 = trunc i64 %66 to i16
  %68 = load i16** %1, align 8
  %69 = getelementptr inbounds i16* %68, i64 0
  store i16 %67, i16* %69, align 2
  %70 = load i64* %4, align 8
  ret i64 %70
}

; Function Attrs: nounwind uwtable
define void @iir1(i16* %coefs, i16* %input, i64* %optr, i64* %state) #0 {
  %1 = alloca i16*, align 8
  %2 = alloca i16*, align 8
  %3 = alloca i64*, align 8
  %4 = alloca i64*, align 8
  %x = alloca i64, align 8
  %t = alloca i64, align 8
  %n = alloca i64, align 8
  store i16* %coefs, i16** %1, align 8
  store i16* %input, i16** %2, align 8
  store i64* %optr, i64** %3, align 8
  store i64* %state, i64** %4, align 8
  %5 = load i16** %2, align 8
  %6 = getelementptr inbounds i16* %5, i64 0
  %7 = load i16* %6, align 2
  %8 = sext i16 %7 to i64
  store i64 %8, i64* %x, align 8
  store i64 0, i64* %n, align 8
  br label %9

; <label>:9                                       ; preds = %65, %0
  %10 = load i64* %n, align 8
  %11 = icmp slt i64 %10, 50
  br i1 %11, label %12, label %68

; <label>:12                                      ; preds = %9
  %13 = load i64* %x, align 8
  %14 = load i16** %1, align 8
  %15 = getelementptr inbounds i16* %14, i64 2
  %16 = load i16* %15, align 2
  %17 = sext i16 %16 to i64
  %18 = load i64** %4, align 8
  %19 = getelementptr inbounds i64* %18, i64 0
  %20 = load i64* %19, align 8
  %21 = mul nsw i64 %17, %20
  %22 = load i16** %1, align 8
  %23 = getelementptr inbounds i16* %22, i64 3
  %24 = load i16* %23, align 2
  %25 = sext i16 %24 to i64
  %26 = load i64** %4, align 8
  %27 = getelementptr inbounds i64* %26, i64 1
  %28 = load i64* %27, align 8
  %29 = mul nsw i64 %25, %28
  %30 = add nsw i64 %21, %29
  %31 = ashr i64 %30, 15
  %32 = add nsw i64 %13, %31
  store i64 %32, i64* %t, align 8
  %33 = load i64* %t, align 8
  %34 = load i16** %1, align 8
  %35 = getelementptr inbounds i16* %34, i64 0
  %36 = load i16* %35, align 2
  %37 = sext i16 %36 to i64
  %38 = load i64** %4, align 8
  %39 = getelementptr inbounds i64* %38, i64 0
  %40 = load i64* %39, align 8
  %41 = mul nsw i64 %37, %40
  %42 = load i16** %1, align 8
  %43 = getelementptr inbounds i16* %42, i64 1
  %44 = load i16* %43, align 2
  %45 = sext i16 %44 to i64
  %46 = load i64** %4, align 8
  %47 = getelementptr inbounds i64* %46, i64 1
  %48 = load i64* %47, align 8
  %49 = mul nsw i64 %45, %48
  %50 = add nsw i64 %41, %49
  %51 = ashr i64 %50, 15
  %52 = add nsw i64 %33, %51
  store i64 %52, i64* %x, align 8
  %53 = load i64** %4, align 8
  %54 = getelementptr inbounds i64* %53, i64 0
  %55 = load i64* %54, align 8
  %56 = load i64** %4, align 8
  %57 = getelementptr inbounds i64* %56, i64 1
  store i64 %55, i64* %57, align 8
  %58 = load i64* %t, align 8
  %59 = load i64** %4, align 8
  %60 = getelementptr inbounds i64* %59, i64 0
  store i64 %58, i64* %60, align 8
  %61 = load i16** %1, align 8
  %62 = getelementptr inbounds i16* %61, i64 4
  store i16* %62, i16** %1, align 8
  %63 = load i64** %4, align 8
  %64 = getelementptr inbounds i64* %63, i64 2
  store i64* %64, i64** %4, align 8
  br label %65

; <label>:65                                      ; preds = %12
  %66 = load i64* %n, align 8
  %67 = add nsw i64 %66, 1
  store i64 %67, i64* %n, align 8
  br label %9

; <label>:68                                      ; preds = %9
  %69 = load i64* %x, align 8
  %70 = load i64** %3, align 8
  %71 = getelementptr inbounds i64* %70, i32 1
  store i64* %71, i64** %3, align 8
  store i64 %69, i64* %70, align 8
  ret void
}

; Function Attrs: nounwind uwtable
define i64 @codebook(i64 %mask, i64 %bitchanged, i64 %numbasis, i64 %codeword, i64 %g, i16* %d, i16 signext %ddim, i16 signext %theta) #0 {
  %1 = alloca i64, align 8
  %2 = alloca i64, align 8
  %3 = alloca i64, align 8
  %4 = alloca i64, align 8
  %5 = alloca i64, align 8
  %6 = alloca i16*, align 8
  %7 = alloca i16, align 2
  %8 = alloca i16, align 2
  %j = alloca i64, align 8
  %tmpMask = alloca i64, align 8
  store i64 %mask, i64* %1, align 8
  store i64 %bitchanged, i64* %2, align 8
  store i64 %numbasis, i64* %3, align 8
  store i64 %codeword, i64* %4, align 8
  store i64 %g, i64* %5, align 8
  store i16* %d, i16** %6, align 8
  store i16 %ddim, i16* %7, align 2
  store i16 %theta, i16* %8, align 2
  %9 = load i64* %1, align 8
  %10 = shl i64 %9, 1
  store i64 %10, i64* %tmpMask, align 8
  %11 = load i64* %2, align 8
  %12 = add nsw i64 %11, 1
  store i64 %12, i64* %j, align 8
  br label %13

; <label>:13                                      ; preds = %18, %0
  %14 = load i64* %j, align 8
  %15 = load i64* %3, align 8
  %16 = icmp sle i64 %14, %15
  br i1 %16, label %17, label %21

; <label>:17                                      ; preds = %13
  br label %18

; <label>:18                                      ; preds = %17
  %19 = load i64* %j, align 8
  %20 = add nsw i64 %19, 1
  store i64 %20, i64* %j, align 8
  br label %13

; <label>:21                                      ; preds = %13
  %22 = load i64* %5, align 8
  ret i64 %22
}

; Function Attrs: nounwind uwtable
define void @jpegdct(i16* %d, i16* %r) #0 {
  %1 = alloca i16*, align 8
  %2 = alloca i16*, align 8
  %t = alloca [12 x i64], align 16
  %i = alloca i16, align 2
  %j = alloca i16, align 2
  %k = alloca i16, align 2
  %m = alloca i16, align 2
  %n = alloca i16, align 2
  %p = alloca i16, align 2
  store i16* %d, i16** %1, align 8
  store i16* %r, i16** %2, align 8
  store i16 1, i16* %k, align 2
  store i16 0, i16* %m, align 2
  store i16 13, i16* %n, align 2
  store i16 8, i16* %p, align 2
  br label %3

; <label>:3                                       ; preds = %379, %0
  %4 = load i16* %k, align 2
  %5 = sext i16 %4 to i32
  %6 = icmp sle i32 %5, 8
  br i1 %6, label %7, label %398

; <label>:7                                       ; preds = %3
  store i16 0, i16* %i, align 2
  br label %8

; <label>:8                                       ; preds = %370, %7
  %9 = load i16* %i, align 2
  %10 = sext i16 %9 to i32
  %11 = icmp slt i32 %10, 8
  br i1 %11, label %12, label %378

; <label>:12                                      ; preds = %8
  store i16 0, i16* %j, align 2
  br label %13

; <label>:13                                      ; preds = %72, %12
  %14 = load i16* %j, align 2
  %15 = sext i16 %14 to i32
  %16 = icmp slt i32 %15, 4
  br i1 %16, label %17, label %75

; <label>:17                                      ; preds = %13
  %18 = load i16* %k, align 2
  %19 = sext i16 %18 to i32
  %20 = load i16* %j, align 2
  %21 = sext i16 %20 to i32
  %22 = mul nsw i32 %19, %21
  %23 = sext i32 %22 to i64
  %24 = load i16** %1, align 8
  %25 = getelementptr inbounds i16* %24, i64 %23
  %26 = load i16* %25, align 2
  %27 = sext i16 %26 to i32
  %28 = load i16* %k, align 2
  %29 = sext i16 %28 to i32
  %30 = load i16* %j, align 2
  %31 = sext i16 %30 to i32
  %32 = sub nsw i32 7, %31
  %33 = mul nsw i32 %29, %32
  %34 = sext i32 %33 to i64
  %35 = load i16** %1, align 8
  %36 = getelementptr inbounds i16* %35, i64 %34
  %37 = load i16* %36, align 2
  %38 = sext i16 %37 to i32
  %39 = add nsw i32 %27, %38
  %40 = sext i32 %39 to i64
  %41 = load i16* %j, align 2
  %42 = sext i16 %41 to i64
  %43 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 %42
  store i64 %40, i64* %43, align 8
  %44 = load i16* %k, align 2
  %45 = sext i16 %44 to i32
  %46 = load i16* %j, align 2
  %47 = sext i16 %46 to i32
  %48 = mul nsw i32 %45, %47
  %49 = sext i32 %48 to i64
  %50 = load i16** %1, align 8
  %51 = getelementptr inbounds i16* %50, i64 %49
  %52 = load i16* %51, align 2
  %53 = sext i16 %52 to i32
  %54 = load i16* %k, align 2
  %55 = sext i16 %54 to i32
  %56 = load i16* %j, align 2
  %57 = sext i16 %56 to i32
  %58 = sub nsw i32 7, %57
  %59 = mul nsw i32 %55, %58
  %60 = sext i32 %59 to i64
  %61 = load i16** %1, align 8
  %62 = getelementptr inbounds i16* %61, i64 %60
  %63 = load i16* %62, align 2
  %64 = sext i16 %63 to i32
  %65 = sub nsw i32 %53, %64
  %66 = sext i32 %65 to i64
  %67 = load i16* %j, align 2
  %68 = sext i16 %67 to i32
  %69 = sub nsw i32 7, %68
  %70 = sext i32 %69 to i64
  %71 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 %70
  store i64 %66, i64* %71, align 8
  br label %72

; <label>:72                                      ; preds = %17
  %73 = load i16* %j, align 2
  %74 = add i16 %73, 1
  store i16 %74, i16* %j, align 2
  br label %13

; <label>:75                                      ; preds = %13
  %76 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 0
  %77 = load i64* %76, align 8
  %78 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 3
  %79 = load i64* %78, align 8
  %80 = add nsw i64 %77, %79
  %81 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 8
  store i64 %80, i64* %81, align 8
  %82 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 0
  %83 = load i64* %82, align 8
  %84 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 3
  %85 = load i64* %84, align 8
  %86 = sub nsw i64 %83, %85
  %87 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 9
  store i64 %86, i64* %87, align 8
  %88 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 1
  %89 = load i64* %88, align 8
  %90 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 2
  %91 = load i64* %90, align 8
  %92 = add nsw i64 %89, %91
  %93 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 10
  store i64 %92, i64* %93, align 8
  %94 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 1
  %95 = load i64* %94, align 8
  %96 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 2
  %97 = load i64* %96, align 8
  %98 = sub nsw i64 %95, %97
  %99 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 11
  store i64 %98, i64* %99, align 8
  %100 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 8
  %101 = load i64* %100, align 8
  %102 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 10
  %103 = load i64* %102, align 8
  %104 = add nsw i64 %101, %103
  %105 = load i16* %m, align 2
  %106 = sext i16 %105 to i32
  %107 = zext i32 %106 to i64
  %108 = ashr i64 %104, %107
  %109 = trunc i64 %108 to i16
  %110 = load i16** %1, align 8
  %111 = getelementptr inbounds i16* %110, i64 0
  store i16 %109, i16* %111, align 2
  %112 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 8
  %113 = load i64* %112, align 8
  %114 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 10
  %115 = load i64* %114, align 8
  %116 = sub nsw i64 %113, %115
  %117 = load i16* %m, align 2
  %118 = sext i16 %117 to i32
  %119 = zext i32 %118 to i64
  %120 = ashr i64 %116, %119
  %121 = trunc i64 %120 to i16
  %122 = load i16* %k, align 2
  %123 = sext i16 %122 to i32
  %124 = mul nsw i32 4, %123
  %125 = sext i32 %124 to i64
  %126 = load i16** %1, align 8
  %127 = getelementptr inbounds i16* %126, i64 %125
  store i16 %121, i16* %127, align 2
  %128 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 11
  %129 = load i64* %128, align 8
  %130 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 9
  %131 = load i64* %130, align 8
  %132 = add nsw i64 %129, %131
  %133 = trunc i64 %132 to i16
  %134 = sext i16 %133 to i32
  %135 = load i16** %2, align 8
  %136 = getelementptr inbounds i16* %135, i64 10
  %137 = load i16* %136, align 2
  %138 = sext i16 %137 to i32
  %139 = mul nsw i32 %134, %138
  %140 = sext i32 %139 to i64
  %141 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 8
  store i64 %140, i64* %141, align 8
  %142 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 8
  %143 = load i64* %142, align 8
  %144 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 9
  %145 = load i64* %144, align 8
  %146 = load i16** %2, align 8
  %147 = getelementptr inbounds i16* %146, i64 9
  %148 = load i16* %147, align 2
  %149 = sext i16 %148 to i64
  %150 = mul nsw i64 %145, %149
  %151 = load i16* %n, align 2
  %152 = sext i16 %151 to i32
  %153 = zext i32 %152 to i64
  %154 = ashr i64 %150, %153
  %155 = trunc i64 %154 to i16
  %156 = sext i16 %155 to i64
  %157 = add nsw i64 %143, %156
  %158 = trunc i64 %157 to i16
  %159 = load i16* %k, align 2
  %160 = sext i16 %159 to i32
  %161 = mul nsw i32 2, %160
  %162 = sext i32 %161 to i64
  %163 = load i16** %1, align 8
  %164 = getelementptr inbounds i16* %163, i64 %162
  store i16 %158, i16* %164, align 2
  %165 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 8
  %166 = load i64* %165, align 8
  %167 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 11
  %168 = load i64* %167, align 8
  %169 = load i16** %2, align 8
  %170 = getelementptr inbounds i16* %169, i64 11
  %171 = load i16* %170, align 2
  %172 = sext i16 %171 to i64
  %173 = mul nsw i64 %168, %172
  %174 = load i16* %n, align 2
  %175 = sext i16 %174 to i32
  %176 = zext i32 %175 to i64
  %177 = ashr i64 %173, %176
  %178 = trunc i64 %177 to i16
  %179 = sext i16 %178 to i64
  %180 = add nsw i64 %166, %179
  %181 = trunc i64 %180 to i16
  %182 = load i16* %k, align 2
  %183 = sext i16 %182 to i32
  %184 = mul nsw i32 6, %183
  %185 = sext i32 %184 to i64
  %186 = load i16** %1, align 8
  %187 = getelementptr inbounds i16* %186, i64 %185
  store i16 %181, i16* %187, align 2
  %188 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 4
  %189 = load i64* %188, align 8
  %190 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 7
  %191 = load i64* %190, align 8
  %192 = add nsw i64 %189, %191
  %193 = trunc i64 %192 to i16
  %194 = sext i16 %193 to i32
  %195 = load i16** %2, align 8
  %196 = getelementptr inbounds i16* %195, i64 2
  %197 = load i16* %196, align 2
  %198 = sext i16 %197 to i32
  %199 = mul nsw i32 %194, %198
  %200 = sext i32 %199 to i64
  %201 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 0
  store i64 %200, i64* %201, align 8
  %202 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 5
  %203 = load i64* %202, align 8
  %204 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 6
  %205 = load i64* %204, align 8
  %206 = add nsw i64 %203, %205
  %207 = trunc i64 %206 to i16
  %208 = sext i16 %207 to i32
  %209 = load i16** %2, align 8
  %210 = getelementptr inbounds i16* %209, i64 0
  %211 = load i16* %210, align 2
  %212 = sext i16 %211 to i32
  %213 = mul nsw i32 %208, %212
  %214 = sext i32 %213 to i64
  %215 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 1
  store i64 %214, i64* %215, align 8
  %216 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 4
  %217 = load i64* %216, align 8
  %218 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 6
  %219 = load i64* %218, align 8
  %220 = add nsw i64 %217, %219
  %221 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 2
  store i64 %220, i64* %221, align 8
  %222 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 5
  %223 = load i64* %222, align 8
  %224 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 7
  %225 = load i64* %224, align 8
  %226 = add nsw i64 %223, %225
  %227 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 3
  store i64 %226, i64* %227, align 8
  %228 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 2
  %229 = load i64* %228, align 8
  %230 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 3
  %231 = load i64* %230, align 8
  %232 = add nsw i64 %229, %231
  %233 = trunc i64 %232 to i16
  %234 = sext i16 %233 to i32
  %235 = load i16** %2, align 8
  %236 = getelementptr inbounds i16* %235, i64 8
  %237 = load i16* %236, align 2
  %238 = sext i16 %237 to i32
  %239 = mul nsw i32 %234, %238
  %240 = sext i32 %239 to i64
  %241 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 8
  store i64 %240, i64* %241, align 8
  %242 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 2
  %243 = load i64* %242, align 8
  %244 = trunc i64 %243 to i16
  %245 = sext i16 %244 to i32
  %246 = load i16** %2, align 8
  %247 = getelementptr inbounds i16* %246, i64 1
  %248 = load i16* %247, align 2
  %249 = sext i16 %248 to i32
  %250 = mul nsw i32 %245, %249
  %251 = sext i32 %250 to i64
  %252 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 8
  %253 = load i64* %252, align 8
  %254 = add nsw i64 %251, %253
  %255 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 2
  store i64 %254, i64* %255, align 8
  %256 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 3
  %257 = load i64* %256, align 8
  %258 = trunc i64 %257 to i16
  %259 = sext i16 %258 to i32
  %260 = load i16** %2, align 8
  %261 = getelementptr inbounds i16* %260, i64 3
  %262 = load i16* %261, align 2
  %263 = sext i16 %262 to i32
  %264 = mul nsw i32 %259, %263
  %265 = sext i32 %264 to i64
  %266 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 8
  %267 = load i64* %266, align 8
  %268 = add nsw i64 %265, %267
  %269 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 3
  store i64 %268, i64* %269, align 8
  %270 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 4
  %271 = load i64* %270, align 8
  %272 = load i16** %2, align 8
  %273 = getelementptr inbounds i16* %272, i64 4
  %274 = load i16* %273, align 2
  %275 = sext i16 %274 to i64
  %276 = mul nsw i64 %271, %275
  %277 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 0
  %278 = load i64* %277, align 8
  %279 = add nsw i64 %276, %278
  %280 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 2
  %281 = load i64* %280, align 8
  %282 = add nsw i64 %279, %281
  %283 = trunc i64 %282 to i16
  %284 = sext i16 %283 to i32
  %285 = load i16* %n, align 2
  %286 = sext i16 %285 to i32
  %287 = ashr i32 %284, %286
  %288 = trunc i32 %287 to i16
  %289 = load i16* %k, align 2
  %290 = sext i16 %289 to i32
  %291 = mul nsw i32 7, %290
  %292 = sext i32 %291 to i64
  %293 = load i16** %1, align 8
  %294 = getelementptr inbounds i16* %293, i64 %292
  store i16 %288, i16* %294, align 2
  %295 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 5
  %296 = load i64* %295, align 8
  %297 = load i16** %2, align 8
  %298 = getelementptr inbounds i16* %297, i64 6
  %299 = load i16* %298, align 2
  %300 = sext i16 %299 to i64
  %301 = mul nsw i64 %296, %300
  %302 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 1
  %303 = load i64* %302, align 8
  %304 = add nsw i64 %301, %303
  %305 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 3
  %306 = load i64* %305, align 8
  %307 = add nsw i64 %304, %306
  %308 = trunc i64 %307 to i16
  %309 = sext i16 %308 to i32
  %310 = load i16* %n, align 2
  %311 = sext i16 %310 to i32
  %312 = ashr i32 %309, %311
  %313 = trunc i32 %312 to i16
  %314 = load i16* %k, align 2
  %315 = sext i16 %314 to i32
  %316 = mul nsw i32 5, %315
  %317 = sext i32 %316 to i64
  %318 = load i16** %1, align 8
  %319 = getelementptr inbounds i16* %318, i64 %317
  store i16 %313, i16* %319, align 2
  %320 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 6
  %321 = load i64* %320, align 8
  %322 = load i16** %2, align 8
  %323 = getelementptr inbounds i16* %322, i64 5
  %324 = load i16* %323, align 2
  %325 = sext i16 %324 to i64
  %326 = mul nsw i64 %321, %325
  %327 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 1
  %328 = load i64* %327, align 8
  %329 = add nsw i64 %326, %328
  %330 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 2
  %331 = load i64* %330, align 8
  %332 = add nsw i64 %329, %331
  %333 = trunc i64 %332 to i16
  %334 = sext i16 %333 to i32
  %335 = load i16* %n, align 2
  %336 = sext i16 %335 to i32
  %337 = ashr i32 %334, %336
  %338 = trunc i32 %337 to i16
  %339 = load i16* %k, align 2
  %340 = sext i16 %339 to i32
  %341 = mul nsw i32 3, %340
  %342 = sext i32 %341 to i64
  %343 = load i16** %1, align 8
  %344 = getelementptr inbounds i16* %343, i64 %342
  store i16 %338, i16* %344, align 2
  %345 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 7
  %346 = load i64* %345, align 8
  %347 = load i16** %2, align 8
  %348 = getelementptr inbounds i16* %347, i64 7
  %349 = load i16* %348, align 2
  %350 = sext i16 %349 to i64
  %351 = mul nsw i64 %346, %350
  %352 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 0
  %353 = load i64* %352, align 8
  %354 = add nsw i64 %351, %353
  %355 = getelementptr inbounds [12 x i64]* %t, i32 0, i64 3
  %356 = load i64* %355, align 8
  %357 = add nsw i64 %354, %356
  %358 = trunc i64 %357 to i16
  %359 = sext i16 %358 to i32
  %360 = load i16* %n, align 2
  %361 = sext i16 %360 to i32
  %362 = ashr i32 %359, %361
  %363 = trunc i32 %362 to i16
  %364 = load i16* %k, align 2
  %365 = sext i16 %364 to i32
  %366 = mul nsw i32 1, %365
  %367 = sext i32 %366 to i64
  %368 = load i16** %1, align 8
  %369 = getelementptr inbounds i16* %368, i64 %367
  store i16 %363, i16* %369, align 2
  br label %370

; <label>:370                                     ; preds = %75
  %371 = load i16* %i, align 2
  %372 = add i16 %371, 1
  store i16 %372, i16* %i, align 2
  %373 = load i16* %p, align 2
  %374 = sext i16 %373 to i32
  %375 = load i16** %1, align 8
  %376 = sext i32 %374 to i64
  %377 = getelementptr inbounds i16* %375, i64 %376
  store i16* %377, i16** %1, align 8
  br label %8

; <label>:378                                     ; preds = %8
  br label %379

; <label>:379                                     ; preds = %378
  %380 = load i16* %k, align 2
  %381 = sext i16 %380 to i32
  %382 = add nsw i32 %381, 7
  %383 = trunc i32 %382 to i16
  store i16 %383, i16* %k, align 2
  %384 = load i16* %m, align 2
  %385 = sext i16 %384 to i32
  %386 = add nsw i32 %385, 3
  %387 = trunc i32 %386 to i16
  store i16 %387, i16* %m, align 2
  %388 = load i16* %n, align 2
  %389 = sext i16 %388 to i32
  %390 = add nsw i32 %389, 3
  %391 = trunc i32 %390 to i16
  store i16 %391, i16* %n, align 2
  %392 = load i16* %p, align 2
  %393 = sext i16 %392 to i32
  %394 = sub nsw i32 %393, 7
  %395 = trunc i32 %394 to i16
  store i16 %395, i16* %p, align 2
  %396 = load i16** %1, align 8
  %397 = getelementptr inbounds i16* %396, i64 -64
  store i16* %397, i16** %1, align 8
  br label %3

; <label>:398                                     ; preds = %3
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %c = alloca i16, align 2
  %output = alloca [200 x i64], align 16
  %d = alloca i64, align 8
  %e = alloca [1 x i32], align 4
  store i32 0, i32* %1
  store i16 3, i16* %c, align 2
  store i64 43690, i64* %d, align 8
  %2 = bitcast [1 x i32]* %e to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %2, i8* bitcast ([1 x i32]* @main.e to i8*), i64 4, i32 4, i1 false)
  %3 = load i16* %c, align 2
  call void @vec_mpy1(i16* getelementptr inbounds ([200 x i16]* @a, i32 0, i32 0), i16* getelementptr inbounds ([200 x i16]* @b, i32 0, i32 0), i16 signext %3)
  %4 = load i16* %c, align 2
  %5 = sext i16 %4 to i64
  %6 = getelementptr inbounds [200 x i64]* %output, i32 0, i32 0
  %7 = call i64 @mac(i16* getelementptr inbounds ([200 x i16]* @a, i32 0, i32 0), i16* getelementptr inbounds ([200 x i16]* @b, i32 0, i32 0), i64 %5, i64* %6)
  %8 = trunc i64 %7 to i16
  store i16 %8, i16* %c, align 2
  %9 = getelementptr inbounds [200 x i64]* %output, i32 0, i32 0
  call void @fir(i16* getelementptr inbounds ([200 x i16]* @a, i32 0, i32 0), i16* getelementptr inbounds ([200 x i16]* @b, i32 0, i32 0), i64* %9)
  %10 = getelementptr inbounds [200 x i64]* %output, i32 0, i32 0
  call void @fir_no_red_ld(i16* getelementptr inbounds ([200 x i16]* @a, i32 0, i32 0), i16* getelementptr inbounds ([200 x i16]* @b, i32 0, i32 0), i64* %10)
  %11 = load i64* %d, align 8
  %12 = call i64 @latsynth(i16* getelementptr inbounds ([200 x i16]* @a, i32 0, i32 0), i16* getelementptr inbounds ([200 x i16]* @b, i32 0, i32 0), i64 100, i64 %11)
  store i64 %12, i64* %d, align 8
  %13 = getelementptr inbounds [200 x i64]* %output, i32 0, i64 100
  %14 = getelementptr inbounds [200 x i64]* %output, i32 0, i32 0
  call void @iir1(i16* getelementptr inbounds ([200 x i16]* @a, i32 0, i32 0), i16* getelementptr inbounds ([200 x i16]* @b, i32 0, i32 0), i64* %13, i64* %14)
  %15 = load i64* %d, align 8
  %16 = getelementptr inbounds [1 x i32]* %e, i32 0, i64 0
  %17 = load i32* %16, align 4
  %18 = sext i32 %17 to i64
  %19 = load i64* %d, align 8
  %20 = load i16* %c, align 2
  %21 = call i64 @codebook(i64 %15, i64 1, i64 17, i64 %18, i64 %19, i16* getelementptr inbounds ([200 x i16]* @a, i32 0, i32 0), i16 signext %20, i16 signext 1)
  %22 = trunc i64 %21 to i32
  %23 = getelementptr inbounds [1 x i32]* %e, i32 0, i64 0
  store i32 %22, i32* %23, align 4
  call void @jpegdct(i16* getelementptr inbounds ([200 x i16]* @a, i32 0, i32 0), i16* getelementptr inbounds ([200 x i16]* @b, i32 0, i32 0))
  ret i32 0
}

; Function Attrs: nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture, i64, i32, i1) #1

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
