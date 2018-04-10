; ModuleID = 'loop-aninhado11.c'
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
  %n = alloca i32, align 4
  store i32 0, i32* %1
  store i32 0, i32* %i, align 4
  store i32 0, i32* %j, align 4
  store i32 0, i32* %k, align 4
  store i32 0, i32* %l, align 4
  store i32 0, i32* %m, align 4
  store i32 0, i32* %n, align 4
  br label %2

; <label>:2                                       ; preds = %126, %0
  %3 = load i32* %n, align 4
  %4 = add nsw i32 %3, 1
  store i32 %4, i32* %n, align 4
  %5 = icmp slt i32 %3, 10
  br i1 %5, label %6, label %127

; <label>:6                                       ; preds = %2
  store i32 0, i32* %m, align 4
  br label %7

; <label>:7                                       ; preds = %43, %6
  %8 = load i32* %m, align 4
  %9 = icmp slt i32 %8, 10
  br i1 %9, label %10, label %46

; <label>:10                                      ; preds = %7
  store i32 0, i32* %i, align 4
  br label %11

; <label>:11                                      ; preds = %31, %10
  %12 = load i32* %i, align 4
  %13 = icmp slt i32 %12, 10
  br i1 %13, label %14, label %34

; <label>:14                                      ; preds = %11
  store i32 0, i32* %j, align 4
  br label %15

; <label>:15                                      ; preds = %19, %14
  %16 = load i32* %j, align 4
  %17 = icmp slt i32 %16, 10
  br i1 %17, label %18, label %22

; <label>:18                                      ; preds = %15
  br label %19

; <label>:19                                      ; preds = %18
  %20 = load i32* %j, align 4
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %j, align 4
  br label %15

; <label>:22                                      ; preds = %15
  store i32 0, i32* %k, align 4
  br label %23

; <label>:23                                      ; preds = %27, %22
  %24 = load i32* %k, align 4
  %25 = icmp slt i32 %24, 10
  br i1 %25, label %26, label %30

; <label>:26                                      ; preds = %23
  br label %27

; <label>:27                                      ; preds = %26
  %28 = load i32* %k, align 4
  %29 = add nsw i32 %28, 1
  store i32 %29, i32* %k, align 4
  br label %23

; <label>:30                                      ; preds = %23
  br label %31

; <label>:31                                      ; preds = %30
  %32 = load i32* %i, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, i32* %i, align 4
  br label %11

; <label>:34                                      ; preds = %11
  store i32 0, i32* %l, align 4
  br label %35

; <label>:35                                      ; preds = %39, %34
  %36 = load i32* %l, align 4
  %37 = icmp slt i32 %36, 10
  br i1 %37, label %38, label %42

; <label>:38                                      ; preds = %35
  br label %39

; <label>:39                                      ; preds = %38
  %40 = load i32* %l, align 4
  %41 = add nsw i32 %40, 1
  store i32 %41, i32* %l, align 4
  br label %35

; <label>:42                                      ; preds = %35
  br label %43

; <label>:43                                      ; preds = %42
  %44 = load i32* %m, align 4
  %45 = add nsw i32 %44, 1
  store i32 %45, i32* %m, align 4
  br label %7

; <label>:46                                      ; preds = %7
  store i32 0, i32* %m, align 4
  br label %47

; <label>:47                                      ; preds = %83, %46
  %48 = load i32* %m, align 4
  %49 = icmp slt i32 %48, 10
  br i1 %49, label %50, label %86

; <label>:50                                      ; preds = %47
  store i32 0, i32* %i, align 4
  br label %51

; <label>:51                                      ; preds = %71, %50
  %52 = load i32* %i, align 4
  %53 = icmp slt i32 %52, 10
  br i1 %53, label %54, label %74

; <label>:54                                      ; preds = %51
  store i32 0, i32* %j, align 4
  br label %55

; <label>:55                                      ; preds = %59, %54
  %56 = load i32* %j, align 4
  %57 = icmp slt i32 %56, 10
  br i1 %57, label %58, label %62

; <label>:58                                      ; preds = %55
  br label %59

; <label>:59                                      ; preds = %58
  %60 = load i32* %j, align 4
  %61 = add nsw i32 %60, 1
  store i32 %61, i32* %j, align 4
  br label %55

