; ModuleID = 'compress.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@maxbits = global i32 16, align 4
@maxmaxcode = global i64 65536, align 8
@hsize = global i64 257, align 8
@free_ent = global i64 0, align 8
@exit_stat = global i32 0, align 4
@nomagic = global i32 1, align 4
@zcat_flg = global i32 0, align 4
@quiet = global i32 1, align 4
@block_compress = global i32 128, align 4
@clear_flg = global i32 0, align 4
@ratio = global i64 0, align 8
@checkpoint = global i64 10000, align 8
@force = global i32 0, align 4
@InCnt = common global i32 0, align 4
@apsim_InCnt = common global i32 0, align 4
@orig_text_buffer = common global [50 x i8] zeroinitializer, align 16
@InBuff = common global i8* null, align 8
@comp_text_buffer = common global [55 x i8] zeroinitializer, align 16
@OutBuff = common global i8* null, align 8
@in_count = global i64 1, align 8
@out_count = global i64 0, align 8
@offset = internal global i32 0, align 4
@bytes_out = common global i64 0, align 8
@n_bits = common global i32 0, align 4
@maxcode = common global i64 0, align 8
@htab = common global [257 x i64] zeroinitializer, align 16
@codetab = common global [257 x i16] zeroinitializer, align 16
@lmask = global [9 x i8] c"\FF\FE\FC\F8\F0\E0\C0\80\00", align 1
@rmask = global [9 x i8] c"\00\01\03\07\0F\1F?\7F\FF", align 1
@buf = common global [16 x i8] zeroinitializer, align 16
@fsize = common global i64 0, align 8
@ofname = common global [100 x i8] zeroinitializer, align 16

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %count = alloca i32, align 4
  store i32 0, i32* %1
  store i32 50, i32* %count, align 4
  call void @initbuffer()
  store i32 16, i32* @maxbits, align 4
  %2 = load i32* @maxbits, align 4
  %3 = shl i32 1, %2
  %4 = sext i32 %3 to i64
  store i64 %4, i64* @maxmaxcode, align 8
  %5 = load i32* %count, align 4
  store i32 %5, i32* @InCnt, align 4
  store i32 53, i32* @apsim_InCnt, align 4
  store i8* getelementptr inbounds ([50 x i8]* @orig_text_buffer, i32 0, i32 0), i8** @InBuff, align 8
  store i8* getelementptr inbounds ([55 x i8]* @comp_text_buffer, i32 0, i32 0), i8** @OutBuff, align 8
  call void @compress()
  ret i32 0
}

; Function Attrs: nounwind uwtable
define void @initbuffer() #0 {
  %seed = alloca i32, align 4
  %i = alloca i32, align 4
  %tabort = alloca i32, align 4
  store i32 1, i32* %seed, align 4
  store i32 0, i32* %i, align 4
  br label %1

; <label>:1                                       ; preds = %16, %0
  %2 = load i32* %i, align 4
  %3 = icmp slt i32 %2, 50
  br i1 %3, label %4, label %19

; <label>:4                                       ; preds = %1
  %5 = load i32* %i, align 4
  store i32 %5, i32* %tabort, align 4
  %6 = load i32* %seed, align 4
  %7 = mul nsw i32 %6, 133
  %8 = add nsw i32 %7, 81
  %9 = srem i32 %8, 8095
  store i32 %9, i32* %seed, align 4
  %10 = load i32* %seed, align 4
  %11 = srem i32 %10, 256
  %12 = trunc i32 %11 to i8
  %13 = load i32* %i, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds [50 x i8]* @orig_text_buffer, i32 0, i64 %14
  store i8 %12, i8* %15, align 1
  br label %16

; <label>:16                                      ; preds = %4
  %17 = load i32* %i, align 4
  %18 = add nsw i32 %17, 1
  store i32 %18, i32* %i, align 4
  br label %1

; <label>:19                                      ; preds = %1
  ret void
}

