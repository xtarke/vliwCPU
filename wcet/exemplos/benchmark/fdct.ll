; ModuleID = 'fdct.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@block = global [64 x i16] [i16 99, i16 104, i16 109, i16 113, i16 115, i16 115, i16 55, i16 55, i16 104, i16 111, i16 113, i16 116, i16 119, i16 56, i16 56, i16 56, i16 110, i16 115, i16 120, i16 119, i16 118, i16 56, i16 56, i16 56, i16 119, i16 121, i16 122, i16 120, i16 120, i16 59, i16 59, i16 59, i16 119, i16 120, i16 121, i16 122, i16 122, i16 55, i16 55, i16 55, i16 121, i16 121, i16 121, i16 121, i16 60, i16 57, i16 57, i16 57, i16 122, i16 122, i16 61, i16 63, i16 62, i16 57, i16 57, i16 57, i16 62, i16 62, i16 61, i16 61, i16 63, i16 58, i16 58, i16 58], align 16
@out = common global i32 0, align 4

; Function Attrs: nounwind uwtable
define void @fdct(i16* %blk, i32 %lx) #0 {
  %1 = alloca i16*, align 8
  %2 = alloca i32, align 4
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
  %i = alloca i32, align 4
  %block = alloca i16*, align 8
  %constant = alloca i32, align 4
  store i16* %blk, i16** %1, align 8
  store i32 %lx, i32* %2, align 4
  %3 = load i16** %1, align 8
  store i16* %3, i16** %block, align 8
  store i32 0, i32* %i, align 4
  br label %4

; <label>:4                                       ; preds = %216, %0
  %5 = load i32* %i, align 4
  %6 = icmp slt i32 %5, 8
  br i1 %6, label %7, label %219

