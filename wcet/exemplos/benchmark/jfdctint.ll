; ModuleID = 'jfdctint.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@data = common global [64 x i32] zeroinitializer, align 16

; Function Attrs: nounwind uwtable
define void @jpeg_fdct_islow() #0 {
  %tmp0 = alloca i32, align 4
  %tmp1 = alloca i32, align 4
  %tmp2 = alloca i32, align 4
  %tmp3 = alloca i32, align 4
  %tmp4 = alloca i32, align 4
  %tmp5 = alloca i32, align 4
  %tmp6 = alloca i32, align 4
  %tmp7 = alloca i32, align 4
  %tmp10 = alloca i32, align 4
  %tmp11 = alloca i32, align 4
  %tmp12 = alloca i32, align 4
  %tmp13 = alloca i32, align 4
  %z1 = alloca i32, align 4
  %z2 = alloca i32, align 4
  %z3 = alloca i32, align 4
  %z4 = alloca i32, align 4
  %z5 = alloca i32, align 4
  %dataptr = alloca i32*, align 8
  %ctr = alloca i32, align 4
  store i32* getelementptr inbounds ([64 x i32]* @data, i32 0, i32 0), i32** %dataptr, align 8
  store i32 7, i32* %ctr, align 4
  br label %1

; <label>:1                                       ; preds = %181, %0
  %2 = load i32* %ctr, align 4
  %3 = icmp sge i32 %2, 0
  br i1 %3, label %4, label %184

