; ModuleID = 'fir.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@fir_int = global [36 x i64] [i64 4294967294, i64 1, i64 4, i64 3, i64 4294967294, i64 4294967292, i64 2, i64 7, i64 0, i64 4294967287, i64 4294967292, i64 12, i64 11, i64 4294967282, i64 4294967270, i64 15, i64 89, i64 127, i64 89, i64 15, i64 4294967270, i64 4294967282, i64 11, i64 12, i64 4294967292, i64 4294967287, i64 0, i64 7, i64 2, i64 4294967292, i64 4294967294, i64 3, i64 4, i64 1, i64 4294967294, i64 0], align 16
@in_data = global [701 x i64] [i64 0, i64 0, i64 0, i64 0, i64 127, i64 121, i64 114, i64 121, i64 13, i64 13, i64 0, i64 3, i64 5, i64 2, i64 3, i64 127, i64 127, i64 2, i64 126, i64 0, i64 1, i64 126, i64 1, i64 1, i64 127, i64 0, i64 127, i64 0, i64 2, i64 1, i64 1, i64 3, i64 1, i64 127, i64 1, i64 0, i64 1, i64 1, i64 125, i64 123, i64 115, i64 106, i64 119, i64 16, i64 14, i64 1, i64 5, i64 5, i64 5, i64 5, i64 125, i64 0, i64 2, i64 125, i64 0, i64 0, i64 126, i64 1, i64 126, i64 127, i64 3, i64 124, i64 126, i64 6, i64 0, i64 126, i64 3, i64 2, i64 127, i64 126, i64 127, i64 2, i64 1, i64 127, i64 1, i64 1, i64 0, i64 3, i64 0, i64 127, i64 2, i64 0, i64 127, i64 3, i64 1, i64 0, i64 0, i64 125, i64 0, i64 3, i64 0, i64 126, i64 127, i64 2, i64 1, i64 126, i64 0, i64 3, i64 127, i64 125, i64 1, i64 1, i64 1, i64 127, i64 0, i64 5, i64 0, i64 127, i64 2, i64 126, i64 127, i64 2, i64 1, i64 0, i64 126, i64 0, i64 5, i64 0, i64 127, i64 0, i64 126, i64 1, i64 0, i64 125, i64 1, i64 3, i64 127, i64 0, i64 0, i64 126, i64 2, i64 3, i64 126, i64 125, i64 114, i64 104, i64 113, i64 5, i64 12, i64 7, i64 2, i64 6, i64 13, i64 5, i64 125, i64 3, i64 2, i64 127, i64 0, i64 121, i64 122, i64 3, i64 126, i64 125, i64 0, i64 125, i64 2, i64 1, i64 125, i64 8, i64 3, i64 124, i64 6, i64 0, i64 122, i64 6, i64 2, i64 124, i64 3, i64 126, i64 121, i64 6, i64 5, i64 116, i64 127, i64 13, i64 122, i64 120, i64 6, i64 5, i64 1, i64 0, i64 125, i64 1, i64 4, i64 124, i64 127, i64 3, i64 127, i64 5, i64 3, i64 122, i64 6, i64 10, i64 118, i64 124, i64 10, i64 124, i64 127, i64 6, i64 121, i64 3, i64 12, i64 117, i64 120, i64 10, i64 0, i64 121, i64 3, i64 126, i64 124, i64 6, i64 0, i64 121, i64 2, i64 126, i64 127, i64 6, i64 118, i64 127, i64 13, i64 121, i64 127, i64 6, i64 121, i64 6, i64 3, i64 113, i64 6, i64 10, i64 115, i64 127, i64 10, i64 0, i64 127, i64 122, i64 124, i64 10, i64 0, i64 117, i64 127, i64 12, i64 10, i64 124, i64 121, i64 9, i64 13, i64 125, i64 122, i64 5, i64 11, i64 10, i64 121, i64 124, i64 22, i64 3, i64 114, i64 13, i64 7, i64 121, i64 12, i64 7, i64 122, i64 11, i64 7, i64 122, i64 10, i64 7, i64 121, i64 10, i64 5, i64 117, i64 6, i64 5, i64 121, i64 5, i64 6, i64 1, i64 6, i64 0, i64 122, i64 2, i64 7, i64 3, i64 125, i64 1, i64 10, i64 7, i64 2, i64 127, i64 127, i64 9, i64 7, i64 121, i64 121, i64 6, i64 8, i64 125, i64 122, i64 6, i64 12, i64 6, i64 125, i64 127, i64 13, i64 7, i64 121, i64 1, i64 6, i64 127, i64 127, i64 2, i64 3, i64 1, i64 126, i64 1, i64 1, i64 125, i64 1, i64 0, i64 125, i64 6, i64 3, i64 125, i64 5, i64 7, i64 127, i64 124, i64 1, i64 6, i64 6, i64 124, i64 122, i64 7, i64 10, i64 0, i64 120, i64 1, i64 8, i64 0, i64 121, i64 122, i64 4, i64 10, i64 0, i64 120, i64 1, i64 6, i64 122, i64 117, i64 122, i64 0, i64 0, i64 121, i64 118, i64 127, i64 7, i64 0, i64 122, i64 125, i64 2, i64 4, i64 124, i64 122, i64 2, i64 5, i64 124, i64 122, i64 125, i64 127, i64 0, i64 120, i64 117, i64 127, i64 0, i64 121, i64 120, i64 121, i64 1, i64 3, i64 121, i64 121, i64 0, i64 0, i64 127, i64 127, i64 121, i64 127, i64 2, i64 122, i64 124, i64 125, i64 124, i64 127, i64 125, i64 121, i64 125, i64 0, i64 121, i64 122, i64 124, i64 125, i64 0, i64 125, i64 125, i64 0, i64 0, i64 0, i64 0, i64 125, i64 125, i64 0, i64 125, i64 126, i64 0, i64 126, i64 3, i64 3, i64 125, i64 1, i64 5, i64 0, i64 126, i64 125, i64 127, i64 3, i64 125, i64 121, i64 1, i64 2, i64 125, i64 127, i64 1, i64 0, i64 0, i64 127, i64 127, i64 126, i64 127, i64 0, i64 127, i64 0, i64 124, i64 125, i64 0, i64 121, i64 120, i64 124, i64 124, i64 123, i64 123, i64 125, i64 127, i64 0, i64 0, i64 127, i64 0, i64 1, i64 2, i64 0, i64 127, i64 0, i64 0, i64 0, i64 127, i64 126, i64 0, i64 0, i64 127, i64 0, i64 2, i64 1, i64 2, i64 6, i64 5, i64 3, i64 6, i64 8, i64 5, i64 2, i64 1, i64 1, i64 3, i64 0, i64 125, i64 127, i64 0, i64 127, i64 126, i64 0, i64 2, i64 3, i64 2, i64 1, i64 2, i64 3, i64 1, i64 124, i64 125, i64 0, i64 0, i64 126, i64 124, i64 127, i64 1, i64 0, i64 126, i64 124, i64 127, i64 1, i64 0, i64 126, i64 127, i64 2, i64 3, i64 1, i64 0, i64 4, i64 6, i64 5, i64 6, i64 7, i64 10, i64 10, i64 4, i64 2, i64 5, i64 8, i64 9, i64 8, i64 7, i64 12, i64 20, i64 20, i64 16, i64 14, i64 20, i64 21, i64 15, i64 9, i64 7, i64 4, i64 126, i64 118, i64 100, i64 65, i64 72, i64 125, i64 108, i64 61, i64 103, i64 16, i64 6, i64 125, i64 117, i64 7, i64 29, i64 0, i64 108, i64 2, i64 125, i64 120, i64 119, i64 111, i64 119, i64 1, i64 0, i64 2, i64 7, i64 10, i64 28, i64 28, i64 23, i64 35, i64 47, i64 65, i64 67, i64 79, i64 85, i64 88, i64 126, i64 2, i64 76, i64 16, i64 105, i64 44, i64 13, i64 116, i64 42, i64 116, i64 99, i64 41, i64 124, i64 94, i64 33, i64 53, i64 70, i64 36, i64 103, i64 53, i64 60, i64 60, i64 38, i64 38, i64 47, i64 71, i64 100, i64 4, i64 19, i64 24, i64 39, i64 43, i64 48, i64 27, i64 127, i64 120, i64 114, i64 104, i64 92, i64 90, i64 104, i64 124, i64 3, i64 13, i64 38, i64 65, i64 81, i64 90, i64 106, i64 108, i64 84, i64 120, i64 9, i64 69, i64 121, i64 31, i64 11, i64 46, i64 96, i64 11, i64 102, i64 127, i64 104, i64 119, i64 78, i64 70, i64 74, i64 59, i64 18, i64 91, i64 55, i64 49, i64 33, i64 11, i64 18, i64 46, i64 87, i64 126, i64 25, i64 34, i64 43, i64 63, i64 58, i64 37, i64 11, i64 121, i64 113, i64 104, i64 97, i64 92, i64 102, i64 114, i64 6, i64 22, i64 41, i64 65, i64 94, i64 109, i64 102, i64 96, i64 110, i64 23, i64 72, i64 54, i64 18, i64 23, i64 47, i64 99, i64 120, i64 92, i64 119, i64 108, i64 117, i64 65, i64 73, i64 79, i64 59, i64 11, i64 84, i64 55, i64 0], align 16
@out_data = global [720 x i64] [i64 3, i64 4294967290, i64 4294967293, i64 29, i64 88, i64 137, i64 135, i64 86, i64 32, i64 7, i64 7, i64 4, i64 4294967289, i64 0, i64 40, i64 91, i64 107, i64 79, i64 43, i64 33, i64 45, i64 48, i64 39, i64 39, i64 55, i64 71, i64 66, i64 39, i64 8, i64 4294967284, i64 4294967285, i64 13, i64 46, i64 59, i64 37, i64 0, i64 4294967288, i64 29, i64 89, i64 131, i64 135, i64 111, i64 78, i64 47, i64 18, i64 4294967295, i64 4294967291, i64 4, i64 21, i64 35, i64 45, i64 49, i64 47, i64 41, i64 38, i64 42, i64 54, i64 72, i64 88, i64 95, i64 90, i64 79, i64 70, i64 65, i64 50, i64 27, i64 23, i64 55, i64 105, i64 123, i64 89, i64 47, i64 36, i64 48, i64 42, i64 8, i64 4294967286, i64 7, i64 36, i64 49, i64 47, i64 51, i64 50, i64 30, i64 4, i64 7, i64 35, i64 51, i64 33, i64 14, i64 30, i64 74, i64 97, i64 75, i64 33, i64 14, i64 34, i64 73, i64 94, i64 77, i64 37, i64 11, i64 24, i64 50, i64 51, i64 21, i64 5, i64 41, i64 100, i64 118, i64 77, i64 22, i64 9, i64 38, i64 55, i64 35, i64 11, i64 21, i64 60, i64 82, i64 64, i64 35, i64 29, i64 45, i64 54, i64 45, i64 36, i64 41, i64 50, i64 44, i64 33, i64 43, i64 80, i64 123, i64 141, i64 115, i64 71, i64 34, i64 15, i64 7, i64 4294967295, i64 0, i64 19, i64 45, i64 54, i64 43, i64 35, i64 50, i64 78, i64 92, i64 85, i64 79, i64 85, i64 92, i64 80, i64 52, i64 32, i64 34, i64 50, i64 56, i64 47, i64 37, i64 42, i64 53, i64 50, i64 35, i64 31, i64 54, i64 87, i64 96, i64 76, i64 49, i64 45, i64 64, i64 87, i64 103, i64 103, i64 76, i64 33, i64 4, i64 8, i64 32, i64 48, i64 44, i64 51, i64 78, i64 97, i64 86, i64 57, i64 38, i64 38, i64 43, i64 46, i64 56, i64 74, i64 87, i64 88, i64 92, i64 95, i64 80, i64 49, i64 29, i64 49, i64 88, i64 93, i64 55, i64 22, i64 35, i64 85, i64 113, i64 86, i64 40, i64 24, i64 48, i64 81, i64 96, i64 92, i64 82, i64 79, i64 84, i64 94, i64 98, i64 87, i64 69, i64 58, i64 53, i64 38, i64 23, i64 35, i64 71, i64 93, i64 72, i64 39, i64 48, i64 97, i64 121, i64 90, i64 49, i64 45, i64 69, i64 79, i64 65, i64 62, i64 72, i64 72, i64 58, i64 61, i64 83, i64 85, i64 47, i64 13, i64 31, i64 85, i64 105, i64 71, i64 30, i64 28, i64 50, i64 60, i64 49, i64 40, i64 45, i64 52, i64 50, i64 46, i64 46, i64 47, i64 45, i64 47, i64 50, i64 47, i64 38, i64 35, i64 48, i64 61, i64 44, i64 3, i64 4294967279, i64 10, i64 52, i64 57, i64 24, i64 10, i64 40, i64 66, i64 40, i64 4294967291, i64 4294967294, i64 55, i64 97, i64 83, i64 50, i64 53, i64 75, i64 76, i64 54, i64 54, i64 78, i64 86, i64 51, i64 14, i64 27, i64 78, i64 105, i64 81, i64 34, i64 13, i64 36, i64 75, i64 94, i64 77, i64 42, i64 18, i64 22, i64 41, i64 53, i64 51, i64 42, i64 37, i64 38, i64 47, i64 56, i64 49, i64 29, i64 29, i64 66, i64 104, i64 88, i64 26, i64 4294967295, i64 42, i64 99, i64 95, i64 39, i64 10, i64 34, i64 52, i64 30, i64 11, i64 39, i64 88, i64 90, i64 46, i64 16, i64 27, i64 40, i64 35, i64 49, i64 96, i64 124, i64 86, i64 27, i64 29, i64 93, i64 129, i64 92, i64 41, i64 44, i64 78, i64 81, i64 53, i64 51, i64 77, i64 83, i64 50, i64 36, i64 80, i64 134, i64 133, i64 90, i64 70, i64 93, i64 107, i64 91, i64 79, i64 99, i64 113, i64 84, i64 42, i64 44, i64 80, i64 86, i64 48, i64 30, i64 77, i64 141, i64 144, i64 91, i64 58, i64 85, i64 128, i64 137, i64 120, i64 123, i64 138, i64 125, i64 83, i64 62, i64 91, i64 131, i64 127, i64 89, i64 74, i64 91, i64 94, i64 46, i64 4294967284, i64 4294967283, i64 45, i64 95, i64 97, i64 80, i64 84, i64 94, i64 80, i64 48, i64 38, i64 52, i64 50, i64 24, i64 9, i64 39, i64 91, i64 116, i64 109, i64 94, i64 82, i64 64, i64 45, i64 52, i64 84, i64 92, i64 49, i64 0, i64 10, i64 86, i64 156, i64 150, i64 89, i64 46, i64 56, i64 87, i64 94, i64 75, i64 70, i64 94, i64 120, i64 124, i64 119, i64 128, i64 141, i64 125, i64 79, i64 43, i64 43, i64 51, i64 30, i64 0, i64 6, i64 40, i64 55, i64 29, i64 9, i64 36, i64 83, i64 93, i64 61, i64 31, i64 33, i64 41, i64 24, i64 4294967292, i64 4294967285, i64 6, i64 18, i64 9, i64 4294967293, i64 1, i64 15, i64 12, i64 4294967290, i64 4294967282, i64 9, i64 50, i64 77, i64 86, i64 92, i64 98, i64 83, i64 39, i64 0, i64 4294967292, i64 12, i64 8, i64 4294967280, i64 4294967289, i64 54, i64 106, i64 85, i64 28, i64 27, i64 96, i64 142, i64 97, i64 21, i64 20, i64 94, i64 140, i64 97, i64 29, i64 26, i64 82, i64 107, i64 61, i64 4294967291, i64 4294967272, i64 1, i64 21, i64 12, i64 4294967294, i64 0, i64 13, i64 17, i64 9, i64 1, i64 1, i64 7, i64 12, i64 11, i64 7, i64 6, i64 13, i64 22, i64 23, i64 16, i64 12, i64 19, i64 28, i64 19, i64 0, i64 0, i64 38, i64 95, i64 123, i64 104, i64 72, i64 72, i64 104, i64 125, i64 96, i64 45, i64 25, i64 55, i64 92, i64 90, i64 49, i64 15, i64 19, i64 49, i64 76, i64 94, i64 113, i64 131, i64 127, i64 88, i64 32, i64 4294967293, i64 4294967288, i64 9, i64 24, i64 25, i64 22, i64 25, i64 39, i64 55, i64 61, i64 66, i64 79, i64 98, i64 101, i64 79, i64 51, i64 44, i64 54, i64 61, i64 56, i64 52, i64 64, i64 84, i64 93, i64 91, i64 88, i64 89, i64 83, i64 65, i64 50, i64 51, i64 63, i64 74, i64 75, i64 67, i64 51, i64 37, i64 40, i64 61, i64 79, i64 68, i64 35, i64 14, i64 22, i64 41, i64 44, i64 40, i64 57, i64 99, i64 132, i64 125, i64 95, i64 86, i64 105, i64 115, i64 86, i64 36, i64 12, i64 30, i64 64, i64 86, i64 96, i64 105, i64 110, i64 99, i64 78, i64 66, i64 68, i64 71, i64 59, i64 42, i64 34, i64 45, i64 69, i64 93, i64 112, i64 119, i64 109, i64 91, i64 74, i64 63, i64 55, i64 50, i64 57, i64 67, i64 61, i64 32, i64 5, i64 16, i64 63, i64 100, i64 90, i64 52, i64 33, i64 46, i64 62, i64 51, i64 34, i64 48, i64 89, i64 117, i64 113, i64 96, i64 97, i64 103, i64 85, i64 45, i64 18, i64 29, i64 67, i64 101, i64 113, i64 108, i64 95, i64 83, i64 71, i64 57, i64 41, i64 28, i64 30, i64 53, i64 86, i64 111, i64 116, i64 111, i64 106, i64 102, i64 92, i64 75, i64 58, i64 51, i64 54, i64 56, i64 44, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0, i64 0], align 16

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %output = alloca [720 x i64], align 16
  store i32 0, i32* %1
  %2 = getelementptr inbounds [720 x i64]* %output, i32 0, i32 0
  call void @fir_filter_int(i64* getelementptr inbounds ([701 x i64]* @in_data, i32 0, i32 0), i64* %2, i64 700, i64* getelementptr inbounds ([36 x i64]* @fir_int, i32 0, i32 0), i64 35, i64 285)
  ret i32 0
}

