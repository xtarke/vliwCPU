; ModuleID = 'ndes.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

%struct.GREAT = type { i64, i64, i64 }
%struct.IMMENSE = type { i64, i64 }

@des.ip = internal global [65 x i8] c"\00:2*\22\1A\12\0A\02<4,$\1C\14\0C\04>6.&\1E\16\0E\06@80( \18\10\0891)!\19\11\09\01;3+#\1B\13\0B\03=5-%\1D\15\0D\05?7/'\1F\17\0F\07", align 16
@des.ipm = internal global [65 x i8] c"\00(\080\108\18@ '\07/\0F7\17?\1F&\06.\0E6\16>\1E%\05-\0D5\15=\1D$\04,\0C4\14<\1C#\03+\0B3\13;\1B\22\02*\0A2\12:\1A!\01)\091\119\19", align 16
@des.kns = internal global [17 x %struct.GREAT] zeroinitializer, align 16
@des.initflag = internal global i32 1, align 4
@bit = common global [33 x i64] zeroinitializer, align 16
@icd = internal global %struct.IMMENSE zeroinitializer, align 8
@ipc1 = internal global [57 x i8] c"\0091)!\19\11\09\01:2*\22\1A\12\0A\02;3+#\1B\13\0B\03<4,$?7/'\1F\17\0F\07>6.&\1E\16\0E\06=5-%\1D\15\0D\05\1C\14\0C\04", align 16
@ipc2 = internal global [49 x i8] c"\00\0E\11\0B\18\01\05\03\1C\0F\06\15\0A\17\13\0C\04\1A\08\10\07\1B\14\0D\02)4\1F%/7\1E(3-!0,1'8\225.*2$\1D ", align 16
@cyfun.iet = internal global [49 x i32] [i32 0, i32 32, i32 1, i32 2, i32 3, i32 4, i32 5, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 12, i32 13, i32 14, i32 15, i32 16, i32 17, i32 16, i32 17, i32 18, i32 19, i32 20, i32 21, i32 20, i32 21, i32 22, i32 23, i32 24, i32 25, i32 24, i32 25, i32 26, i32 27, i32 28, i32 29, i32 28, i32 29, i32 30, i32 31, i32 32, i32 1], align 16
@cyfun.ipp = internal global [33 x i32] [i32 0, i32 16, i32 7, i32 20, i32 21, i32 29, i32 12, i32 28, i32 17, i32 1, i32 15, i32 23, i32 26, i32 5, i32 18, i32 31, i32 10, i32 2, i32 8, i32 24, i32 14, i32 32, i32 27, i32 3, i32 9, i32 19, i32 13, i32 30, i32 6, i32 22, i32 11, i32 4, i32 25], align 16
@cyfun.is = internal global [16 x [4 x [9 x i8]]] [[4 x [9 x i8]] [[9 x i8] c"\00\0E\0F\0A\07\02\0C\04\0D", [9 x i8] c"\00\00\03\0D\0D\0E\0A\0D\01", [9 x i8] c"\00\04\00\0D\0A\04\09\01\07", [9 x i8] c"\00\0F\0D\01\03\0B\04\06\02"], [4 x [9 x i8]] [[9 x i8] c"\00\04\01\00\0D\0C\01\0B\02", [9 x i8] c"\00\0F\0D\07\08\0B\0F\00\0F", [9 x i8] c"\00\01\0E\06\06\02\0E\04\0B", [9 x i8] c"\00\0C\08\0A\0F\08\03\0B\01"], [4 x [9 x i8]] [[9 x i8] c"\00\0D\08\09\0E\04\0A\02\08", [9 x i8] c"\00\07\04\00\0B\02\04\0B\0D", [9 x i8] c"\00\0E\07\04\09\01\0F\0B\04", [9 x i8] c"\00\08\0A\0D\00\0C\02\0D\0E"], [4 x [9 x i8]] [[9 x i8] c"\00\01\0E\0E\03\01\0F\0E\04", [9 x i8] c"\00\04\07\09\05\0C\02\07\08", [9 x i8] c"\00\08\0B\09\00\0B\05\0D\01", [9 x i8] c"\00\02\01\00\06\07\0C\08\07"], [4 x [9 x i8]] [[9 x i8] c"\00\02\06\06\00\07\09\0F\06", [9 x i8] c"\00\0E\0F\03\06\04\07\04\0A", [9 x i8] c"\00\0D\0A\08\0C\0A\02\0C\09", [9 x i8] c"\00\04\03\06\0A\01\09\01\04"], [4 x [9 x i8]] [[9 x i8] c"\00\0F\0B\03\06\0A\02\00\0F", [9 x i8] c"\00\02\02\04\0F\07\0C\09\03", [9 x i8] c"\00\06\04\0F\0B\0D\08\03\0C", [9 x i8] c"\00\09\0F\09\01\0E\05\04\0A"], [4 x [9 x i8]] [[9 x i8] c"\00\0B\03\0F\09\0B\06\08\0B", [9 x i8] c"\00\0D\08\06\00\0D\09\01\07", [9 x i8] c"\00\02\0D\03\07\07\0C\07\0E", [9 x i8] c"\00\01\04\08\0D\02\0F\0A\08"], [4 x [9 x i8]] [[9 x i8] c"\00\08\04\05\0A\06\08\0D\01", [9 x i8] c"\00\01\0E\0A\03\01\05\0A\04", [9 x i8] c"\00\0B\01\00\0D\08\03\0E\02", [9 x i8] c"\00\07\02\07\08\0D\0A\07\0D"], [4 x [9 x i8]] [[9 x i8] c"\00\03\09\01\01\08\00\03\0A", [9 x i8] c"\00\0A\0C\02\04\05\06\0E\0C", [9 x i8] c"\00\0F\05\0B\0F\0F\07\0A\00", [9 x i8] c"\00\05\0B\04\09\06\0B\09\0F"], [4 x [9 x i8]] [[9 x i8] c"\00\0A\07\0D\02\05\0D\0C\09", [9 x i8] c"\00\06\00\08\07\00\01\03\05", [9 x i8] c"\00\0C\08\01\01\09\00\0F\06", [9 x i8] c"\00\0B\06\0F\04\0F\0E\05\0C"], [4 x [9 x i8]] [[9 x i8] c"\00\06\02\0C\08\03\03\09\03", [9 x i8] c"\00\0C\01\05\02\0F\0D\05\06", [9 x i8] c"\00\09\0C\02\03\0C\04\06\0A", [9 x i8] c"\00\03\07\0E\05\00\01\00\09"], [4 x [9 x i8]] [[9 x i8] c"\00\0C\0D\07\05\0F\04\07\0E", [9 x i8] c"\00\0B\0A\0E\0C\0A\0E\0C\0B", [9 x i8] c"\00\07\06\0C\0E\05\0A\08\0D", [9 x i8] c"\00\0E\0C\03\0B\09\07\0F\00"], [4 x [9 x i8]] [[9 x i8] c"\00\05\0C\0B\0B\0D\0E\05\05", [9 x i8] c"\00\09\06\0C\01\03\00\02\00", [9 x i8] c"\00\03\09\05\05\06\01\00\0F", [9 x i8] c"\00\0A\00\0B\0C\0A\06\0E\03"], [4 x [9 x i8]] [[9 x i8] c"\00\09\00\04\0C\00\07\0A\00", [9 x i8] c"\00\05\09\0B\0A\09\0B\0F\0E", [9 x i8] c"\00\0A\03\0A\02\03\0D\05\03", [9 x i8] c"\00\00\05\05\07\04\00\02\05"], [4 x [9 x i8]] [[9 x i8] c"\00\00\05\02\04\0E\05\06\0C", [9 x i8] c"\00\03\0B\0F\0E\08\03\08\09", [9 x i8] c"\00\05\02\0E\08\00\0B\09\05", [9 x i8] c"\00\06\0E\02\02\05\08\03\06"], [4 x [9 x i8]] [[9 x i8] c"\00\07\0A\08\0F\09\0B\01\07", [9 x i8] c"\00\08\05\01\09\06\08\06\02", [9 x i8] c"\00\00\0F\07\04\0E\06\02\08", [9 x i8] c"\00\0D\09\0C\0E\03\0D\0C\0B"]], align 16
@cyfun.ibin = internal global [16 x i8] c"\00\08\04\0C\02\0A\06\0E\01\09\05\0D\03\0B\07\0F", align 16
@value = global i32 1, align 4

