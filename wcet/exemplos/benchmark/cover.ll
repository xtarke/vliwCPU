; ModuleID = 'cover.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

; Function Attrs: nounwind uwtable
define i32 @swi120(i32 %c) #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 %c, i32* %1, align 4
  store i32 0, i32* %i, align 4
  br label %2

; <label>:2                                       ; preds = %371, %0
  %3 = load i32* %i, align 4
  %4 = icmp slt i32 %3, 120
  br i1 %4, label %5, label %374

; <label>:5                                       ; preds = %2
  %6 = load i32* %i, align 4
  switch i32 %6, label %367 [
    i32 0, label %7
    i32 1, label %10
    i32 2, label %13
    i32 3, label %16
    i32 4, label %19
    i32 5, label %22
    i32 6, label %25
    i32 7, label %28
    i32 8, label %31
    i32 9, label %34
    i32 10, label %37
    i32 11, label %40
    i32 12, label %43
    i32 13, label %46
    i32 14, label %49
    i32 15, label %52
    i32 16, label %55
    i32 17, label %58
    i32 18, label %61
    i32 19, label %64
    i32 20, label %67
    i32 21, label %70
    i32 22, label %73
    i32 23, label %76
    i32 24, label %79
    i32 25, label %82
    i32 26, label %85
    i32 27, label %88
    i32 28, label %91
    i32 29, label %94
    i32 30, label %97
    i32 31, label %100
    i32 32, label %103
    i32 33, label %106
    i32 34, label %109
    i32 35, label %112
    i32 36, label %115
    i32 37, label %118
    i32 38, label %121
    i32 39, label %124
    i32 40, label %127
    i32 41, label %130
    i32 42, label %133
    i32 43, label %136
    i32 44, label %139
    i32 45, label %142
    i32 46, label %145
    i32 47, label %148
    i32 48, label %151
    i32 49, label %154
    i32 50, label %157
    i32 51, label %160
    i32 52, label %163
    i32 53, label %166
    i32 54, label %169
    i32 55, label %172
    i32 56, label %175
    i32 57, label %178
    i32 58, label %181
    i32 59, label %184
    i32 60, label %187
    i32 61, label %190
    i32 62, label %193
    i32 63, label %196
    i32 64, label %199
    i32 65, label %202
    i32 66, label %205
    i32 67, label %208
    i32 68, label %211
    i32 69, label %214
    i32 70, label %217
    i32 71, label %220
    i32 72, label %223
    i32 73, label %226
    i32 74, label %229
    i32 75, label %232
    i32 76, label %235
    i32 77, label %238
    i32 78, label %241
    i32 79, label %244
    i32 80, label %247
    i32 81, label %250
    i32 82, label %253
    i32 83, label %256
    i32 84, label %259
    i32 85, label %262
    i32 86, label %265
    i32 87, label %268
    i32 88, label %271
    i32 89, label %274
    i32 90, label %277
    i32 91, label %280
    i32 92, label %283
    i32 93, label %286
    i32 94, label %289
    i32 95, label %292
    i32 96, label %295
    i32 97, label %298
    i32 98, label %301
    i32 99, label %304
    i32 100, label %307
    i32 101, label %310
    i32 102, label %313
    i32 103, label %316
    i32 104, label %319
    i32 105, label %322
    i32 106, label %325
    i32 107, label %328
    i32 108, label %331
    i32 109, label %334
    i32 110, label %337
    i32 111, label %340
    i32 112, label %343
    i32 113, label %346
    i32 114, label %349
    i32 115, label %352
    i32 116, label %355
    i32 117, label %358
    i32 118, label %361
    i32 119, label %364
  ]

; <label>:7                                       ; preds = %5
  %8 = load i32* %1, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %1, align 4
  br label %370

; <label>:10                                      ; preds = %5
  %11 = load i32* %1, align 4
  %12 = add nsw i32 %11, 1
  store i32 %12, i32* %1, align 4
  br label %370

; <label>:13                                      ; preds = %5
  %14 = load i32* %1, align 4
  %15 = add nsw i32 %14, 1
  store i32 %15, i32* %1, align 4
  br label %370

; <label>:16                                      ; preds = %5
  %17 = load i32* %1, align 4
  %18 = add nsw i32 %17, 1
  store i32 %18, i32* %1, align 4
  br label %370

; <label>:19                                      ; preds = %5
  %20 = load i32* %1, align 4
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %1, align 4
  br label %370

; <label>:22                                      ; preds = %5
  %23 = load i32* %1, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %1, align 4
  br label %370

; <label>:25                                      ; preds = %5
  %26 = load i32* %1, align 4
  %27 = add nsw i32 %26, 1
  store i32 %27, i32* %1, align 4
  br label %370

; <label>:28                                      ; preds = %5
  %29 = load i32* %1, align 4
  %30 = add nsw i32 %29, 1
  store i32 %30, i32* %1, align 4
  br label %370

; <label>:31                                      ; preds = %5
  %32 = load i32* %1, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, i32* %1, align 4
  br label %370

; <label>:34                                      ; preds = %5
  %35 = load i32* %1, align 4
  %36 = add nsw i32 %35, 1
  store i32 %36, i32* %1, align 4
  br label %370

; <label>:37                                      ; preds = %5
  %38 = load i32* %1, align 4
  %39 = add nsw i32 %38, 1
  store i32 %39, i32* %1, align 4
  br label %370

; <label>:40                                      ; preds = %5
  %41 = load i32* %1, align 4
  %42 = add nsw i32 %41, 1
  store i32 %42, i32* %1, align 4
  br label %370