; Function Attrs: nounwind uwtable
define void @compress() #0 {
  %fcode = alloca i64, align 8
  %i = alloca i64, align 8
  %c = alloca i32, align 4
  %ent = alloca i64, align 8
  %disp = alloca i32, align 4
  %hsize_reg = alloca i64, align 8
  %hshift = alloca i32, align 4
  %apsim_bound111 = alloca i32, align 4
  store i64 0, i64* %i, align 8
  store i32 0, i32* @offset, align 4
  store i64 3, i64* @bytes_out, align 8
  store i64 0, i64* @out_count, align 8
  store i32 0, i32* @clear_flg, align 4
  store i64 0, i64* @ratio, align 8
  store i64 1, i64* @in_count, align 8
  store i64 10000, i64* @checkpoint, align 8
  store i32 9, i32* @n_bits, align 4
  store i64 511, i64* @maxcode, align 8
  %1 = load i32* @block_compress, align 4
  %2 = icmp ne i32 %1, 0
  %3 = select i1 %2, i32 257, i32 256
  %4 = sext i32 %3 to i64
  store i64 %4, i64* @free_ent, align 8
  %5 = call i32 @getbyte()
  %6 = zext i32 %5 to i64
  store i64 %6, i64* %ent, align 8
  store i32 0, i32* %hshift, align 4
  %7 = load i64* @hsize, align 8
  store i64 %7, i64* %fcode, align 8
  br label %8

; <label>:8                                       ; preds = %14, %0
  %9 = load i64* %fcode, align 8
  %10 = icmp slt i64 %9, 65536
  br i1 %10, label %11, label %17

; <label>:11                                      ; preds = %8
  %12 = load i32* %hshift, align 4
  %13 = add nsw i32 %12, 1
  store i32 %13, i32* %hshift, align 4
  br label %14

; <label>:14                                      ; preds = %11
  %15 = load i64* %fcode, align 8
  %16 = mul nsw i64 %15, 2
  store i64 %16, i64* %fcode, align 8
  br label %8

; <label>:17                                      ; preds = %8
  %18 = load i32* %hshift, align 4
  %19 = sub nsw i32 8, %18
  store i32 %19, i32* %hshift, align 4
  %20 = load i64* @hsize, align 8
  store i64 %20, i64* %hsize_reg, align 8
  %21 = load i64* %hsize_reg, align 8
  call void @cl_hash(i64 %21)
  br label %22

; <label>:22                                      ; preds = %128, %84, %47, %17
  %23 = load i32* @InCnt, align 4
  %24 = icmp sgt i32 %23, 0
  br i1 %24, label %25, label %129

; <label>:25                                      ; preds = %22
  store i32 0, i32* %apsim_bound111, align 4
  %26 = call i32 @getbyte()
  store i32 %26, i32* %c, align 4
  %27 = load i64* @in_count, align 8
  %28 = add nsw i64 %27, 1
  store i64 %28, i64* @in_count, align 8
  %29 = load i32* %c, align 4
  %30 = sext i32 %29 to i64
  %31 = load i32* @maxbits, align 4
  %32 = zext i32 %31 to i64
  %33 = shl i64 %30, %32
  %34 = load i64* %ent, align 8
  %35 = add nsw i64 %33, %34
  store i64 %35, i64* %fcode, align 8
  %36 = load i32* %c, align 4
  %37 = load i32* %hshift, align 4
  %38 = shl i32 %36, %37
  %39 = sext i32 %38 to i64
  %40 = load i64* %ent, align 8
  %41 = xor i64 %39, %40
  store i64 %41, i64* %i, align 8
  %42 = load i64* %i, align 8
  %43 = getelementptr inbounds [257 x i64]* @htab, i32 0, i64 %42
  %44 = load i64* %43, align 8
  %45 = load i64* %fcode, align 8
  %46 = icmp eq i64 %44, %45
  br i1 %46, label %47, label %52

; <label>:47                                      ; preds = %25
  %48 = load i64* %i, align 8
  %49 = getelementptr inbounds [257 x i16]* @codetab, i32 0, i64 %48
  %50 = load i16* %49, align 2
  %51 = zext i16 %50 to i64
  store i64 %51, i64* %ent, align 8
  br label %22

; <label>:52                                      ; preds = %25
  %53 = load i64* %i, align 8
  %54 = getelementptr inbounds [257 x i64]* @htab, i32 0, i64 %53
  %55 = load i64* %54, align 8
  %56 = icmp slt i64 %55, 0
  br i1 %56, label %57, label %58

; <label>:57                                      ; preds = %52
  br label %102