; Function Attrs: nounwind uwtable
define void @des(i64 %inp.coerce0, i64 %inp.coerce1, i64 %key.coerce0, i64 %key.coerce1, i32* %newkey, i32 %isw, %struct.IMMENSE* %out) #0 {
  %inp = alloca %struct.IMMENSE, align 8
  %key = alloca %struct.IMMENSE, align 8
  %1 = alloca i32*, align 8
  %2 = alloca i32, align 4
  %3 = alloca %struct.IMMENSE*, align 8
  %ii = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %ic = alloca i64, align 8
  %shifter = alloca i64, align 8
  %itmp = alloca %struct.IMMENSE, align 8
  %pg = alloca %struct.GREAT, align 8
  %4 = bitcast %struct.IMMENSE* %inp to { i64, i64 }*
  %5 = getelementptr { i64, i64 }* %4, i32 0, i32 0
  store i64 %inp.coerce0, i64* %5
  %6 = getelementptr { i64, i64 }* %4, i32 0, i32 1
  store i64 %inp.coerce1, i64* %6
  %7 = bitcast %struct.IMMENSE* %key to { i64, i64 }*
  %8 = getelementptr { i64, i64 }* %7, i32 0, i32 0
  store i64 %key.coerce0, i64* %8
  %9 = getelementptr { i64, i64 }* %7, i32 0, i32 1
  store i64 %key.coerce1, i64* %9
  store i32* %newkey, i32** %1, align 8
  store i32 %isw, i32* %2, align 4
  store %struct.IMMENSE* %out, %struct.IMMENSE** %3, align 8
  %10 = load i32* @des.initflag, align 4
  %11 = icmp ne i32 %10, 0
  br i1 %11, label %12, label %26

; <label>:12                                      ; preds = %0
  store i32 0, i32* @des.initflag, align 4
  store i64 1, i64* %shifter, align 8
  store i64 1, i64* getelementptr inbounds ([33 x i64]* @bit, i32 0, i64 1), align 8
  store i32 2, i32* %j, align 4
  br label %13

; <label>:13                                      ; preds = %22, %12
  %14 = load i32* %j, align 4
  %15 = icmp sle i32 %14, 32
  br i1 %15, label %16, label %25

; <label>:16                                      ; preds = %13
  %17 = load i64* %shifter, align 8
  %18 = shl i64 %17, 1
  store i64 %18, i64* %shifter, align 8
  %19 = load i32* %j, align 4
  %20 = sext i32 %19 to i64
  %21 = getelementptr inbounds [33 x i64]* @bit, i32 0, i64 %20
  store i64 %18, i64* %21, align 8
  br label %22

; <label>:22                                      ; preds = %16
  %23 = load i32* %j, align 4
  %24 = add nsw i32 %23, 1
  store i32 %24, i32* %j, align 4
  br label %13

; <label>:25                                      ; preds = %13
  br label %26

; <label>:26                                      ; preds = %25, %0
  %27 = load i32** %1, align 8
  %28 = load i32* %27, align 4
  %29 = icmp ne i32 %28, 0
  br i1 %29, label %30, label %89

; <label>:30                                      ; preds = %26
  %31 = load i32** %1, align 8
  store i32 0, i32* %31, align 4
  store i64 0, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  store i64 0, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  store i32 28, i32* %j, align 4
  store i32 56, i32* %k, align 4
  br label %32

; <label>:32                                      ; preds = %64, %30
  %33 = load i32* %j, align 4
  %34 = icmp sge i32 %33, 1
  br i1 %34, label %35, label %69

