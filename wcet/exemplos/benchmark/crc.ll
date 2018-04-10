; ModuleID = 'crc.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@lin = global [256 x i8] c"asdffeagewaHAFEFaeDsFEawFdsFaefaeerdjgp\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00", align 16
@icrc.icrctb = internal global [256 x i16] zeroinitializer, align 16
@icrc.init = internal global i16 0, align 2
@icrc.rchr = internal global [256 x i8] zeroinitializer, align 16
@icrc.it = internal global [16 x i8] c"\00\08\04\0C\02\0A\06\0E\01\09\05\0D\03\0B\07\0F", align 16

; Function Attrs: nounwind uwtable
define zeroext i16 @icrc1(i16 zeroext %crc, i8 zeroext %onech) #0 {
  %1 = alloca i16, align 2
  %2 = alloca i8, align 1
  %i = alloca i32, align 4
  %ans = alloca i16, align 2
  store i16 %crc, i16* %1, align 2
  store i8 %onech, i8* %2, align 1
  %3 = load i16* %1, align 2
  %4 = zext i16 %3 to i32
  %5 = load i8* %2, align 1
  %6 = zext i8 %5 to i32
  %7 = shl i32 %6, 8
  %8 = xor i32 %4, %7
  %9 = trunc i32 %8 to i16
  store i16 %9, i16* %ans, align 2
  store i32 0, i32* %i, align 4
  br label %10

; <label>:10                                      ; preds = %32, %0
  %11 = load i32* %i, align 4
  %12 = icmp slt i32 %11, 8
  br i1 %12, label %13, label %35

; <label>:13                                      ; preds = %10
  %14 = load i16* %ans, align 2
  %15 = zext i16 %14 to i32
  %16 = and i32 %15, 32768
  %17 = icmp ne i32 %16, 0
  br i1 %17, label %18, label %26

; <label>:18                                      ; preds = %13
  %19 = load i16* %ans, align 2
  %20 = zext i16 %19 to i32
  %21 = shl i32 %20, 1
  %22 = trunc i32 %21 to i16
  store i16 %22, i16* %ans, align 2
  %23 = zext i16 %22 to i32
  %24 = xor i32 %23, 4129
  %25 = trunc i32 %24 to i16
  store i16 %25, i16* %ans, align 2
  br label %31

; <label>:26                                      ; preds = %13
  %27 = load i16* %ans, align 2
  %28 = zext i16 %27 to i32
  %29 = shl i32 %28, 1
  %30 = trunc i32 %29 to i16
  store i16 %30, i16* %ans, align 2
  br label %31

; <label>:31                                      ; preds = %26, %18
  br label %32

; <label>:32                                      ; preds = %31
  %33 = load i32* %i, align 4
  %34 = add nsw i32 %33, 1
  store i32 %34, i32* %i, align 4
  br label %10

; <label>:35                                      ; preds = %10
  %36 = load i16* %ans, align 2
  ret i16 %36
}

; Function Attrs: nounwind uwtable
define zeroext i16 @icrc(i16 zeroext %crc, i64 %len, i16 signext %jinit, i32 %jrev) #0 {
  %1 = alloca i16, align 2
  %2 = alloca i64, align 8
  %3 = alloca i16, align 2
  %4 = alloca i32, align 4
  %tmp1 = alloca i16, align 2
  %tmp2 = alloca i16, align 2
  %j = alloca i16, align 2
  %cword = alloca i16, align 2
  store i16 %crc, i16* %1, align 2
  store i64 %len, i64* %2, align 8
  store i16 %jinit, i16* %3, align 2
  store i32 %jrev, i32* %4, align 4
  %5 = load i16* %1, align 2
  store i16 %5, i16* %cword, align 2
  %6 = load i16* @icrc.init, align 2
  %7 = icmp ne i16 %6, 0
  br i1 %7, label %46, label %8

; <label>:8                                       ; preds = %0
  store i16 1, i16* @icrc.init, align 2
  store i16 0, i16* %j, align 2
  br label %9

; <label>:9                                       ; preds = %42, %8
  %10 = load i16* %j, align 2
  %11 = zext i16 %10 to i32
  %12 = icmp sle i32 %11, 255
  br i1 %12, label %13, label %45