; <label>:4                                       ; preds = %1
  %5 = load i32** %dataptr, align 8
  %6 = getelementptr inbounds i32* %5, i64 0
  %7 = load i32* %6, align 4
  %8 = load i32** %dataptr, align 8
  %9 = getelementptr inbounds i32* %8, i64 7
  %10 = load i32* %9, align 4
  %11 = add nsw i32 %7, %10
  store i32 %11, i32* %tmp0, align 4
  %12 = load i32** %dataptr, align 8
  %13 = getelementptr inbounds i32* %12, i64 0
  %14 = load i32* %13, align 4
  %15 = load i32** %dataptr, align 8
  %16 = getelementptr inbounds i32* %15, i64 7
  %17 = load i32* %16, align 4
  %18 = sub nsw i32 %14, %17
  store i32 %18, i32* %tmp7, align 4
  %19 = load i32** %dataptr, align 8
  %20 = getelementptr inbounds i32* %19, i64 1
  %21 = load i32* %20, align 4
  %22 = load i32** %dataptr, align 8
  %23 = getelementptr inbounds i32* %22, i64 6
  %24 = load i32* %23, align 4
  %25 = add nsw i32 %21, %24
  store i32 %25, i32* %tmp1, align 4
  %26 = load i32** %dataptr, align 8
  %27 = getelementptr inbounds i32* %26, i64 1
  %28 = load i32* %27, align 4
  %29 = load i32** %dataptr, align 8
  %30 = getelementptr inbounds i32* %29, i64 6
  %31 = load i32* %30, align 4
  %32 = sub nsw i32 %28, %31
  store i32 %32, i32* %tmp6, align 4
  %33 = load i32** %dataptr, align 8
  %34 = getelementptr inbounds i32* %33, i64 2
  %35 = load i32* %34, align 4
  %36 = load i32** %dataptr, align 8
  %37 = getelementptr inbounds i32* %36, i64 5
  %38 = load i32* %37, align 4
  %39 = add nsw i32 %35, %38
  store i32 %39, i32* %tmp2, align 4
  %40 = load i32** %dataptr, align 8
  %41 = getelementptr inbounds i32* %40, i64 2
  %42 = load i32* %41, align 4
  %43 = load i32** %dataptr, align 8
  %44 = getelementptr inbounds i32* %43, i64 5
  %45 = load i32* %44, align 4
  %46 = sub nsw i32 %42, %45
  store i32 %46, i32* %tmp5, align 4
  %47 = load i32** %dataptr, align 8
  %48 = getelementptr inbounds i32* %47, i64 3
  %49 = load i32* %48, align 4
  %50 = load i32** %dataptr, align 8
  %51 = getelementptr inbounds i32* %50, i64 4
  %52 = load i32* %51, align 4
  %53 = add nsw i32 %49, %52
  store i32 %53, i32* %tmp3, align 4
  %54 = load i32** %dataptr, align 8
  %55 = getelementptr inbounds i32* %54, i64 3
  %56 = load i32* %55, align 4
  %57 = load i32** %dataptr, align 8
  %58 = getelementptr inbounds i32* %57, i64 4
  %59 = load i32* %58, align 4
  %60 = sub nsw i32 %56, %59
  store i32 %60, i32* %tmp4, align 4
  %61 = load i32* %tmp0, align 4
  %62 = load i32* %tmp3, align 4
  %63 = add nsw i32 %61, %62
  store i32 %63, i32* %tmp10, align 4
  %64 = load i32* %tmp0, align 4
  %65 = load i32* %tmp3, align 4
  %66 = sub nsw i32 %64, %65
  store i32 %66, i32* %tmp13, align 4
  %67 = load i32* %tmp1, align 4
  %68 = load i32* %tmp2, align 4
  %69 = add nsw i32 %67, %68
  store i32 %69, i32* %tmp11, align 4
  %70 = load i32* %tmp1, align 4
  %71 = load i32* %tmp2, align 4
  %72 = sub nsw i32 %70, %71
  store i32 %72, i32* %tmp12, align 4
  %73 = load i32* %tmp10, align 4
  %74 = load i32* %tmp11, align 4
  %75 = add nsw i32 %73, %74
  %76 = shl i32 %75, 2
  %77 = load i32** %dataptr, align 8
  %78 = getelementptr inbounds i32* %77, i64 0
  store i32 %76, i32* %78, align 4
  %79 = load i32* %tmp10, align 4
  %80 = load i32* %tmp11, align 4
  %81 = sub nsw i32 %79, %80
  %82 = shl i32 %81, 2
  %83 = load i32** %dataptr, align 8
  %84 = getelementptr inbounds i32* %83, i64 4
  store i32 %82, i32* %84, align 4
  %85 = load i32* %tmp12, align 4
  %86 = load i32* %tmp13, align 4
  %87 = add nsw i32 %85, %86
  %88 = mul nsw i32 %87, 4433
  store i32 %88, i32* %z1, align 4
  %89 = load i32* %z1, align 4
  %90 = load i32* %tmp13, align 4
  %91 = mul nsw i32 %90, 6270
  %92 = add nsw i32 %89, %91
  %93 = add nsw i32 %92, 1024
  %94 = ashr i32 %93, 11
  %95 = load i32** %dataptr, align 8
  %96 = getelementptr inbounds i32* %95, i64 2
  store i32 %94, i32* %96, align 4
  %97 = load i32* %z1, align 4
  %98 = load i32* %tmp12, align 4
  %99 = mul nsw i32 %98, -15137
  %100 = add nsw i32 %97, %99
  %101 = add nsw i32 %100, 1024
  %102 = ashr i32 %101, 11
  %103 = load i32** %dataptr, align 8
  %104 = getelementptr inbounds i32* %103, i64 6
  store i32 %102, i32* %104, align 4
  %105 = load i32* %tmp4, align 4
  %106 = load i32* %tmp7, align 4
  %107 = add nsw i32 %105, %106
  store i32 %107, i32* %z1, align 4
  %108 = load i32* %tmp5, align 4
  %109 = load i32* %tmp6, align 4
  %110 = add nsw i32 %108, %109
  store i32 %110, i32* %z2, align 4
  %111 = load i32* %tmp4, align 4
  %112 = load i32* %tmp6, align 4
  %113 = add nsw i32 %111, %112
  store i32 %113, i32* %z3, align 4
  %114 = load i32* %tmp5, align 4
  %115 = load i32* %tmp7, align 4
  %116 = add nsw i32 %114, %115
  store i32 %116, i32* %z4, align 4
  %117 = load i32* %z3, align 4
  %118 = load i32* %z4, align 4
  %119 = add nsw i32 %117, %118
  %120 = mul nsw i32 %119, 9633
  store i32 %120, i32* %z5, align 4
  %121 = load i32* %tmp4, align 4
  %122 = mul nsw i32 %121, 2446
  store i32 %122, i32* %tmp4, align 4
  %123 = load i32* %tmp5, align 4
  %124 = mul nsw i32 %123, 16819
  store i32 %124, i32* %tmp5, align 4
  %125 = load i32* %tmp6, align 4
  %126 = mul nsw i32 %125, 25172
  store i32 %126, i32* %tmp6, align 4
  %127 = load i32* %tmp7, align 4
  %128 = mul nsw i32 %127, 12299
  store i32 %128, i32* %tmp7, align 4
  %129 = load i32* %z1, align 4
  %130 = mul nsw i32 %129, -7373
  store i32 %130, i32* %z1, align 4
  %131 = load i32* %z2, align 4
  %132 = mul nsw i32 %131, -20995
  store i32 %132, i32* %z2, align 4
  %133 = load i32* %z3, align 4
  %134 = mul nsw i32 %133, -16069
  store i32 %134, i32* %z3, align 4
  %135 = load i32* %z4, align 4
  %136 = mul nsw i32 %135, -3196
  store i32 %136, i32* %z4, align 4
  %137 = load i32* %z5, align 4
  %138 = load i32* %z3, align 4
  %139 = add nsw i32 %138, %137
  store i32 %139, i32* %z3, align 4
  %140 = load i32* %z5, align 4
  %141 = load i32* %z4, align 4
  %142 = add nsw i32 %141, %140
  store i32 %142, i32* %z4, align 4
  %143 = load i32* %tmp4, align 4
  %144 = load i32* %z1, align 4
  %145 = add nsw i32 %143, %144
  %146 = load i32* %z3, align 4
  %147 = add nsw i32 %145, %146
  %148 = add nsw i32 %147, 1024
  %149 = ashr i32 %148, 11
  %150 = load i32** %dataptr, align 8
  %151 = getelementptr inbounds i32* %150, i64 7
  store i32 %149, i32* %151, align 4
  %152 = load i32* %tmp5, align 4
  %153 = load i32* %z2, align 4
  %154 = add nsw i32 %152, %153
  %155 = load i32* %z4, align 4
  %156 = add nsw i32 %154, %155
  %157 = add nsw i32 %156, 1024
  %158 = ashr i32 %157, 11
  %159 = load i32** %dataptr, align 8
  %160 = getelementptr inbounds i32* %159, i64 5
  store i32 %158, i32* %160, align 4
  %161 = load i32* %tmp6, align 4
  %162 = load i32* %z2, align 4
  %163 = add nsw i32 %161, %162
  %164 = load i32* %z3, align 4
  %165 = add nsw i32 %163, %164
  %166 = add nsw i32 %165, 1024
  %167 = ashr i32 %166, 11
  %168 = load i32** %dataptr, align 8
  %169 = getelementptr inbounds i32* %168, i64 3
  store i32 %167, i32* %169, align 4
  %170 = load i32* %tmp7, align 4
  %171 = load i32* %z1, align 4
  %172 = add nsw i32 %170, %171
  %173 = load i32* %z4, align 4
  %174 = add nsw i32 %172, %173
  %175 = add nsw i32 %174, 1024
  %176 = ashr i32 %175, 11
  %177 = load i32** %dataptr, align 8
  %178 = getelementptr inbounds i32* %177, i64 1
  store i32 %176, i32* %178, align 4
  %179 = load i32** %dataptr, align 8
  %180 = getelementptr inbounds i32* %179, i64 8
  store i32* %180, i32** %dataptr, align 8
  br label %181