; <label>:35                                      ; preds = %32
  %36 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  %37 = shl i64 %36, 1
  store i64 %37, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  %38 = load i32* %j, align 4
  %39 = sext i32 %38 to i64
  %40 = getelementptr inbounds [57 x i8]* @ipc1, i32 0, i64 %39
  %41 = load i8* %40, align 1
  %42 = sext i8 %41 to i32
  %43 = bitcast %struct.IMMENSE* %key to { i64, i64 }*
  %44 = getelementptr { i64, i64 }* %43, i32 0, i32 0
  %45 = load i64* %44, align 1
  %46 = getelementptr { i64, i64 }* %43, i32 0, i32 1
  %47 = load i64* %46, align 1
  %48 = call i64 @getbit(i64 %45, i64 %47, i32 %42, i32 32)
  %49 = or i64 %37, %48
  store i64 %49, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  %50 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  %51 = shl i64 %50, 1
  store i64 %51, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  %52 = load i32* %k, align 4
  %53 = sext i32 %52 to i64
  %54 = getelementptr inbounds [57 x i8]* @ipc1, i32 0, i64 %53
  %55 = load i8* %54, align 1
  %56 = sext i8 %55 to i32
  %57 = bitcast %struct.IMMENSE* %key to { i64, i64 }*
  %58 = getelementptr { i64, i64 }* %57, i32 0, i32 0
  %59 = load i64* %58, align 1
  %60 = getelementptr { i64, i64 }* %57, i32 0, i32 1
  %61 = load i64* %60, align 1
  %62 = call i64 @getbit(i64 %59, i64 %61, i32 %56, i32 32)
  %63 = or i64 %51, %62
  store i64 %63, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  br label %64

; <label>:64                                      ; preds = %35
  %65 = load i32* %j, align 4
  %66 = add nsw i32 %65, -1
  store i32 %66, i32* %j, align 4
  %67 = load i32* %k, align 4
  %68 = add nsw i32 %67, -1
  store i32 %68, i32* %k, align 4
  br label %32

; <label>:69                                      ; preds = %32
  store i32 1, i32* %i, align 4
  br label %70

; <label>:70                                      ; preds = %85, %69
  %71 = load i32* %i, align 4
  %72 = icmp sle i32 %71, 16
  br i1 %72, label %73, label %88

; <label>:73                                      ; preds = %70
  %74 = load i32* %i, align 4
  %75 = sext i32 %74 to i64
  %76 = getelementptr inbounds [17 x %struct.GREAT]* @des.kns, i32 0, i64 %75
  %77 = bitcast %struct.GREAT* %pg to i8*
  %78 = bitcast %struct.GREAT* %76 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %77, i8* %78, i64 24, i32 8, i1 false)
  %79 = load i32* %i, align 4
  call void @ks(i32 %79, %struct.GREAT* %pg)
  %80 = load i32* %i, align 4
  %81 = sext i32 %80 to i64
  %82 = getelementptr inbounds [17 x %struct.GREAT]* @des.kns, i32 0, i64 %81
  %83 = bitcast %struct.GREAT* %82 to i8*
  %84 = bitcast %struct.GREAT* %pg to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %83, i8* %84, i64 24, i32 8, i1 false)
  br label %85

; <label>:85                                      ; preds = %73
  %86 = load i32* %i, align 4
  %87 = add nsw i32 %86, 1
  store i32 %87, i32* %i, align 4
  br label %70

; <label>:88                                      ; preds = %70
  br label %89

; <label>:89                                      ; preds = %88, %26
  %90 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 0
  store i64 0, i64* %90, align 8
  %91 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 1
  store i64 0, i64* %91, align 8
  store i32 32, i32* %j, align 4
  store i32 64, i32* %k, align 4
  br label %92

; <label>:92                                      ; preds = %128, %89
  %93 = load i32* %j, align 4
  %94 = icmp sge i32 %93, 1
  br i1 %94, label %95, label %133

; <label>:95                                      ; preds = %92
  %96 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 1
  %97 = load i64* %96, align 8
  %98 = shl i64 %97, 1
  store i64 %98, i64* %96, align 8
  %99 = load i32* %j, align 4
  %100 = sext i32 %99 to i64
  %101 = getelementptr inbounds [65 x i8]* @des.ip, i32 0, i64 %100
  %102 = load i8* %101, align 1
  %103 = sext i8 %102 to i32
  %104 = bitcast %struct.IMMENSE* %inp to { i64, i64 }*
  %105 = getelementptr { i64, i64 }* %104, i32 0, i32 0
  %106 = load i64* %105, align 1
  %107 = getelementptr { i64, i64 }* %104, i32 0, i32 1
  %108 = load i64* %107, align 1
  %109 = call i64 @getbit(i64 %106, i64 %108, i32 %103, i32 32)
  %110 = or i64 %98, %109
  %111 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 1
  store i64 %110, i64* %111, align 8
  %112 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 0
  %113 = load i64* %112, align 8
  %114 = shl i64 %113, 1
  store i64 %114, i64* %112, align 8
  %115 = load i32* %k, align 4
  %116 = sext i32 %115 to i64
  %117 = getelementptr inbounds [65 x i8]* @des.ip, i32 0, i64 %116
  %118 = load i8* %117, align 1
  %119 = sext i8 %118 to i32
  %120 = bitcast %struct.IMMENSE* %inp to { i64, i64 }*
  %121 = getelementptr { i64, i64 }* %120, i32 0, i32 0
  %122 = load i64* %121, align 1
  %123 = getelementptr { i64, i64 }* %120, i32 0, i32 1
  %124 = load i64* %123, align 1
  %125 = call i64 @getbit(i64 %122, i64 %124, i32 %119, i32 32)
  %126 = or i64 %114, %125
  %127 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 0
  store i64 %126, i64* %127, align 8
  br label %128

; <label>:128                                     ; preds = %95
  %129 = load i32* %j, align 4
  %130 = add nsw i32 %129, -1
  store i32 %130, i32* %j, align 4
  %131 = load i32* %k, align 4
  %132 = add nsw i32 %131, -1
  store i32 %132, i32* %k, align 4
  br label %92

; <label>:133                                     ; preds = %92
  store i32 1, i32* %i, align 4
  br label %134

