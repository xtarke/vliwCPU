; ModuleID = 'ud.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@a = common global [50 x [50 x i64]] zeroinitializer, align 16
@b = common global [50 x i64] zeroinitializer, align 16
@x = common global [50 x i64] zeroinitializer, align 16

; Function Attrs: nounwind uwtable
define void @main() #0 {
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %nmax = alloca i32, align 4
  %n = alloca i32, align 4
  %chkerr = alloca i32, align 4
  %w = alloca i64, align 8
  store i32 50, i32* %nmax, align 4
  store i32 5, i32* %n, align 4
  store i32 0, i32* %i, align 4
  br label %1

; <label>:1                                       ; preds = %53, %0
  %2 = load i32* %i, align 4
  %3 = load i32* %n, align 4
  %4 = icmp sle i32 %2, %3
  br i1 %4, label %5, label %56

; <label>:5                                       ; preds = %1
  store i64 0, i64* %w, align 8
  store i32 0, i32* %j, align 4
  br label %6

; <label>:6                                       ; preds = %45, %5
  %7 = load i32* %j, align 4
  %8 = load i32* %n, align 4
  %9 = icmp sle i32 %7, %8
  br i1 %9, label %10, label %48

; <label>:10                                      ; preds = %6
  %11 = load i32* %i, align 4
  %12 = add nsw i32 %11, 1
  %13 = load i32* %j, align 4
  %14 = add nsw i32 %13, 1
  %15 = add nsw i32 %12, %14
  %16 = sext i32 %15 to i64
  %17 = load i32* %j, align 4
  %18 = sext i32 %17 to i64
  %19 = load i32* %i, align 4
  %20 = sext i32 %19 to i64
  %21 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %20
  %22 = getelementptr inbounds [50 x i64]* %21, i32 0, i64 %18
  store i64 %16, i64* %22, align 8
  %23 = load i32* %i, align 4
  %24 = load i32* %j, align 4
  %25 = icmp eq i32 %23, %24
  br i1 %25, label %26, label %35

; <label>:26                                      ; preds = %10
  %27 = load i32* %j, align 4
  %28 = sext i32 %27 to i64
  %29 = load i32* %i, align 4
  %30 = sext i32 %29 to i64
  %31 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %30
  %32 = getelementptr inbounds [50 x i64]* %31, i32 0, i64 %28
  %33 = load i64* %32, align 8
  %34 = mul nsw i64 %33, 2
  store i64 %34, i64* %32, align 8
  br label %35

; <label>:35                                      ; preds = %26, %10
  %36 = load i32* %j, align 4
  %37 = sext i32 %36 to i64
  %38 = load i32* %i, align 4
  %39 = sext i32 %38 to i64
  %40 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %39
  %41 = getelementptr inbounds [50 x i64]* %40, i32 0, i64 %37
  %42 = load i64* %41, align 8
  %43 = load i64* %w, align 8
  %44 = add nsw i64 %43, %42
  store i64 %44, i64* %w, align 8
  br label %45

; <label>:45                                      ; preds = %35
  %46 = load i32* %j, align 4
  %47 = add nsw i32 %46, 1
  store i32 %47, i32* %j, align 4
  br label %6

; <label>:48                                      ; preds = %6
  %49 = load i64* %w, align 8
  %50 = load i32* %i, align 4
  %51 = sext i32 %50 to i64
  %52 = getelementptr inbounds [50 x i64]* @b, i32 0, i64 %51
  store i64 %49, i64* %52, align 8
  br label %53

; <label>:53                                      ; preds = %48
  %54 = load i32* %i, align 4
  %55 = add nsw i32 %54, 1
  store i32 %55, i32* %i, align 4
  br label %1

; <label>:56                                      ; preds = %1
  %57 = load i32* %nmax, align 4
  %58 = load i32* %n, align 4
  %59 = call i32 @ludcmp(i32 %57, i32 %58)
  store i32 %59, i32* %chkerr, align 4
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @ludcmp(i32 %nmax, i32 %n) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %w = alloca i64, align 8
  %y = alloca [100 x i64], align 16
  store i32 %nmax, i32* %1, align 4
  store i32 %n, i32* %2, align 4
  store i32 0, i32* %i, align 4
  br label %3