; <label>:58                                      ; preds = %52
  br label %59

; <label>:59                                      ; preds = %58
  %60 = load i64* %hsize_reg, align 8
  %61 = load i64* %i, align 8
  %62 = sub nsw i64 %60, %61
  %63 = trunc i64 %62 to i32
  store i32 %63, i32* %disp, align 4
  %64 = load i64* %i, align 8
  %65 = icmp eq i64 %64, 0
  br i1 %65, label %66, label %67

; <label>:66                                      ; preds = %59
  store i32 1, i32* %disp, align 4
  br label %67

; <label>:67                                      ; preds = %66, %59
  br label %68

; <label>:68                                      ; preds = %100, %67
  %69 = load i32* %disp, align 4
  %70 = sext i32 %69 to i64
  %71 = load i64* %i, align 8
  %72 = sub nsw i64 %71, %70
  store i64 %72, i64* %i, align 8
  %73 = icmp slt i64 %72, 0
  br i1 %73, label %74, label %78

; <label>:74                                      ; preds = %68
  %75 = load i64* %hsize_reg, align 8
  %76 = load i64* %i, align 8
  %77 = add nsw i64 %76, %75
  store i64 %77, i64* %i, align 8
  br label %78

; <label>:78                                      ; preds = %74, %68
  %79 = load i64* %i, align 8
  %80 = getelementptr inbounds [257 x i64]* @htab, i32 0, i64 %79
  %81 = load i64* %80, align 8
  %82 = load i64* %fcode, align 8
  %83 = icmp eq i64 %81, %82
  br i1 %83, label %84, label %89

; <label>:84                                      ; preds = %78
  %85 = load i64* %i, align 8
  %86 = getelementptr inbounds [257 x i16]* @codetab, i32 0, i64 %85
  %87 = load i16* %86, align 2
  %88 = zext i16 %87 to i64
  store i64 %88, i64* %ent, align 8
  br label %22

; <label>:89                                      ; preds = %78
  %90 = load i64* %i, align 8
  %91 = getelementptr inbounds [257 x i64]* @htab, i32 0, i64 %90
  %92 = load i64* %91, align 8
  %93 = icmp sgt i64 %92, 0
  br i1 %93, label %94, label %101

; <label>:94                                      ; preds = %89
  %95 = load i32* %apsim_bound111, align 4
  %96 = add nsw i32 %95, 1
  store i32 %96, i32* %apsim_bound111, align 4
  %97 = sext i32 %96 to i64
  %98 = load i64* @in_count, align 8
  %99 = icmp slt i64 %97, %98
  br i1 %99, label %100, label %101

; <label>:100                                     ; preds = %94
  br label %68

; <label>:101                                     ; preds = %94, %89
  br label %102

; <label>:102                                     ; preds = %101, %57
  %103 = load i64* @out_count, align 8
  %104 = add nsw i64 %103, 1
  store i64 %104, i64* @out_count, align 8
  %105 = load i32* %c, align 4
  %106 = sext i32 %105 to i64
  store i64 %106, i64* %ent, align 8
  %107 = load i64* @free_ent, align 8
  %108 = load i64* @maxmaxcode, align 8
  %109 = icmp slt i64 %107, %108
  br i1 %109, label %110, label %119

; <label>:110                                     ; preds = %102
  %111 = load i64* @free_ent, align 8
  %112 = add nsw i64 %111, 1
  store i64 %112, i64* @free_ent, align 8
  %113 = trunc i64 %111 to i16
  %114 = load i64* %i, align 8
  %115 = getelementptr inbounds [257 x i16]* @codetab, i32 0, i64 %114
  store i16 %113, i16* %115, align 2
  %116 = load i64* %fcode, align 8
  %117 = load i64* %i, align 8
  %118 = getelementptr inbounds [257 x i64]* @htab, i32 0, i64 %117
  store i64 %116, i64* %118, align 8
  br label %128

; <label>:119                                     ; preds = %102
  %120 = load i64* @in_count, align 8
  %121 = load i64* @checkpoint, align 8
  %122 = icmp sge i64 %120, %121
  br i1 %122, label %123, label %127

; <label>:123                                     ; preds = %119
  %124 = load i32* @block_compress, align 4
  %125 = icmp ne i32 %124, 0
  br i1 %125, label %126, label %127