; <label>:43                                      ; preds = %5
  %44 = load i32* %1, align 4
  %45 = add nsw i32 %44, 1
  store i32 %45, i32* %1, align 4
  br label %370

; <label>:46                                      ; preds = %5
  %47 = load i32* %1, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, i32* %1, align 4
  br label %370

; <label>:49                                      ; preds = %5
  %50 = load i32* %1, align 4
  %51 = add nsw i32 %50, 1
  store i32 %51, i32* %1, align 4
  br label %370

; <label>:52                                      ; preds = %5
  %53 = load i32* %1, align 4
  %54 = add nsw i32 %53, 1
  store i32 %54, i32* %1, align 4
  br label %370

; <label>:55                                      ; preds = %5
  %56 = load i32* %1, align 4
  %57 = add nsw i32 %56, 1
  store i32 %57, i32* %1, align 4
  br label %370

; <label>:58                                      ; preds = %5
  %59 = load i32* %1, align 4
  %60 = add nsw i32 %59, 1
  store i32 %60, i32* %1, align 4
  br label %370

; <label>:61                                      ; preds = %5
  %62 = load i32* %1, align 4
  %63 = add nsw i32 %62, 1
  store i32 %63, i32* %1, align 4
  br label %370

; <label>:64                                      ; preds = %5
  %65 = load i32* %1, align 4
  %66 = add nsw i32 %65, 1
  store i32 %66, i32* %1, align 4
  br label %370

; <label>:67                                      ; preds = %5
  %68 = load i32* %1, align 4
  %69 = add nsw i32 %68, 1
  store i32 %69, i32* %1, align 4
  br label %370

; <label>:70                                      ; preds = %5
  %71 = load i32* %1, align 4
  %72 = add nsw i32 %71, 1
  store i32 %72, i32* %1, align 4
  br label %370

; <label>:73                                      ; preds = %5
  %74 = load i32* %1, align 4
  %75 = add nsw i32 %74, 1
  store i32 %75, i32* %1, align 4
  br label %370

; <label>:76                                      ; preds = %5
  %77 = load i32* %1, align 4
  %78 = add nsw i32 %77, 1
  store i32 %78, i32* %1, align 4
  br label %370

; <label>:79                                      ; preds = %5
  %80 = load i32* %1, align 4
  %81 = add nsw i32 %80, 1
  store i32 %81, i32* %1, align 4
  br label %370

; <label>:82                                      ; preds = %5
  %83 = load i32* %1, align 4
  %84 = add nsw i32 %83, 1
  store i32 %84, i32* %1, align 4
  br label %370

; <label>:85                                      ; preds = %5
  %86 = load i32* %1, align 4
  %87 = add nsw i32 %86, 1
  store i32 %87, i32* %1, align 4
  br label %370

; <label>:88                                      ; preds = %5
  %89 = load i32* %1, align 4
  %90 = add nsw i32 %89, 1
  store i32 %90, i32* %1, align 4
  br label %370

; <label>:91                                      ; preds = %5
  %92 = load i32* %1, align 4
  %93 = add nsw i32 %92, 1
  store i32 %93, i32* %1, align 4
  br label %370

; <label>:94                                      ; preds = %5
  %95 = load i32* %1, align 4
  %96 = add nsw i32 %95, 1
  store i32 %96, i32* %1, align 4
  br label %370

; <label>:97                                      ; preds = %5
  %98 = load i32* %1, align 4
  %99 = add nsw i32 %98, 1
  store i32 %99, i32* %1, align 4
  br label %370

; <label>:100                                     ; preds = %5
  %101 = load i32* %1, align 4
  %102 = add nsw i32 %101, 1
  store i32 %102, i32* %1, align 4
  br label %370

; <label>:103                                     ; preds = %5
  %104 = load i32* %1, align 4
  %105 = add nsw i32 %104, 1
  store i32 %105, i32* %1, align 4
  br label %370

; <label>:106                                     ; preds = %5
  %107 = load i32* %1, align 4
  %108 = add nsw i32 %107, 1
  store i32 %108, i32* %1, align 4
  br label %370

; <label>:109                                     ; preds = %5
  %110 = load i32* %1, align 4
  %111 = add nsw i32 %110, 1
  store i32 %111, i32* %1, align 4
  br label %370

; <label>:112                                     ; preds = %5
  %113 = load i32* %1, align 4
  %114 = add nsw i32 %113, 1
  store i32 %114, i32* %1, align 4
  br label %370

; <label>:115                                     ; preds = %5
  %116 = load i32* %1, align 4
  %117 = add nsw i32 %116, 1
  store i32 %117, i32* %1, align 4
  br label %370

; <label>:118                                     ; preds = %5
  %119 = load i32* %1, align 4
  %120 = add nsw i32 %119, 1
  store i32 %120, i32* %1, align 4
  br label %370

; <label>:121                                     ; preds = %5
  %122 = load i32* %1, align 4
  %123 = add nsw i32 %122, 1
  store i32 %123, i32* %1, align 4
  br label %370

; <label>:124                                     ; preds = %5
  %125 = load i32* %1, align 4
  %126 = add nsw i32 %125, 1
  store i32 %126, i32* %1, align 4
  br label %370

; <label>:127                                     ; preds = %5
  %128 = load i32* %1, align 4
  %129 = add nsw i32 %128, 1
  store i32 %129, i32* %1, align 4
  br label %370

; <label>:130                                     ; preds = %5
  %131 = load i32* %1, align 4
  %132 = add nsw i32 %131, 1
  store i32 %132, i32* %1, align 4
  br label %370

; <label>:133                                     ; preds = %5
  %134 = load i32* %1, align 4
  %135 = add nsw i32 %134, 1
  store i32 %135, i32* %1, align 4
  br label %370

