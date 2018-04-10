; ModuleID = 'lcdnum.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@IN = common global i8 0, align 1
@OUT = common global i8 0, align 1

; Function Attrs: nounwind uwtable
define zeroext i8 @num_to_lcd(i8 zeroext %a) #0 {
  %1 = alloca i8, align 1
  %2 = alloca i8, align 1
  store i8 %a, i8* %2, align 1
  %3 = load i8* %2, align 1
  %4 = zext i8 %3 to i32
  switch i32 %4, label %21 [
    i32 0, label %5
    i32 1, label %6
    i32 2, label %7
    i32 3, label %8
    i32 4, label %9
    i32 5, label %10
    i32 6, label %11
    i32 7, label %12
    i32 8, label %13
    i32 9, label %14
    i32 10, label %15
    i32 11, label %16
    i32 12, label %17
    i32 13, label %18
    i32 14, label %19
    i32 15, label %20
  ]

; <label>:5                                       ; preds = %0
  store i8 0, i8* %1
  br label %22

; <label>:6                                       ; preds = %0
  store i8 36, i8* %1
  br label %22

; <label>:7                                       ; preds = %0
  store i8 93, i8* %1
  br label %22

; <label>:8                                       ; preds = %0
  store i8 109, i8* %1
  br label %22

; <label>:9                                       ; preds = %0
  store i8 46, i8* %1
  br label %22

; <label>:10                                      ; preds = %0
  store i8 93, i8* %1
  br label %22

; <label>:11                                      ; preds = %0
  store i8 123, i8* %1
  br label %22

; <label>:12                                      ; preds = %0
  store i8 37, i8* %1
  br label %22

; <label>:13                                      ; preds = %0
  store i8 127, i8* %1
  br label %22

; <label>:14                                      ; preds = %0
  store i8 111, i8* %1
  br label %22

; <label>:15                                      ; preds = %0
  store i8 63, i8* %1
  br label %22

; <label>:16                                      ; preds = %0
  store i8 122, i8* %1
  br label %22

; <label>:17                                      ; preds = %0
  store i8 83, i8* %1
  br label %22

; <label>:18                                      ; preds = %0
  store i8 124, i8* %1
  br label %22

; <label>:19                                      ; preds = %0
  store i8 91, i8* %1
  br label %22

; <label>:20                                      ; preds = %0
  store i8 27, i8* %1
  br label %22

; <label>:21                                      ; preds = %0
  store i8 0, i8* %1
  br label %22

; <label>:22                                      ; preds = %21, %20, %19, %18, %17, %16, %15, %14, %13, %12, %11, %10, %9, %8, %7, %6, %5
  %23 = load i8* %1
  ret i8 %23
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  %a = alloca i8, align 1
  %n = alloca i32, align 4
  store i32 0, i32* %1
  store i32 10, i32* %n, align 4
  store i32 0, i32* %i, align 4
  br label %2

; <label>:2                                       ; preds = %18, %0
  %3 = load i32* %i, align 4
  %4 = load i32* %n, align 4
  %5 = icmp slt i32 %3, %4
  br i1 %5, label %6, label %21

; <label>:6                                       ; preds = %2
  %7 = load volatile i8* @IN, align 1
  store i8 %7, i8* %a, align 1
  %8 = load i32* %i, align 4
  %9 = icmp slt i32 %8, 5
  br i1 %9, label %10, label %17

; <label>:10                                      ; preds = %6
  %11 = load i8* %a, align 1
  %12 = zext i8 %11 to i32
  %13 = and i32 %12, 15
  %14 = trunc i32 %13 to i8
  store i8 %14, i8* %a, align 1
  %15 = load i8* %a, align 1
  %16 = call zeroext i8 @num_to_lcd(i8 zeroext %15)
  store volatile i8 %16, i8* @OUT, align 1
  br label %17

; <label>:17                                      ; preds = %10, %6
  br label %18

; <label>:18                                      ; preds = %17
  %19 = load i32* %i, align 4
  %20 = add nsw i32 %19, 1
  store i32 %20, i32* %i, align 4
  br label %2

; <label>:21                                      ; preds = %2
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