; <label>:3                                       ; preds = %125, %0
  %4 = load i32* %i, align 4
  %5 = load i32* %2, align 4
  %6 = icmp slt i32 %4, %5
  br i1 %6, label %7, label %128

; <label>:7                                       ; preds = %3
  %8 = load i32* %i, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %j, align 4
  br label %10

; <label>:10                                      ; preds = %67, %7
  %11 = load i32* %j, align 4
  %12 = load i32* %2, align 4
  %13 = icmp sle i32 %11, %12
  br i1 %13, label %14, label %70

; <label>:14                                      ; preds = %10
  %15 = load i32* %i, align 4
  %16 = sext i32 %15 to i64
  %17 = load i32* %j, align 4
  %18 = sext i32 %17 to i64
  %19 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %18
  %20 = getelementptr inbounds [50 x i64]* %19, i32 0, i64 %16
  %21 = load i64* %20, align 8
  store i64 %21, i64* %w, align 8
  %22 = load i32* %i, align 4
  %23 = icmp ne i32 %22, 0
  br i1 %23, label %24, label %51

; <label>:24                                      ; preds = %14
  store i32 0, i32* %k, align 4
  br label %25

; <label>:25                                      ; preds = %47, %24
  %26 = load i32* %k, align 4
  %27 = load i32* %i, align 4
  %28 = icmp slt i32 %26, %27
  br i1 %28, label %29, label %50

; <label>:29                                      ; preds = %25
  %30 = load i32* %k, align 4
  %31 = sext i32 %30 to i64
  %32 = load i32* %j, align 4
  %33 = sext i32 %32 to i64
  %34 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %33
  %35 = getelementptr inbounds [50 x i64]* %34, i32 0, i64 %31
  %36 = load i64* %35, align 8
  %37 = load i32* %i, align 4
  %38 = sext i32 %37 to i64
  %39 = load i32* %k, align 4
  %40 = sext i32 %39 to i64
  %41 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %40
  %42 = getelementptr inbounds [50 x i64]* %41, i32 0, i64 %38
  %43 = load i64* %42, align 8
  %44 = mul nsw i64 %36, %43
  %45 = load i64* %w, align 8
  %46 = sub nsw i64 %45, %44
  store i64 %46, i64* %w, align 8
  br label %47

; <label>:47                                      ; preds = %29
  %48 = load i32* %k, align 4
  %49 = add nsw i32 %48, 1
  store i32 %49, i32* %k, align 4
  br label %25

; <label>:50                                      ; preds = %25
  br label %51

; <label>:51                                      ; preds = %50, %14
  %52 = load i64* %w, align 8
  %53 = load i32* %i, align 4
  %54 = sext i32 %53 to i64
  %55 = load i32* %i, align 4
  %56 = sext i32 %55 to i64
  %57 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %56
  %58 = getelementptr inbounds [50 x i64]* %57, i32 0, i64 %54
  %59 = load i64* %58, align 8
  %60 = sdiv i64 %52, %59
  %61 = load i32* %i, align 4
  %62 = sext i32 %61 to i64
  %63 = load i32* %j, align 4
  %64 = sext i32 %63 to i64
  %65 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %64
  %66 = getelementptr inbounds [50 x i64]* %65, i32 0, i64 %62
  store i64 %60, i64* %66, align 8
  br label %67

; <label>:67                                      ; preds = %51
  %68 = load i32* %j, align 4
  %69 = add nsw i32 %68, 1
  store i32 %69, i32* %j, align 4
  br label %10

; <label>:70                                      ; preds = %10
  %71 = load i32* %i, align 4
  %72 = add nsw i32 %71, 1
  store i32 %72, i32* %j, align 4
  br label %73

; <label>:73                                      ; preds = %121, %70
  %74 = load i32* %j, align 4
  %75 = load i32* %2, align 4
  %76 = icmp sle i32 %74, %75
  br i1 %76, label %77, label %124

; <label>:77                                      ; preds = %73
  %78 = load i32* %j, align 4
  %79 = sext i32 %78 to i64
  %80 = load i32* %i, align 4
  %81 = add nsw i32 %80, 1
  %82 = sext i32 %81 to i64
  %83 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %82
  %84 = getelementptr inbounds [50 x i64]* %83, i32 0, i64 %79
  %85 = load i64* %84, align 8
  store i64 %85, i64* %w, align 8
  store i32 0, i32* %k, align 4
  br label %86