; <label>:126                                     ; preds = %123
  call void @cl_block()
  br label %127

; <label>:127                                     ; preds = %126, %123, %119
  br label %128

; <label>:128                                     ; preds = %127, %110
  br label %22

; <label>:129                                     ; preds = %22
  %130 = load i64* @bytes_out, align 8
  %131 = load i64* @in_count, align 8
  %132 = icmp sgt i64 %130, %131
  br i1 %132, label %133, label %134

; <label>:133                                     ; preds = %129
  store i32 2, i32* @exit_stat, align 4
  br label %134

; <label>:134                                     ; preds = %133, %129
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @getbyte() #0 {
  %1 = alloca i32, align 4
  %2 = load i32* @InCnt, align 4
  %3 = icmp sgt i32 %2, 0
  br i1 %3, label %4, label %15

; <label>:4                                       ; preds = %0
  %5 = load i32* @apsim_InCnt, align 4
  %6 = add nsw i32 %5, -1
  store i32 %6, i32* @apsim_InCnt, align 4
  %7 = icmp sgt i32 %5, 0
  br i1 %7, label %8, label %15

; <label>:8                                       ; preds = %4
  %9 = load i32* @InCnt, align 4
  %10 = add nsw i32 %9, -1
  store i32 %10, i32* @InCnt, align 4
  %11 = load i8** @InBuff, align 8
  %12 = getelementptr inbounds i8* %11, i32 1
  store i8* %12, i8** @InBuff, align 8
  %13 = load i8* %11, align 1
  %14 = zext i8 %13 to i32
  store i32 %14, i32* %1
  br label %16

; <label>:15                                      ; preds = %4, %0
  store i32 -1, i32* %1
  br label %16

; <label>:16                                      ; preds = %15, %8
  %17 = load i32* %1
  ret i32 %17
}

; Function Attrs: nounwind uwtable
define void @cl_hash(i64 %hsize) #0 {
  %1 = alloca i64, align 8
  %htab_p = alloca i64*, align 8
  %i = alloca i64, align 8
  %m1 = alloca i64, align 8
  store i64 %hsize, i64* %1, align 8
  %2 = load i64* %1, align 8
  %3 = getelementptr inbounds i64* getelementptr inbounds ([257 x i64]* @htab, i32 0, i32 0), i64 %2
  store i64* %3, i64** %htab_p, align 8
  store i64 -1, i64* %m1, align 8
  %4 = load i64* %1, align 8
  %5 = sub nsw i64 %4, 16
  store i64 %5, i64* %i, align 8
  br label %6