; <label>:7                                       ; preds = %4
  %8 = load i16** %block, align 8
  %9 = getelementptr inbounds i16* %8, i64 0
  %10 = load i16* %9, align 2
  %11 = sext i16 %10 to i32
  %12 = load i16** %block, align 8
  %13 = getelementptr inbounds i16* %12, i64 7
  %14 = load i16* %13, align 2
  %15 = sext i16 %14 to i32
  %16 = add nsw i32 %11, %15
  store i32 %16, i32* %tmp0, align 4
  %17 = load i16** %block, align 8
  %18 = getelementptr inbounds i16* %17, i64 0
  %19 = load i16* %18, align 2
  %20 = sext i16 %19 to i32
  %21 = load i16** %block, align 8
  %22 = getelementptr inbounds i16* %21, i64 7
  %23 = load i16* %22, align 2
  %24 = sext i16 %23 to i32
  %25 = sub nsw i32 %20, %24
  store i32 %25, i32* %tmp7, align 4
  %26 = load i16** %block, align 8
  %27 = getelementptr inbounds i16* %26, i64 1
  %28 = load i16* %27, align 2
  %29 = sext i16 %28 to i32
  %30 = load i16** %block, align 8
  %31 = getelementptr inbounds i16* %30, i64 6
  %32 = load i16* %31, align 2
  %33 = sext i16 %32 to i32
  %34 = add nsw i32 %29, %33
  store i32 %34, i32* %tmp1, align 4
  %35 = load i16** %block, align 8
  %36 = getelementptr inbounds i16* %35, i64 1
  %37 = load i16* %36, align 2
  %38 = sext i16 %37 to i32
  %39 = load i16** %block, align 8
  %40 = getelementptr inbounds i16* %39, i64 6
  %41 = load i16* %40, align 2
  %42 = sext i16 %41 to i32
  %43 = sub nsw i32 %38, %42
  store i32 %43, i32* %tmp6, align 4
  %44 = load i16** %block, align 8
  %45 = getelementptr inbounds i16* %44, i64 2
  %46 = load i16* %45, align 2
  %47 = sext i16 %46 to i32
  %48 = load i16** %block, align 8
  %49 = getelementptr inbounds i16* %48, i64 5
  %50 = load i16* %49, align 2
  %51 = sext i16 %50 to i32
  %52 = add nsw i32 %47, %51
  store i32 %52, i32* %tmp2, align 4
  %53 = load i16** %block, align 8
  %54 = getelementptr inbounds i16* %53, i64 2
  %55 = load i16* %54, align 2
  %56 = sext i16 %55 to i32
  %57 = load i16** %block, align 8
  %58 = getelementptr inbounds i16* %57, i64 5
  %59 = load i16* %58, align 2
  %60 = sext i16 %59 to i32
  %61 = sub nsw i32 %56, %60
  store i32 %61, i32* %tmp5, align 4
  %62 = load i16** %block, align 8
  %63 = getelementptr inbounds i16* %62, i64 3
  %64 = load i16* %63, align 2
  %65 = sext i16 %64 to i32
  %66 = load i16** %block, align 8
  %67 = getelementptr inbounds i16* %66, i64 4
  %68 = load i16* %67, align 2
  %69 = sext i16 %68 to i32
  %70 = add nsw i32 %65, %69
  store i32 %70, i32* %tmp3, align 4
  %71 = load i16** %block, align 8
  %72 = getelementptr inbounds i16* %71, i64 3
  %73 = load i16* %72, align 2
  %74 = sext i16 %73 to i32
  %75 = load i16** %block, align 8
  %76 = getelementptr inbounds i16* %75, i64 4
  %77 = load i16* %76, align 2
  %78 = sext i16 %77 to i32
  %79 = sub nsw i32 %74, %78
  store i32 %79, i32* %tmp4, align 4
  %80 = load i32* %tmp0, align 4
  %81 = load i32* %tmp3, align 4
  %82 = add nsw i32 %80, %81
  store i32 %82, i32* %tmp10, align 4
  %83 = load i32* %tmp0, align 4
  %84 = load i32* %tmp3, align 4
  %85 = sub nsw i32 %83, %84
  store i32 %85, i32* %tmp13, align 4
  %86 = load i32* %tmp1, align 4
  %87 = load i32* %tmp2, align 4
  %88 = add nsw i32 %86, %87
  store i32 %88, i32* %tmp11, align 4
  %89 = load i32* %tmp1, align 4
  %90 = load i32* %tmp2, align 4
  %91 = sub nsw i32 %89, %90
  store i32 %91, i32* %tmp12, align 4
  %92 = load i32* %tmp10, align 4
  %93 = load i32* %tmp11, align 4
  %94 = add nsw i32 %92, %93
  %95 = shl i32 %94, 2
  %96 = trunc i32 %95 to i16
  %97 = load i16** %block, align 8
  %98 = getelementptr inbounds i16* %97, i64 0
  store i16 %96, i16* %98, align 2
  %99 = load i32* %tmp10, align 4
  %100 = load i32* %tmp11, align 4
  %101 = sub nsw i32 %99, %100
  %102 = shl i32 %101, 2
  %103 = trunc i32 %102 to i16
  %104 = load i16** %block, align 8
  %105 = getelementptr inbounds i16* %104, i64 4
  store i16 %103, i16* %105, align 2
  store i32 4433, i32* %constant, align 4
  %106 = load i32* %tmp12, align 4
  %107 = load i32* %tmp13, align 4
  %108 = add nsw i32 %106, %107
  %109 = load i32* %constant, align 4
  %110 = mul nsw i32 %108, %109
  store i32 %110, i32* %z1, align 4
  store i32 6270, i32* %constant, align 4
  %111 = load i32* %z1, align 4
  %112 = load i32* %tmp13, align 4
  %113 = load i32* %constant, align 4
  %114 = mul nsw i32 %112, %113
  %115 = add nsw i32 %111, %114
  %116 = ashr i32 %115, 11
  %117 = trunc i32 %116 to i16
  %118 = load i16** %block, align 8
  %119 = getelementptr inbounds i16* %118, i64 2
  store i16 %117, i16* %119, align 2
  store i32 -15137, i32* %constant, align 4
  %120 = load i32* %z1, align 4
  %121 = load i32* %tmp12, align 4
  %122 = load i32* %constant, align 4
  %123 = mul nsw i32 %121, %122
  %124 = add nsw i32 %120, %123
  %125 = ashr i32 %124, 11
  %126 = trunc i32 %125 to i16
  %127 = load i16** %block, align 8
  %128 = getelementptr inbounds i16* %127, i64 6
  store i16 %126, i16* %128, align 2
  %129 = load i32* %tmp4, align 4
  %130 = load i32* %tmp7, align 4
  %131 = add nsw i32 %129, %130
  store i32 %131, i32* %z1, align 4
  %132 = load i32* %tmp5, align 4
  %133 = load i32* %tmp6, align 4
  %134 = add nsw i32 %132, %133
  store i32 %134, i32* %z2, align 4
  %135 = load i32* %tmp4, align 4
  %136 = load i32* %tmp6, align 4
  %137 = add nsw i32 %135, %136
  store i32 %137, i32* %z3, align 4
  %138 = load i32* %tmp5, align 4
  %139 = load i32* %tmp7, align 4
  %140 = add nsw i32 %138, %139
  store i32 %140, i32* %z4, align 4
  store i32 9633, i32* %constant, align 4
  %141 = load i32* %z3, align 4
  %142 = load i32* %z4, align 4
  %143 = add nsw i32 %141, %142
  %144 = load i32* %constant, align 4
  %145 = mul nsw i32 %143, %144
  store i32 %145, i32* %z5, align 4
  store i32 2446, i32* %constant, align 4
  %146 = load i32* %tmp4, align 4
  %147 = load i32* %constant, align 4
  %148 = mul nsw i32 %146, %147
  store i32 %148, i32* %tmp4, align 4
  store i32 16819, i32* %constant, align 4
  %149 = load i32* %tmp5, align 4
  %150 = load i32* %constant, align 4
  %151 = mul nsw i32 %149, %150
  store i32 %151, i32* %tmp5, align 4
  store i32 25172, i32* %constant, align 4
  %152 = load i32* %tmp6, align 4
  %153 = load i32* %constant, align 4
  %154 = mul nsw i32 %152, %153
  store i32 %154, i32* %tmp6, align 4
  store i32 12299, i32* %constant, align 4
  %155 = load i32* %tmp7, align 4
  %156 = load i32* %constant, align 4
  %157 = mul nsw i32 %155, %156
  store i32 %157, i32* %tmp7, align 4
  store i32 -7373, i32* %constant, align 4
  %158 = load i32* %z1, align 4
  %159 = load i32* %constant, align 4
  %160 = mul nsw i32 %158, %159
  store i32 %160, i32* %z1, align 4
  store i32 -20995, i32* %constant, align 4
  %161 = load i32* %z2, align 4
  %162 = load i32* %constant, align 4
  %163 = mul nsw i32 %161, %162
  store i32 %163, i32* %z2, align 4
  store i32 -16069, i32* %constant, align 4
  %164 = load i32* %z3, align 4
  %165 = load i32* %constant, align 4
  %166 = mul nsw i32 %164, %165
  store i32 %166, i32* %z3, align 4
  store i32 -3196, i32* %constant, align 4
  %167 = load i32* %z4, align 4
  %168 = load i32* %constant, align 4
  %169 = mul nsw i32 %167, %168
  store i32 %169, i32* %z4, align 4
  %170 = load i32* %z5, align 4
  %171 = load i32* %z3, align 4
  %172 = add nsw i32 %171, %170
  store i32 %172, i32* %z3, align 4
  %173 = load i32* %z5, align 4
  %174 = load i32* %z4, align 4
  %175 = add nsw i32 %174, %173
  store i32 %175, i32* %z4, align 4
  %176 = load i32* %tmp4, align 4
  %177 = load i32* %z1, align 4
  %178 = add nsw i32 %176, %177
  %179 = load i32* %z3, align 4
  %180 = add nsw i32 %178, %179
  %181 = ashr i32 %180, 11
  %182 = trunc i32 %181 to i16
  %183 = load i16** %block, align 8
  %184 = getelementptr inbounds i16* %183, i64 7
  store i16 %182, i16* %184, align 2
  %185 = load i32* %tmp5, align 4
  %186 = load i32* %z2, align 4
  %187 = add nsw i32 %185, %186
  %188 = load i32* %z4, align 4
  %189 = add nsw i32 %187, %188
  %190 = ashr i32 %189, 11
  %191 = trunc i32 %190 to i16
  %192 = load i16** %block, align 8
  %193 = getelementptr inbounds i16* %192, i64 5
  store i16 %191, i16* %193, align 2
  %194 = load i32* %tmp6, align 4
  %195 = load i32* %z2, align 4
  %196 = add nsw i32 %194, %195
  %197 = load i32* %z3, align 4
  %198 = add nsw i32 %196, %197
  %199 = ashr i32 %198, 11
  %200 = trunc i32 %199 to i16
  %201 = load i16** %block, align 8
  %202 = getelementptr inbounds i16* %201, i64 3
  store i16 %200, i16* %202, align 2
  %203 = load i32* %tmp7, align 4
  %204 = load i32* %z1, align 4
  %205 = add nsw i32 %203, %204
  %206 = load i32* %z4, align 4
  %207 = add nsw i32 %205, %206
  %208 = ashr i32 %207, 11
  %209 = trunc i32 %208 to i16
  %210 = load i16** %block, align 8
  %211 = getelementptr inbounds i16* %210, i64 1
  store i16 %209, i16* %211, align 2
  %212 = load i32* %2, align 4
  %213 = load i16** %block, align 8
  %214 = sext i32 %212 to i64
  %215 = getelementptr inbounds i16* %213, i64 %214
  store i16* %215, i16** %block, align 8
  br label %216