; <label>:136                                     ; preds = %5
  %137 = load i32* %1, align 4
  %138 = add nsw i32 %137, 1
  store i32 %138, i32* %1, align 4
  br label %370

; <label>:139                                     ; preds = %5
  %140 = load i32* %1, align 4
  %141 = add nsw i32 %140, 1
  store i32 %141, i32* %1, align 4
  br label %370

; <label>:142                                     ; preds = %5
  %143 = load i32* %1, align 4
  %144 = add nsw i32 %143, 1
  store i32 %144, i32* %1, align 4
  br label %370

; <label>:145                                     ; preds = %5
  %146 = load i32* %1, align 4
  %147 = add nsw i32 %146, 1
  store i32 %147, i32* %1, align 4
  br label %370

; <label>:148                                     ; preds = %5
  %149 = load i32* %1, align 4
  %150 = add nsw i32 %149, 1
  store i32 %150, i32* %1, align 4
  br label %370

; <label>:151                                     ; preds = %5
  %152 = load i32* %1, align 4
  %153 = add nsw i32 %152, 1
  store i32 %153, i32* %1, align 4
  br label %370

; <label>:154                                     ; preds = %5
  %155 = load i32* %1, align 4
  %156 = add nsw i32 %155, 1
  store i32 %156, i32* %1, align 4
  br label %370

; <label>:157                                     ; preds = %5
  %158 = load i32* %1, align 4
  %159 = add nsw i32 %158, 1
  store i32 %159, i32* %1, align 4
  br label %370

; <label>:160                                     ; preds = %5
  %161 = load i32* %1, align 4
  %162 = add nsw i32 %161, 1
  store i32 %162, i32* %1, align 4
  br label %370

; <label>:163                                     ; preds = %5
  %164 = load i32* %1, align 4
  %165 = add nsw i32 %164, 1
  store i32 %165, i32* %1, align 4
  br label %370

; <label>:166                                     ; preds = %5
  %167 = load i32* %1, align 4
  %168 = add nsw i32 %167, 1
  store i32 %168, i32* %1, align 4
  br label %370

; <label>:169                                     ; preds = %5
  %170 = load i32* %1, align 4
  %171 = add nsw i32 %170, 1
  store i32 %171, i32* %1, align 4
  br label %370

; <label>:172                                     ; preds = %5
  %173 = load i32* %1, align 4
  %174 = add nsw i32 %173, 1
  store i32 %174, i32* %1, align 4
  br label %370

; <label>:175                                     ; preds = %5
  %176 = load i32* %1, align 4
  %177 = add nsw i32 %176, 1
  store i32 %177, i32* %1, align 4
  br label %370

; <label>:178                                     ; preds = %5
  %179 = load i32* %1, align 4
  %180 = add nsw i32 %179, 1
  store i32 %180, i32* %1, align 4
  br label %370

; <label>:181                                     ; preds = %5
  %182 = load i32* %1, align 4
  %183 = add nsw i32 %182, 1
  store i32 %183, i32* %1, align 4
  br label %370

; <label>:184                                     ; preds = %5
  %185 = load i32* %1, align 4
  %186 = add nsw i32 %185, 1
  store i32 %186, i32* %1, align 4
  br label %370

; <label>:187                                     ; preds = %5
  %188 = load i32* %1, align 4
  %189 = add nsw i32 %188, 1
  store i32 %189, i32* %1, align 4
  br label %370

; <label>:190                                     ; preds = %5
  %191 = load i32* %1, align 4
  %192 = add nsw i32 %191, 1
  store i32 %192, i32* %1, align 4
  br label %370

; <label>:193                                     ; preds = %5
  %194 = load i32* %1, align 4
  %195 = add nsw i32 %194, 1
  store i32 %195, i32* %1, align 4
  br label %370

; <label>:196                                     ; preds = %5
  %197 = load i32* %1, align 4
  %198 = add nsw i32 %197, 1
  store i32 %198, i32* %1, align 4
  br label %370

; <label>:199                                     ; preds = %5
  %200 = load i32* %1, align 4
  %201 = add nsw i32 %200, 1
  store i32 %201, i32* %1, align 4
  br label %370

; <label>:202                                     ; preds = %5
  %203 = load i32* %1, align 4
  %204 = add nsw i32 %203, 1
  store i32 %204, i32* %1, align 4
  br label %370

; <label>:205                                     ; preds = %5
  %206 = load i32* %1, align 4
  %207 = add nsw i32 %206, 1
  store i32 %207, i32* %1, align 4
  br label %370

; <label>:208                                     ; preds = %5
  %209 = load i32* %1, align 4
  %210 = add nsw i32 %209, 1
  store i32 %210, i32* %1, align 4
  br label %370

; <label>:211                                     ; preds = %5
  %212 = load i32* %1, align 4
  %213 = add nsw i32 %212, 1
  store i32 %213, i32* %1, align 4
  br label %370

; <label>:214                                     ; preds = %5
  %215 = load i32* %1, align 4
  %216 = add nsw i32 %215, 1
  store i32 %216, i32* %1, align 4
  br label %370

; <label>:217                                     ; preds = %5
  %218 = load i32* %1, align 4
  %219 = add nsw i32 %218, 1
  store i32 %219, i32* %1, align 4
  br label %370

; <label>:220                                     ; preds = %5
  %221 = load i32* %1, align 4
  %222 = add nsw i32 %221, 1
  store i32 %222, i32* %1, align 4
  br label %370

; <label>:223                                     ; preds = %5
  %224 = load i32* %1, align 4
  %225 = add nsw i32 %224, 1
  store i32 %225, i32* %1, align 4
  br label %370