; <label>:6                                       ; preds = %57, %0
  %7 = load i64* %m1, align 8
  %8 = load i64** %htab_p, align 8
  %9 = getelementptr inbounds i64* %8, i64 -16
  store i64 %7, i64* %9, align 8
  %10 = load i64* %m1, align 8
  %11 = load i64** %htab_p, align 8
  %12 = getelementptr inbounds i64* %11, i64 -15
  store i64 %10, i64* %12, align 8
  %13 = load i64* %m1, align 8
  %14 = load i64** %htab_p, align 8
  %15 = getelementptr inbounds i64* %14, i64 -14
  store i64 %13, i64* %15, align 8
  %16 = load i64* %m1, align 8
  %17 = load i64** %htab_p, align 8
  %18 = getelementptr inbounds i64* %17, i64 -13
  store i64 %16, i64* %18, align 8
  %19 = load i64* %m1, align 8
  %20 = load i64** %htab_p, align 8
  %21 = getelementptr inbounds i64* %20, i64 -12
  store i64 %19, i64* %21, align 8
  %22 = load i64* %m1, align 8
  %23 = load i64** %htab_p, align 8
  %24 = getelementptr inbounds i64* %23, i64 -11
  store i64 %22, i64* %24, align 8
  %25 = load i64* %m1, align 8
  %26 = load i64** %htab_p, align 8
  %27 = getelementptr inbounds i64* %26, i64 -10
  store i64 %25, i64* %27, align 8
  %28 = load i64* %m1, align 8
  %29 = load i64** %htab_p, align 8
  %30 = getelementptr inbounds i64* %29, i64 -9
  store i64 %28, i64* %30, align 8
  %31 = load i64* %m1, align 8
  %32 = load i64** %htab_p, align 8
  %33 = getelementptr inbounds i64* %32, i64 -8
  store i64 %31, i64* %33, align 8
  %34 = load i64* %m1, align 8
  %35 = load i64** %htab_p, align 8
  %36 = getelementptr inbounds i64* %35, i64 -7
  store i64 %34, i64* %36, align 8
  %37 = load i64* %m1, align 8
  %38 = load i64** %htab_p, align 8
  %39 = getelementptr inbounds i64* %38, i64 -6
  store i64 %37, i64* %39, align 8
  %40 = load i64* %m1, align 8
  %41 = load i64** %htab_p, align 8
  %42 = getelementptr inbounds i64* %41, i64 -5
  store i64 %40, i64* %42, align 8
  %43 = load i64* %m1, align 8
  %44 = load i64** %htab_p, align 8
  %45 = getelementptr inbounds i64* %44, i64 -4
  store i64 %43, i64* %45, align 8
  %46 = load i64* %m1, align 8
  %47 = load i64** %htab_p, align 8
  %48 = getelementptr inbounds i64* %47, i64 -3
  store i64 %46, i64* %48, align 8
  %49 = load i64* %m1, align 8
  %50 = load i64** %htab_p, align 8
  %51 = getelementptr inbounds i64* %50, i64 -2
  store i64 %49, i64* %51, align 8
  %52 = load i64* %m1, align 8
  %53 = load i64** %htab_p, align 8
  %54 = getelementptr inbounds i64* %53, i64 -1
  store i64 %52, i64* %54, align 8
  %55 = load i64** %htab_p, align 8
  %56 = getelementptr inbounds i64* %55, i64 -16
  store i64* %56, i64** %htab_p, align 8
  br label %57

; <label>:57                                      ; preds = %6
  %58 = load i64* %i, align 8
  %59 = sub nsw i64 %58, 16
  store i64 %59, i64* %i, align 8
  %60 = icmp sge i64 %59, 0
  br i1 %60, label %6, label %61

; <label>:61                                      ; preds = %57
  %62 = load i64* %i, align 8
  %63 = add nsw i64 %62, 16
  store i64 %63, i64* %i, align 8
  br label %64

; <label>:64                                      ; preds = %71, %61
  %65 = load i64* %i, align 8
  %66 = icmp sgt i64 %65, 0
  br i1 %66, label %67, label %74

; <label>:67                                      ; preds = %64
  %68 = load i64* %m1, align 8
  %69 = load i64** %htab_p, align 8
  %70 = getelementptr inbounds i64* %69, i32 -1
  store i64* %70, i64** %htab_p, align 8
  store i64 %68, i64* %70, align 8
  br label %71

; <label>:71                                      ; preds = %67
  %72 = load i64* %i, align 8
  %73 = add nsw i64 %72, -1
  store i64 %73, i64* %i, align 8
  br label %64

; <label>:74                                      ; preds = %64
  ret void
}

; Function Attrs: nounwind uwtable
define void @cl_block() #0 {
  %rat = alloca i64, align 8
  %1 = load i64* @in_count, align 8
  %2 = add nsw i64 %1, 10000
  store i64 %2, i64* @checkpoint, align 8
  %3 = load i64* @in_count, align 8
  %4 = icmp sgt i64 %3, 8388607
  br i1 %4, label %5, label %16

; <label>:5                                       ; preds = %0
  %6 = load i64* @bytes_out, align 8
  %7 = ashr i64 %6, 8
  store i64 %7, i64* %rat, align 8
  %8 = load i64* %rat, align 8
  %9 = icmp eq i64 %8, 0
  br i1 %9, label %10, label %11

; <label>:10                                      ; preds = %5
  store i64 2147483647, i64* %rat, align 8
  br label %15

; <label>:11                                      ; preds = %5
  %12 = load i64* @in_count, align 8
  %13 = load i64* %rat, align 8
  %14 = sdiv i64 %12, %13
  store i64 %14, i64* %rat, align 8
  br label %15

; <label>:15                                      ; preds = %11, %10
  br label %21

; <label>:16                                      ; preds = %0
  %17 = load i64* @in_count, align 8
  %18 = shl i64 %17, 8
  %19 = load i64* @bytes_out, align 8
  %20 = sdiv i64 %18, %19
  store i64 %20, i64* %rat, align 8
  br label %21