; <label>:216                                     ; preds = %7
  %217 = load i32* %i, align 4
  %218 = add nsw i32 %217, 1
  store i32 %218, i32* %i, align 4
  br label %4

; <label>:219                                     ; preds = %4
  %220 = load i16** %1, align 8
  store i16* %220, i16** %block, align 8
  store i32 0, i32* %i, align 4
  br label %221

; <label>:221                                     ; preds = %491, %219
  %222 = load i32* %i, align 4
  %223 = icmp slt i32 %222, 8
  br i1 %223, label %224, label %494

; <label>:224                                     ; preds = %221
  %225 = load i16** %block, align 8
  %226 = getelementptr inbounds i16* %225, i64 0
  %227 = load i16* %226, align 2
  %228 = sext i16 %227 to i32
  %229 = load i32* %2, align 4
  %230 = mul nsw i32 7, %229
  %231 = sext i32 %230 to i64
  %232 = load i16** %block, align 8
  %233 = getelementptr inbounds i16* %232, i64 %231
  %234 = load i16* %233, align 2
  %235 = sext i16 %234 to i32
  %236 = add nsw i32 %228, %235
  store i32 %236, i32* %tmp0, align 4
  %237 = load i16** %block, align 8
  %238 = getelementptr inbounds i16* %237, i64 0
  %239 = load i16* %238, align 2
  %240 = sext i16 %239 to i32
  %241 = load i32* %2, align 4
  %242 = mul nsw i32 7, %241
  %243 = sext i32 %242 to i64
  %244 = load i16** %block, align 8
  %245 = getelementptr inbounds i16* %244, i64 %243
  %246 = load i16* %245, align 2
  %247 = sext i16 %246 to i32
  %248 = sub nsw i32 %240, %247
  store i32 %248, i32* %tmp7, align 4
  %249 = load i32* %2, align 4
  %250 = sext i32 %249 to i64
  %251 = load i16** %block, align 8
  %252 = getelementptr inbounds i16* %251, i64 %250
  %253 = load i16* %252, align 2
  %254 = sext i16 %253 to i32
  %255 = load i32* %2, align 4
  %256 = mul nsw i32 6, %255
  %257 = sext i32 %256 to i64
  %258 = load i16** %block, align 8
  %259 = getelementptr inbounds i16* %258, i64 %257
  %260 = load i16* %259, align 2
  %261 = sext i16 %260 to i32
  %262 = add nsw i32 %254, %261
  store i32 %262, i32* %tmp1, align 4
  %263 = load i32* %2, align 4
  %264 = sext i32 %263 to i64
  %265 = load i16** %block, align 8
  %266 = getelementptr inbounds i16* %265, i64 %264
  %267 = load i16* %266, align 2
  %268 = sext i16 %267 to i32
  %269 = load i32* %2, align 4
  %270 = mul nsw i32 6, %269
  %271 = sext i32 %270 to i64
  %272 = load i16** %block, align 8
  %273 = getelementptr inbounds i16* %272, i64 %271
  %274 = load i16* %273, align 2
  %275 = sext i16 %274 to i32
  %276 = sub nsw i32 %268, %275
  store i32 %276, i32* %tmp6, align 4
  %277 = load i32* %2, align 4
  %278 = mul nsw i32 2, %277
  %279 = sext i32 %278 to i64
  %280 = load i16** %block, align 8
  %281 = getelementptr inbounds i16* %280, i64 %279
  %282 = load i16* %281, align 2
  %283 = sext i16 %282 to i32
  %284 = load i32* %2, align 4
  %285 = mul nsw i32 5, %284
  %286 = sext i32 %285 to i64
  %287 = load i16** %block, align 8
  %288 = getelementptr inbounds i16* %287, i64 %286
  %289 = load i16* %288, align 2
  %290 = sext i16 %289 to i32
  %291 = add nsw i32 %283, %290
  store i32 %291, i32* %tmp2, align 4
  %292 = load i32* %2, align 4
  %293 = mul nsw i32 2, %292
  %294 = sext i32 %293 to i64
  %295 = load i16** %block, align 8
  %296 = getelementptr inbounds i16* %295, i64 %294
  %297 = load i16* %296, align 2
  %298 = sext i16 %297 to i32
  %299 = load i32* %2, align 4
  %300 = mul nsw i32 5, %299
  %301 = sext i32 %300 to i64
  %302 = load i16** %block, align 8
  %303 = getelementptr inbounds i16* %302, i64 %301
  %304 = load i16* %303, align 2
  %305 = sext i16 %304 to i32
  %306 = sub nsw i32 %298, %305
  store i32 %306, i32* %tmp5, align 4
  %307 = load i32* %2, align 4
  %308 = mul nsw i32 3, %307
  %309 = sext i32 %308 to i64
  %310 = load i16** %block, align 8
  %311 = getelementptr inbounds i16* %310, i64 %309
  %312 = load i16* %311, align 2
  %313 = sext i16 %312 to i32
  %314 = load i32* %2, align 4
  %315 = mul nsw i32 4, %314
  %316 = sext i32 %315 to i64
  %317 = load i16** %block, align 8
  %318 = getelementptr inbounds i16* %317, i64 %316
  %319 = load i16* %318, align 2
  %320 = sext i16 %319 to i32
  %321 = add nsw i32 %313, %320
  store i32 %321, i32* %tmp3, align 4
  %322 = load i32* %2, align 4
  %323 = mul nsw i32 3, %322
  %324 = sext i32 %323 to i64
  %325 = load i16** %block, align 8
  %326 = getelementptr inbounds i16* %325, i64 %324
  %327 = load i16* %326, align 2
  %328 = sext i16 %327 to i32
  %329 = load i32* %2, align 4
  %330 = mul nsw i32 4, %329
  %331 = sext i32 %330 to i64
  %332 = load i16** %block, align 8
  %333 = getelementptr inbounds i16* %332, i64 %331
  %334 = load i16* %333, align 2
  %335 = sext i16 %334 to i32
  %336 = sub nsw i32 %328, %335
  store i32 %336, i32* %tmp4, align 4
  %337 = load i32* %tmp0, align 4
  %338 = load i32* %tmp3, align 4
  %339 = add nsw i32 %337, %338
  store i32 %339, i32* %tmp10, align 4
  %340 = load i32* %tmp0, align 4
  %341 = load i32* %tmp3, align 4
  %342 = sub nsw i32 %340, %341
  store i32 %342, i32* %tmp13, align 4
  %343 = load i32* %tmp1, align 4
  %344 = load i32* %tmp2, align 4
  %345 = add nsw i32 %343, %344
  store i32 %345, i32* %tmp11, align 4
  %346 = load i32* %tmp1, align 4
  %347 = load i32* %tmp2, align 4
  %348 = sub nsw i32 %346, %347
  store i32 %348, i32* %tmp12, align 4
  %349 = load i32* %tmp10, align 4
  %350 = load i32* %tmp11, align 4
  %351 = add nsw i32 %349, %350
  %352 = ashr i32 %351, 5
  %353 = trunc i32 %352 to i16
  %354 = load i16** %block, align 8
  %355 = getelementptr inbounds i16* %354, i64 0
  store i16 %353, i16* %355, align 2
  %356 = load i32* %tmp10, align 4
  %357 = load i32* %tmp11, align 4
  %358 = sub nsw i32 %356, %357
  %359 = ashr i32 %358, 5
  %360 = trunc i32 %359 to i16
  %361 = load i32* %2, align 4
  %362 = mul nsw i32 4, %361
  %363 = sext i32 %362 to i64
  %364 = load i16** %block, align 8
  %365 = getelementptr inbounds i16* %364, i64 %363
  store i16 %360, i16* %365, align 2
  store i32 4433, i32* %constant, align 4
  %366 = load i32* %tmp12, align 4
  %367 = load i32* %tmp13, align 4
  %368 = add nsw i32 %366, %367
  %369 = load i32* %constant, align 4
  %370 = mul nsw i32 %368, %369
  store i32 %370, i32* %z1, align 4
  store i32 6270, i32* %constant, align 4
  %371 = load i32* %z1, align 4
  %372 = load i32* %tmp13, align 4
  %373 = load i32* %constant, align 4
  %374 = mul nsw i32 %372, %373
  %375 = add nsw i32 %371, %374
  %376 = ashr i32 %375, 18
  %377 = trunc i32 %376 to i16
  %378 = load i32* %2, align 4
  %379 = mul nsw i32 2, %378
  %380 = sext i32 %379 to i64
  %381 = load i16** %block, align 8
  %382 = getelementptr inbounds i16* %381, i64 %380
  store i16 %377, i16* %382, align 2
  store i32 -15137, i32* %constant, align 4
  %383 = load i32* %z1, align 4
  %384 = load i32* %tmp12, align 4
  %385 = load i32* %constant, align 4
  %386 = mul nsw i32 %384, %385
  %387 = add nsw i32 %383, %386
  %388 = ashr i32 %387, 18
  %389 = trunc i32 %388 to i16
  %390 = load i32* %2, align 4
  %391 = mul nsw i32 6, %390
  %392 = sext i32 %391 to i64
  %393 = load i16** %block, align 8
  %394 = getelementptr inbounds i16* %393, i64 %392
  store i16 %389, i16* %394, align 2
  %395 = load i32* %tmp4, align 4
  %396 = load i32* %tmp7, align 4
  %397 = add nsw i32 %395, %396
  store i32 %397, i32* %z1, align 4
  %398 = load i32* %tmp5, align 4
  %399 = load i32* %tmp6, align 4
  %400 = add nsw i32 %398, %399
  store i32 %400, i32* %z2, align 4
  %401 = load i32* %tmp4, align 4
  %402 = load i32* %tmp6, align 4
  %403 = add nsw i32 %401, %402
  store i32 %403, i32* %z3, align 4
  %404 = load i32* %tmp5, align 4
  %405 = load i32* %tmp7, align 4
  %406 = add nsw i32 %404, %405
  store i32 %406, i32* %z4, align 4
  store i32 9633, i32* %constant, align 4
  %407 = load i32* %z3, align 4
  %408 = load i32* %z4, align 4
  %409 = add nsw i32 %407, %408
  %410 = load i32* %constant, align 4
  %411 = mul nsw i32 %409, %410
  store i32 %411, i32* %z5, align 4
  store i32 2446, i32* %constant, align 4
  %412 = load i32* %tmp4, align 4
  %413 = load i32* %constant, align 4
  %414 = mul nsw i32 %412, %413
  store i32 %414, i32* %tmp4, align 4
  store i32 16819, i32* %constant, align 4
  %415 = load i32* %tmp5, align 4
  %416 = load i32* %constant, align 4
  %417 = mul nsw i32 %415, %416
  store i32 %417, i32* %tmp5, align 4
  store i32 25172, i32* %constant, align 4
  %418 = load i32* %tmp6, align 4
  %419 = load i32* %constant, align 4
  %420 = mul nsw i32 %418, %419
  store i32 %420, i32* %tmp6, align 4
  store i32 12299, i32* %constant, align 4
  %421 = load i32* %tmp7, align 4
  %422 = load i32* %constant, align 4
  %423 = mul nsw i32 %421, %422
  store i32 %423, i32* %tmp7, align 4
  store i32 -7373, i32* %constant, align 4
  %424 = load i32* %z1, align 4
  %425 = load i32* %constant, align 4
  %426 = mul nsw i32 %424, %425
  store i32 %426, i32* %z1, align 4
  store i32 -20995, i32* %constant, align 4
  %427 = load i32* %z2, align 4
  %428 = load i32* %constant, align 4
  %429 = mul nsw i32 %427, %428
  store i32 %429, i32* %z2, align 4
  store i32 -16069, i32* %constant, align 4
  %430 = load i32* %z3, align 4
  %431 = load i32* %constant, align 4
  %432 = mul nsw i32 %430, %431
  store i32 %432, i32* %z3, align 4
  store i32 -3196, i32* %constant, align 4
  %433 = load i32* %z4, align 4
  %434 = load i32* %constant, align 4
  %435 = mul nsw i32 %433, %434
  store i32 %435, i32* %z4, align 4
  %436 = load i32* %z5, align 4
  %437 = load i32* %z3, align 4
  %438 = add nsw i32 %437, %436
  store i32 %438, i32* %z3, align 4
  %439 = load i32* %z5, align 4
  %440 = load i32* %z4, align 4
  %441 = add nsw i32 %440, %439
  store i32 %441, i32* %z4, align 4
  %442 = load i32* %tmp4, align 4
  %443 = load i32* %z1, align 4
  %444 = add nsw i32 %442, %443
  %445 = load i32* %z3, align 4
  %446 = add nsw i32 %444, %445
  %447 = ashr i32 %446, 18
  %448 = trunc i32 %447 to i16
  %449 = load i32* %2, align 4
  %450 = mul nsw i32 7, %449
  %451 = sext i32 %450 to i64
  %452 = load i16** %block, align 8
  %453 = getelementptr inbounds i16* %452, i64 %451
  store i16 %448, i16* %453, align 2
  %454 = load i32* %tmp5, align 4
  %455 = load i32* %z2, align 4
  %456 = add nsw i32 %454, %455
  %457 = load i32* %z4, align 4
  %458 = add nsw i32 %456, %457
  %459 = ashr i32 %458, 18
  %460 = trunc i32 %459 to i16
  %461 = load i32* %2, align 4
  %462 = mul nsw i32 5, %461
  %463 = sext i32 %462 to i64
  %464 = load i16** %block, align 8
  %465 = getelementptr inbounds i16* %464, i64 %463
  store i16 %460, i16* %465, align 2
  %466 = load i32* %tmp6, align 4
  %467 = load i32* %z2, align 4
  %468 = add nsw i32 %466, %467
  %469 = load i32* %z3, align 4
  %470 = add nsw i32 %468, %469
  %471 = ashr i32 %470, 18
  %472 = trunc i32 %471 to i16
  %473 = load i32* %2, align 4
  %474 = mul nsw i32 3, %473
  %475 = sext i32 %474 to i64
  %476 = load i16** %block, align 8
  %477 = getelementptr inbounds i16* %476, i64 %475
  store i16 %472, i16* %477, align 2
  %478 = load i32* %tmp7, align 4
  %479 = load i32* %z1, align 4
  %480 = add nsw i32 %478, %479
  %481 = load i32* %z4, align 4
  %482 = add nsw i32 %480, %481
  %483 = ashr i32 %482, 18
  %484 = trunc i32 %483 to i16
  %485 = load i32* %2, align 4
  %486 = sext i32 %485 to i64
  %487 = load i16** %block, align 8
  %488 = getelementptr inbounds i16* %487, i64 %486
  store i16 %484, i16* %488, align 2
  %489 = load i16** %block, align 8
  %490 = getelementptr inbounds i16* %489, i32 1
  store i16* %490, i16** %block, align 8
  br label %491

; <label>:491                                     ; preds = %224
  %492 = load i32* %i, align 4
  %493 = add nsw i32 %492, 1
  store i32 %493, i32* %i, align 4
  br label %221

; <label>:494                                     ; preds = %221
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  store i32 0, i32* %1
  call void @fdct(i16* getelementptr inbounds ([64 x i16]* @block, i32 0, i32 0), i32 8)
  %2 = load i16* getelementptr inbounds ([64 x i16]* @block, i32 0, i64 0), align 2
  %3 = sext i16 %2 to i32
  ret i32 %3
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