; <label>:181                                     ; preds = %4
  %182 = load i32* %ctr, align 4
  %183 = add nsw i32 %182, -1
  store i32 %183, i32* %ctr, align 4
  br label %1

; <label>:184                                     ; preds = %1
  store i32* getelementptr inbounds ([64 x i32]* @data, i32 0, i32 0), i32** %dataptr, align 8
  store i32 7, i32* %ctr, align 4
  br label %185

; <label>:185                                     ; preds = %367, %184
  %186 = load i32* %ctr, align 4
  %187 = icmp sge i32 %186, 0
  br i1 %187, label %188, label %370

; <label>:188                                     ; preds = %185
  %189 = load i32** %dataptr, align 8
  %190 = getelementptr inbounds i32* %189, i64 0
  %191 = load i32* %190, align 4
  %192 = load i32** %dataptr, align 8
  %193 = getelementptr inbounds i32* %192, i64 56
  %194 = load i32* %193, align 4
  %195 = add nsw i32 %191, %194
  store i32 %195, i32* %tmp0, align 4
  %196 = load i32** %dataptr, align 8
  %197 = getelementptr inbounds i32* %196, i64 0
  %198 = load i32* %197, align 4
  %199 = load i32** %dataptr, align 8
  %200 = getelementptr inbounds i32* %199, i64 56
  %201 = load i32* %200, align 4
  %202 = sub nsw i32 %198, %201
  store i32 %202, i32* %tmp7, align 4
  %203 = load i32** %dataptr, align 8
  %204 = getelementptr inbounds i32* %203, i64 8
  %205 = load i32* %204, align 4
  %206 = load i32** %dataptr, align 8
  %207 = getelementptr inbounds i32* %206, i64 48
  %208 = load i32* %207, align 4
  %209 = add nsw i32 %205, %208
  store i32 %209, i32* %tmp1, align 4
  %210 = load i32** %dataptr, align 8
  %211 = getelementptr inbounds i32* %210, i64 8
  %212 = load i32* %211, align 4
  %213 = load i32** %dataptr, align 8
  %214 = getelementptr inbounds i32* %213, i64 48
  %215 = load i32* %214, align 4
  %216 = sub nsw i32 %212, %215
  store i32 %216, i32* %tmp6, align 4
  %217 = load i32** %dataptr, align 8
  %218 = getelementptr inbounds i32* %217, i64 16
  %219 = load i32* %218, align 4
  %220 = load i32** %dataptr, align 8
  %221 = getelementptr inbounds i32* %220, i64 40
  %222 = load i32* %221, align 4
  %223 = add nsw i32 %219, %222
  store i32 %223, i32* %tmp2, align 4
  %224 = load i32** %dataptr, align 8
  %225 = getelementptr inbounds i32* %224, i64 16
  %226 = load i32* %225, align 4
  %227 = load i32** %dataptr, align 8
  %228 = getelementptr inbounds i32* %227, i64 40
  %229 = load i32* %228, align 4
  %230 = sub nsw i32 %226, %229
  store i32 %230, i32* %tmp5, align 4
  %231 = load i32** %dataptr, align 8
  %232 = getelementptr inbounds i32* %231, i64 24
  %233 = load i32* %232, align 4
  %234 = load i32** %dataptr, align 8
  %235 = getelementptr inbounds i32* %234, i64 32
  %236 = load i32* %235, align 4
  %237 = add nsw i32 %233, %236
  store i32 %237, i32* %tmp3, align 4
  %238 = load i32** %dataptr, align 8
  %239 = getelementptr inbounds i32* %238, i64 24
  %240 = load i32* %239, align 4
  %241 = load i32** %dataptr, align 8
  %242 = getelementptr inbounds i32* %241, i64 32
  %243 = load i32* %242, align 4
  %244 = sub nsw i32 %240, %243
  store i32 %244, i32* %tmp4, align 4
  %245 = load i32* %tmp0, align 4
  %246 = load i32* %tmp3, align 4
  %247 = add nsw i32 %245, %246
  store i32 %247, i32* %tmp10, align 4
  %248 = load i32* %tmp0, align 4
  %249 = load i32* %tmp3, align 4
  %250 = sub nsw i32 %248, %249
  store i32 %250, i32* %tmp13, align 4
  %251 = load i32* %tmp1, align 4
  %252 = load i32* %tmp2, align 4
  %253 = add nsw i32 %251, %252
  store i32 %253, i32* %tmp11, align 4
  %254 = load i32* %tmp1, align 4
  %255 = load i32* %tmp2, align 4
  %256 = sub nsw i32 %254, %255
  store i32 %256, i32* %tmp12, align 4
  %257 = load i32* %tmp10, align 4
  %258 = load i32* %tmp11, align 4
  %259 = add nsw i32 %257, %258
  %260 = add nsw i32 %259, 2
  %261 = ashr i32 %260, 2
  %262 = load i32** %dataptr, align 8
  %263 = getelementptr inbounds i32* %262, i64 0
  store i32 %261, i32* %263, align 4
  %264 = load i32* %tmp10, align 4
  %265 = load i32* %tmp11, align 4
  %266 = sub nsw i32 %264, %265
  %267 = add nsw i32 %266, 2
  %268 = ashr i32 %267, 2
  %269 = load i32** %dataptr, align 8
  %270 = getelementptr inbounds i32* %269, i64 32
  store i32 %268, i32* %270, align 4
  %271 = load i32* %tmp12, align 4
  %272 = load i32* %tmp13, align 4
  %273 = add nsw i32 %271, %272
  %274 = mul nsw i32 %273, 4433
  store i32 %274, i32* %z1, align 4
  %275 = load i32* %z1, align 4
  %276 = load i32* %tmp13, align 4
  %277 = mul nsw i32 %276, 6270
  %278 = add nsw i32 %275, %277
  %279 = add nsw i32 %278, 16384
  %280 = ashr i32 %279, 15
  %281 = load i32** %dataptr, align 8
  %282 = getelementptr inbounds i32* %281, i64 16
  store i32 %280, i32* %282, align 4
  %283 = load i32* %z1, align 4
  %284 = load i32* %tmp12, align 4
  %285 = mul nsw i32 %284, -15137
  %286 = add nsw i32 %283, %285
  %287 = add nsw i32 %286, 16384
  %288 = ashr i32 %287, 15
  %289 = load i32** %dataptr, align 8
  %290 = getelementptr inbounds i32* %289, i64 48
  store i32 %288, i32* %290, align 4
  %291 = load i32* %tmp4, align 4
  %292 = load i32* %tmp7, align 4
  %293 = add nsw i32 %291, %292
  store i32 %293, i32* %z1, align 4
  %294 = load i32* %tmp5, align 4
  %295 = load i32* %tmp6, align 4
  %296 = add nsw i32 %294, %295
  store i32 %296, i32* %z2, align 4
  %297 = load i32* %tmp4, align 4
  %298 = load i32* %tmp6, align 4
  %299 = add nsw i32 %297, %298
  store i32 %299, i32* %z3, align 4
  %300 = load i32* %tmp5, align 4
  %301 = load i32* %tmp7, align 4
  %302 = add nsw i32 %300, %301
  store i32 %302, i32* %z4, align 4
  %303 = load i32* %z3, align 4
  %304 = load i32* %z4, align 4
  %305 = add nsw i32 %303, %304
  %306 = mul nsw i32 %305, 9633
  store i32 %306, i32* %z5, align 4
  %307 = load i32* %tmp4, align 4
  %308 = mul nsw i32 %307, 2446
  store i32 %308, i32* %tmp4, align 4
  %309 = load i32* %tmp5, align 4
  %310 = mul nsw i32 %309, 16819
  store i32 %310, i32* %tmp5, align 4
  %311 = load i32* %tmp6, align 4
  %312 = mul nsw i32 %311, 25172
  store i32 %312, i32* %tmp6, align 4
  %313 = load i32* %tmp7, align 4
  %314 = mul nsw i32 %313, 12299
  store i32 %314, i32* %tmp7, align 4
  %315 = load i32* %z1, align 4
  %316 = mul nsw i32 %315, -7373
  store i32 %316, i32* %z1, align 4
  %317 = load i32* %z2, align 4
  %318 = mul nsw i32 %317, -20995
  store i32 %318, i32* %z2, align 4
  %319 = load i32* %z3, align 4
  %320 = mul nsw i32 %319, -16069
  store i32 %320, i32* %z3, align 4
  %321 = load i32* %z4, align 4
  %322 = mul nsw i32 %321, -3196
  store i32 %322, i32* %z4, align 4
  %323 = load i32* %z5, align 4
  %324 = load i32* %z3, align 4
  %325 = add nsw i32 %324, %323
  store i32 %325, i32* %z3, align 4
  %326 = load i32* %z5, align 4
  %327 = load i32* %z4, align 4
  %328 = add nsw i32 %327, %326
  store i32 %328, i32* %z4, align 4
  %329 = load i32* %tmp4, align 4
  %330 = load i32* %z1, align 4
  %331 = add nsw i32 %329, %330
  %332 = load i32* %z3, align 4
  %333 = add nsw i32 %331, %332
  %334 = add nsw i32 %333, 16384
  %335 = ashr i32 %334, 15
  %336 = load i32** %dataptr, align 8
  %337 = getelementptr inbounds i32* %336, i64 56
  store i32 %335, i32* %337, align 4
  %338 = load i32* %tmp5, align 4
  %339 = load i32* %z2, align 4
  %340 = add nsw i32 %338, %339
  %341 = load i32* %z4, align 4
  %342 = add nsw i32 %340, %341
  %343 = add nsw i32 %342, 16384
  %344 = ashr i32 %343, 15
  %345 = load i32** %dataptr, align 8
  %346 = getelementptr inbounds i32* %345, i64 40
  store i32 %344, i32* %346, align 4
  %347 = load i32* %tmp6, align 4
  %348 = load i32* %z2, align 4
  %349 = add nsw i32 %347, %348
  %350 = load i32* %z3, align 4
  %351 = add nsw i32 %349, %350
  %352 = add nsw i32 %351, 16384
  %353 = ashr i32 %352, 15
  %354 = load i32** %dataptr, align 8
  %355 = getelementptr inbounds i32* %354, i64 24
  store i32 %353, i32* %355, align 4
  %356 = load i32* %tmp7, align 4
  %357 = load i32* %z1, align 4
  %358 = add nsw i32 %356, %357
  %359 = load i32* %z4, align 4
  %360 = add nsw i32 %358, %359
  %361 = add nsw i32 %360, 16384
  %362 = ashr i32 %361, 15
  %363 = load i32** %dataptr, align 8
  %364 = getelementptr inbounds i32* %363, i64 8
  store i32 %362, i32* %364, align 4
  %365 = load i32** %dataptr, align 8
  %366 = getelementptr inbounds i32* %365, i32 1
  store i32* %366, i32** %dataptr, align 8
  br label %367