; Function Attrs: nounwind uwtable
define void @fir_filter_int(i64* %in, i64* %out, i64 %in_len, i64* %coef, i64 %coef_len, i64 %scale) #0 {
  %1 = alloca i64*, align 8
  %2 = alloca i64*, align 8
  %3 = alloca i64, align 8
  %4 = alloca i64*, align 8
  %5 = alloca i64, align 8
  %6 = alloca i64, align 8
  %i = alloca i64, align 8
  %j = alloca i64, align 8
  %coef_len2 = alloca i64, align 8
  %acc_length = alloca i64, align 8
  %acc = alloca i64, align 8
  %in_ptr = alloca i64*, align 8
  %data_ptr = alloca i64*, align 8
  %coef_start = alloca i64*, align 8
  %coef_ptr = alloca i64*, align 8
  %in_end = alloca i64*, align 8
  store i64* %in, i64** %1, align 8
  store i64* %out, i64** %2, align 8
  store i64 %in_len, i64* %3, align 8
  store i64* %coef, i64** %4, align 8
  store i64 %coef_len, i64* %5, align 8
  store i64 %scale, i64* %6, align 8
  %7 = load i64** %4, align 8
  store i64* %7, i64** %coef_start, align 8
  %8 = load i64* %5, align 8
  %9 = add nsw i64 %8, 1
  %10 = ashr i64 %9, 1
  store i64 %10, i64* %coef_len2, align 8
  %11 = load i64** %1, align 8
  %12 = load i64* %3, align 8
  %13 = getelementptr inbounds i64* %11, i64 %12
  %14 = getelementptr inbounds i64* %13, i64 -1
  store i64* %14, i64** %in_end, align 8
  %15 = load i64** %1, align 8
  %16 = load i64* %coef_len2, align 8
  %17 = getelementptr inbounds i64* %15, i64 %16
  %18 = getelementptr inbounds i64* %17, i64 -1
  store i64* %18, i64** %in_ptr, align 8
  %19 = load i64* %coef_len2, align 8
  store i64 %19, i64* %acc_length, align 8
  store i64 0, i64* %i, align 8
  br label %20