; <label>:226                                     ; preds = %5
  %227 = load i32* %1, align 4
  %228 = add nsw i32 %227, 1
  store i32 %228, i32* %1, align 4
  br label %370

; <label>:229                                     ; preds = %5
  %230 = load i32* %1, align 4
  %231 = add nsw i32 %230, 1
  store i32 %231, i32* %1, align 4
  br label %370

; <label>:232                                     ; preds = %5
  %233 = load i32* %1, align 4
  %234 = add nsw i32 %233, 1
  store i32 %234, i32* %1, align 4
  br label %370

; <label>:235                                     ; preds = %5
  %236 = load i32* %1, align 4
  %237 = add nsw i32 %236, 1
  store i32 %237, i32* %1, align 4
  br label %370

; <label>:238                                     ; preds = %5
  %239 = load i32* %1, align 4
  %240 = add nsw i32 %239, 1
  store i32 %240, i32* %1, align 4
  br label %370

; <label>:241                                     ; preds = %5
  %242 = load i32* %1, align 4
  %243 = add nsw i32 %242, 1
  store i32 %243, i32* %1, align 4
  br label %370

; <label>:244                                     ; preds = %5
  %245 = load i32* %1, align 4
  %246 = add nsw i32 %245, 1
  store i32 %246, i32* %1, align 4
  br label %370

; <label>:247                                     ; preds = %5
  %248 = load i32* %1, align 4
  %249 = add nsw i32 %248, 1
  store i32 %249, i32* %1, align 4
  br label %370

; <label>:250                                     ; preds = %5
  %251 = load i32* %1, align 4
  %252 = add nsw i32 %251, 1
  store i32 %252, i32* %1, align 4
  br label %370

; <label>:253                                     ; preds = %5
  %254 = load i32* %1, align 4
  %255 = add nsw i32 %254, 1
  store i32 %255, i32* %1, align 4
  br label %370

; <label>:256                                     ; preds = %5
  %257 = load i32* %1, align 4
  %258 = add nsw i32 %257, 1
  store i32 %258, i32* %1, align 4
  br label %370

; <label>:259                                     ; preds = %5
  %260 = load i32* %1, align 4
  %261 = add nsw i32 %260, 1
  store i32 %261, i32* %1, align 4
  br label %370

; <label>:262                                     ; preds = %5
  %263 = load i32* %1, align 4
  %264 = add nsw i32 %263, 1
  store i32 %264, i32* %1, align 4
  br label %370

; <label>:265                                     ; preds = %5
  %266 = load i32* %1, align 4
  %267 = add nsw i32 %266, 1
  store i32 %267, i32* %1, align 4
  br label %370

; <label>:268                                     ; preds = %5
  %269 = load i32* %1, align 4
  %270 = add nsw i32 %269, 1
  store i32 %270, i32* %1, align 4
  br label %370

; <label>:271                                     ; preds = %5
  %272 = load i32* %1, align 4
  %273 = add nsw i32 %272, 1
  store i32 %273, i32* %1, align 4
  br label %370

; <label>:274                                     ; preds = %5
  %275 = load i32* %1, align 4
  %276 = add nsw i32 %275, 1
  store i32 %276, i32* %1, align 4
  br label %370

; <label>:277                                     ; preds = %5
  %278 = load i32* %1, align 4
  %279 = add nsw i32 %278, 1
  store i32 %279, i32* %1, align 4
  br label %370

; <label>:280                                     ; preds = %5
  %281 = load i32* %1, align 4
  %282 = add nsw i32 %281, 1
  store i32 %282, i32* %1, align 4
  br label %370

; <label>:283                                     ; preds = %5
  %284 = load i32* %1, align 4
  %285 = add nsw i32 %284, 1
  store i32 %285, i32* %1, align 4
  br label %370

; <label>:286                                     ; preds = %5
  %287 = load i32* %1, align 4
  %288 = add nsw i32 %287, 1
  store i32 %288, i32* %1, align 4
  br label %370

; <label>:289                                     ; preds = %5
  %290 = load i32* %1, align 4
  %291 = add nsw i32 %290, 1
  store i32 %291, i32* %1, align 4
  br label %370

; <label>:292                                     ; preds = %5
  %293 = load i32* %1, align 4
  %294 = add nsw i32 %293, 1
  store i32 %294, i32* %1, align 4
  br label %370

; <label>:295                                     ; preds = %5
  %296 = load i32* %1, align 4
  %297 = add nsw i32 %296, 1
  store i32 %297, i32* %1, align 4
  br label %370

; <label>:298                                     ; preds = %5
  %299 = load i32* %1, align 4
  %300 = add nsw i32 %299, 1
  store i32 %300, i32* %1, align 4
  br label %370

; <label>:301                                     ; preds = %5
  %302 = load i32* %1, align 4
  %303 = add nsw i32 %302, 1
  store i32 %303, i32* %1, align 4
  br label %370

; <label>:304                                     ; preds = %5
  %305 = load i32* %1, align 4
  %306 = add nsw i32 %305, 1
  store i32 %306, i32* %1, align 4
  br label %370

; <label>:307                                     ; preds = %5
  %308 = load i32* %1, align 4
  %309 = add nsw i32 %308, 1
  store i32 %309, i32* %1, align 4
  br label %370

; <label>:310                                     ; preds = %5
  %311 = load i32* %1, align 4
  %312 = add nsw i32 %311, 1
  store i32 %312, i32* %1, align 4
  br label %370