; <label>:367                                     ; preds = %188
  %368 = load i32* %ctr, align 4
  %369 = add nsw i32 %368, -1
  store i32 %369, i32* %ctr, align 4
  br label %185

; <label>:370                                     ; preds = %185
  ret void
}

; Function Attrs: nounwind uwtable
define void @main() #0 {
  %i = alloca i32, align 4
  %seed = alloca i32, align 4
  store i32 1, i32* %seed, align 4
  store i32 0, i32* %i, align 4
  br label %1

; <label>:1                                       ; preds = %13, %0
  %2 = load i32* %i, align 4
  %3 = icmp slt i32 %2, 64
  br i1 %3, label %4, label %16

; <label>:4                                       ; preds = %1
  %5 = load i32* %seed, align 4
  %6 = mul nsw i32 %5, 133
  %7 = add nsw i32 %6, 81
  %8 = srem i32 %7, 65535
  store i32 %8, i32* %seed, align 4
  %9 = load i32* %seed, align 4
  %10 = load i32* %i, align 4
  %11 = sext i32 %10 to i64
  %12 = getelementptr inbounds [64 x i32]* @data, i32 0, i64 %11
  store i32 %9, i32* %12, align 4
  br label %13

; <label>:13                                      ; preds = %4
  %14 = load i32* %i, align 4
  %15 = add nsw i32 %14, 1
  store i32 %15, i32* %i, align 4
  br label %1

; <label>:16                                      ; preds = %1
  call void @jpeg_fdct_islow()
  ret void
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