; <label>:134                                     ; preds = %161, %133
  %135 = load i32* %i, align 4
  %136 = icmp sle i32 %135, 16
  br i1 %136, label %137, label %164

; <label>:137                                     ; preds = %134
  %138 = load i32* %2, align 4
  %139 = icmp eq i32 %138, 1
  br i1 %139, label %140, label %143

; <label>:140                                     ; preds = %137
  %141 = load i32* %i, align 4
  %142 = sub nsw i32 17, %141
  br label %145

; <label>:143                                     ; preds = %137
  %144 = load i32* %i, align 4
  br label %145

; <label>:145                                     ; preds = %143, %140
  %146 = phi i32 [ %142, %140 ], [ %144, %143 ]
  store i32 %146, i32* %ii, align 4
  %147 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 0
  %148 = load i64* %147, align 8
  %149 = load i32* %ii, align 4
  %150 = sext i32 %149 to i64
  %151 = getelementptr inbounds [17 x %struct.GREAT]* @des.kns, i32 0, i64 %150
  call void @cyfun(i64 %148, %struct.GREAT* byval align 8 %151, i64* %ic)
  %152 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 1
  %153 = load i64* %152, align 8
  %154 = load i64* %ic, align 8
  %155 = xor i64 %154, %153
  store i64 %155, i64* %ic, align 8
  %156 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 0
  %157 = load i64* %156, align 8
  %158 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 1
  store i64 %157, i64* %158, align 8
  %159 = load i64* %ic, align 8
  %160 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 0
  store i64 %159, i64* %160, align 8
  br label %161

; <label>:161                                     ; preds = %145
  %162 = load i32* %i, align 4
  %163 = add nsw i32 %162, 1
  store i32 %163, i32* %i, align 4
  br label %134

; <label>:164                                     ; preds = %134
  %165 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 1
  %166 = load i64* %165, align 8
  store i64 %166, i64* %ic, align 8
  %167 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 0
  %168 = load i64* %167, align 8
  %169 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 1
  store i64 %168, i64* %169, align 8
  %170 = load i64* %ic, align 8
  %171 = getelementptr inbounds %struct.IMMENSE* %itmp, i32 0, i32 0
  store i64 %170, i64* %171, align 8
  %172 = load %struct.IMMENSE** %3, align 8
  %173 = getelementptr inbounds %struct.IMMENSE* %172, i32 0, i32 0
  store i64 0, i64* %173, align 8
  %174 = load %struct.IMMENSE** %3, align 8
  %175 = getelementptr inbounds %struct.IMMENSE* %174, i32 0, i32 1
  store i64 0, i64* %175, align 8
  store i32 32, i32* %j, align 4
  store i32 64, i32* %k, align 4
  br label %176

; <label>:176                                     ; preds = %216, %164
  %177 = load i32* %j, align 4
  %178 = icmp sge i32 %177, 1
  br i1 %178, label %179, label %221

; <label>:179                                     ; preds = %176
  %180 = load %struct.IMMENSE** %3, align 8
  %181 = getelementptr inbounds %struct.IMMENSE* %180, i32 0, i32 1
  %182 = load i64* %181, align 8
  %183 = shl i64 %182, 1
  store i64 %183, i64* %181, align 8
  %184 = load i32* %j, align 4
  %185 = sext i32 %184 to i64
  %186 = getelementptr inbounds [65 x i8]* @des.ipm, i32 0, i64 %185
  %187 = load i8* %186, align 1
  %188 = sext i8 %187 to i32
  %189 = bitcast %struct.IMMENSE* %itmp to { i64, i64 }*
  %190 = getelementptr { i64, i64 }* %189, i32 0, i32 0
  %191 = load i64* %190, align 1
  %192 = getelementptr { i64, i64 }* %189, i32 0, i32 1
  %193 = load i64* %192, align 1
  %194 = call i64 @getbit(i64 %191, i64 %193, i32 %188, i32 32)
  %195 = or i64 %183, %194
  %196 = load %struct.IMMENSE** %3, align 8
  %197 = getelementptr inbounds %struct.IMMENSE* %196, i32 0, i32 1
  store i64 %195, i64* %197, align 8
  %198 = load %struct.IMMENSE** %3, align 8
  %199 = getelementptr inbounds %struct.IMMENSE* %198, i32 0, i32 0
  %200 = load i64* %199, align 8
  %201 = shl i64 %200, 1
  store i64 %201, i64* %199, align 8
  %202 = load i32* %k, align 4
  %203 = sext i32 %202 to i64
  %204 = getelementptr inbounds [65 x i8]* @des.ipm, i32 0, i64 %203
  %205 = load i8* %204, align 1
  %206 = sext i8 %205 to i32
  %207 = bitcast %struct.IMMENSE* %itmp to { i64, i64 }*
  %208 = getelementptr { i64, i64 }* %207, i32 0, i32 0
  %209 = load i64* %208, align 1
  %210 = getelementptr { i64, i64 }* %207, i32 0, i32 1
  %211 = load i64* %210, align 1
  %212 = call i64 @getbit(i64 %209, i64 %211, i32 %206, i32 32)
  %213 = or i64 %201, %212
  %214 = load %struct.IMMENSE** %3, align 8
  %215 = getelementptr inbounds %struct.IMMENSE* %214, i32 0, i32 0
  store i64 %213, i64* %215, align 8
  br label %216

; <label>:216                                     ; preds = %179
  %217 = load i32* %j, align 4
  %218 = add nsw i32 %217, -1
  store i32 %218, i32* %j, align 4
  %219 = load i32* %k, align 4
  %220 = add nsw i32 %219, -1
  store i32 %220, i32* %k, align 4
  br label %176

; <label>:221                                     ; preds = %176
  ret void
}