; <label>:21                                      ; preds = %16, %15
  %22 = load i64* %rat, align 8
  %23 = load i64* @ratio, align 8
  %24 = icmp sgt i64 %22, %23
  br i1 %24, label %25, label %27

; <label>:25                                      ; preds = %21
  %26 = load i64* %rat, align 8
  store i64 %26, i64* @ratio, align 8
  br label %29

; <label>:27                                      ; preds = %21
  store i64 0, i64* @ratio, align 8
  %28 = load i64* @hsize, align 8
  call void @cl_hash(i64 %28)
  store i64 257, i64* @free_ent, align 8
  store i32 1, i32* @clear_flg, align 4
  call void @output(i64 256)
  br label %29

; <label>:29                                      ; preds = %27, %25
  ret void
}

; Function Attrs: nounwind uwtable
define void @output(i64 %code) #0 {
  %1 = alloca i64, align 8
  %r_off = alloca i32, align 4
  %bits = alloca i32, align 4
  %bp = alloca i8*, align 8
  store i64 %code, i64* %1, align 8
  %2 = load i32* @offset, align 4
  store i32 %2, i32* %r_off, align 4
  %3 = load i32* @n_bits, align 4
  store i32 %3, i32* %bits, align 4
  store i8* getelementptr inbounds ([16 x i8]* @buf, i32 0, i32 0), i8** %bp, align 8
  %4 = load i64* %1, align 8
  %5 = icmp sge i64 %4, 0
  br i1 %5, label %6, label %132

; <label>:6                                       ; preds = %0
  %7 = load i32* %r_off, align 4
  %8 = ashr i32 %7, 3
  %9 = load i8** %bp, align 8
  %10 = sext i32 %8 to i64
  %11 = getelementptr inbounds i8* %9, i64 %10
  store i8* %11, i8** %bp, align 8
  %12 = load i32* %r_off, align 4
  %13 = and i32 %12, 7
  store i32 %13, i32* %r_off, align 4
  %14 = load i8** %bp, align 8
  %15 = load i8* %14, align 1
  %16 = sext i8 %15 to i32
  %17 = load i32* %r_off, align 4
  %18 = sext i32 %17 to i64
  %19 = getelementptr inbounds [9 x i8]* @rmask, i32 0, i64 %18
  %20 = load i8* %19, align 1
  %21 = zext i8 %20 to i32
  %22 = and i32 %16, %21
  %23 = sext i32 %22 to i64
  %24 = load i64* %1, align 8
  %25 = load i32* %r_off, align 4
  %26 = zext i32 %25 to i64
  %27 = shl i64 %24, %26
  %28 = or i64 %23, %27
  %29 = load i32* %r_off, align 4
  %30 = sext i32 %29 to i64
  %31 = getelementptr inbounds [9 x i8]* @lmask, i32 0, i64 %30
  %32 = load i8* %31, align 1
  %33 = zext i8 %32 to i64
  %34 = and i64 %28, %33
  %35 = trunc i64 %34 to i8
  %36 = load i8** %bp, align 8
  store i8 %35, i8* %36, align 1
  %37 = load i8** %bp, align 8
  %38 = getelementptr inbounds i8* %37, i32 1
  store i8* %38, i8** %bp, align 8
  %39 = load i32* %r_off, align 4
  %40 = sub nsw i32 8, %39
  %41 = load i32* %bits, align 4
  %42 = sub nsw i32 %41, %40
  store i32 %42, i32* %bits, align 4
  %43 = load i32* %r_off, align 4
  %44 = sub nsw i32 8, %43
  %45 = load i64* %1, align 8
  %46 = zext i32 %44 to i64
  %47 = ashr i64 %45, %46
  store i64 %47, i64* %1, align 8
  %48 = load i32* %bits, align 4
  %49 = icmp sge i32 %48, 8
  br i1 %49, label %50, label %59

