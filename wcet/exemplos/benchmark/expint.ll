; ModuleID = 'expint.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define void @main() #0 {
  %1 = call i64 @expint(i32 50, i64 1)
  ret void
}

; Function Attrs: nounwind uwtable
define i64 @expint(i32 %n, i64 %x) #0 {
  %1 = alloca i64, align 8
  %2 = alloca i32, align 4
  %3 = alloca i64, align 8
  %i = alloca i32, align 4
  %ii = alloca i32, align 4
  %nm1 = alloca i32, align 4
  %a = alloca i64, align 8
  %b = alloca i64, align 8
  %c = alloca i64, align 8
  %d = alloca i64, align 8
  %del = alloca i64, align 8
  %fact = alloca i64, align 8
  %h = alloca i64, align 8
  %psi = alloca i64, align 8
  %ans = alloca i64, align 8
  store i32 %n, i32* %2, align 4
  store i64 %x, i64* %3, align 8
  %4 = load i32* %2, align 4
  %5 = sub nsw i32 %4, 1
  store i32 %5, i32* %nm1, align 4
  %6 = load i64* %3, align 8
  %7 = icmp sgt i64 %6, 1
  br i1 %7, label %8, label %57

; <label>:8                                       ; preds = %0
  %9 = load i64* %3, align 8
  %10 = load i32* %2, align 4
  %11 = sext i32 %10 to i64
  %12 = add nsw i64 %9, %11
  store i64 %12, i64* %b, align 8
  store i64 2000000, i64* %c, align 8
  store i64 30000000, i64* %d, align 8
  %13 = load i64* %d, align 8
  store i64 %13, i64* %h, align 8
  store i32 1, i32* %i, align 4
  br label %14

; <label>:14                                      ; preds = %53, %8
  %15 = load i32* %i, align 4
  %16 = icmp sle i32 %15, 100
  br i1 %16, label %17, label %56

; <label>:17                                      ; preds = %14
  %18 = load i32* %i, align 4
  %19 = sub nsw i32 0, %18
  %20 = load i32* %nm1, align 4
  %21 = load i32* %i, align 4
  %22 = add nsw i32 %20, %21
  %23 = mul nsw i32 %19, %22
  %24 = sext i32 %23 to i64
  store i64 %24, i64* %a, align 8
  %25 = load i64* %b, align 8
  %26 = add nsw i64 %25, 2
  store i64 %26, i64* %b, align 8
  %27 = load i64* %a, align 8
  %28 = load i64* %d, align 8
  %29 = mul nsw i64 %27, %28
  %30 = load i64* %b, align 8
  %31 = add nsw i64 %29, %30
  %32 = mul nsw i64 10, %31
  store i64 %32, i64* %d, align 8
  %33 = load i64* %b, align 8
  %34 = load i64* %a, align 8
  %35 = load i64* %c, align 8
  %36 = sdiv i64 %34, %35
  %37 = add nsw i64 %33, %36
  store i64 %37, i64* %c, align 8
  %38 = load i64* %c, align 8
  %39 = load i64* %d, align 8
  %40 = mul nsw i64 %38, %39
  store i64 %40, i64* %del, align 8
  %41 = load i64* %del, align 8
  %42 = load i64* %h, align 8
  %43 = mul nsw i64 %42, %41
  store i64 %43, i64* %h, align 8
  %44 = load i64* %del, align 8
  %45 = icmp slt i64 %44, 10000
  br i1 %45, label %46, label %52

; <label>:46                                      ; preds = %17
  %47 = load i64* %h, align 8
  %48 = load i64* %3, align 8
  %49 = sub nsw i64 0, %48
  %50 = mul nsw i64 %47, %49
  store i64 %50, i64* %ans, align 8
  %51 = load i64* %ans, align 8
  store i64 %51, i64* %1
  br label %116

; <label>:52                                      ; preds = %17
  br label %53

; <label>:53                                      ; preds = %52
  %54 = load i32* %i, align 4
  %55 = add nsw i32 %54, 1
  store i32 %55, i32* %i, align 4
  br label %14

; <label>:56                                      ; preds = %14
  br label %114

; <label>:57                                      ; preds = %0
  %58 = load i32* %nm1, align 4
  %59 = icmp ne i32 %58, 0
  %60 = select i1 %59, i32 2, i32 1000
  %61 = sext i32 %60 to i64
  store i64 %61, i64* %ans, align 8
  store i64 1, i64* %fact, align 8
  store i32 1, i32* %i, align 4
  br label %62

; <label>:62                                      ; preds = %110, %57
  %63 = load i32* %i, align 4
  %64 = icmp sle i32 %63, 100
  br i1 %64, label %65, label %113

; <label>:65                                      ; preds = %62
  %66 = load i64* %3, align 8
  %67 = sub nsw i64 0, %66
  %68 = load i32* %i, align 4
  %69 = sext i32 %68 to i64
  %70 = sdiv i64 %67, %69
  %71 = load i64* %fact, align 8
  %72 = mul nsw i64 %71, %70
  store i64 %72, i64* %fact, align 8
  %73 = load i32* %i, align 4
  %74 = load i32* %nm1, align 4
  %75 = icmp ne i32 %73, %74
  br i1 %75, label %76, label %84

; <label>:76                                      ; preds = %65
  %77 = load i64* %fact, align 8
  %78 = sub nsw i64 0, %77
  %79 = load i32* %i, align 4
  %80 = load i32* %nm1, align 4
  %81 = sub nsw i32 %79, %80
  %82 = sext i32 %81 to i64
  %83 = sdiv i64 %78, %82
  store i64 %83, i64* %del, align 8
  br label %106

; <label>:84                                      ; preds = %65
  store i64 255, i64* %psi, align 8
  store i32 1, i32* %ii, align 4
  br label %85

; <label>:85                                      ; preds = %96, %84
  %86 = load i32* %ii, align 4
  %87 = load i32* %nm1, align 4
  %88 = icmp sle i32 %86, %87
  br i1 %88, label %89, label %99

; <label>:89                                      ; preds = %85
  %90 = load i32* %ii, align 4
  %91 = load i32* %nm1, align 4
  %92 = add nsw i32 %90, %91
  %93 = sext i32 %92 to i64
  %94 = load i64* %psi, align 8
  %95 = add nsw i64 %94, %93
  store i64 %95, i64* %psi, align 8
  br label %96

; <label>:96                                      ; preds = %89
  %97 = load i32* %ii, align 4
  %98 = add nsw i32 %97, 1
  store i32 %98, i32* %ii, align 4
  br label %85

; <label>:99                                      ; preds = %85
  %100 = load i64* %psi, align 8
  %101 = load i64* %fact, align 8
  %102 = load i64* %3, align 8
  %103 = call i64 @foo(i64 %102)
  %104 = mul nsw i64 %101, %103
  %105 = add nsw i64 %100, %104
  store i64 %105, i64* %del, align 8
  br label %106

; <label>:106                                     ; preds = %99, %76
  %107 = load i64* %del, align 8
  %108 = load i64* %ans, align 8
  %109 = add nsw i64 %108, %107
  store i64 %109, i64* %ans, align 8
  br label %110

; <label>:110                                     ; preds = %106
  %111 = load i32* %i, align 4
  %112 = add nsw i32 %111, 1
  store i32 %112, i32* %i, align 4
  br label %62

; <label>:113                                     ; preds = %62
  br label %114

; <label>:114                                     ; preds = %113, %56
  %115 = load i64* %ans, align 8
  store i64 %115, i64* %1
  br label %116

; <label>:116                                     ; preds = %114, %46
  %117 = load i64* %1
  ret i64 %117
}

; Function Attrs: nounwind uwtable
define i64 @foo(i64 %x) #0 {
  %1 = alloca i64, align 8
  store i64 %x, i64* %1, align 8
  %2 = load i64* %1, align 8
  %3 = load i64* %1, align 8
  %4 = mul nsw i64 %2, %3
  %5 = load i64* %1, align 8
  %6 = mul nsw i64 8, %5
  %7 = add nsw i64 %4, %6
  %8 = load i64* %1, align 8
  %9 = sub nsw i64 4, %8
  %10 = shl i64 %7, %9
  ret i64 %10
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