; Function Attrs: nounwind uwtable
define i64 @getbit(i64 %source.coerce0, i64 %source.coerce1, i32 %bitno, i32 %nbits) #0 {
  %1 = alloca i64, align 8
  %source = alloca %struct.IMMENSE, align 8
  %2 = alloca i32, align 4
  %3 = alloca i32, align 4
  %4 = bitcast %struct.IMMENSE* %source to { i64, i64 }*
  %5 = getelementptr { i64, i64 }* %4, i32 0, i32 0
  store i64 %source.coerce0, i64* %5
  %6 = getelementptr { i64, i64 }* %4, i32 0, i32 1
  store i64 %source.coerce1, i64* %6
  store i32 %bitno, i32* %2, align 4
  store i32 %nbits, i32* %3, align 4
  %7 = load i32* %2, align 4
  %8 = load i32* %3, align 4
  %9 = icmp sle i32 %7, %8
  br i1 %9, label %10, label %20

; <label>:10                                      ; preds = %0
  %11 = load i32* %2, align 4
  %12 = sext i32 %11 to i64
  %13 = getelementptr inbounds [33 x i64]* @bit, i32 0, i64 %12
  %14 = load i64* %13, align 8
  %15 = getelementptr inbounds %struct.IMMENSE* %source, i32 0, i32 1
  %16 = load i64* %15, align 8
  %17 = and i64 %14, %16
  %18 = icmp ne i64 %17, 0
  %19 = select i1 %18, i64 1, i64 0
  store i64 %19, i64* %1
  br label %32

; <label>:20                                      ; preds = %0
  %21 = load i32* %2, align 4
  %22 = load i32* %3, align 4
  %23 = sub nsw i32 %21, %22
  %24 = sext i32 %23 to i64
  %25 = getelementptr inbounds [33 x i64]* @bit, i32 0, i64 %24
  %26 = load i64* %25, align 8
  %27 = getelementptr inbounds %struct.IMMENSE* %source, i32 0, i32 0
  %28 = load i64* %27, align 8
  %29 = and i64 %26, %28
  %30 = icmp ne i64 %29, 0
  %31 = select i1 %30, i64 1, i64 0
  store i64 %31, i64* %1
  br label %32

; <label>:32                                      ; preds = %20, %10
  %33 = load i64* %1
  ret i64 %33
}

; Function Attrs: nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture, i64, i32, i1) #1

; Function Attrs: nounwind uwtable
define void @ks(i32 %n, %struct.GREAT* %kn) #0 {
  %1 = alloca i32, align 4
  %2 = alloca %struct.GREAT*, align 8
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %k = alloca i32, align 4
  %l = alloca i32, align 4
  store i32 %n, i32* %1, align 4
  store %struct.GREAT* %kn, %struct.GREAT** %2, align 8
  %3 = load i32* %1, align 4
  %4 = icmp eq i32 %3, 1
  br i1 %4, label %14, label %5

; <label>:5                                       ; preds = %0
  %6 = load i32* %1, align 4
  %7 = icmp eq i32 %6, 2
  br i1 %7, label %14, label %8

; <label>:8                                       ; preds = %5
  %9 = load i32* %1, align 4
  %10 = icmp eq i32 %9, 9
  br i1 %10, label %14, label %11

; <label>:11                                      ; preds = %8
  %12 = load i32* %1, align 4
  %13 = icmp eq i32 %12, 16
  br i1 %13, label %14, label %27

; <label>:14                                      ; preds = %11, %8, %5, %0
  %15 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  %16 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  %17 = and i64 %16, 1
  %18 = shl i64 %17, 28
  %19 = or i64 %15, %18
  %20 = lshr i64 %19, 1
  store i64 %20, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  %21 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  %22 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  %23 = and i64 %22, 1
  %24 = shl i64 %23, 28
  %25 = or i64 %21, %24
  %26 = lshr i64 %25, 1
  store i64 %26, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  br label %48

; <label>:27                                      ; preds = %11
  store i32 1, i32* %i, align 4
  br label %28

; <label>:28                                      ; preds = %44, %27
  %29 = load i32* %i, align 4
  %30 = icmp sle i32 %29, 2
  br i1 %30, label %31, label %47

; <label>:31                                      ; preds = %28
  %32 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  %33 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  %34 = and i64 %33, 1
  %35 = shl i64 %34, 28
  %36 = or i64 %32, %35
  %37 = lshr i64 %36, 1
  store i64 %37, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 1), align 8
  %38 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  %39 = load i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  %40 = and i64 %39, 1
  %41 = shl i64 %40, 28
  %42 = or i64 %38, %41
  %43 = lshr i64 %42, 1
  store i64 %43, i64* getelementptr inbounds (%struct.IMMENSE* @icd, i32 0, i32 0), align 8
  br label %44

; <label>:44                                      ; preds = %31
  %45 = load i32* %i, align 4
  %46 = add nsw i32 %45, 1
  store i32 %46, i32* %i, align 4
  br label %28

; <label>:47                                      ; preds = %28
  br label %48

; <label>:48                                      ; preds = %47, %14
  %49 = load %struct.GREAT** %2, align 8
  %50 = getelementptr inbounds %struct.GREAT* %49, i32 0, i32 0
  store i64 0, i64* %50, align 8
  %51 = load %struct.GREAT** %2, align 8
  %52 = getelementptr inbounds %struct.GREAT* %51, i32 0, i32 1
  store i64 0, i64* %52, align 8
  %53 = load %struct.GREAT** %2, align 8
  %54 = getelementptr inbounds %struct.GREAT* %53, i32 0, i32 2
  store i64 0, i64* %54, align 8
  store i32 16, i32* %j, align 4
  store i32 32, i32* %k, align 4
  store i32 48, i32* %l, align 4
  br label %55

; <label>:55                                      ; preds = %110, %48
  %56 = load i32* %j, align 4
  %57 = icmp sge i32 %56, 1
  br i1 %57, label %58, label %117