; <label>:13                                      ; preds = %9
  %14 = load i16* %j, align 2
  %15 = zext i16 %14 to i32
  %16 = shl i32 %15, 8
  %17 = trunc i32 %16 to i16
  %18 = call zeroext i16 @icrc1(i16 zeroext %17, i8 zeroext 0)
  %19 = load i16* %j, align 2
  %20 = zext i16 %19 to i64
  %21 = getelementptr inbounds [256 x i16]* @icrc.icrctb, i32 0, i64 %20
  store i16 %18, i16* %21, align 2
  %22 = load i16* %j, align 2
  %23 = zext i16 %22 to i32
  %24 = and i32 %23, 15
  %25 = sext i32 %24 to i64
  %26 = getelementptr inbounds [16 x i8]* @icrc.it, i32 0, i64 %25
  %27 = load i8* %26, align 1
  %28 = zext i8 %27 to i32
  %29 = shl i32 %28, 4
  %30 = load i16* %j, align 2
  %31 = zext i16 %30 to i32
  %32 = ashr i32 %31, 4
  %33 = sext i32 %32 to i64
  %34 = getelementptr inbounds [16 x i8]* @icrc.it, i32 0, i64 %33
  %35 = load i8* %34, align 1
  %36 = zext i8 %35 to i32
  %37 = or i32 %29, %36
  %38 = trunc i32 %37 to i8
  %39 = load i16* %j, align 2
  %40 = zext i16 %39 to i64
  %41 = getelementptr inbounds [256 x i8]* @icrc.rchr, i32 0, i64 %40
  store i8 %38, i8* %41, align 1
  br label %42

; <label>:42                                      ; preds = %13
  %43 = load i16* %j, align 2
  %44 = add i16 %43, 1
  store i16 %44, i16* %j, align 2
  br label %9

; <label>:45                                      ; preds = %9
  br label %46

; <label>:46                                      ; preds = %45, %0
  %47 = load i16* %3, align 2
  %48 = sext i16 %47 to i32
  %49 = icmp sge i32 %48, 0
  br i1 %49, label %50, label %60

; <label>:50                                      ; preds = %46
  %51 = load i16* %3, align 2
  %52 = trunc i16 %51 to i8
  %53 = zext i8 %52 to i32
  %54 = load i16* %3, align 2
  %55 = trunc i16 %54 to i8
  %56 = zext i8 %55 to i32
  %57 = shl i32 %56, 8
  %58 = or i32 %53, %57
  %59 = trunc i32 %58 to i16
  store i16 %59, i16* %cword, align 2
  br label %84

; <label>:60                                      ; preds = %46
  %61 = load i32* %4, align 4
  %62 = icmp slt i32 %61, 0
  br i1 %62, label %63, label %83

; <label>:63                                      ; preds = %60
  %64 = load i16* %cword, align 2
  %65 = zext i16 %64 to i32
  %66 = ashr i32 %65, 8
  %67 = trunc i32 %66 to i8
  %68 = zext i8 %67 to i64
  %69 = getelementptr inbounds [256 x i8]* @icrc.rchr, i32 0, i64 %68
  %70 = load i8* %69, align 1
  %71 = zext i8 %70 to i32
  %72 = load i16* %cword, align 2
  %73 = zext i16 %72 to i32
  %74 = and i32 %73, 255
  %75 = trunc i32 %74 to i8
  %76 = zext i8 %75 to i64
  %77 = getelementptr inbounds [256 x i8]* @icrc.rchr, i32 0, i64 %76
  %78 = load i8* %77, align 1
  %79 = zext i8 %78 to i32
  %80 = shl i32 %79, 8
  %81 = or i32 %71, %80
  %82 = trunc i32 %81 to i16
  store i16 %82, i16* %cword, align 2
  br label %83

; <label>:83                                      ; preds = %63, %60
  br label %84

; <label>:84                                      ; preds = %83, %50
  store i16 1, i16* %j, align 2
  br label %85

; <label>:85                                      ; preds = %136, %84
  %86 = load i16* %j, align 2
  %87 = zext i16 %86 to i64
  %88 = load i64* %2, align 8
  %89 = icmp ule i64 %87, %88
  br i1 %89, label %90, label %139

; <label>:90                                      ; preds = %85
  %91 = load i32* %4, align 4
  %92 = icmp slt i32 %91, 0
  br i1 %92, label %93, label %109

; <label>:93                                      ; preds = %90
  %94 = load i16* %j, align 2
  %95 = zext i16 %94 to i64
  %96 = getelementptr inbounds [256 x i8]* @lin, i32 0, i64 %95
  %97 = load i8* %96, align 1
  %98 = zext i8 %97 to i64
  %99 = getelementptr inbounds [256 x i8]* @icrc.rchr, i32 0, i64 %98
  %100 = load i8* %99, align 1
  %101 = zext i8 %100 to i32
  %102 = load i16* %cword, align 2
  %103 = zext i16 %102 to i32
  %104 = ashr i32 %103, 8
  %105 = trunc i32 %104 to i8
  %106 = zext i8 %105 to i32
  %107 = xor i32 %101, %106
  %108 = trunc i32 %107 to i16
  store i16 %108, i16* %tmp1, align 2
  br label %122