; <label>:313                                     ; preds = %5
  %314 = load i32* %1, align 4
  %315 = add nsw i32 %314, 1
  store i32 %315, i32* %1, align 4
  br label %370

; <label>:316                                     ; preds = %5
  %317 = load i32* %1, align 4
  %318 = add nsw i32 %317, 1
  store i32 %318, i32* %1, align 4
  br label %370

; <label>:319                                     ; preds = %5
  %320 = load i32* %1, align 4
  %321 = add nsw i32 %320, 1
  store i32 %321, i32* %1, align 4
  br label %370

; <label>:322                                     ; preds = %5
  %323 = load i32* %1, align 4
  %324 = add nsw i32 %323, 1
  store i32 %324, i32* %1, align 4
  br label %370

; <label>:325                                     ; preds = %5
  %326 = load i32* %1, align 4
  %327 = add nsw i32 %326, 1
  store i32 %327, i32* %1, align 4
  br label %370

; <label>:328                                     ; preds = %5
  %329 = load i32* %1, align 4
  %330 = add nsw i32 %329, 1
  store i32 %330, i32* %1, align 4
  br label %370

; <label>:331                                     ; preds = %5
  %332 = load i32* %1, align 4
  %333 = add nsw i32 %332, 1
  store i32 %333, i32* %1, align 4
  br label %370

; <label>:334                                     ; preds = %5
  %335 = load i32* %1, align 4
  %336 = add nsw i32 %335, 1
  store i32 %336, i32* %1, align 4
  br label %370

; <label>:337                                     ; preds = %5
  %338 = load i32* %1, align 4
  %339 = add nsw i32 %338, 1
  store i32 %339, i32* %1, align 4
  br label %370

; <label>:340                                     ; preds = %5
  %341 = load i32* %1, align 4
  %342 = add nsw i32 %341, 1
  store i32 %342, i32* %1, align 4
  br label %370

; <label>:343                                     ; preds = %5
  %344 = load i32* %1, align 4
  %345 = add nsw i32 %344, 1
  store i32 %345, i32* %1, align 4
  br label %370

; <label>:346                                     ; preds = %5
  %347 = load i32* %1, align 4
  %348 = add nsw i32 %347, 1
  store i32 %348, i32* %1, align 4
  br label %370

; <label>:349                                     ; preds = %5
  %350 = load i32* %1, align 4
  %351 = add nsw i32 %350, 1
  store i32 %351, i32* %1, align 4
  br label %370

; <label>:352                                     ; preds = %5
  %353 = load i32* %1, align 4
  %354 = add nsw i32 %353, 1
  store i32 %354, i32* %1, align 4
  br label %370

; <label>:355                                     ; preds = %5
  %356 = load i32* %1, align 4
  %357 = add nsw i32 %356, 1
  store i32 %357, i32* %1, align 4
  br label %370

; <label>:358                                     ; preds = %5
  %359 = load i32* %1, align 4
  %360 = add nsw i32 %359, 1
  store i32 %360, i32* %1, align 4
  br label %370

; <label>:361                                     ; preds = %5
  %362 = load i32* %1, align 4
  %363 = add nsw i32 %362, 1
  store i32 %363, i32* %1, align 4
  br label %370

; <label>:364                                     ; preds = %5
  %365 = load i32* %1, align 4
  %366 = add nsw i32 %365, 1
  store i32 %366, i32* %1, align 4
  br label %370

; <label>:367                                     ; preds = %5
  %368 = load i32* %1, align 4
  %369 = add nsw i32 %368, -1
  store i32 %369, i32* %1, align 4
  br label %370

; <label>:370                                     ; preds = %367, %364, %361, %358, %355, %352, %349, %346, %343, %340, %337, %334, %331, %328, %325, %322, %319, %316, %313, %310, %307, %304, %301, %298, %295, %292, %289, %286, %283, %280, %277, %274, %271, %268, %265, %262, %259, %256, %253, %250, %247, %244, %241, %238, %235, %232, %229, %226, %223, %220, %217, %214, %211, %208, %205, %202, %199, %196, %193, %190, %187, %184, %181, %178, %175, %172, %169, %166, %163, %160, %157, %154, %151, %148, %145, %142, %139, %136, %133, %130, %127, %124, %121, %118, %115, %112, %109, %106, %103, %100, %97, %94, %91, %88, %85, %82, %79, %76, %73, %70, %67, %64, %61, %58, %55, %52, %49, %46, %43, %40, %37, %34, %31, %28, %25, %22, %19, %16, %13, %10, %7
  br label %371

; <label>:371                                     ; preds = %370
  %372 = load i32* %i, align 4
  %373 = add nsw i32 %372, 1
  store i32 %373, i32* %i, align 4
  br label %2

; <label>:374                                     ; preds = %2
  %375 = load i32* %1, align 4
  ret i32 %375
}

; Function Attrs: nounwind uwtable
define i32 @swi50(i32 %c) #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 %c, i32* %1, align 4
  store i32 0, i32* %i, align 4
  br label %2

; <label>:2                                       ; preds = %191, %0
  %3 = load i32* %i, align 4
  %4 = icmp slt i32 %3, 50
  br i1 %4, label %5, label %194