; <label>:58                                      ; preds = %55
  %59 = load %struct.GREAT** %2, align 8
  %60 = getelementptr inbounds %struct.GREAT* %59, i32 0, i32 2
  %61 = load i64* %60, align 8
  %62 = shl i64 %61, 1
  store i64 %62, i64* %60, align 8
  %63 = load i32* %j, align 4
  %64 = sext i32 %63 to i64
  %65 = getelementptr inbounds [49 x i8]* @ipc2, i32 0, i64 %64
  %66 = load i8* %65, align 1
  %67 = sext i8 %66 to i32
  %68 = load i64* getelementptr ({ i64, i64 }* bitcast (%struct.IMMENSE* @icd to { i64, i64 }*), i32 0, i32 0), align 1
  %69 = load i64* getelementptr ({ i64, i64 }* bitcast (%struct.IMMENSE* @icd to { i64, i64 }*), i32 0, i32 1), align 1
  %70 = call i64 @getbit(i64 %68, i64 %69, i32 %67, i32 28)
  %71 = trunc i64 %70 to i16
  %72 = zext i16 %71 to i64
  %73 = or i64 %62, %72
  %74 = load %struct.GREAT** %2, align 8
  %75 = getelementptr inbounds %struct.GREAT* %74, i32 0, i32 2
  store i64 %73, i64* %75, align 8
  %76 = load %struct.GREAT** %2, align 8
  %77 = getelementptr inbounds %struct.GREAT* %76, i32 0, i32 1
  %78 = load i64* %77, align 8
  %79 = shl i64 %78, 1
  store i64 %79, i64* %77, align 8
  %80 = load i32* %k, align 4
  %81 = sext i32 %80 to i64
  %82 = getelementptr inbounds [49 x i8]* @ipc2, i32 0, i64 %81
  %83 = load i8* %82, align 1
  %84 = sext i8 %83 to i32
  %85 = load i64* getelementptr ({ i64, i64 }* bitcast (%struct.IMMENSE* @icd to { i64, i64 }*), i32 0, i32 0), align 1
  %86 = load i64* getelementptr ({ i64, i64 }* bitcast (%struct.IMMENSE* @icd to { i64, i64 }*), i32 0, i32 1), align 1
  %87 = call i64 @getbit(i64 %85, i64 %86, i32 %84, i32 28)
  %88 = trunc i64 %87 to i16
  %89 = zext i16 %88 to i64
  %90 = or i64 %79, %89
  %91 = load %struct.GREAT** %2, align 8
  %92 = getelementptr inbounds %struct.GREAT* %91, i32 0, i32 1
  store i64 %90, i64* %92, align 8
  %93 = load %struct.GREAT** %2, align 8
  %94 = getelementptr inbounds %struct.GREAT* %93, i32 0, i32 0
  %95 = load i64* %94, align 8
  %96 = shl i64 %95, 1
  store i64 %96, i64* %94, align 8
  %97 = load i32* %l, align 4
  %98 = sext i32 %97 to i64
  %99 = getelementptr inbounds [49 x i8]* @ipc2, i32 0, i64 %98
  %100 = load i8* %99, align 1
  %101 = sext i8 %100 to i32
  %102 = load i64* getelementptr ({ i64, i64 }* bitcast (%struct.IMMENSE* @icd to { i64, i64 }*), i32 0, i32 0), align 1
  %103 = load i64* getelementptr ({ i64, i64 }* bitcast (%struct.IMMENSE* @icd to { i64, i64 }*), i32 0, i32 1), align 1
  %104 = call i64 @getbit(i64 %102, i64 %103, i32 %101, i32 28)
  %105 = trunc i64 %104 to i16
  %106 = zext i16 %105 to i64
  %107 = or i64 %96, %106
  %108 = load %struct.GREAT** %2, align 8
  %109 = getelementptr inbounds %struct.GREAT* %108, i32 0, i32 0
  store i64 %107, i64* %109, align 8
  br label %110

; <label>:110                                     ; preds = %58
  %111 = load i32* %j, align 4
  %112 = add nsw i32 %111, -1
  store i32 %112, i32* %j, align 4
  %113 = load i32* %k, align 4
  %114 = add nsw i32 %113, -1
  store i32 %114, i32* %k, align 4
  %115 = load i32* %l, align 4
  %116 = add nsw i32 %115, -1
  store i32 %116, i32* %l, align 4
  br label %55

; <label>:117                                     ; preds = %55
  ret void
}

; Function Attrs: nounwind uwtable
define void @cyfun(i64 %ir, %struct.GREAT* byval align 8 %k, i64* %iout) #0 {
  %1 = alloca i64, align 8
  %2 = alloca i64*, align 8
  %ie = alloca %struct.GREAT, align 8
  %itmp = alloca i64, align 8
  %ietmp1 = alloca i64, align 8
  %ietmp2 = alloca i64, align 8
  %iec = alloca [9 x i8], align 1
  %jj = alloca i32, align 4
  %irow = alloca i32, align 4
  %icol = alloca i32, align 4
  %iss = alloca i32, align 4
  %j = alloca i32, align 4
  %l = alloca i32, align 4
  %m = alloca i32, align 4
  %p = alloca i64*, align 8
  store i64 %ir, i64* %1, align 8
  store i64* %iout, i64** %2, align 8
  store i64* getelementptr inbounds ([33 x i64]* @bit, i32 0, i32 0), i64** %p, align 8
  %3 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 0
  store i64 0, i64* %3, align 8
  %4 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 1
  store i64 0, i64* %4, align 8
  %5 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 2
  store i64 0, i64* %5, align 8
  store i32 16, i32* %j, align 4
  store i32 32, i32* %l, align 4
  store i32 48, i32* %m, align 4
  br label %6

; <label>:6                                       ; preds = %64, %0
  %7 = load i32* %j, align 4
  %8 = icmp sge i32 %7, 1
  br i1 %8, label %9, label %71