; <label>:109                                     ; preds = %90
  %110 = load i16* %j, align 2
  %111 = zext i16 %110 to i64
  %112 = getelementptr inbounds [256 x i8]* @lin, i32 0, i64 %111
  %113 = load i8* %112, align 1
  %114 = zext i8 %113 to i32
  %115 = load i16* %cword, align 2
  %116 = zext i16 %115 to i32
  %117 = ashr i32 %116, 8
  %118 = trunc i32 %117 to i8
  %119 = zext i8 %118 to i32
  %120 = xor i32 %114, %119
  %121 = trunc i32 %120 to i16
  store i16 %121, i16* %tmp1, align 2
  br label %122

; <label>:122                                     ; preds = %109, %93
  %123 = load i16* %tmp1, align 2
  %124 = zext i16 %123 to i64
  %125 = getelementptr inbounds [256 x i16]* @icrc.icrctb, i32 0, i64 %124
  %126 = load i16* %125, align 2
  %127 = zext i16 %126 to i32
  %128 = load i16* %cword, align 2
  %129 = zext i16 %128 to i32
  %130 = and i32 %129, 255
  %131 = trunc i32 %130 to i8
  %132 = zext i8 %131 to i32
  %133 = shl i32 %132, 8
  %134 = xor i32 %127, %133
  %135 = trunc i32 %134 to i16
  store i16 %135, i16* %cword, align 2
  br label %136

; <label>:136                                     ; preds = %122
  %137 = load i16* %j, align 2
  %138 = add i16 %137, 1
  store i16 %138, i16* %j, align 2
  br label %85

; <label>:139                                     ; preds = %85
  %140 = load i32* %4, align 4
  %141 = icmp sge i32 %140, 0
  br i1 %141, label %142, label %144

; <label>:142                                     ; preds = %139
  %143 = load i16* %cword, align 2
  store i16 %143, i16* %tmp2, align 2
  br label %164

; <label>:144                                     ; preds = %139
  %145 = load i16* %cword, align 2
  %146 = zext i16 %145 to i32
  %147 = ashr i32 %146, 8
  %148 = trunc i32 %147 to i8
  %149 = zext i8 %148 to i64
  %150 = getelementptr inbounds [256 x i8]* @icrc.rchr, i32 0, i64 %149
  %151 = load i8* %150, align 1
  %152 = zext i8 %151 to i32
  %153 = load i16* %cword, align 2
  %154 = zext i16 %153 to i32
  %155 = and i32 %154, 255
  %156 = trunc i32 %155 to i8
  %157 = zext i8 %156 to i64
  %158 = getelementptr inbounds [256 x i8]* @icrc.rchr, i32 0, i64 %157
  %159 = load i8* %158, align 1
  %160 = zext i8 %159 to i32
  %161 = shl i32 %160, 8
  %162 = or i32 %152, %161
  %163 = trunc i32 %162 to i16
  store i16 %163, i16* %tmp2, align 2
  br label %164

; <label>:164                                     ; preds = %144, %142
  %165 = load i16* %tmp2, align 2
  ret i16 %165
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %i1 = alloca i16, align 2
  %i2 = alloca i16, align 2
  %n = alloca i64, align 8
  store i32 0, i32* %1
  store i64 40, i64* %n, align 8
  %2 = load i64* %n, align 8
  %3 = add i64 %2, 1
  %4 = getelementptr inbounds [256 x i8]* @lin, i32 0, i64 %3
  store i8 0, i8* %4, align 1
  %5 = load i64* %n, align 8
  %6 = call zeroext i16 @icrc(i16 zeroext 0, i64 %5, i16 signext 0, i32 1)
  store i16 %6, i16* %i1, align 2
  %7 = load i16* %i1, align 2
  %8 = zext i16 %7 to i32
  %9 = ashr i32 %8, 8
  %10 = trunc i32 %9 to i8
  %11 = load i64* %n, align 8
  %12 = add i64 %11, 1
  %13 = getelementptr inbounds [256 x i8]* @lin, i32 0, i64 %12
  store i8 %10, i8* %13, align 1
  %14 = load i16* %i1, align 2
  %15 = zext i16 %14 to i32
  %16 = and i32 %15, 255
  %17 = trunc i32 %16 to i8
  %18 = load i64* %n, align 8
  %19 = add i64 %18, 2
  %20 = getelementptr inbounds [256 x i8]* @lin, i32 0, i64 %19
  store i8 %17, i8* %20, align 1
  %21 = load i16* %i1, align 2
  %22 = load i64* %n, align 8
  %23 = add i64 %22, 2
  %24 = call zeroext i16 @icrc(i16 zeroext %21, i64 %23, i16 signext 0, i32 1)
  store i16 %24, i16* %i2, align 2
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