; <label>:50                                      ; preds = %6
  %51 = load i64* %1, align 8
  %52 = trunc i64 %51 to i8
  %53 = load i8** %bp, align 8
  %54 = getelementptr inbounds i8* %53, i32 1
  store i8* %54, i8** %bp, align 8
  store i8 %52, i8* %53, align 1
  %55 = load i64* %1, align 8
  %56 = ashr i64 %55, 8
  store i64 %56, i64* %1, align 8
  %57 = load i32* %bits, align 4
  %58 = sub nsw i32 %57, 8
  store i32 %58, i32* %bits, align 4
  br label %59

; <label>:59                                      ; preds = %50, %6
  %60 = load i32* %bits, align 4
  %61 = icmp ne i32 %60, 0
  br i1 %61, label %62, label %66

; <label>:62                                      ; preds = %59
  %63 = load i64* %1, align 8
  %64 = trunc i64 %63 to i8
  %65 = load i8** %bp, align 8
  store i8 %64, i8* %65, align 1
  br label %66

; <label>:66                                      ; preds = %62, %59
  %67 = load i32* @n_bits, align 4
  %68 = load i32* @offset, align 4
  %69 = add nsw i32 %68, %67
  store i32 %69, i32* @offset, align 4
  %70 = load i32* @offset, align 4
  %71 = load i32* @n_bits, align 4
  %72 = shl i32 %71, 3
  %73 = icmp eq i32 %70, %72
  br i1 %73, label %74, label %96

; <label>:74                                      ; preds = %66
  store i8* getelementptr inbounds ([16 x i8]* @buf, i32 0, i32 0), i8** %bp, align 8
  %75 = load i32* @n_bits, align 4
  store i32 %75, i32* %bits, align 4
  %76 = load i32* %bits, align 4
  %77 = sext i32 %76 to i64
  %78 = load i64* @bytes_out, align 8
  %79 = add nsw i64 %78, %77
  store i64 %79, i64* @bytes_out, align 8
  br label %80

; <label>:80                                      ; preds = %93, %74
  %81 = load i8** %bp, align 8
  %82 = getelementptr inbounds i8* %81, i32 1
  store i8* %82, i8** %bp, align 8
  %83 = load i8* %81, align 1
  call void @putbyte(i8 signext %83)
  br label %84

; <label>:84                                      ; preds = %80
  %85 = load i32* %bits, align 4
  %86 = add nsw i32 %85, -1
  store i32 %86, i32* %bits, align 4
  %87 = icmp ne i32 %86, 0
  br i1 %87, label %88, label %93

; <label>:88                                      ; preds = %84
  %89 = load i8** %bp, align 8
  %90 = ptrtoint i8* %89 to i64
  %91 = sub i64 %90, ptrtoint ([16 x i8]* @buf to i64)
  %92 = icmp slt i64 %91, 16
  br label %93

; <label>:93                                      ; preds = %88, %84
  %94 = phi i1 [ false, %84 ], [ %92, %88 ]
  br i1 %94, label %80, label %95

; <label>:95                                      ; preds = %93
  store i32 0, i32* @offset, align 4
  br label %96

; <label>:96                                      ; preds = %95, %66
  %97 = load i64* @free_ent, align 8
  %98 = load i64* @maxcode, align 8
  %99 = icmp sgt i64 %97, %98
  br i1 %99, label %103, label %100

; <label>:100                                     ; preds = %96
  %101 = load i32* @clear_flg, align 4
  %102 = icmp sgt i32 %101, 0
  br i1 %102, label %103, label %131

; <label>:103                                     ; preds = %100, %96
  %104 = load i32* @offset, align 4
  %105 = icmp sgt i32 %104, 0
  br i1 %105, label %106, label %112

; <label>:106                                     ; preds = %103
  %107 = load i32* @n_bits, align 4
  call void @writebytes(i8* getelementptr inbounds ([16 x i8]* @buf, i32 0, i32 0), i32 %107)
  %108 = load i32* @n_bits, align 4
  %109 = sext i32 %108 to i64
  %110 = load i64* @bytes_out, align 8
  %111 = add nsw i64 %110, %109
  store i64 %111, i64* @bytes_out, align 8
  br label %112

; <label>:112                                     ; preds = %106, %103
  store i32 0, i32* @offset, align 4
  %113 = load i32* @clear_flg, align 4
  %114 = icmp ne i32 %113, 0
  br i1 %114, label %115, label %116