; <label>:86                                      ; preds = %109, %77
  %87 = load i32* %k, align 4
  %88 = load i32* %i, align 4
  %89 = icmp sle i32 %87, %88
  br i1 %89, label %90, label %112

; <label>:90                                      ; preds = %86
  %91 = load i32* %k, align 4
  %92 = sext i32 %91 to i64
  %93 = load i32* %i, align 4
  %94 = add nsw i32 %93, 1
  %95 = sext i32 %94 to i64
  %96 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %95
  %97 = getelementptr inbounds [50 x i64]* %96, i32 0, i64 %92
  %98 = load i64* %97, align 8
  %99 = load i32* %j, align 4
  %100 = sext i32 %99 to i64
  %101 = load i32* %k, align 4
  %102 = sext i32 %101 to i64
  %103 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %102
  %104 = getelementptr inbounds [50 x i64]* %103, i32 0, i64 %100
  %105 = load i64* %104, align 8
  %106 = mul nsw i64 %98, %105
  %107 = load i64* %w, align 8
  %108 = sub nsw i64 %107, %106
  store i64 %108, i64* %w, align 8
  br label %109

; <label>:109                                     ; preds = %90
  %110 = load i32* %k, align 4
  %111 = add nsw i32 %110, 1
  store i32 %111, i32* %k, align 4
  br label %86

; <label>:112                                     ; preds = %86
  %113 = load i64* %w, align 8
  %114 = load i32* %j, align 4
  %115 = sext i32 %114 to i64
  %116 = load i32* %i, align 4
  %117 = add nsw i32 %116, 1
  %118 = sext i32 %117 to i64
  %119 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %118
  %120 = getelementptr inbounds [50 x i64]* %119, i32 0, i64 %115
  store i64 %113, i64* %120, align 8
  br label %121

; <label>:121                                     ; preds = %112
  %122 = load i32* %j, align 4
  %123 = add nsw i32 %122, 1
  store i32 %123, i32* %j, align 4
  br label %73

; <label>:124                                     ; preds = %73
  br label %125

; <label>:125                                     ; preds = %124
  %126 = load i32* %i, align 4
  %127 = add nsw i32 %126, 1
  store i32 %127, i32* %i, align 4
  br label %3

; <label>:128                                     ; preds = %3
  %129 = load i64* getelementptr inbounds ([50 x i64]* @b, i32 0, i64 0), align 8
  %130 = getelementptr inbounds [100 x i64]* %y, i32 0, i64 0
  store i64 %129, i64* %130, align 8
  store i32 1, i32* %i, align 4
  br label %131

; <label>:131                                     ; preds = %167, %128
  %132 = load i32* %i, align 4
  %133 = load i32* %2, align 4
  %134 = icmp sle i32 %132, %133
  br i1 %134, label %135, label %170

; <label>:135                                     ; preds = %131
  %136 = load i32* %i, align 4
  %137 = sext i32 %136 to i64
  %138 = getelementptr inbounds [50 x i64]* @b, i32 0, i64 %137
  %139 = load i64* %138, align 8
  store i64 %139, i64* %w, align 8
  store i32 0, i32* %j, align 4
  br label %140

; <label>:140                                     ; preds = %159, %135
  %141 = load i32* %j, align 4
  %142 = load i32* %i, align 4
  %143 = icmp slt i32 %141, %142
  br i1 %143, label %144, label %162

; <label>:144                                     ; preds = %140
  %145 = load i32* %j, align 4
  %146 = sext i32 %145 to i64
  %147 = load i32* %i, align 4
  %148 = sext i32 %147 to i64
  %149 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %148
  %150 = getelementptr inbounds [50 x i64]* %149, i32 0, i64 %146
  %151 = load i64* %150, align 8
  %152 = load i32* %j, align 4
  %153 = sext i32 %152 to i64
  %154 = getelementptr inbounds [100 x i64]* %y, i32 0, i64 %153
  %155 = load i64* %154, align 8
  %156 = mul nsw i64 %151, %155
  %157 = load i64* %w, align 8
  %158 = sub nsw i64 %157, %156
  store i64 %158, i64* %w, align 8
  br label %159

; <label>:159                                     ; preds = %144
  %160 = load i32* %j, align 4
  %161 = add nsw i32 %160, 1
  store i32 %161, i32* %j, align 4
  br label %140

