; ModuleID = 'loop-aninhado8.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @bar() #0 {
  %k = alloca i32, align 4
  store i32 0, i32* %k, align 4
  store i32 0, i32* %k, align 4
  br label %1

; <label>:1                                       ; preds = %5, %0
  %2 = load i32* %k, align 4
  %3 = icmp slt i32 %2, 1
  br i1 %3, label %4, label %8

; <label>:4                                       ; preds = %1
  br label %5

; <label>:5                                       ; preds = %4
  %6 = load i32* %k, align 4
  %7 = add nsw i32 %6, 1
  store i32 %7, i32* %k, align 4
  br label %1

; <label>:8                                       ; preds = %1
  ret i32 0
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %l = alloca i32, align 4
  %m = alloca i32, align 4
  %n = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %k, align 4
  store i32 0, i32* %l, align 4
  store i32 0, i32* %m, align 4
  store i32 0, i32* %n, align 4
  store i32 0, i32* %m, align 4
  br label %2

; <label>:2                                       ; preds = %70, %0
  %3 = load i32* %m, align 4
  %4 = icmp slt i32 %3, 1
  br i1 %4, label %5, label %73

; <label>:5                                       ; preds = %2
  %6 = load i32* %n, align 4
  %7 = icmp ne i32 %6, 0
  br i1 %7, label %8, label %44

; <label>:8                                       ; preds = %5
  store i32 0, i32* %i, align 4
  br label %9

; <label>:9                                       ; preds = %31, %8
  %10 = load i32* %i, align 4
  %11 = icmp slt i32 %10, 1
  br i1 %11, label %12, label %34

; <label>:12                                      ; preds = %9
  store i32 0, i32* %j, align 4
  br label %13

; <label>:13                                      ; preds = %18, %12
  %14 = load i32* %j, align 4
  %15 = icmp slt i32 %14, 1
  br i1 %15, label %16, label %21

; <label>:16                                      ; preds = %13
  %17 = call i32 @bar()
  br label %18

; <label>:18                                      ; preds = %16
  %19 = load i32* %j, align 4
  %20 = add nsw i32 %19, 1
  store i32 %20, i32* %j, align 4
  br label %13

; <label>:21                                      ; preds = %13
  store i32 0, i32* %k, align 4
  br label %22

; <label>:22                                      ; preds = %27, %21
  %23 = load i32* %k, align 4
  %24 = icmp slt i32 %23, 1
  br i1 %24, label %25, label %30

; <label>:25                                      ; preds = %22
  %26 = call i32 @bar()
  br label %27

; <label>:27                                      ; preds = %25
  %28 = load i32* %k, align 4
  %29 = add nsw i32 %28, 1
  store i32 %29, i32* %k, align 4
  br label %22

; <label>:30                                      ; preds = %22
  br label %31

; <label>:31                                      ; preds = %30
  %32 = load i32* %i, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, i32* %i, align 4
  br label %9

; <label>:34                                      ; preds = %9
  store i32 0, i32* %l, align 4
  br label %35

; <label>:35                                      ; preds = %40, %34
  %36 = load i32* %l, align 4
  %37 = icmp slt i32 %36, 1
  br i1 %37, label %38, label %43

; <label>:38                                      ; preds = %35
  %39 = call i32 @bar()
  br label %40

; <label>:40                                      ; preds = %38
  %41 = load i32* %l, align 4
  %42 = add nsw i32 %41, 1
  store i32 %42, i32* %l, align 4
  br label %35

; <label>:43                                      ; preds = %35
  br label %69

; <label>:44                                      ; preds = %5
  %45 = call i32 @bar()
  %46 = call i32 @bar()
  %47 = call i32 @bar()
  %48 = call i32 @bar()
  %49 = call i32 @bar()
  %50 = call i32 @bar()
  %51 = call i32 @bar()
  %52 = call i32 @bar()
  %53 = call i32 @bar()
  %54 = call i32 @bar()
  %55 = call i32 @bar()
  %56 = call i32 @bar()
  %57 = call i32 @bar()
  %58 = call i32 @bar()
  %59 = call i32 @bar()
  %60 = call i32 @bar()
  %61 = call i32 @bar()
  %62 = call i32 @bar()
  %63 = call i32 @bar()
  %64 = call i32 @bar()
  %65 = call i32 @bar()
  %66 = call i32 @bar()
  %67 = call i32 @bar()
  %68 = call i32 @bar()
  br label %69

; <label>:69                                      ; preds = %44, %43
  br label %70

; <label>:70                                      ; preds = %69
  %71 = load i32* %m, align 4
  %72 = add nsw i32 %71, 1
  store i32 %72, i32* %m, align 4
  br label %2

; <label>:73                                      ; preds = %2
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