; <label>:20                                      ; preds = %78, %0
  %21 = load i64* %i, align 8
  %22 = load i64* %3, align 8
  %23 = icmp slt i64 %21, %22
  br i1 %23, label %24, label %81

; <label>:24                                      ; preds = %20
  %25 = load i64** %in_ptr, align 8
  store i64* %25, i64** %data_ptr, align 8
  %26 = load i64** %coef_start, align 8
  store i64* %26, i64** %coef_ptr, align 8
  %27 = load i64** %coef_ptr, align 8
  %28 = getelementptr inbounds i64* %27, i32 1
  store i64* %28, i64** %coef_ptr, align 8
  %29 = load i64* %27, align 8
  %30 = load i64** %data_ptr, align 8
  %31 = getelementptr inbounds i64* %30, i32 -1
  store i64* %31, i64** %data_ptr, align 8
  %32 = load i64* %30, align 8
  %33 = mul nsw i64 %29, %32
  store i64 %33, i64* %acc, align 8
  store i64 1, i64* %j, align 8
  br label %34

; <label>:34                                      ; preds = %48, %24
  %35 = load i64* %j, align 8
  %36 = load i64* %acc_length, align 8
  %37 = icmp slt i64 %35, %36
  br i1 %37, label %38, label %51

; <label>:38                                      ; preds = %34
  %39 = load i64** %coef_ptr, align 8
  %40 = getelementptr inbounds i64* %39, i32 1
  store i64* %40, i64** %coef_ptr, align 8
  %41 = load i64* %39, align 8
  %42 = load i64** %data_ptr, align 8
  %43 = getelementptr inbounds i64* %42, i32 -1
  store i64* %43, i64** %data_ptr, align 8
  %44 = load i64* %42, align 8
  %45 = mul nsw i64 %41, %44
  %46 = load i64* %acc, align 8
  %47 = add nsw i64 %46, %45
  store i64 %47, i64* %acc, align 8
  br label %48