; <label>:9                                       ; preds = %6
  %10 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 2
  %11 = load i64* %10, align 8
  %12 = shl i64 %11, 1
  store i64 %12, i64* %10, align 8
  %13 = load i32* %j, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds [49 x i32]* @cyfun.iet, i32 0, i64 %14
  %16 = load i32* %15, align 4
  %17 = sext i32 %16 to i64
  %18 = load i64** %p, align 8
  %19 = getelementptr inbounds i64* %18, i64 %17
  %20 = load i64* %19, align 8
  %21 = load i64* %1, align 8
  %22 = and i64 %20, %21
  %23 = icmp ne i64 %22, 0
  %24 = select i1 %23, i32 1, i32 0
  %25 = sext i32 %24 to i64
  %26 = or i64 %12, %25
  %27 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 2
  store i64 %26, i64* %27, align 8
  %28 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 1
  %29 = load i64* %28, align 8
  %30 = shl i64 %29, 1
  store i64 %30, i64* %28, align 8
  %31 = load i32* %l, align 4
  %32 = sext i32 %31 to i64
  %33 = getelementptr inbounds [49 x i32]* @cyfun.iet, i32 0, i64 %32
  %34 = load i32* %33, align 4
  %35 = sext i32 %34 to i64
  %36 = load i64** %p, align 8
  %37 = getelementptr inbounds i64* %36, i64 %35
  %38 = load i64* %37, align 8
  %39 = load i64* %1, align 8
  %40 = and i64 %38, %39
  %41 = icmp ne i64 %40, 0
  %42 = select i1 %41, i32 1, i32 0
  %43 = sext i32 %42 to i64
  %44 = or i64 %30, %43
  %45 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 1
  store i64 %44, i64* %45, align 8
  %46 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 0
  %47 = load i64* %46, align 8
  %48 = shl i64 %47, 1
  store i64 %48, i64* %46, align 8
  %49 = load i32* %m, align 4
  %50 = sext i32 %49 to i64
  %51 = getelementptr inbounds [49 x i32]* @cyfun.iet, i32 0, i64 %50
  %52 = load i32* %51, align 4
  %53 = sext i32 %52 to i64
  %54 = load i64** %p, align 8
  %55 = getelementptr inbounds i64* %54, i64 %53
  %56 = load i64* %55, align 8
  %57 = load i64* %1, align 8
  %58 = and i64 %56, %57
  %59 = icmp ne i64 %58, 0
  %60 = select i1 %59, i32 1, i32 0
  %61 = sext i32 %60 to i64
  %62 = or i64 %48, %61
  %63 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 0
  store i64 %62, i64* %63, align 8
  br label %64

; <label>:64                                      ; preds = %9
  %65 = load i32* %j, align 4
  %66 = add nsw i32 %65, -1
  store i32 %66, i32* %j, align 4
  %67 = load i32* %l, align 4
  %68 = add nsw i32 %67, -1
  store i32 %68, i32* %l, align 4
  %69 = load i32* %m, align 4
  %70 = add nsw i32 %69, -1
  store i32 %70, i32* %m, align 4
  br label %6

; <label>:71                                      ; preds = %6
  %72 = getelementptr inbounds %struct.GREAT* %k, i32 0, i32 2
  %73 = load i64* %72, align 8
  %74 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 2
  %75 = load i64* %74, align 8
  %76 = xor i64 %75, %73
  store i64 %76, i64* %74, align 8
  %77 = getelementptr inbounds %struct.GREAT* %k, i32 0, i32 1
  %78 = load i64* %77, align 8
  %79 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 1
  %80 = load i64* %79, align 8
  %81 = xor i64 %80, %78
  store i64 %81, i64* %79, align 8
  %82 = getelementptr inbounds %struct.GREAT* %k, i32 0, i32 0
  %83 = load i64* %82, align 8
  %84 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 0
  %85 = load i64* %84, align 8
  %86 = xor i64 %85, %83
  store i64 %86, i64* %84, align 8
  %87 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 1
  %88 = load i64* %87, align 8
  %89 = shl i64 %88, 16
  %90 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 2
  %91 = load i64* %90, align 8
  %92 = add i64 %89, %91
  store i64 %92, i64* %ietmp1, align 8
  %93 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 0
  %94 = load i64* %93, align 8
  %95 = shl i64 %94, 8
  %96 = getelementptr inbounds %struct.GREAT* %ie, i32 0, i32 1
  %97 = load i64* %96, align 8
  %98 = lshr i64 %97, 8
  %99 = add i64 %95, %98
  store i64 %99, i64* %ietmp2, align 8
  store i32 1, i32* %j, align 4
  store i32 5, i32* %m, align 4
  br label %100

; <label>:100                                     ; preds = %120, %71
  %101 = load i32* %j, align 4
  %102 = icmp sle i32 %101, 4
  br i1 %102, label %103, label %125

; <label>:103                                     ; preds = %100
  %104 = load i64* %ietmp1, align 8
  %105 = and i64 %104, 63
  %106 = trunc i64 %105 to i8
  %107 = load i32* %j, align 4
  %108 = sext i32 %107 to i64
  %109 = getelementptr inbounds [9 x i8]* %iec, i32 0, i64 %108
  store i8 %106, i8* %109, align 1
  %110 = load i64* %ietmp2, align 8
  %111 = and i64 %110, 63
  %112 = trunc i64 %111 to i8
  %113 = load i32* %m, align 4
  %114 = sext i32 %113 to i64
  %115 = getelementptr inbounds [9 x i8]* %iec, i32 0, i64 %114
  store i8 %112, i8* %115, align 1
  %116 = load i64* %ietmp1, align 8
  %117 = lshr i64 %116, 6
  store i64 %117, i64* %ietmp1, align 8
  %118 = load i64* %ietmp2, align 8
  %119 = lshr i64 %118, 6
  store i64 %119, i64* %ietmp2, align 8
  br label %120

; <label>:120                                     ; preds = %103
  %121 = load i32* %j, align 4
  %122 = add nsw i32 %121, 1
  store i32 %122, i32* %j, align 4
  %123 = load i32* %m, align 4
  %124 = add nsw i32 %123, 1
  store i32 %124, i32* %m, align 4
  br label %100

; <label>:125                                     ; preds = %100
  store i64 0, i64* %itmp, align 8
  store i32 8, i32* %jj, align 4
  br label %126

; <label>:126                                     ; preds = %175, %125
  %127 = load i32* %jj, align 4
  %128 = icmp sge i32 %127, 1
  br i1 %128, label %129, label %178