; <label>:62                                      ; preds = %55
  store i32 0, i32* %k, align 4
  br label %63

; <label>:63                                      ; preds = %67, %62
  %64 = load i32* %k, align 4
  %65 = icmp slt i32 %64, 10
  br i1 %65, label %66, label %70

; <label>:66                                      ; preds = %63
  br label %67

; <label>:67                                      ; preds = %66
  %68 = load i32* %k, align 4
  %69 = add nsw i32 %68, 1
  store i32 %69, i32* %k, align 4
  br label %63

; <label>:70                                      ; preds = %63
  br label %71

; <label>:71                                      ; preds = %70
  %72 = load i32* %i, align 4
  %73 = add nsw i32 %72, 1
  store i32 %73, i32* %i, align 4
  br label %51

; <label>:74                                      ; preds = %51
  store i32 0, i32* %l, align 4
  br label %75

; <label>:75                                      ; preds = %79, %74
  %76 = load i32* %l, align 4
  %77 = icmp slt i32 %76, 10
  br i1 %77, label %78, label %82

; <label>:78                                      ; preds = %75
  br label %79

; <label>:79                                      ; preds = %78
  %80 = load i32* %l, align 4
  %81 = add nsw i32 %80, 1
  store i32 %81, i32* %l, align 4
  br label %75

; <label>:82                                      ; preds = %75
  br label %83

; <label>:83                                      ; preds = %82
  %84 = load i32* %m, align 4
  %85 = add nsw i32 %84, 1
  store i32 %85, i32* %m, align 4
  br label %47

; <label>:86                                      ; preds = %47
  store i32 0, i32* %m, align 4
  br label %87

; <label>:87                                      ; preds = %123, %86
  %88 = load i32* %m, align 4
  %89 = icmp slt i32 %88, 10
  br i1 %89, label %90, label %126

; <label>:90                                      ; preds = %87
  store i32 0, i32* %i, align 4
  br label %91

; <label>:91                                      ; preds = %111, %90
  %92 = load i32* %i, align 4
  %93 = icmp slt i32 %92, 10
  br i1 %93, label %94, label %114

; <label>:94                                      ; preds = %91
  store i32 0, i32* %j, align 4
  br label %95

; <label>:95                                      ; preds = %99, %94
  %96 = load i32* %j, align 4
  %97 = icmp slt i32 %96, 10
  br i1 %97, label %98, label %102

; <label>:98                                      ; preds = %95
  br label %99

; <label>:99                                      ; preds = %98
  %100 = load i32* %j, align 4
  %101 = add nsw i32 %100, 1
  store i32 %101, i32* %j, align 4
  br label %95

; <label>:102                                     ; preds = %95
  store i32 0, i32* %k, align 4
  br label %103

; <label>:103                                     ; preds = %107, %102
  %104 = load i32* %k, align 4
  %105 = icmp slt i32 %104, 10
  br i1 %105, label %106, label %110

; <label>:106                                     ; preds = %103
  br label %107

; <label>:107                                     ; preds = %106
  %108 = load i32* %k, align 4
  %109 = add nsw i32 %108, 1
  store i32 %109, i32* %k, align 4
  br label %103

; <label>:110                                     ; preds = %103
  br label %111

; <label>:111                                     ; preds = %110
  %112 = load i32* %i, align 4
  %113 = add nsw i32 %112, 1
  store i32 %113, i32* %i, align 4
  br label %91

; <label>:114                                     ; preds = %91
  store i32 0, i32* %l, align 4
  br label %115

; <label>:115                                     ; preds = %119, %114
  %116 = load i32* %l, align 4
  %117 = icmp slt i32 %116, 10
  br i1 %117, label %118, label %122

; <label>:118                                     ; preds = %115
  br label %119

; <label>:119                                     ; preds = %118
  %120 = load i32* %l, align 4
  %121 = add nsw i32 %120, 1
  store i32 %121, i32* %l, align 4
  br label %115

; <label>:122                                     ; preds = %115
  br label %123

; <label>:123                                     ; preds = %122
  %124 = load i32* %m, align 4
  %125 = add nsw i32 %124, 1
  store i32 %125, i32* %m, align 4
  br label %87

; <label>:126                                     ; preds = %87
  br label %2

; <label>:127                                     ; preds = %2
  %128 = load i32* %1
  ret i32 %128
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