; <label>:48                                      ; preds = %38
  %49 = load i64* %j, align 8
  %50 = add nsw i64 %49, 1
  store i64 %50, i64* %j, align 8
  br label %34

; <label>:51                                      ; preds = %34
  %52 = load i64* %acc, align 8
  %53 = load i64* %6, align 8
  %54 = sdiv i64 %52, %53
  %55 = trunc i64 %54 to i32
  %56 = sext i32 %55 to i64
  %57 = load i64** %2, align 8
  %58 = getelementptr inbounds i64* %57, i32 1
  store i64* %58, i64** %2, align 8
  store i64 %56, i64* %57, align 8
  %59 = load i64** %in_ptr, align 8
  %60 = load i64** %in_end, align 8
  %61 = icmp eq i64* %59, %60
  br i1 %61, label %62, label %67

; <label>:62                                      ; preds = %51
  %63 = load i64* %acc_length, align 8
  %64 = add nsw i64 %63, -1
  store i64 %64, i64* %acc_length, align 8
  %65 = load i64** %coef_start, align 8
  %66 = getelementptr inbounds i64* %65, i32 1
  store i64* %66, i64** %coef_start, align 8
  br label %77

; <label>:67                                      ; preds = %51
  %68 = load i64* %acc_length, align 8
  %69 = load i64* %5, align 8
  %70 = icmp slt i64 %68, %69
  br i1 %70, label %71, label %74

; <label>:71                                      ; preds = %67
  %72 = load i64* %acc_length, align 8
  %73 = add nsw i64 %72, 1
  store i64 %73, i64* %acc_length, align 8
  br label %74

; <label>:74                                      ; preds = %71, %67
  %75 = load i64** %in_ptr, align 8
  %76 = getelementptr inbounds i64* %75, i32 1
  store i64* %76, i64** %in_ptr, align 8
  br label %77

; <label>:77                                      ; preds = %74, %62
  br label %78

; <label>:78                                      ; preds = %77
  %79 = load i64* %i, align 8
  %80 = add nsw i64 %79, 1
  store i64 %80, i64* %i, align 8
  br label %20

; <label>:81                                      ; preds = %20
  ret void
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