; <label>:162                                     ; preds = %140
  %163 = load i64* %w, align 8
  %164 = load i32* %i, align 4
  %165 = sext i32 %164 to i64
  %166 = getelementptr inbounds [100 x i64]* %y, i32 0, i64 %165
  store i64 %163, i64* %166, align 8
  br label %167

; <label>:167                                     ; preds = %162
  %168 = load i32* %i, align 4
  %169 = add nsw i32 %168, 1
  store i32 %169, i32* %i, align 4
  br label %131

; <label>:170                                     ; preds = %131
  %171 = load i32* %2, align 4
  %172 = sext i32 %171 to i64
  %173 = getelementptr inbounds [100 x i64]* %y, i32 0, i64 %172
  %174 = load i64* %173, align 8
  %175 = load i32* %2, align 4
  %176 = sext i32 %175 to i64
  %177 = load i32* %2, align 4
  %178 = sext i32 %177 to i64
  %179 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %178
  %180 = getelementptr inbounds [50 x i64]* %179, i32 0, i64 %176
  %181 = load i64* %180, align 8
  %182 = sdiv i64 %174, %181
  %183 = load i32* %2, align 4
  %184 = sext i32 %183 to i64
  %185 = getelementptr inbounds [50 x i64]* @x, i32 0, i64 %184
  store i64 %182, i64* %185, align 8
  %186 = load i32* %2, align 4
  %187 = sub nsw i32 %186, 1
  store i32 %187, i32* %i, align 4
  br label %188

; <label>:188                                     ; preds = %233, %170
  %189 = load i32* %i, align 4
  %190 = icmp sge i32 %189, 0
  br i1 %190, label %191, label %236

; <label>:191                                     ; preds = %188
  %192 = load i32* %i, align 4
  %193 = sext i32 %192 to i64
  %194 = getelementptr inbounds [100 x i64]* %y, i32 0, i64 %193
  %195 = load i64* %194, align 8
  store i64 %195, i64* %w, align 8
  %196 = load i32* %i, align 4
  %197 = add nsw i32 %196, 1
  store i32 %197, i32* %j, align 4
  br label %198

; <label>:198                                     ; preds = %217, %191
  %199 = load i32* %j, align 4
  %200 = load i32* %2, align 4
  %201 = icmp sle i32 %199, %200
  br i1 %201, label %202, label %220

; <label>:202                                     ; preds = %198
  %203 = load i32* %j, align 4
  %204 = sext i32 %203 to i64
  %205 = load i32* %i, align 4
  %206 = sext i32 %205 to i64
  %207 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %206
  %208 = getelementptr inbounds [50 x i64]* %207, i32 0, i64 %204
  %209 = load i64* %208, align 8
  %210 = load i32* %j, align 4
  %211 = sext i32 %210 to i64
  %212 = getelementptr inbounds [50 x i64]* @x, i32 0, i64 %211
  %213 = load i64* %212, align 8
  %214 = mul nsw i64 %209, %213
  %215 = load i64* %w, align 8
  %216 = sub nsw i64 %215, %214
  store i64 %216, i64* %w, align 8
  br label %217

; <label>:217                                     ; preds = %202
  %218 = load i32* %j, align 4
  %219 = add nsw i32 %218, 1
  store i32 %219, i32* %j, align 4
  br label %198

; <label>:220                                     ; preds = %198
  %221 = load i64* %w, align 8
  %222 = load i32* %i, align 4
  %223 = sext i32 %222 to i64
  %224 = load i32* %i, align 4
  %225 = sext i32 %224 to i64
  %226 = getelementptr inbounds [50 x [50 x i64]]* @a, i32 0, i64 %225
  %227 = getelementptr inbounds [50 x i64]* %226, i32 0, i64 %223
  %228 = load i64* %227, align 8
  %229 = sdiv i64 %221, %228
  %230 = load i32* %i, align 4
  %231 = sext i32 %230 to i64
  %232 = getelementptr inbounds [50 x i64]* @x, i32 0, i64 %231
  store i64 %229, i64* %232, align 8
  br label %233

; <label>:233                                     ; preds = %220
  %234 = load i32* %i, align 4
  %235 = add nsw i32 %234, -1
  store i32 %235, i32* %i, align 4
  br label %188

; <label>:236                                     ; preds = %188
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