; <label>:129                                     ; preds = %126
  %130 = load i32* %jj, align 4
  %131 = sext i32 %130 to i64
  %132 = getelementptr inbounds [9 x i8]* %iec, i32 0, i64 %131
  %133 = load i8* %132, align 1
  %134 = sext i8 %133 to i32
  store i32 %134, i32* %j, align 4
  %135 = load i32* %j, align 4
  %136 = and i32 %135, 1
  %137 = shl i32 %136, 1
  %138 = load i32* %j, align 4
  %139 = and i32 %138, 32
  %140 = ashr i32 %139, 5
  %141 = add nsw i32 %137, %140
  store i32 %141, i32* %irow, align 4
  %142 = load i32* %j, align 4
  %143 = and i32 %142, 2
  %144 = shl i32 %143, 2
  %145 = load i32* %j, align 4
  %146 = and i32 %145, 4
  %147 = add nsw i32 %144, %146
  %148 = load i32* %j, align 4
  %149 = and i32 %148, 8
  %150 = ashr i32 %149, 2
  %151 = add nsw i32 %147, %150
  %152 = load i32* %j, align 4
  %153 = and i32 %152, 16
  %154 = ashr i32 %153, 4
  %155 = add nsw i32 %151, %154
  store i32 %155, i32* %icol, align 4
  %156 = load i32* %jj, align 4
  %157 = sext i32 %156 to i64
  %158 = load i32* %irow, align 4
  %159 = sext i32 %158 to i64
  %160 = load i32* %icol, align 4
  %161 = sext i32 %160 to i64
  %162 = getelementptr inbounds [16 x [4 x [9 x i8]]]* @cyfun.is, i32 0, i64 %161
  %163 = getelementptr inbounds [4 x [9 x i8]]* %162, i32 0, i64 %159
  %164 = getelementptr inbounds [9 x i8]* %163, i32 0, i64 %157
  %165 = load i8* %164, align 1
  %166 = sext i8 %165 to i32
  store i32 %166, i32* %iss, align 4
  %167 = load i64* %itmp, align 8
  %168 = shl i64 %167, 4
  store i64 %168, i64* %itmp, align 8
  %169 = load i32* %iss, align 4
  %170 = sext i32 %169 to i64
  %171 = getelementptr inbounds [16 x i8]* @cyfun.ibin, i32 0, i64 %170
  %172 = load i8* %171, align 1
  %173 = sext i8 %172 to i64
  %174 = or i64 %168, %173
  store i64 %174, i64* %itmp, align 8
  br label %175

; <label>:175                                     ; preds = %129
  %176 = load i32* %jj, align 4
  %177 = add nsw i32 %176, -1
  store i32 %177, i32* %jj, align 4
  br label %126

; <label>:178                                     ; preds = %126
  %179 = load i64** %2, align 8
  store i64 0, i64* %179, align 8
  store i64* getelementptr inbounds ([33 x i64]* @bit, i32 0, i32 0), i64** %p, align 8
  store i32 32, i32* %j, align 4
  br label %180

; <label>:180                                     ; preds = %202, %178
  %181 = load i32* %j, align 4
  %182 = icmp sge i32 %181, 1
  br i1 %182, label %183, label %205

; <label>:183                                     ; preds = %180
  %184 = load i64** %2, align 8
  %185 = load i64* %184, align 8
  %186 = shl i64 %185, 1
  store i64 %186, i64* %184, align 8
  %187 = load i32* %j, align 4
  %188 = sext i32 %187 to i64
  %189 = getelementptr inbounds [33 x i32]* @cyfun.ipp, i32 0, i64 %188
  %190 = load i32* %189, align 4
  %191 = sext i32 %190 to i64
  %192 = load i64** %p, align 8
  %193 = getelementptr inbounds i64* %192, i64 %191
  %194 = load i64* %193, align 8
  %195 = load i64* %itmp, align 8
  %196 = and i64 %194, %195
  %197 = icmp ne i64 %196, 0
  %198 = select i1 %197, i32 1, i32 0
  %199 = sext i32 %198 to i64
  %200 = or i64 %186, %199
  %201 = load i64** %2, align 8
  store i64 %200, i64* %201, align 8
  br label %202

; <label>:202                                     ; preds = %183
  %203 = load i32* %j, align 4
  %204 = add nsw i32 %203, -1
  store i32 %204, i32* %j, align 4
  br label %180

; <label>:205                                     ; preds = %180
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %inp = alloca %struct.IMMENSE, align 8
  %key = alloca %struct.IMMENSE, align 8
  %out = alloca %struct.IMMENSE, align 8
  %newkey = alloca i32, align 4
  %isw = alloca i32, align 4
  store i32 0, i32* %1
  %2 = getelementptr inbounds %struct.IMMENSE* %inp, i32 0, i32 0
  store i64 35, i64* %2, align 8
  %3 = getelementptr inbounds %struct.IMMENSE* %inp, i32 0, i32 1
  store i64 26, i64* %3, align 8
  %4 = getelementptr inbounds %struct.IMMENSE* %key, i32 0, i32 0
  store i64 2, i64* %4, align 8
  %5 = getelementptr inbounds %struct.IMMENSE* %key, i32 0, i32 1
  store i64 16, i64* %5, align 8
  %6 = load i32* @value, align 4
  store i32 %6, i32* %newkey, align 4
  %7 = load i32* @value, align 4
  store i32 %7, i32* %isw, align 4
  %8 = load i32* %isw, align 4
  %9 = bitcast %struct.IMMENSE* %inp to { i64, i64 }*
  %10 = getelementptr { i64, i64 }* %9, i32 0, i32 0
  %11 = load i64* %10, align 1
  %12 = getelementptr { i64, i64 }* %9, i32 0, i32 1
  %13 = load i64* %12, align 1
  %14 = bitcast %struct.IMMENSE* %key to { i64, i64 }*
  %15 = getelementptr { i64, i64 }* %14, i32 0, i32 0
  %16 = load i64* %15, align 1
  %17 = getelementptr { i64, i64 }* %14, i32 0, i32 1
  %18 = load i64* %17, align 1
  call void @des(i64 %11, i64 %13, i64 %16, i64 %18, i32* %newkey, i32 %8, %struct.IMMENSE* %out)
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind }
