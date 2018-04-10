; ModuleID = 'prime.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define zeroext i8 @divides(i32 %n, i32 %m) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 %n, i32* %1, align 4
  store i32 %m, i32* %2, align 4
  %3 = load i32* %2, align 4
  %4 = load i32* %1, align 4
  %5 = urem i32 %3, %4
  %6 = icmp eq i32 %5, 0
  %7 = zext i1 %6 to i32
  %8 = trunc i32 %7 to i8
  ret i8 %8
}

; Function Attrs: nounwind uwtable
define zeroext i8 @even(i32 %n) #0 {
  %1 = alloca i32, align 4
  store i32 %n, i32* %1, align 4
  %2 = load i32* %1, align 4
  %3 = call zeroext i8 @divides(i32 2, i32 %2)
  ret i8 %3
}

; Function Attrs: nounwind uwtable
define zeroext i8 @prime(i32 %n) #0 {
  %1 = alloca i8, align 1
  %2 = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 %n, i32* %2, align 4
  %3 = load i32* %2, align 4
  %4 = call zeroext i8 @even(i32 %3)
  %5 = icmp ne i8 %4, 0
  br i1 %5, label %6, label %11

; <label>:6                                       ; preds = %0
  %7 = load i32* %2, align 4
  %8 = icmp eq i32 %7, 2
  %9 = zext i1 %8 to i32
  %10 = trunc i32 %9 to i8
  store i8 %10, i8* %1
  br label %33

; <label>:11                                      ; preds = %0
  store i32 3, i32* %i, align 4
  br label %12

; <label>:12                                      ; preds = %25, %11
  %13 = load i32* %i, align 4
  %14 = load i32* %i, align 4
  %15 = mul i32 %13, %14
  %16 = load i32* %2, align 4
  %17 = icmp ule i32 %15, %16
  br i1 %17, label %18, label %28

; <label>:18                                      ; preds = %12
  %19 = load i32* %i, align 4
  %20 = load i32* %2, align 4
  %21 = call zeroext i8 @divides(i32 %19, i32 %20)
  %22 = icmp ne i8 %21, 0
  br i1 %22, label %23, label %24

; <label>:23                                      ; preds = %18
  store i8 0, i8* %1
  br label %33

; <label>:24                                      ; preds = %18
  br label %25

; <label>:25                                      ; preds = %24
  %26 = load i32* %i, align 4
  %27 = add i32 %26, 2
  store i32 %27, i32* %i, align 4
  br label %12

; <label>:28                                      ; preds = %12
  %29 = load i32* %2, align 4
  %30 = icmp ugt i32 %29, 1
  %31 = zext i1 %30 to i32
  %32 = trunc i32 %31 to i8
  store i8 %32, i8* %1
  br label %33

; <label>:33                                      ; preds = %28, %23, %6
  %34 = load i8* %1
  ret i8 %34
}

; Function Attrs: nounwind uwtable
define void @swap(i32* %a, i32* %b) #0 {
  %1 = alloca i32*, align 8
  %2 = alloca i32*, align 8
  %tmp = alloca i32, align 4
  store i32* %a, i32** %1, align 8
  store i32* %b, i32** %2, align 8
  %3 = load i32** %1, align 8
  %4 = load i32* %3, align 4
  store i32 %4, i32* %tmp, align 4
  %5 = load i32** %2, align 8
  %6 = load i32* %5, align 4
  %7 = load i32** %1, align 8
  store i32 %6, i32* %7, align 4
  %8 = load i32* %tmp, align 4
  %9 = load i32** %2, align 8
  store i32 %8, i32* %9, align 4
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %x = alloca i32, align 4
  %y = alloca i32, align 4
  store i32 0, i32* %1
  store i32 21649, i32* %x, align 4
  store i32 513239, i32* %y, align 4
  call void @swap(i32* %x, i32* %y)
  %2 = load i32* %x, align 4
  %3 = call zeroext i8 @prime(i32 %2)
  %4 = zext i8 %3 to i32
  %5 = icmp ne i32 %4, 0
  br i1 %5, label %6, label %11

; <label>:6                                       ; preds = %0
  %7 = load i32* %y, align 4
  %8 = call zeroext i8 @prime(i32 %7)
  %9 = zext i8 %8 to i32
  %10 = icmp ne i32 %9, 0
  br label %11

; <label>:11                                      ; preds = %6, %0
  %12 = phi i1 [ false, %0 ], [ %10, %6 ]
  %13 = xor i1 %12, true
  %14 = zext i1 %13 to i32
  ret i32 %14
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