; <label>:5                                       ; preds = %2
  %6 = load i32* %i, align 4
  switch i32 %6, label %187 [
    i32 0, label %7
    i32 1, label %10
    i32 2, label %13
    i32 3, label %16
    i32 4, label %19
    i32 5, label %22
    i32 6, label %25
    i32 7, label %28
    i32 8, label %31
    i32 9, label %34
    i32 10, label %37
    i32 11, label %40
    i32 12, label %43
    i32 13, label %46
    i32 14, label %49
    i32 15, label %52
    i32 16, label %55
    i32 17, label %58
    i32 18, label %61
    i32 19, label %64
    i32 20, label %67
    i32 21, label %70
    i32 22, label %73
    i32 23, label %76
    i32 24, label %79
    i32 25, label %82
    i32 26, label %85
    i32 27, label %88
    i32 28, label %91
    i32 29, label %94
    i32 30, label %97
    i32 31, label %100
    i32 32, label %103
    i32 33, label %106
    i32 34, label %109
    i32 35, label %112
    i32 36, label %115
    i32 37, label %118
    i32 38, label %121
    i32 39, label %124
    i32 40, label %127
    i32 41, label %130
    i32 42, label %133
    i32 43, label %136
    i32 44, label %139
    i32 45, label %142
    i32 46, label %145
    i32 47, label %148
    i32 48, label %151
    i32 49, label %154
    i32 50, label %157
    i32 51, label %160
    i32 52, label %163
    i32 53, label %166
    i32 54, label %169
    i32 55, label %172
    i32 56, label %175
    i32 57, label %178
    i32 58, label %181
    i32 59, label %184
  ]

; <label>:7                                       ; preds = %5
  %8 = load i32* %1, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %1, align 4
  br label %190

; <label>:10                                      ; preds = %5
  %11 = load i32* %1, align 4
  %12 = add nsw i32 %11, 1
  store i32 %12, i32* %1, align 4
  br label %190

; <label>:13                                      ; preds = %5
  %14 = load i32* %1, align 4
  %15 = add nsw i32 %14, 1
  store i32 %15, i32* %1, align 4
  br label %190

; <label>:16                                      ; preds = %5
  %17 = load i32* %1, align 4
  %18 = add nsw i32 %17, 1
  store i32 %18, i32* %1, align 4
  br label %190

; <label>:19                                      ; preds = %5
  %20 = load i32* %1, align 4
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %1, align 4
  br label %190

; <label>:22                                      ; preds = %5
  %23 = load i32* %1, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %1, align 4
  br label %190

; <label>:25                                      ; preds = %5
  %26 = load i32* %1, align 4
  %27 = add nsw i32 %26, 1
  store i32 %27, i32* %1, align 4
  br label %190

; <label>:28                                      ; preds = %5
  %29 = load i32* %1, align 4
  %30 = add nsw i32 %29, 1
  store i32 %30, i32* %1, align 4
  br label %190

; <label>:31                                      ; preds = %5
  %32 = load i32* %1, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, i32* %1, align 4
  br label %190

; <label>:34                                      ; preds = %5
  %35 = load i32* %1, align 4
  %36 = add nsw i32 %35, 1
  store i32 %36, i32* %1, align 4
  br label %190

; <label>:37                                      ; preds = %5
  %38 = load i32* %1, align 4
  %39 = add nsw i32 %38, 1
  store i32 %39, i32* %1, align 4
  br label %190

; <label>:40                                      ; preds = %5
  %41 = load i32* %1, align 4
  %42 = add nsw i32 %41, 1
  store i32 %42, i32* %1, align 4
  br label %190

; <label>:43                                      ; preds = %5
  %44 = load i32* %1, align 4
  %45 = add nsw i32 %44, 1
  store i32 %45, i32* %1, align 4
  br label %190

; <label>:46                                      ; preds = %5
  %47 = load i32* %1, align 4
  %48 = add nsw i32 %47, 1
  store i32 %48, i32* %1, align 4
  br label %190

; <label>:49                                      ; preds = %5
  %50 = load i32* %1, align 4
  %51 = add nsw i32 %50, 1
  store i32 %51, i32* %1, align 4
  br label %190

; <label>:52                                      ; preds = %5
  %53 = load i32* %1, align 4
  %54 = add nsw i32 %53, 1
  store i32 %54, i32* %1, align 4
  br label %190

; <label>:55                                      ; preds = %5
  %56 = load i32* %1, align 4
  %57 = add nsw i32 %56, 1
  store i32 %57, i32* %1, align 4
  br label %190

; <label>:58                                      ; preds = %5
  %59 = load i32* %1, align 4
  %60 = add nsw i32 %59, 1
  store i32 %60, i32* %1, align 4
  br label %190

; <label>:61                                      ; preds = %5
  %62 = load i32* %1, align 4
  %63 = add nsw i32 %62, 1
  store i32 %63, i32* %1, align 4
  br label %190

; <label>:64                                      ; preds = %5
  %65 = load i32* %1, align 4
  %66 = add nsw i32 %65, 1
  store i32 %66, i32* %1, align 4
  br label %190

; <label>:67                                      ; preds = %5
  %68 = load i32* %1, align 4
  %69 = add nsw i32 %68, 1
  store i32 %69, i32* %1, align 4
  br label %190

; <label>:70                                      ; preds = %5
  %71 = load i32* %1, align 4
  %72 = add nsw i32 %71, 1
  store i32 %72, i32* %1, align 4
  br label %190

; <label>:73                                      ; preds = %5
  %74 = load i32* %1, align 4
  %75 = add nsw i32 %74, 1
  store i32 %75, i32* %1, align 4
  br label %190

; <label>:76                                      ; preds = %5
  %77 = load i32* %1, align 4
  %78 = add nsw i32 %77, 1
  store i32 %78, i32* %1, align 4
  br label %190

; <label>:79                                      ; preds = %5
  %80 = load i32* %1, align 4
  %81 = add nsw i32 %80, 1
  store i32 %81, i32* %1, align 4
  br label %190

; <label>:82                                      ; preds = %5
  %83 = load i32* %1, align 4
  %84 = add nsw i32 %83, 1
  store i32 %84, i32* %1, align 4
  br label %190

