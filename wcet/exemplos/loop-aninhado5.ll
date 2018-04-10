; ModuleID = 'loop-aninhado5.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %l = alloca i32, align 4
  %m = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %k, align 4
  store i32 0, i32* %l, align 4
  store i32 0, i32* %m, align 4
  store i32 0, i32* %m, align 4
  br label %2

; <label>:2                                       ; preds = %38, %0
  %3 = load i32* %m, align 4
  %4 = icmp slt i32 %3, 5
  br i1 %4, label %5, label %41

; <label>:5                                       ; preds = %2
  store i32 0, i32* %i, align 4
  br label %6

; <label>:6                                       ; preds = %26, %5
  %7 = load i32* %i, align 4
  %8 = icmp slt i32 %7, 5
  br i1 %8, label %9, label %29

; <label>:9                                       ; preds = %6
  store i32 0, i32* %j, align 4
  br label %10

; <label>:10                                      ; preds = %14, %9
  %11 = load i32* %j, align 4
  %12 = icmp slt i32 %11, 5
  br i1 %12, label %13, label %17

; <label>:13                                      ; preds = %10
  br label %14

; <label>:14                                      ; preds = %13
  %15 = load i32* %j, align 4
  %16 = add nsw i32 %15, 1
  store i32 %16, i32* %j, align 4
  br label %10

; <label>:17                                      ; preds = %10
  store i32 0, i32* %k, align 4
  br label %18

; <label>:18                                      ; preds = %22, %17
  %19 = load i32* %k, align 4
  %20 = icmp slt i32 %19, 5
  br i1 %20, label %21, label %25

; <label>:21                                      ; preds = %18
  br label %22

; <label>:22                                      ; preds = %21
  %23 = load i32* %k, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %k, align 4
  br label %18

; <label>:25                                      ; preds = %18
  br label %26

; <label>:26                                      ; preds = %25
  %27 = load i32* %i, align 4
  %28 = add nsw i32 %27, 1
  store i32 %28, i32* %i, align 4
  br label %6

; <label>:29                                      ; preds = %6
  store i32 0, i32* %l, align 4
  br label %30

; <label>:30                                      ; preds = %34, %29
  %31 = load i32* %l, align 4
  %32 = icmp slt i32 %31, 5
  br i1 %32, label %33, label %37

; <label>:33                                      ; preds = %30
  br label %34

; <label>:34                                      ; preds = %33
  %35 = load i32* %l, align 4
  %36 = add nsw i32 %35, 1
  store i32 %36, i32* %l, align 4
  br label %30

; <label>:37                                      ; preds = %30
  br label %38

; <label>:38                                      ; preds = %37
  %39 = load i32* %m, align 4
  %40 = add nsw i32 %39, 1
  store i32 %40, i32* %m, align 4
  br label %2

; <label>:41                                      ; preds = %2
  store i32 0, i32* %m, align 4
  br label %42

; <label>:42                                      ; preds = %78, %41
  %43 = load i32* %m, align 4
  %44 = icmp slt i32 %43, 5
  br i1 %44, label %45, label %81

; <label>:45                                      ; preds = %42
  store i32 0, i32* %i, align 4
  br label %46

; <label>:46                                      ; preds = %66, %45
  %47 = load i32* %i, align 4
  %48 = icmp slt i32 %47, 5
  br i1 %48, label %49, label %69

; <label>:49                                      ; preds = %46
  store i32 0, i32* %j, align 4
  br label %50

; <label>:50                                      ; preds = %54, %49
  %51 = load i32* %j, align 4
  %52 = icmp slt i32 %51, 5
  br i1 %52, label %53, label %57

; <label>:53                                      ; preds = %50
  br label %54

; <label>:54                                      ; preds = %53
  %55 = load i32* %j, align 4
  %56 = add nsw i32 %55, 1
  store i32 %56, i32* %j, align 4
  br label %50

; <label>:57                                      ; preds = %50
  store i32 0, i32* %k, align 4
  br label %58

; <label>:58                                      ; preds = %62, %57
  %59 = load i32* %k, align 4
  %60 = icmp slt i32 %59, 5
  br i1 %60, label %61, label %65

; <label>:61                                      ; preds = %58
  br label %62

; <label>:62                                      ; preds = %61
  %63 = load i32* %k, align 4
  %64 = add nsw i32 %63, 1
  store i32 %64, i32* %k, align 4
  br label %58

; <label>:65                                      ; preds = %58
  br label %66

; <label>:66                                      ; preds = %65
  %67 = load i32* %i, align 4
  %68 = add nsw i32 %67, 1
  store i32 %68, i32* %i, align 4
  br label %46

; <label>:69                                      ; preds = %46
  store i32 0, i32* %l, align 4
  br label %70

; <label>:70                                      ; preds = %74, %69
  %71 = load i32* %l, align 4
  %72 = icmp slt i32 %71, 5
  br i1 %72, label %73, label %77

; <label>:73                                      ; preds = %70
  br label %74

; <label>:74                                      ; preds = %73
  %75 = load i32* %l, align 4
  %76 = add nsw i32 %75, 1
  store i32 %76, i32* %l, align 4
  br label %70

; <label>:77                                      ; preds = %70
  br label %78

; <label>:78                                      ; preds = %77
  %79 = load i32* %m, align 4
  %80 = add nsw i32 %79, 1
  store i32 %80, i32* %m, align 4
  br label %42

; <label>:81                                      ; preds = %42
  %82 = load i32* %1
  ret i32 %82
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