; <label>:115                                     ; preds = %112
  store i32 9, i32* @n_bits, align 4
  store i64 511, i64* @maxcode, align 8
  store i32 0, i32* @clear_flg, align 4
  br label %130

; <label>:116                                     ; preds = %112
  %117 = load i32* @n_bits, align 4
  %118 = add nsw i32 %117, 1
  store i32 %118, i32* @n_bits, align 4
  %119 = load i32* @n_bits, align 4
  %120 = load i32* @maxbits, align 4
  %121 = icmp eq i32 %119, %120
  br i1 %121, label %122, label %124

; <label>:122                                     ; preds = %116
  %123 = load i64* @maxmaxcode, align 8
  store i64 %123, i64* @maxcode, align 8
  br label %129

; <label>:124                                     ; preds = %116
  %125 = load i32* @n_bits, align 4
  %126 = shl i32 1, %125
  %127 = sub nsw i32 %126, 1
  %128 = sext i32 %127 to i64
  store i64 %128, i64* @maxcode, align 8
  br label %129

; <label>:129                                     ; preds = %124, %122
  br label %130

; <label>:130                                     ; preds = %129, %115
  br label %131

; <label>:131                                     ; preds = %130, %100
  br label %146

; <label>:132                                     ; preds = %0
  %133 = load i32* @offset, align 4
  %134 = icmp sgt i32 %133, 0
  br i1 %134, label %135, label %139

; <label>:135                                     ; preds = %132
  %136 = load i32* @offset, align 4
  %137 = add nsw i32 %136, 7
  %138 = sdiv i32 %137, 8
  call void @writebytes(i8* getelementptr inbounds ([16 x i8]* @buf, i32 0, i32 0), i32 %138)
  br label %139

; <label>:139                                     ; preds = %135, %132
  %140 = load i32* @offset, align 4
  %141 = add nsw i32 %140, 7
  %142 = sdiv i32 %141, 8
  %143 = sext i32 %142 to i64
  %144 = load i64* @bytes_out, align 8
  %145 = add nsw i64 %144, %143
  store i64 %145, i64* @bytes_out, align 8
  store i32 0, i32* @offset, align 4
  br label %146

; <label>:146                                     ; preds = %139, %131
  ret void
}

; Function Attrs: nounwind uwtable
define void @putbyte(i8 signext %c) #0 {
  %1 = alloca i8, align 1
  store i8 %c, i8* %1, align 1
  %2 = load i8* %1, align 1
  %3 = load i8** @OutBuff, align 8
  %4 = getelementptr inbounds i8* %3, i32 1
  store i8* %4, i8** @OutBuff, align 8
  store i8 %2, i8* %3, align 1
  ret void
}

; Function Attrs: nounwind uwtable
define void @writebytes(i8* %buf, i32 %n) #0 {
  %1 = alloca i8*, align 8
  %2 = alloca i32, align 4
  %i = alloca i32, align 4
  store i8* %buf, i8** %1, align 8
  store i32 %n, i32* %2, align 4
  store i32 0, i32* %i, align 4
  br label %3

; <label>:3                                       ; preds = %20, %0
  %4 = load i32* %i, align 4
  %5 = load i32* %2, align 4
  %6 = icmp slt i32 %4, %5
  br i1 %6, label %7, label %10

; <label>:7                                       ; preds = %3
  %8 = load i32* %i, align 4
  %9 = icmp slt i32 %8, 16
  br label %10

; <label>:10                                      ; preds = %7, %3
  %11 = phi i1 [ false, %3 ], [ %9, %7 ]
  br i1 %11, label %12, label %23

; <label>:12                                      ; preds = %10
  %13 = load i32* %i, align 4
  %14 = sext i32 %13 to i64
  %15 = load i8** %1, align 8
  %16 = getelementptr inbounds i8* %15, i64 %14
  %17 = load i8* %16, align 1
  %18 = load i8** @OutBuff, align 8
  %19 = getelementptr inbounds i8* %18, i32 1
  store i8* %19, i8** @OutBuff, align 8
  store i8 %17, i8* %18, align 1
  br label %20

; <label>:20                                      ; preds = %12
  %21 = load i32* %i, align 4
  %22 = add nsw i32 %21, 1
  store i32 %22, i32* %i, align 4
  br label %3

; <label>:23                                      ; preds = %10
  ret void
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