; <label>:85                                      ; preds = %5
  %86 = load i32* %1, align 4
  %87 = add nsw i32 %86, 1
  store i32 %87, i32* %1, align 4
  br label %190

; <label>:88                                      ; preds = %5
  %89 = load i32* %1, align 4
  %90 = add nsw i32 %89, 1
  store i32 %90, i32* %1, align 4
  br label %190

; <label>:91                                      ; preds = %5
  %92 = load i32* %1, align 4
  %93 = add nsw i32 %92, 1
  store i32 %93, i32* %1, align 4
  br label %190

; <label>:94                                      ; preds = %5
  %95 = load i32* %1, align 4
  %96 = add nsw i32 %95, 1
  store i32 %96, i32* %1, align 4
  br label %190

; <label>:97                                      ; preds = %5
  %98 = load i32* %1, align 4
  %99 = add nsw i32 %98, 1
  store i32 %99, i32* %1, align 4
  br label %190

; <label>:100                                     ; preds = %5
  %101 = load i32* %1, align 4
  %102 = add nsw i32 %101, 1
  store i32 %102, i32* %1, align 4
  br label %190

; <label>:103                                     ; preds = %5
  %104 = load i32* %1, align 4
  %105 = add nsw i32 %104, 1
  store i32 %105, i32* %1, align 4
  br label %190

; <label>:106                                     ; preds = %5
  %107 = load i32* %1, align 4
  %108 = add nsw i32 %107, 1
  store i32 %108, i32* %1, align 4
  br label %190

; <label>:109                                     ; preds = %5
  %110 = load i32* %1, align 4
  %111 = add nsw i32 %110, 1
  store i32 %111, i32* %1, align 4
  br label %190

; <label>:112                                     ; preds = %5
  %113 = load i32* %1, align 4
  %114 = add nsw i32 %113, 1
  store i32 %114, i32* %1, align 4
  br label %190

; <label>:115                                     ; preds = %5
  %116 = load i32* %1, align 4
  %117 = add nsw i32 %116, 1
  store i32 %117, i32* %1, align 4
  br label %190

; <label>:118                                     ; preds = %5
  %119 = load i32* %1, align 4
  %120 = add nsw i32 %119, 1
  store i32 %120, i32* %1, align 4
  br label %190

; <label>:121                                     ; preds = %5
  %122 = load i32* %1, align 4
  %123 = add nsw i32 %122, 1
  store i32 %123, i32* %1, align 4
  br label %190

; <label>:124                                     ; preds = %5
  %125 = load i32* %1, align 4
  %126 = add nsw i32 %125, 1
  store i32 %126, i32* %1, align 4
  br label %190

; <label>:127                                     ; preds = %5
  %128 = load i32* %1, align 4
  %129 = add nsw i32 %128, 1
  store i32 %129, i32* %1, align 4
  br label %190

; <label>:130                                     ; preds = %5
  %131 = load i32* %1, align 4
  %132 = add nsw i32 %131, 1
  store i32 %132, i32* %1, align 4
  br label %190

; <label>:133                                     ; preds = %5
  %134 = load i32* %1, align 4
  %135 = add nsw i32 %134, 1
  store i32 %135, i32* %1, align 4
  br label %190

; <label>:136                                     ; preds = %5
  %137 = load i32* %1, align 4
  %138 = add nsw i32 %137, 1
  store i32 %138, i32* %1, align 4
  br label %190

; <label>:139                                     ; preds = %5
  %140 = load i32* %1, align 4
  %141 = add nsw i32 %140, 1
  store i32 %141, i32* %1, align 4
  br label %190

; <label>:142                                     ; preds = %5
  %143 = load i32* %1, align 4
  %144 = add nsw i32 %143, 1
  store i32 %144, i32* %1, align 4
  br label %190

; <label>:145                                     ; preds = %5
  %146 = load i32* %1, align 4
  %147 = add nsw i32 %146, 1
  store i32 %147, i32* %1, align 4
  br label %190

; <label>:148                                     ; preds = %5
  %149 = load i32* %1, align 4
  %150 = add nsw i32 %149, 1
  store i32 %150, i32* %1, align 4
  br label %190

; <label>:151                                     ; preds = %5
  %152 = load i32* %1, align 4
  %153 = add nsw i32 %152, 1
  store i32 %153, i32* %1, align 4
  br label %190

; <label>:154                                     ; preds = %5
  %155 = load i32* %1, align 4
  %156 = add nsw i32 %155, 1
  store i32 %156, i32* %1, align 4
  br label %190

; <label>:157                                     ; preds = %5
  %158 = load i32* %1, align 4
  %159 = add nsw i32 %158, 1
  store i32 %159, i32* %1, align 4
  br label %190

; <label>:160                                     ; preds = %5
  %161 = load i32* %1, align 4
  %162 = add nsw i32 %161, 1
  store i32 %162, i32* %1, align 4
  br label %190

; <label>:163                                     ; preds = %5
  %164 = load i32* %1, align 4
  %165 = add nsw i32 %164, 1
  store i32 %165, i32* %1, align 4
  br label %190

; <label>:166                                     ; preds = %5
  %167 = load i32* %1, align 4
  %168 = add nsw i32 %167, 1
  store i32 %168, i32* %1, align 4
  br label %190

; <label>:169                                     ; preds = %5
  %170 = load i32* %1, align 4
  %171 = add nsw i32 %170, 1
  store i32 %171, i32* %1, align 4
  br label %190

; <label>:172                                     ; preds = %5
  %173 = load i32* %1, align 4
  %174 = add nsw i32 %173, 1
  store i32 %174, i32* %1, align 4
  br label %190

; <label>:175                                     ; preds = %5
  %176 = load i32* %1, align 4
  %177 = add nsw i32 %176, 1
  store i32 %177, i32* %1, align 4
  br label %190

; <label>:178                                     ; preds = %5
  %179 = load i32* %1, align 4
  %180 = add nsw i32 %179, 1
  store i32 %180, i32* %1, align 4
  br label %190

; <label>:181                                     ; preds = %5
  %182 = load i32* %1, align 4
  %183 = add nsw i32 %182, 1
  store i32 %183, i32* %1, align 4
  br label %190

; <label>:184                                     ; preds = %5
  %185 = load i32* %1, align 4
  %186 = add nsw i32 %185, 1
  store i32 %186, i32* %1, align 4
  br label %190

; <label>:187                                     ; preds = %5
  %188 = load i32* %1, align 4
  %189 = add nsw i32 %188, -1
  store i32 %189, i32* %1, align 4
  br label %190

; <label>:190                                     ; preds = %187, %184, %181, %178, %175, %172, %169, %166, %163, %160, %157, %154, %151, %148, %145, %142, %139, %136, %133, %130, %127, %124, %121, %118, %115, %112, %109, %106, %103, %100, %97, %94, %91, %88, %85, %82, %79, %76, %73, %70, %67, %64, %61, %58, %55, %52, %49, %46, %43, %40, %37, %34, %31, %28, %25, %22, %19, %16, %13, %10, %7
  br label %191

; <label>:191                                     ; preds = %190
  %192 = load i32* %i, align 4
  %193 = add nsw i32 %192, 1
  store i32 %193, i32* %i, align 4
  br label %2

; <label>:194                                     ; preds = %2
  %195 = load i32* %1, align 4
  ret i32 %195
}

; Function Attrs: nounwind uwtable
define i32 @swi10(i32 %c) #0 {
  %1 = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 %c, i32* %1, align 4
  store i32 0, i32* %i, align 4
  br label %2

; <label>:2                                       ; preds = %41, %0
  %3 = load i32* %i, align 4
  %4 = icmp slt i32 %3, 10
  br i1 %4, label %5, label %44

; <label>:5                                       ; preds = %2
  %6 = load i32* %i, align 4
  switch i32 %6, label %37 [
    i32 0, label %7
    i32 1, label %10
    i32 2, label %13
    i32 3, label %16
    i32 4, label %19
    i32 5, label %22
    i32 6, label %25
    i32 7, label %28
    i32 8, label %31
    i32 9, label %34
  ]

; <label>:7                                       ; preds = %5
  %8 = load i32* %1, align 4
  %9 = add nsw i32 %8, 1
  store i32 %9, i32* %1, align 4
  br label %40

; <label>:10                                      ; preds = %5
  %11 = load i32* %1, align 4
  %12 = add nsw i32 %11, 1
  store i32 %12, i32* %1, align 4
  br label %40

; <label>:13                                      ; preds = %5
  %14 = load i32* %1, align 4
  %15 = add nsw i32 %14, 1
  store i32 %15, i32* %1, align 4
  br label %40

; <label>:16                                      ; preds = %5
  %17 = load i32* %1, align 4
  %18 = add nsw i32 %17, 1
  store i32 %18, i32* %1, align 4
  br label %40

; <label>:19                                      ; preds = %5
  %20 = load i32* %1, align 4
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %1, align 4
  br label %40

; <label>:22                                      ; preds = %5
  %23 = load i32* %1, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %1, align 4
  br label %40

; <label>:25                                      ; preds = %5
  %26 = load i32* %1, align 4
  %27 = add nsw i32 %26, 1
  store i32 %27, i32* %1, align 4
  br label %40

; <label>:28                                      ; preds = %5
  %29 = load i32* %1, align 4
  %30 = add nsw i32 %29, 1
  store i32 %30, i32* %1, align 4
  br label %40

; <label>:31                                      ; preds = %5
  %32 = load i32* %1, align 4
  %33 = add nsw i32 %32, 1
  store i32 %33, i32* %1, align 4
  br label %40

; <label>:34                                      ; preds = %5
  %35 = load i32* %1, align 4
  %36 = add nsw i32 %35, 1
  store i32 %36, i32* %1, align 4
  br label %40

; <label>:37                                      ; preds = %5
  %38 = load i32* %1, align 4
  %39 = add nsw i32 %38, -1
  store i32 %39, i32* %1, align 4
  br label %40

; <label>:40                                      ; preds = %37, %34, %31, %28, %25, %22, %19, %16, %13, %10, %7
  br label %41

; <label>:41                                      ; preds = %40
  %42 = load i32* %i, align 4
  %43 = add nsw i32 %42, 1
  store i32 %43, i32* %i, align 4
  br label %2

; <label>:44                                      ; preds = %2
  %45 = load i32* %1, align 4
  ret i32 %45
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %cnt = alloca i32, align 4
  store i32 0, i32* %1
  store volatile i32 0, i32* %cnt, align 4
  %2 = load volatile i32* %cnt, align 4
  %3 = call i32 @swi10(i32 %2)
  store volatile i32 %3, i32* %cnt, align 4
  %4 = load volatile i32* %cnt, align 4
  %5 = call i32 @swi50(i32 %4)
  store volatile i32 %5, i32* %cnt, align 4
  %6 = load volatile i32* %cnt, align 4
  %7 = call i32 @swi120(i32 %6)
  store volatile i32 %7, i32* %cnt, align 4
  %8 = load volatile i32* %cnt, align 4
  ret i32 %8
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
