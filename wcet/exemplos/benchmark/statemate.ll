; ModuleID = 'statemate.c'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@Bitlist = internal global [64 x i8] zeroinitializer, align 16
@time = common global i64 0, align 8
@tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRL = common global i64 0, align 8
@tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRLexited_BEREIT_FH_TUERMODUL_CTRL = common global i64 0, align 8
@sc_FH_TUERMODUL_CTRL_2375_2 = common global i64 0, align 8
@FH_TUERMODUL__MFHA_copy = common global i8 0, align 1
@sc_FH_TUERMODUL_CTRL_2352_1 = common global i64 0, align 8
@FH_TUERMODUL__MFHZ_copy = common global i8 0, align 1
@sc_FH_TUERMODUL_CTRL_2329_1 = common global i64 0, align 8
@sc_FH_TUERMODUL_CTRL_1781_10 = common global i64 0, align 8
@sc_FH_TUERMODUL_CTRL_1739_10 = common global i64 0, align 8
@BLOCK_ERKENNUNG_CTRL__N = common global i32 0, align 4
@BLOCK_ERKENNUNG_CTRL__N_old = common global i32 0, align 4
@tm_entered_EINSCHALTSTROM_MESSEN_BLOCK_ERKENNUNG_CTRLch_BLOCK_ERKENNUNG_CTRL__N_copy = common global i64 0, align 8
@NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state = common global i8 0, align 1
@ZENTRAL_KINDERSICHERUNG_CTRL_next_state = common global i8 0, align 1
@MEC_KINDERSICHERUNG_CTRL_next_state = common global i8 0, align 1
@KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state = common global i8 0, align 1
@B_FH_TUERMODUL_CTRL_next_state = common global i8 0, align 1
@A_FH_TUERMODUL_CTRL_next_state = common global i8 0, align 1
@WIEDERHOLSPERRE_FH_TUERMODUL_CTRL_next_state = common global i8 0, align 1
@INITIALISIERT_FH_TUERMODUL_CTRL_next_state = common global i8 0, align 1
@TIPP_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state = common global i8 0, align 1
@MANUELL_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state = common global i8 0, align 1
@OEFFNEN_FH_TUERMODUL_CTRL_next_state = common global i8 0, align 1
@SCHLIESSEN_FH_TUERMODUL_CTRL_next_state = common global i8 0, align 1
@FH_STEUERUNG_DUMMY_FH_STEUERUNG_DUMMY_next_state = common global i8 0, align 1
@EINKLEMMSCHUTZ_CTRL_EINKLEMMSCHUTZ_CTRL_next_state = common global i8 0, align 1
@BEWEGUNG_BLOCK_ERKENNUNG_CTRL_next_state = common global i8 0, align 1
@BLOCK_ERKENNUNG_CTRL_BLOCK_ERKENNUNG_CTRL_next_state = common global i8 0, align 1
@FH_TUERMODUL__SFHA_ZENTRAL = common global i8 0, align 1
@FH_TUERMODUL__SFHZ_ZENTRAL = common global i8 0, align 1
@stable = common global i8 0, align 1
@FH_TUERMODUL__SFHZ_copy = common global i8 0, align 1
@FH_TUERMODUL__SFHA_copy = common global i8 0, align 1
@FH_TUERMODUL__SFHA_ZENTRAL_old = common global i8 0, align 1
@FH_TUERMODUL__SFHZ_ZENTRAL_old = common global i8 0, align 1
@FH_TUERMODUL__SFHA_MEC = common global i8 0, align 1
@FH_TUERMODUL__SFHZ_MEC = common global i8 0, align 1
@FH_TUERMODUL__SFHA_MEC_old = common global i8 0, align 1
@FH_TUERMODUL__SFHZ_MEC_old = common global i8 0, align 1
@FH_TUERMODUL__KL_50 = common global i8 0, align 1
@FH_TUERMODUL_CTRL__N = common global i32 0, align 4
@FH_TUERMODUL_CTRL__N_old = common global i32 0, align 4
@FH_TUERMODUL__BLOCK = common global i8 0, align 1
@FH_TUERMODUL__BLOCK_old = common global i8 0, align 1
@FH_TUERMODUL__MFHZ = common global i8 0, align 1
@FH_TUERMODUL__SFHZ = common global i8 0, align 1
@FH_TUERMODUL__SFHA = common global i8 0, align 1
@FH_TUERMODUL_CTRL__INREVERS1 = common global i8 0, align 1
@FH_TUERMODUL_CTRL__INREVERS2 = common global i8 0, align 1
@FH_TUERMODUL__MFHA = common global i8 0, align 1
@FH_TUERMODUL__POSITION = common global i32 0, align 4
@FH_TUERMODUL__SFHZ_old = common global i8 0, align 1
@FH_TUERMODUL__SFHA_old = common global i8 0, align 1
@FH_TUERMODUL_CTRL__INREVERS2_copy = common global i8 0, align 1
@FH_TUERMODUL_CTRL__INREVERS1_copy = common global i8 0, align 1
@step = common global i8 0, align 1
@FH_TUERMODUL__EKS_LEISTE_AKTIV = common global i8 0, align 1
@FH_TUERMODUL__EKS_LEISTE_AKTIV_old = common global i8 0, align 1
@FH_TUERMODUL__I_EIN = common global i32 0, align 4
@FH_TUERMODUL__I_EIN_old = common global i32 0, align 4
@FH_TUERMODUL__BLOCK_copy = common global i8 0, align 1
@BLOCK_ERKENNUNG_CTRL__I_EIN_MAX = common global i32 0, align 4
@FH_TUERMODUL__MFHA_old = common global i8 0, align 1
@FH_TUERMODUL__MFHZ_old = common global i8 0, align 1
@FH_DU__MFHZ = common global i8 0, align 1
@FH_DU__MFHZ_old = common global i8 0, align 1
@FH_DU__MFH = common global i32 0, align 4
@FH_DU__MFHA = common global i8 0, align 1
@FH_DU__MFHA_old = common global i8 0, align 1
@FH_DU__S_FH_TMBFZUCAN = common global i8 0, align 1
@FH_DU__S_FH_TMBFZUCAN_old = common global i8 0, align 1
@FH_DU__DOOR_ID = common global i8 0, align 1
@FH_DU__S_FH_FTZU = common global i8 0, align 1
@FH_DU__S_FH_TMBFZUDISC = common global i8 0, align 1
@FH_DU__S_FH_TMBFZUDISC_old = common global i8 0, align 1
@FH_DU__S_FH_TMBFAUFCAN = common global i8 0, align 1
@FH_DU__S_FH_TMBFAUFCAN_old = common global i8 0, align 1
@FH_DU__S_FH_FTAUF = common global i8 0, align 1
@FH_DU__S_FH_TMBFAUFDISC = common global i8 0, align 1
@FH_DU__S_FH_TMBFAUFDISC_old = common global i8 0, align 1
@FH_DU__S_FH_AUFDISC = common global i8 0, align 1
@FH_DU__S_FH_ZUDISC = common global i8 0, align 1
@FH_DU__I_EIN = common global i32 0, align 4
@FH_DU__EKS_LEISTE_AKTIV = common global i8 0, align 1
@FH_DU__POSITION = common global i32 0, align 4
@FH_TUERMODUL__FT = common global i8 0, align 1
@FH_DU__FT = common global i8 0, align 1
@FH_DU__KL_50 = common global i8 0, align 1
@FH_DU__BLOCK = common global i8 0, align 1
@FH_DU__MFH_copy = common global i32 0, align 4
@FH_DU__I_EIN_old = common global i32 0, align 4
@FH_DU__EKS_LEISTE_AKTIV_old = common global i8 0, align 1
@FH_DU__BLOCK_copy = common global i8 0, align 1
@FH_DU__BLOCK_old = common global i8 0, align 1
@FH_DU__MFHZ_copy = common global i8 0, align 1
@FH_DU__MFHA_copy = common global i8 0, align 1
@FH_TUERMODUL_CTRL__N_copy = common global i32 0, align 4
@BLOCK_ERKENNUNG_CTRL__I_EIN_MAX_copy = common global i32 0, align 4
@BLOCK_ERKENNUNG_CTRL__N_copy = common global i32 0, align 4
@FH_TUERMODUL_CTRL__FT = common global i8 0, align 1
@FH_TUERMODUL__COM_OPEN = common global i8 0, align 1
@FH_TUERMODUL__COM_CLOSE = common global i8 0, align 1
@FH_DU__S_FH_TMBFAUFCAN_copy = common global i8 0, align 1
@FH_DU__S_FH_TMBFZUCAN_copy = common global i8 0, align 1

; Function Attrs: nounwind uwtable
define void @interface() #0 {
  %1 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 4), align 1
  %2 = icmp ne i8 %1, 0
  br i1 %2, label %3, label %5

; <label>:3                                       ; preds = %0
  %4 = load i64* @time, align 8
  store i64 %4, i64* @tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRL, align 8
  br label %5

; <label>:5                                       ; preds = %3, %0
  %6 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 4), align 1
  %7 = sext i8 %6 to i32
  %8 = icmp ne i32 %7, 0
  br i1 %8, label %13, label %9

; <label>:9                                       ; preds = %5
  %10 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 6), align 1
  %11 = sext i8 %10 to i32
  %12 = icmp ne i32 %11, 0
  br i1 %12, label %13, label %15

; <label>:13                                      ; preds = %9, %5
  %14 = load i64* @time, align 8
  store i64 %14, i64* @tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRLexited_BEREIT_FH_TUERMODUL_CTRL, align 8
  br label %15

; <label>:15                                      ; preds = %13, %9
  %16 = load i64* @sc_FH_TUERMODUL_CTRL_2375_2, align 8
  %17 = icmp ne i64 %16, 0
  br i1 %17, label %18, label %25

; <label>:18                                      ; preds = %15
  %19 = load i64* @time, align 8
  %20 = load i64* @sc_FH_TUERMODUL_CTRL_2375_2, align 8
  %21 = sub i64 %19, %20
  %22 = uitofp i64 %21 to double
  %23 = fcmp oge double %22, 5.000000e-01
  br i1 %23, label %24, label %25

; <label>:24                                      ; preds = %18
  store i8 0, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i64 0, i64* @sc_FH_TUERMODUL_CTRL_2375_2, align 8
  br label %25

; <label>:25                                      ; preds = %24, %18, %15
  %26 = load i64* @sc_FH_TUERMODUL_CTRL_2352_1, align 8
  %27 = icmp ne i64 %26, 0
  br i1 %27, label %28, label %35

; <label>:28                                      ; preds = %25
  %29 = load i64* @time, align 8
  %30 = load i64* @sc_FH_TUERMODUL_CTRL_2352_1, align 8
  %31 = sub i64 %29, %30
  %32 = uitofp i64 %31 to double
  %33 = fcmp oge double %32, 5.000000e-01
  br i1 %33, label %34, label %35

; <label>:34                                      ; preds = %28
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i64 0, i64* @sc_FH_TUERMODUL_CTRL_2352_1, align 8
  br label %35

; <label>:35                                      ; preds = %34, %28, %25
  %36 = load i64* @sc_FH_TUERMODUL_CTRL_2329_1, align 8
  %37 = icmp ne i64 %36, 0
  br i1 %37, label %38, label %45

; <label>:38                                      ; preds = %35
  %39 = load i64* @time, align 8
  %40 = load i64* @sc_FH_TUERMODUL_CTRL_2329_1, align 8
  %41 = sub i64 %39, %40
  %42 = uitofp i64 %41 to double
  %43 = fcmp oge double %42, 5.000000e-01
  br i1 %43, label %44, label %45

; <label>:44                                      ; preds = %38
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i64 0, i64* @sc_FH_TUERMODUL_CTRL_2329_1, align 8
  br label %45

; <label>:45                                      ; preds = %44, %38, %35
  %46 = load i64* @sc_FH_TUERMODUL_CTRL_1781_10, align 8
  %47 = icmp ne i64 %46, 0
  br i1 %47, label %48, label %55

; <label>:48                                      ; preds = %45
  %49 = load i64* @time, align 8
  %50 = load i64* @sc_FH_TUERMODUL_CTRL_1781_10, align 8
  %51 = sub i64 %49, %50
  %52 = uitofp i64 %51 to double
  %53 = fcmp oge double %52, 5.000000e-01
  br i1 %53, label %54, label %55

; <label>:54                                      ; preds = %48
  store i64 0, i64* @sc_FH_TUERMODUL_CTRL_1781_10, align 8
  br label %55

; <label>:55                                      ; preds = %54, %48, %45
  %56 = load i64* @sc_FH_TUERMODUL_CTRL_1739_10, align 8
  %57 = icmp ne i64 %56, 0
  br i1 %57, label %58, label %65

; <label>:58                                      ; preds = %55
  %59 = load i64* @time, align 8
  %60 = load i64* @sc_FH_TUERMODUL_CTRL_1739_10, align 8
  %61 = sub i64 %59, %60
  %62 = uitofp i64 %61 to double
  %63 = fcmp oge double %62, 5.000000e-01
  br i1 %63, label %64, label %65

; <label>:64                                      ; preds = %58
  store i64 0, i64* @sc_FH_TUERMODUL_CTRL_1739_10, align 8
  br label %65

; <label>:65                                      ; preds = %64, %58, %55
  %66 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 0), align 1
  %67 = sext i8 %66 to i32
  %68 = icmp ne i32 %67, 0
  br i1 %68, label %73, label %69

; <label>:69                                      ; preds = %65
  %70 = load i32* @BLOCK_ERKENNUNG_CTRL__N, align 4
  %71 = load i32* @BLOCK_ERKENNUNG_CTRL__N_old, align 4
  %72 = icmp ne i32 %70, %71
  br i1 %72, label %73, label %75

; <label>:73                                      ; preds = %69, %65
  %74 = load i64* @time, align 8
  store i64 %74, i64* @tm_entered_EINSCHALTSTROM_MESSEN_BLOCK_ERKENNUNG_CTRLch_BLOCK_ERKENNUNG_CTRL__N_copy, align 8
  br label %75

; <label>:75                                      ; preds = %73, %69
  ret void
}

; Function Attrs: nounwind uwtable
define void @init() #0 {
  store i64 0, i64* @tm_entered_EINSCHALTSTROM_MESSEN_BLOCK_ERKENNUNG_CTRLch_BLOCK_ERKENNUNG_CTRL__N_copy, align 8
  store i64 0, i64* @tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRLexited_BEREIT_FH_TUERMODUL_CTRL, align 8
  store i64 0, i64* @tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRL, align 8
  store i8 0, i8* @NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state, align 1
  store i8 0, i8* @ZENTRAL_KINDERSICHERUNG_CTRL_next_state, align 1
  store i8 0, i8* @MEC_KINDERSICHERUNG_CTRL_next_state, align 1
  store i8 0, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  store i8 0, i8* @B_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @A_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @WIEDERHOLSPERRE_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @TIPP_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @MANUELL_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @OEFFNEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @FH_STEUERUNG_DUMMY_FH_STEUERUNG_DUMMY_next_state, align 1
  store i8 0, i8* @EINKLEMMSCHUTZ_CTRL_EINKLEMMSCHUTZ_CTRL_next_state, align 1
  store i8 0, i8* @BEWEGUNG_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  store i8 0, i8* @BLOCK_ERKENNUNG_CTRL_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  ret void
}

; Function Attrs: nounwind uwtable
define void @generic_KINDERSICHERUNG_CTRL() #0 {
  %1 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 10), align 1
  %2 = icmp ne i8 %1, 0
  br i1 %2, label %3, label %168

; <label>:3                                       ; preds = %0
  %4 = load i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  %5 = sext i8 %4 to i32
  switch i32 %5, label %166 [
    i32 1, label %6
    i32 2, label %53
    i32 3, label %100
  ]

; <label>:6                                       ; preds = %3
  %7 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %8 = sext i8 %7 to i32
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %15, label %10

; <label>:10                                      ; preds = %6
  %11 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  %12 = sext i8 %11 to i32
  %13 = icmp ne i32 %12, 0
  br i1 %13, label %15, label %14

; <label>:14                                      ; preds = %10
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 0, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 3, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  store i8 0, i8* @ZENTRAL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %167

; <label>:15                                      ; preds = %10, %6
  %16 = load i8* @ZENTRAL_KINDERSICHERUNG_CTRL_next_state, align 1
  %17 = sext i8 %16 to i32
  switch i32 %17, label %51 [
    i32 1, label %18
  ]

; <label>:18                                      ; preds = %15
  %19 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %20 = sext i8 %19 to i32
  %21 = icmp ne i32 %20, 0
  br i1 %21, label %22, label %26

; <label>:22                                      ; preds = %18
  %23 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL_old, align 1
  %24 = icmp ne i8 %23, 0
  br i1 %24, label %26, label %25

; <label>:25                                      ; preds = %22
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 1, i8* @ZENTRAL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %52

; <label>:26                                      ; preds = %22, %18
  %27 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  %28 = sext i8 %27 to i32
  %29 = icmp ne i32 %28, 0
  br i1 %29, label %30, label %34

; <label>:30                                      ; preds = %26
  %31 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL_old, align 1
  %32 = icmp ne i8 %31, 0
  br i1 %32, label %34, label %33

; <label>:33                                      ; preds = %30
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 1, i8* @ZENTRAL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %52

; <label>:34                                      ; preds = %30, %26
  %35 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %36 = icmp ne i8 %35, 0
  br i1 %36, label %42, label %37

; <label>:37                                      ; preds = %34
  %38 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL_old, align 1
  %39 = sext i8 %38 to i32
  %40 = icmp ne i32 %39, 0
  br i1 %40, label %41, label %42

; <label>:41                                      ; preds = %37
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 1, i8* @ZENTRAL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %52

; <label>:42                                      ; preds = %37, %34
  %43 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  %44 = icmp ne i8 %43, 0
  br i1 %44, label %50, label %45

; <label>:45                                      ; preds = %42
  %46 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL_old, align 1
  %47 = sext i8 %46 to i32
  %48 = icmp ne i32 %47, 0
  br i1 %48, label %49, label %50

; <label>:49                                      ; preds = %45
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 1, i8* @ZENTRAL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %52

; <label>:50                                      ; preds = %45, %42
  br label %52

; <label>:51                                      ; preds = %15
  store i8 0, i8* @stable, align 1
  br label %52

; <label>:52                                      ; preds = %51, %50, %49, %41, %33, %25
  br label %167

; <label>:53                                      ; preds = %3
  %54 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %55 = sext i8 %54 to i32
  %56 = icmp ne i32 %55, 0
  br i1 %56, label %62, label %57

; <label>:57                                      ; preds = %53
  %58 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %59 = sext i8 %58 to i32
  %60 = icmp ne i32 %59, 0
  br i1 %60, label %62, label %61

; <label>:61                                      ; preds = %57
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 0, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 3, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  store i8 0, i8* @MEC_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %167

; <label>:62                                      ; preds = %57, %53
  %63 = load i8* @MEC_KINDERSICHERUNG_CTRL_next_state, align 1
  %64 = sext i8 %63 to i32
  switch i32 %64, label %98 [
    i32 1, label %65
  ]

; <label>:65                                      ; preds = %62
  %66 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %67 = sext i8 %66 to i32
  %68 = icmp ne i32 %67, 0
  br i1 %68, label %69, label %73

; <label>:69                                      ; preds = %65
  %70 = load i8* @FH_TUERMODUL__SFHA_MEC_old, align 1
  %71 = icmp ne i8 %70, 0
  br i1 %71, label %73, label %72

; <label>:72                                      ; preds = %69
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 1, i8* @MEC_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %99

; <label>:73                                      ; preds = %69, %65
  %74 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %75 = sext i8 %74 to i32
  %76 = icmp ne i32 %75, 0
  br i1 %76, label %77, label %81

; <label>:77                                      ; preds = %73
  %78 = load i8* @FH_TUERMODUL__SFHZ_MEC_old, align 1
  %79 = icmp ne i8 %78, 0
  br i1 %79, label %81, label %80

; <label>:80                                      ; preds = %77
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 1, i8* @MEC_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %99

; <label>:81                                      ; preds = %77, %73
  %82 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %83 = icmp ne i8 %82, 0
  br i1 %83, label %89, label %84

; <label>:84                                      ; preds = %81
  %85 = load i8* @FH_TUERMODUL__SFHA_MEC_old, align 1
  %86 = sext i8 %85 to i32
  %87 = icmp ne i32 %86, 0
  br i1 %87, label %88, label %89

; <label>:88                                      ; preds = %84
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 1, i8* @MEC_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %99

; <label>:89                                      ; preds = %84, %81
  %90 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %91 = icmp ne i8 %90, 0
  br i1 %91, label %97, label %92

; <label>:92                                      ; preds = %89
  %93 = load i8* @FH_TUERMODUL__SFHZ_MEC_old, align 1
  %94 = sext i8 %93 to i32
  %95 = icmp ne i32 %94, 0
  br i1 %95, label %96, label %97

; <label>:96                                      ; preds = %92
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 1, i8* @MEC_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %99

; <label>:97                                      ; preds = %92, %89
  br label %99

; <label>:98                                      ; preds = %62
  store i8 0, i8* @stable, align 1
  br label %99

; <label>:99                                      ; preds = %98, %97, %96, %88, %80, %72
  br label %167

; <label>:100                                     ; preds = %3
  %101 = load i8* @FH_TUERMODUL__KL_50, align 1
  %102 = icmp ne i8 %101, 0
  br i1 %102, label %112, label %103

; <label>:103                                     ; preds = %100
  %104 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %105 = sext i8 %104 to i32
  %106 = icmp ne i32 %105, 0
  br i1 %106, label %107, label %112

; <label>:107                                     ; preds = %103
  %108 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %109 = sext i8 %108 to i32
  %110 = icmp ne i32 %109, 0
  br i1 %110, label %111, label %112

; <label>:111                                     ; preds = %107
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 2, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %167

; <label>:112                                     ; preds = %107, %103, %100
  %113 = load i8* @FH_TUERMODUL__KL_50, align 1
  %114 = icmp ne i8 %113, 0
  br i1 %114, label %123, label %115

; <label>:115                                     ; preds = %112
  %116 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %117 = sext i8 %116 to i32
  %118 = icmp ne i32 %117, 0
  br i1 %118, label %119, label %123

; <label>:119                                     ; preds = %115
  %120 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %121 = icmp ne i8 %120, 0
  br i1 %121, label %123, label %122

; <label>:122                                     ; preds = %119
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 2, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %167

; <label>:123                                     ; preds = %119, %115, %112
  %124 = load i8* @FH_TUERMODUL__KL_50, align 1
  %125 = icmp ne i8 %124, 0
  br i1 %125, label %134, label %126

; <label>:126                                     ; preds = %123
  %127 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %128 = icmp ne i8 %127, 0
  br i1 %128, label %134, label %129

; <label>:129                                     ; preds = %126
  %130 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %131 = sext i8 %130 to i32
  %132 = icmp ne i32 %131, 0
  br i1 %132, label %133, label %134

; <label>:133                                     ; preds = %129
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 2, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %167

; <label>:134                                     ; preds = %129, %126, %123
  %135 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  %136 = icmp ne i8 %135, 0
  br i1 %136, label %145, label %137

; <label>:137                                     ; preds = %134
  %138 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %139 = sext i8 %138 to i32
  %140 = icmp ne i32 %139, 0
  br i1 %140, label %141, label %145

; <label>:141                                     ; preds = %137
  %142 = load i8* @FH_TUERMODUL__KL_50, align 1
  %143 = icmp ne i8 %142, 0
  br i1 %143, label %145, label %144

; <label>:144                                     ; preds = %141
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 1, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %167

; <label>:145                                     ; preds = %141, %137, %134
  %146 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  %147 = sext i8 %146 to i32
  %148 = icmp ne i32 %147, 0
  br i1 %148, label %149, label %154

; <label>:149                                     ; preds = %145
  %150 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %151 = sext i8 %150 to i32
  %152 = icmp ne i32 %151, 0
  br i1 %152, label %153, label %154

; <label>:153                                     ; preds = %149
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 1, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %167

; <label>:154                                     ; preds = %149, %145
  %155 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  %156 = sext i8 %155 to i32
  %157 = icmp ne i32 %156, 0
  br i1 %157, label %158, label %165

; <label>:158                                     ; preds = %154
  %159 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %160 = icmp ne i8 %159, 0
  br i1 %160, label %165, label %161

; <label>:161                                     ; preds = %158
  %162 = load i8* @FH_TUERMODUL__KL_50, align 1
  %163 = icmp ne i8 %162, 0
  br i1 %163, label %165, label %164

; <label>:164                                     ; preds = %161
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 1, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %167

; <label>:165                                     ; preds = %161, %158, %154
  br label %167

; <label>:166                                     ; preds = %3
  store i8 0, i8* @stable, align 1
  store i8 3, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %167

; <label>:167                                     ; preds = %166, %165, %164, %153, %144, %133, %122, %111, %99, %61, %52, %14
  br label %168

; <label>:168                                     ; preds = %167, %0
  ret void
}

; Function Attrs: nounwind uwtable
define void @generic_FH_TUERMODUL_CTRL() #0 {
  %1 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 13), align 1
  %2 = icmp ne i8 %1, 0
  br i1 %2, label %11, label %3

; <label>:3                                       ; preds = %0
  %4 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 15), align 1
  %5 = sext i8 %4 to i32
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %7, label %11

; <label>:7                                       ; preds = %3
  %8 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 14), align 1
  %9 = icmp ne i8 %8, 0
  br i1 %9, label %11, label %10

; <label>:10                                      ; preds = %7
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 4), align 1
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 6), align 1
  br label %11

; <label>:11                                      ; preds = %10, %7, %3, %0
  %12 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 13), align 1
  %13 = icmp ne i8 %12, 0
  br i1 %13, label %14, label %316

; <label>:14                                      ; preds = %11
  %15 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 10), align 1
  %16 = icmp ne i8 %15, 0
  br i1 %16, label %18, label %17

; <label>:17                                      ; preds = %14
  store i8 3, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %18

; <label>:18                                      ; preds = %17, %14
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 11), align 1
  %19 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 19), align 1
  %20 = icmp ne i8 %19, 0
  br i1 %20, label %22, label %21

; <label>:21                                      ; preds = %18
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 0), align 1
  store i8 1, i8* @BLOCK_ERKENNUNG_CTRL_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  br label %22

; <label>:22                                      ; preds = %21, %18
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 20), align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 11), align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 20), align 1
  %23 = load i8* @B_FH_TUERMODUL_CTRL_next_state, align 1
  %24 = sext i8 %23 to i32
  switch i32 %24, label %253 [
    i32 1, label %25
    i32 2, label %33
    i32 3, label %70
  ]

; <label>:25                                      ; preds = %22
  %26 = load i32* @FH_TUERMODUL_CTRL__N, align 4
  %27 = icmp eq i32 %26, 59
  br i1 %27, label %28, label %32

; <label>:28                                      ; preds = %25
  %29 = load i32* @FH_TUERMODUL_CTRL__N_old, align 4
  %30 = icmp eq i32 %29, 59
  br i1 %30, label %32, label %31

; <label>:31                                      ; preds = %28
  store i8 0, i8* @stable, align 1
  store i8 3, i8* @B_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 3, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  br label %254

; <label>:32                                      ; preds = %28, %25
  br label %254

; <label>:33                                      ; preds = %22
  %34 = load i8* @FH_TUERMODUL__BLOCK, align 1
  %35 = sext i8 %34 to i32
  %36 = icmp ne i32 %35, 0
  br i1 %36, label %37, label %46

; <label>:37                                      ; preds = %33
  %38 = load i8* @FH_TUERMODUL__BLOCK_old, align 1
  %39 = icmp ne i8 %38, 0
  br i1 %39, label %46, label %40

; <label>:40                                      ; preds = %37
  %41 = load i8* @FH_TUERMODUL__MFHZ, align 1
  %42 = sext i8 %41 to i32
  %43 = icmp ne i32 %42, 0
  br i1 %43, label %44, label %46

; <label>:44                                      ; preds = %40
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  %45 = load i64* @time, align 8
  store i64 %45, i64* @sc_FH_TUERMODUL_CTRL_2329_1, align 8
  store i8 3, i8* @B_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 3, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  br label %254

; <label>:46                                      ; preds = %40, %37, %33
  %47 = load i8* @NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state, align 1
  %48 = sext i8 %47 to i32
  switch i32 %48, label %68 [
    i32 1, label %49
    i32 2, label %54
    i32 3, label %59
  ]

; <label>:49                                      ; preds = %46
  %50 = load i8* @FH_TUERMODUL__SFHZ, align 1
  %51 = icmp ne i8 %50, 0
  br i1 %51, label %53, label %52

; <label>:52                                      ; preds = %49
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i8 3, i8* @NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state, align 1
  br label %69

; <label>:53                                      ; preds = %49
  br label %69

; <label>:54                                      ; preds = %46
  %55 = load i8* @FH_TUERMODUL__SFHA, align 1
  %56 = icmp ne i8 %55, 0
  br i1 %56, label %58, label %57

; <label>:57                                      ; preds = %54
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 3, i8* @NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state, align 1
  br label %69

; <label>:58                                      ; preds = %54
  br label %69

; <label>:59                                      ; preds = %46
  %60 = load i8* @FH_TUERMODUL__SFHA, align 1
  %61 = icmp ne i8 %60, 0
  br i1 %61, label %62, label %63

; <label>:62                                      ; preds = %59
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 2, i8* @NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state, align 1
  br label %69

; <label>:63                                      ; preds = %59
  %64 = load i8* @FH_TUERMODUL__SFHZ, align 1
  %65 = icmp ne i8 %64, 0
  br i1 %65, label %66, label %67

; <label>:66                                      ; preds = %63
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i8 1, i8* @NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state, align 1
  br label %69

; <label>:67                                      ; preds = %63
  br label %69

; <label>:68                                      ; preds = %46
  store i8 0, i8* @stable, align 1
  store i8 3, i8* @NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state, align 1
  br label %69

; <label>:69                                      ; preds = %68, %67, %66, %62, %58, %57, %53, %52
  br label %254

; <label>:70                                      ; preds = %22
  %71 = load i32* @FH_TUERMODUL_CTRL__N, align 4
  %72 = icmp sgt i32 %71, 60
  br i1 %72, label %73, label %85

; <label>:73                                      ; preds = %70
  %74 = load i32* @FH_TUERMODUL_CTRL__N_old, align 4
  %75 = icmp sgt i32 %74, 60
  br i1 %75, label %85, label %76

; <label>:76                                      ; preds = %73
  %77 = load i8* @FH_TUERMODUL_CTRL__INREVERS1, align 1
  %78 = sext i8 %77 to i32
  %79 = icmp ne i32 %78, 0
  br i1 %79, label %85, label %80

; <label>:80                                      ; preds = %76
  %81 = load i8* @FH_TUERMODUL_CTRL__INREVERS2, align 1
  %82 = sext i8 %81 to i32
  %83 = icmp ne i32 %82, 0
  br i1 %83, label %85, label %84

; <label>:84                                      ; preds = %80
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 1, i8* @B_FH_TUERMODUL_CTRL_next_state, align 1
  br label %254

; <label>:85                                      ; preds = %80, %76, %73, %70
  %86 = load i8* @FH_TUERMODUL__BLOCK, align 1
  %87 = sext i8 %86 to i32
  %88 = icmp ne i32 %87, 0
  br i1 %88, label %89, label %98

; <label>:89                                      ; preds = %85
  %90 = load i8* @FH_TUERMODUL__BLOCK_old, align 1
  %91 = icmp ne i8 %90, 0
  br i1 %91, label %98, label %92

; <label>:92                                      ; preds = %89
  %93 = load i8* @FH_TUERMODUL__MFHA, align 1
  %94 = sext i8 %93 to i32
  %95 = icmp ne i32 %94, 0
  br i1 %95, label %96, label %98

; <label>:96                                      ; preds = %92
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHA_copy, align 1
  %97 = load i64* @time, align 8
  store i64 %97, i64* @sc_FH_TUERMODUL_CTRL_2375_2, align 8
  store i8 2, i8* @B_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 3, i8* @NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state, align 1
  br label %254

; <label>:98                                      ; preds = %92, %89, %85
  %99 = load i8* @FH_TUERMODUL__BLOCK, align 1
  %100 = sext i8 %99 to i32
  %101 = icmp ne i32 %100, 0
  br i1 %101, label %102, label %111

; <label>:102                                     ; preds = %98
  %103 = load i8* @FH_TUERMODUL__BLOCK_old, align 1
  %104 = icmp ne i8 %103, 0
  br i1 %104, label %111, label %105

; <label>:105                                     ; preds = %102
  %106 = load i8* @FH_TUERMODUL__MFHZ, align 1
  %107 = sext i8 %106 to i32
  %108 = icmp ne i32 %107, 0
  br i1 %108, label %109, label %111

; <label>:109                                     ; preds = %105
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  %110 = load i64* @time, align 8
  store i64 %110, i64* @sc_FH_TUERMODUL_CTRL_2352_1, align 8
  store i8 2, i8* @B_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 3, i8* @NICHT_INITIALISIERT_NICHT_INITIALISIERT_next_state, align 1
  br label %254

; <label>:111                                     ; preds = %105, %102, %98
  %112 = load i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  %113 = sext i8 %112 to i32
  switch i32 %113, label %251 [
    i32 1, label %114
    i32 2, label %156
    i32 3, label %228
  ]

; <label>:114                                     ; preds = %111
  %115 = load i32* @FH_TUERMODUL__POSITION, align 4
  %116 = icmp sge i32 %115, 405
  br i1 %116, label %117, label %118

; <label>:117                                     ; preds = %114
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 3, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  br label %252

; <label>:118                                     ; preds = %114
  %119 = load i8* @OEFFNEN_FH_TUERMODUL_CTRL_next_state, align 1
  %120 = sext i8 %119 to i32
  switch i32 %120, label %154 [
    i32 1, label %121
    i32 2, label %137
  ]

; <label>:121                                     ; preds = %118
  %122 = load i8* @FH_TUERMODUL__SFHZ, align 1
  %123 = sext i8 %122 to i32
  %124 = icmp ne i32 %123, 0
  br i1 %124, label %125, label %128

; <label>:125                                     ; preds = %121
  %126 = load i8* @FH_TUERMODUL__SFHZ_old, align 1
  %127 = icmp ne i8 %126, 0
  br i1 %127, label %128, label %135

; <label>:128                                     ; preds = %125, %121
  %129 = load i8* @FH_TUERMODUL__SFHA, align 1
  %130 = sext i8 %129 to i32
  %131 = icmp ne i32 %130, 0
  br i1 %131, label %132, label %136

; <label>:132                                     ; preds = %128
  %133 = load i8* @FH_TUERMODUL__SFHA_old, align 1
  %134 = icmp ne i8 %133, 0
  br i1 %134, label %136, label %135

; <label>:135                                     ; preds = %132, %125
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 3, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @OEFFNEN_FH_TUERMODUL_CTRL_next_state, align 1
  br label %155

; <label>:136                                     ; preds = %132, %128
  br label %155

; <label>:137                                     ; preds = %118
  %138 = load i8* @FH_TUERMODUL__SFHZ, align 1
  %139 = sext i8 %138 to i32
  %140 = icmp ne i32 %139, 0
  br i1 %140, label %141, label %145

; <label>:141                                     ; preds = %137
  %142 = load i8* @FH_TUERMODUL__SFHZ_old, align 1
  %143 = icmp ne i8 %142, 0
  br i1 %143, label %145, label %144

; <label>:144                                     ; preds = %141
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @OEFFNEN_FH_TUERMODUL_CTRL_next_state, align 1
  br label %155

; <label>:145                                     ; preds = %141, %137
  %146 = load i8* @FH_TUERMODUL__SFHA, align 1
  %147 = icmp ne i8 %146, 0
  br i1 %147, label %153, label %148

; <label>:148                                     ; preds = %145
  %149 = load i8* @FH_TUERMODUL__SFHA_old, align 1
  %150 = sext i8 %149 to i32
  %151 = icmp ne i32 %150, 0
  br i1 %151, label %152, label %153

; <label>:152                                     ; preds = %148
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 3, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @OEFFNEN_FH_TUERMODUL_CTRL_next_state, align 1
  br label %155

; <label>:153                                     ; preds = %148, %145
  br label %155

; <label>:154                                     ; preds = %118
  store i8 0, i8* @stable, align 1
  store i8 2, i8* @OEFFNEN_FH_TUERMODUL_CTRL_next_state, align 1
  br label %155

; <label>:155                                     ; preds = %154, %153, %152, %144, %136, %135
  br label %252

; <label>:156                                     ; preds = %111
  %157 = load i32* @FH_TUERMODUL__POSITION, align 4
  %158 = icmp sle i32 %157, 0
  br i1 %158, label %159, label %160

; <label>:159                                     ; preds = %156
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i8 3, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  br label %252

; <label>:160                                     ; preds = %156
  %161 = load i8* @SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  %162 = sext i8 %161 to i32
  switch i32 %162, label %226 [
    i32 1, label %163
    i32 2, label %194
  ]

; <label>:163                                     ; preds = %160
  %164 = load i8* @FH_TUERMODUL__SFHA, align 1
  %165 = sext i8 %164 to i32
  %166 = icmp ne i32 %165, 0
  br i1 %166, label %167, label %170

; <label>:167                                     ; preds = %163
  %168 = load i8* @FH_TUERMODUL__SFHA_old, align 1
  %169 = icmp ne i8 %168, 0
  br i1 %169, label %170, label %177

; <label>:170                                     ; preds = %167, %163
  %171 = load i8* @FH_TUERMODUL__SFHZ, align 1
  %172 = sext i8 %171 to i32
  %173 = icmp ne i32 %172, 0
  br i1 %173, label %174, label %178

; <label>:174                                     ; preds = %170
  %175 = load i8* @FH_TUERMODUL__SFHZ_old, align 1
  %176 = icmp ne i8 %175, 0
  br i1 %176, label %178, label %177

; <label>:177                                     ; preds = %174, %167
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i8 3, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  br label %227

; <label>:178                                     ; preds = %174, %170
  %179 = load i8* @TIPP_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  %180 = sext i8 %179 to i32
  switch i32 %180, label %192 [
    i32 1, label %181
    i32 2, label %186
  ]

; <label>:181                                     ; preds = %178
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 23), align 1
  %182 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 22), align 1
  %183 = icmp ne i8 %182, 0
  br i1 %183, label %184, label %185

; <label>:184                                     ; preds = %181
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i8 0, i8* @FH_TUERMODUL_CTRL__INREVERS2_copy, align 1
  store i8 2, i8* @TIPP_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  br label %193

; <label>:185                                     ; preds = %181
  br label %193

; <label>:186                                     ; preds = %178
  %187 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 24), align 1
  %188 = icmp ne i8 %187, 0
  br i1 %188, label %189, label %191

; <label>:189                                     ; preds = %186
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL_CTRL__INREVERS2_copy, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 23), align 1
  store i8 1, i8* @TIPP_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  %190 = load i64* @time, align 8
  store i64 %190, i64* @sc_FH_TUERMODUL_CTRL_1781_10, align 8
  store i8 1, i8* @FH_TUERMODUL__MFHA_copy, align 1
  br label %193

; <label>:191                                     ; preds = %186
  br label %193

; <label>:192                                     ; preds = %178
  store i8 0, i8* @stable, align 1
  store i8 2, i8* @TIPP_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  br label %193

; <label>:193                                     ; preds = %192, %191, %189, %185, %184
  br label %227

; <label>:194                                     ; preds = %160
  %195 = load i8* @FH_TUERMODUL__SFHZ, align 1
  %196 = icmp ne i8 %195, 0
  br i1 %196, label %202, label %197

; <label>:197                                     ; preds = %194
  %198 = load i8* @FH_TUERMODUL__SFHZ_old, align 1
  %199 = sext i8 %198 to i32
  %200 = icmp ne i32 %199, 0
  br i1 %200, label %201, label %202

; <label>:201                                     ; preds = %197
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i8 3, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  br label %227

; <label>:202                                     ; preds = %197, %194
  %203 = load i8* @MANUELL_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  %204 = sext i8 %203 to i32
  switch i32 %204, label %224 [
    i32 1, label %205
    i32 2, label %210
  ]

; <label>:205                                     ; preds = %202
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 23), align 1
  %206 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 22), align 1
  %207 = icmp ne i8 %206, 0
  br i1 %207, label %208, label %209

; <label>:208                                     ; preds = %205
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL_CTRL__INREVERS1_copy, align 1
  store i8 2, i8* @MANUELL_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  store i8 1, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  br label %225

; <label>:209                                     ; preds = %205
  br label %225

; <label>:210                                     ; preds = %202
  %211 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 24), align 1
  %212 = icmp ne i8 %211, 0
  br i1 %212, label %213, label %215

; <label>:213                                     ; preds = %210
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i8 1, i8* @FH_TUERMODUL_CTRL__INREVERS1_copy, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 23), align 1
  store i8 1, i8* @MANUELL_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  %214 = load i64* @time, align 8
  store i64 %214, i64* @sc_FH_TUERMODUL_CTRL_1739_10, align 8
  store i8 1, i8* @FH_TUERMODUL__MFHA_copy, align 1
  br label %225

; <label>:215                                     ; preds = %210
  %216 = load i8* @FH_TUERMODUL__SFHA, align 1
  %217 = sext i8 %216 to i32
  %218 = icmp ne i32 %217, 0
  br i1 %218, label %219, label %223

; <label>:219                                     ; preds = %215
  %220 = load i8* @FH_TUERMODUL__SFHA_old, align 1
  %221 = icmp ne i8 %220, 0
  br i1 %221, label %223, label %222

; <label>:222                                     ; preds = %219
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 0, i8* @MANUELL_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  br label %225

; <label>:223                                     ; preds = %219, %215
  br label %225

; <label>:224                                     ; preds = %202
  store i8 0, i8* @stable, align 1
  store i8 2, i8* @MANUELL_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  store i8 1, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  br label %225

; <label>:225                                     ; preds = %224, %223, %222, %213, %209, %208
  br label %227

; <label>:226                                     ; preds = %160
  store i8 0, i8* @stable, align 1
  store i8 2, i8* @SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 2, i8* @MANUELL_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  store i8 1, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  br label %227

; <label>:227                                     ; preds = %226, %225, %201, %193, %177
  br label %252

; <label>:228                                     ; preds = %111
  %229 = load i8* @FH_TUERMODUL__SFHZ, align 1
  %230 = sext i8 %229 to i32
  %231 = icmp ne i32 %230, 0
  br i1 %231, label %232, label %239

; <label>:232                                     ; preds = %228
  %233 = load i8* @FH_TUERMODUL__SFHZ_old, align 1
  %234 = icmp ne i8 %233, 0
  br i1 %234, label %239, label %235

; <label>:235                                     ; preds = %232
  %236 = load i32* @FH_TUERMODUL__POSITION, align 4
  %237 = icmp sgt i32 %236, 0
  br i1 %237, label %238, label %239

; <label>:238                                     ; preds = %235
  store i8 0, i8* @stable, align 1
  store i8 2, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 2, i8* @SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 2, i8* @MANUELL_SCHLIESSEN_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  store i8 1, i8* @FH_TUERMODUL__MFHZ_copy, align 1
  br label %252

; <label>:239                                     ; preds = %235, %232, %228
  %240 = load i8* @FH_TUERMODUL__SFHA, align 1
  %241 = sext i8 %240 to i32
  %242 = icmp ne i32 %241, 0
  br i1 %242, label %243, label %250

; <label>:243                                     ; preds = %239
  %244 = load i8* @FH_TUERMODUL__SFHA_old, align 1
  %245 = icmp ne i8 %244, 0
  br i1 %245, label %250, label %246

; <label>:246                                     ; preds = %243
  %247 = load i32* @FH_TUERMODUL__POSITION, align 4
  %248 = icmp slt i32 %247, 405
  br i1 %248, label %249, label %250

; <label>:249                                     ; preds = %246
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 1, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 2, i8* @OEFFNEN_FH_TUERMODUL_CTRL_next_state, align 1
  br label %252

; <label>:250                                     ; preds = %246, %243, %239
  br label %252

; <label>:251                                     ; preds = %111
  store i8 0, i8* @stable, align 1
  store i8 3, i8* @INITIALISIERT_FH_TUERMODUL_CTRL_next_state, align 1
  br label %252

; <label>:252                                     ; preds = %251, %250, %249, %238, %227, %159, %155, %117
  br label %254

; <label>:253                                     ; preds = %22
  store i8 0, i8* @stable, align 1
  store i8 2, i8* @B_FH_TUERMODUL_CTRL_next_state, align 1
  br label %254

; <label>:254                                     ; preds = %253, %252, %109, %96, %84, %69, %44, %32, %31
  %255 = load i8* @A_FH_TUERMODUL_CTRL_next_state, align 1
  %256 = sext i8 %255 to i32
  switch i32 %256, label %312 [
    i32 1, label %257
  ]

; <label>:257                                     ; preds = %254
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 5), align 1
  %258 = load i8* @step, align 1
  %259 = sext i8 %258 to i32
  %260 = icmp eq i32 %259, 1
  br i1 %260, label %261, label %280

; <label>:261                                     ; preds = %257
  %262 = load i64* @tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRLexited_BEREIT_FH_TUERMODUL_CTRL, align 8
  %263 = icmp ne i64 %262, 0
  br i1 %263, label %264, label %280

; <label>:264                                     ; preds = %261
  %265 = load i64* @time, align 8
  %266 = load i64* @tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRLexited_BEREIT_FH_TUERMODUL_CTRL, align 8
  %267 = sub i64 %265, %266
  %268 = icmp eq i64 %267, 1
  br i1 %268, label %269, label %280

; <label>:269                                     ; preds = %264
  %270 = load i8* @FH_TUERMODUL__MFHZ, align 1
  %271 = sext i8 %270 to i32
  %272 = icmp ne i32 %271, 0
  br i1 %272, label %277, label %273

; <label>:273                                     ; preds = %269
  %274 = load i8* @FH_TUERMODUL__MFHA, align 1
  %275 = sext i8 %274 to i32
  %276 = icmp ne i32 %275, 0
  br i1 %276, label %277, label %280

; <label>:277                                     ; preds = %273, %269
  store i8 0, i8* @stable, align 1
  %278 = load i32* @FH_TUERMODUL_CTRL__N, align 4
  %279 = add nsw i32 %278, 1
  store i32 %279, i32* @FH_TUERMODUL_CTRL__N, align 4
  store i8 1, i8* @A_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 5), align 1
  store i8 1, i8* @WIEDERHOLSPERRE_FH_TUERMODUL_CTRL_next_state, align 1
  br label %313

; <label>:280                                     ; preds = %273, %264, %261, %257
  %281 = load i8* @WIEDERHOLSPERRE_FH_TUERMODUL_CTRL_next_state, align 1
  %282 = sext i8 %281 to i32
  switch i32 %282, label %310 [
    i32 1, label %283
  ]

; <label>:283                                     ; preds = %280
  %284 = load i8* @step, align 1
  %285 = sext i8 %284 to i32
  %286 = icmp eq i32 %285, 1
  br i1 %286, label %287, label %309

; <label>:287                                     ; preds = %283
  %288 = load i64* @tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRL, align 8
  %289 = icmp ne i64 %288, 0
  br i1 %289, label %290, label %309

; <label>:290                                     ; preds = %287
  %291 = load i64* @time, align 8
  %292 = load i64* @tm_entered_WIEDERHOLSPERRE_FH_TUERMODUL_CTRL, align 8
  %293 = sub i64 %291, %292
  %294 = icmp eq i64 %293, 3
  br i1 %294, label %295, label %309

; <label>:295                                     ; preds = %290
  %296 = load i8* @FH_TUERMODUL__MFHZ, align 1
  %297 = sext i8 %296 to i32
  %298 = icmp ne i32 %297, 0
  br i1 %298, label %309, label %299

; <label>:299                                     ; preds = %295
  %300 = load i8* @FH_TUERMODUL__MFHA, align 1
  %301 = sext i8 %300 to i32
  %302 = icmp ne i32 %301, 0
  br i1 %302, label %309, label %303

; <label>:303                                     ; preds = %299
  %304 = load i32* @FH_TUERMODUL_CTRL__N, align 4
  %305 = icmp sgt i32 %304, 0
  br i1 %305, label %306, label %309

; <label>:306                                     ; preds = %303
  store i8 0, i8* @stable, align 1
  %307 = load i32* @FH_TUERMODUL_CTRL__N, align 4
  %308 = sub nsw i32 %307, 1
  store i32 %308, i32* @FH_TUERMODUL_CTRL__N, align 4
  store i8 1, i8* @WIEDERHOLSPERRE_FH_TUERMODUL_CTRL_next_state, align 1
  br label %311

; <label>:309                                     ; preds = %303, %299, %295, %290, %287, %283
  br label %311

; <label>:310                                     ; preds = %280
  store i8 0, i8* @stable, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 5), align 1
  store i8 1, i8* @WIEDERHOLSPERRE_FH_TUERMODUL_CTRL_next_state, align 1
  br label %311

; <label>:311                                     ; preds = %310, %309, %306
  br label %313

; <label>:312                                     ; preds = %254
  store i8 0, i8* @stable, align 1
  store i32 0, i32* @FH_TUERMODUL_CTRL__N, align 4
  store i8 1, i8* @A_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 5), align 1
  store i8 1, i8* @WIEDERHOLSPERRE_FH_TUERMODUL_CTRL_next_state, align 1
  br label %313

; <label>:313                                     ; preds = %312, %311, %277
  %314 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 4), align 1
  store i8 %314, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 5), align 1
  %315 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 6), align 1
  store i8 %315, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 7), align 1
  br label %316

; <label>:316                                     ; preds = %313, %11
  ret void
}

; Function Attrs: nounwind uwtable
define void @generic_EINKLEMMSCHUTZ_CTRL() #0 {
  %1 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 16), align 1
  %2 = icmp ne i8 %1, 0
  br i1 %2, label %3, label %34

; <label>:3                                       ; preds = %0
  %4 = load i8* @EINKLEMMSCHUTZ_CTRL_EINKLEMMSCHUTZ_CTRL_next_state, align 1
  %5 = sext i8 %4 to i32
  switch i32 %5, label %32 [
    i32 1, label %6
    i32 2, label %23
  ]

; <label>:6                                       ; preds = %3
  %7 = load i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV, align 1
  %8 = sext i8 %7 to i32
  %9 = icmp ne i32 %8, 0
  br i1 %9, label %10, label %22

; <label>:10                                      ; preds = %6
  %11 = load i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV_old, align 1
  %12 = icmp ne i8 %11, 0
  br i1 %12, label %22, label %13

; <label>:13                                      ; preds = %10
  %14 = load i8* @FH_TUERMODUL__SFHZ, align 1
  %15 = sext i8 %14 to i32
  %16 = icmp ne i32 %15, 0
  br i1 %16, label %17, label %21

; <label>:17                                      ; preds = %13
  %18 = load i8* @FH_TUERMODUL__SFHA, align 1
  %19 = sext i8 %18 to i32
  %20 = icmp ne i32 %19, 0
  br i1 %20, label %22, label %21

; <label>:21                                      ; preds = %17, %13
  store i8 0, i8* @stable, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 24), align 1
  store i8 2, i8* @EINKLEMMSCHUTZ_CTRL_EINKLEMMSCHUTZ_CTRL_next_state, align 1
  br label %33

; <label>:22                                      ; preds = %17, %10, %6
  br label %33

; <label>:23                                      ; preds = %3
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 24), align 1
  %24 = load i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV, align 1
  %25 = icmp ne i8 %24, 0
  br i1 %25, label %31, label %26

; <label>:26                                      ; preds = %23
  %27 = load i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV_old, align 1
  %28 = sext i8 %27 to i32
  %29 = icmp ne i32 %28, 0
  br i1 %29, label %30, label %31

; <label>:30                                      ; preds = %26
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @EINKLEMMSCHUTZ_CTRL_EINKLEMMSCHUTZ_CTRL_next_state, align 1
  br label %33

; <label>:31                                      ; preds = %26, %23
  br label %33

; <label>:32                                      ; preds = %3
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @EINKLEMMSCHUTZ_CTRL_EINKLEMMSCHUTZ_CTRL_next_state, align 1
  br label %33

; <label>:33                                      ; preds = %32, %31, %30, %22, %21
  br label %34

; <label>:34                                      ; preds = %33, %0
  ret void
}

; Function Attrs: nounwind uwtable
define void @generic_BLOCK_ERKENNUNG_CTRL() #0 {
  %1 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 19), align 1
  %2 = icmp ne i8 %1, 0
  br i1 %2, label %11, label %3

; <label>:3                                       ; preds = %0
  %4 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 21), align 1
  %5 = sext i8 %4 to i32
  %6 = icmp ne i32 %5, 0
  br i1 %6, label %7, label %11

; <label>:7                                       ; preds = %3
  %8 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 20), align 1
  %9 = icmp ne i8 %8, 0
  br i1 %9, label %11, label %10

; <label>:10                                      ; preds = %7
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 0), align 1
  br label %11

; <label>:11                                      ; preds = %10, %7, %3, %0
  %12 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 19), align 1
  %13 = icmp ne i8 %12, 0
  br i1 %13, label %14, label %91

; <label>:14                                      ; preds = %11
  %15 = load i8* @BLOCK_ERKENNUNG_CTRL_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  %16 = sext i8 %15 to i32
  switch i32 %16, label %89 [
    i32 1, label %17
    i32 2, label %26
  ]

; <label>:17                                      ; preds = %14
  %18 = load i32* @FH_TUERMODUL__I_EIN, align 4
  %19 = load i32* @FH_TUERMODUL__I_EIN_old, align 4
  %20 = icmp ne i32 %18, %19
  br i1 %20, label %21, label %25

; <label>:21                                      ; preds = %17
  %22 = load i32* @FH_TUERMODUL__I_EIN, align 4
  %23 = icmp sgt i32 %22, 0
  br i1 %23, label %24, label %25

; <label>:24                                      ; preds = %21
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @FH_TUERMODUL__BLOCK_copy, align 1
  store i8 2, i8* @BLOCK_ERKENNUNG_CTRL_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  store i32 0, i32* @BLOCK_ERKENNUNG_CTRL__N, align 4
  store i32 2, i32* @BLOCK_ERKENNUNG_CTRL__I_EIN_MAX, align 4
  store i8 3, i8* @BEWEGUNG_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 0), align 1
  br label %90

; <label>:25                                      ; preds = %21, %17
  br label %90

; <label>:26                                      ; preds = %14
  %27 = load i8* @FH_TUERMODUL__MFHA, align 1
  %28 = icmp ne i8 %27, 0
  br i1 %28, label %33, label %29

; <label>:29                                      ; preds = %26
  %30 = load i8* @FH_TUERMODUL__MFHA_old, align 1
  %31 = sext i8 %30 to i32
  %32 = icmp ne i32 %31, 0
  br i1 %32, label %40, label %33

; <label>:33                                      ; preds = %29, %26
  %34 = load i8* @FH_TUERMODUL__MFHZ, align 1
  %35 = icmp ne i8 %34, 0
  br i1 %35, label %41, label %36

; <label>:36                                      ; preds = %33
  %37 = load i8* @FH_TUERMODUL__MFHZ_old, align 1
  %38 = sext i8 %37 to i32
  %39 = icmp ne i32 %38, 0
  br i1 %39, label %40, label %41

; <label>:40                                      ; preds = %36, %29
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @BLOCK_ERKENNUNG_CTRL_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  store i8 0, i8* @BEWEGUNG_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  br label %90

; <label>:41                                      ; preds = %36, %33
  %42 = load i8* @BEWEGUNG_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  %43 = sext i8 %42 to i32
  switch i32 %43, label %87 [
    i32 1, label %44
    i32 2, label %45
    i32 3, label %52
  ]

; <label>:44                                      ; preds = %41
  br label %88

; <label>:45                                      ; preds = %41
  %46 = load i32* @FH_TUERMODUL__I_EIN, align 4
  %47 = load i32* @BLOCK_ERKENNUNG_CTRL__I_EIN_MAX, align 4
  %48 = sub nsw i32 %47, 2
  %49 = icmp sgt i32 %46, %48
  br i1 %49, label %50, label %51

; <label>:50                                      ; preds = %45
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @FH_TUERMODUL__BLOCK_copy, align 1
  store i8 1, i8* @BEWEGUNG_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  br label %88

; <label>:51                                      ; preds = %45
  br label %88

; <label>:52                                      ; preds = %41
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 0), align 1
  %53 = load i32* @BLOCK_ERKENNUNG_CTRL__N, align 4
  %54 = icmp eq i32 %53, 11
  br i1 %54, label %55, label %59

; <label>:55                                      ; preds = %52
  %56 = load i32* @BLOCK_ERKENNUNG_CTRL__N_old, align 4
  %57 = icmp eq i32 %56, 11
  br i1 %57, label %59, label %58

; <label>:58                                      ; preds = %55
  store i8 0, i8* @stable, align 1
  store i8 2, i8* @BEWEGUNG_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  br label %88

; <label>:59                                      ; preds = %55, %52
  %60 = load i8* @BEWEGUNG_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  %61 = sext i8 %60 to i32
  %62 = icmp eq i32 %61, 3
  br i1 %62, label %63, label %86

; <label>:63                                      ; preds = %59
  %64 = load i8* @step, align 1
  %65 = sext i8 %64 to i32
  %66 = icmp eq i32 %65, 1
  br i1 %66, label %67, label %85

; <label>:67                                      ; preds = %63
  %68 = load i64* @tm_entered_EINSCHALTSTROM_MESSEN_BLOCK_ERKENNUNG_CTRLch_BLOCK_ERKENNUNG_CTRL__N_copy, align 8
  %69 = icmp ne i64 %68, 0
  br i1 %69, label %70, label %85

; <label>:70                                      ; preds = %67
  %71 = load i64* @time, align 8
  %72 = load i64* @tm_entered_EINSCHALTSTROM_MESSEN_BLOCK_ERKENNUNG_CTRLch_BLOCK_ERKENNUNG_CTRL__N_copy, align 8
  %73 = sub i64 %71, %72
  %74 = uitofp i64 %73 to double
  %75 = fcmp oeq double %74, 2.000000e-03
  br i1 %75, label %76, label %85

; <label>:76                                      ; preds = %70
  %77 = load i32* @BLOCK_ERKENNUNG_CTRL__N, align 4
  %78 = add nsw i32 %77, 1
  store i32 %78, i32* @BLOCK_ERKENNUNG_CTRL__N, align 4
  %79 = load i32* @FH_TUERMODUL__I_EIN, align 4
  %80 = load i32* @BLOCK_ERKENNUNG_CTRL__I_EIN_MAX, align 4
  %81 = icmp sgt i32 %79, %80
  br i1 %81, label %82, label %84

; <label>:82                                      ; preds = %76
  %83 = load i32* @FH_TUERMODUL__I_EIN, align 4
  store i32 %83, i32* @BLOCK_ERKENNUNG_CTRL__I_EIN_MAX, align 4
  br label %84

; <label>:84                                      ; preds = %82, %76
  br label %85

; <label>:85                                      ; preds = %84, %70, %67, %63
  br label %86

; <label>:86                                      ; preds = %85, %59
  br label %88

; <label>:87                                      ; preds = %41
  store i8 0, i8* @stable, align 1
  store i32 0, i32* @BLOCK_ERKENNUNG_CTRL__N, align 4
  store i32 2, i32* @BLOCK_ERKENNUNG_CTRL__I_EIN_MAX, align 4
  store i8 3, i8* @BEWEGUNG_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 0), align 1
  br label %88

; <label>:88                                      ; preds = %87, %86, %58, %51, %50, %44
  br label %90

; <label>:89                                      ; preds = %14
  store i8 0, i8* @stable, align 1
  store i8 1, i8* @BLOCK_ERKENNUNG_CTRL_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  br label %90

; <label>:90                                      ; preds = %89, %88, %40, %25, %24
  br label %91

; <label>:91                                      ; preds = %90, %11
  ret void
}

; Function Attrs: nounwind uwtable
define void @FH_DU() #0 {
  store i64 1, i64* @time, align 8
  store i8 0, i8* @stable, align 1
  store i8 0, i8* @step, align 1
  br label %1

; <label>:1                                       ; preds = %110, %0
  %2 = load i8* @stable, align 1
  %3 = icmp ne i8 %2, 0
  %4 = xor i1 %3, true
  br i1 %4, label %5, label %214

; <label>:5                                       ; preds = %1
  store i8 1, i8* @stable, align 1
  %6 = load i8* @step, align 1
  %7 = add i8 %6, 1
  store i8 %7, i8* @step, align 1
  %8 = load i8* @FH_STEUERUNG_DUMMY_FH_STEUERUNG_DUMMY_next_state, align 1
  %9 = sext i8 %8 to i32
  switch i32 %9, label %45 [
    i32 1, label %10
    i32 2, label %19
    i32 3, label %36
  ]

; <label>:10                                      ; preds = %5
  %11 = load i8* @FH_DU__MFHZ, align 1
  %12 = icmp ne i8 %11, 0
  br i1 %12, label %18, label %13

; <label>:13                                      ; preds = %10
  %14 = load i8* @FH_DU__MFHZ_old, align 1
  %15 = sext i8 %14 to i32
  %16 = icmp ne i32 %15, 0
  br i1 %16, label %17, label %18

; <label>:17                                      ; preds = %13
  store i8 0, i8* @stable, align 1
  store i32 0, i32* @FH_DU__MFH, align 4
  store i8 2, i8* @FH_STEUERUNG_DUMMY_FH_STEUERUNG_DUMMY_next_state, align 1
  br label %46

; <label>:18                                      ; preds = %13, %10
  br label %46

; <label>:19                                      ; preds = %5
  %20 = load i8* @FH_DU__MFHZ, align 1
  %21 = sext i8 %20 to i32
  %22 = icmp ne i32 %21, 0
  br i1 %22, label %23, label %27

; <label>:23                                      ; preds = %19
  %24 = load i8* @FH_DU__MFHZ_old, align 1
  %25 = icmp ne i8 %24, 0
  br i1 %25, label %27, label %26

; <label>:26                                      ; preds = %23
  store i8 0, i8* @stable, align 1
  store i32 -100, i32* @FH_DU__MFH, align 4
  store i8 1, i8* @FH_STEUERUNG_DUMMY_FH_STEUERUNG_DUMMY_next_state, align 1
  br label %46

; <label>:27                                      ; preds = %23, %19
  %28 = load i8* @FH_DU__MFHA, align 1
  %29 = sext i8 %28 to i32
  %30 = icmp ne i32 %29, 0
  br i1 %30, label %31, label %35

; <label>:31                                      ; preds = %27
  %32 = load i8* @FH_DU__MFHA_old, align 1
  %33 = icmp ne i8 %32, 0
  br i1 %33, label %35, label %34

; <label>:34                                      ; preds = %31
  store i8 0, i8* @stable, align 1
  store i32 100, i32* @FH_DU__MFH, align 4
  store i8 3, i8* @FH_STEUERUNG_DUMMY_FH_STEUERUNG_DUMMY_next_state, align 1
  br label %46

; <label>:35                                      ; preds = %31, %27
  br label %46

; <label>:36                                      ; preds = %5
  %37 = load i8* @FH_DU__MFHA, align 1
  %38 = icmp ne i8 %37, 0
  br i1 %38, label %44, label %39

; <label>:39                                      ; preds = %36
  %40 = load i8* @FH_DU__MFHA_old, align 1
  %41 = sext i8 %40 to i32
  %42 = icmp ne i32 %41, 0
  br i1 %42, label %43, label %44

; <label>:43                                      ; preds = %39
  store i8 0, i8* @stable, align 1
  store i32 0, i32* @FH_DU__MFH, align 4
  store i8 2, i8* @FH_STEUERUNG_DUMMY_FH_STEUERUNG_DUMMY_next_state, align 1
  br label %46

; <label>:44                                      ; preds = %39, %36
  br label %46

; <label>:45                                      ; preds = %5
  store i8 0, i8* @stable, align 1
  store i32 0, i32* @FH_DU__MFH, align 4
  store i8 2, i8* @FH_STEUERUNG_DUMMY_FH_STEUERUNG_DUMMY_next_state, align 1
  br label %46

; <label>:46                                      ; preds = %45, %44, %43, %35, %34, %26, %18, %17
  %47 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 10), align 1
  %48 = icmp ne i8 %47, 0
  br i1 %48, label %50, label %49

; <label>:49                                      ; preds = %46
  store i8 3, i8* @KINDERSICHERUNG_CTRL_KINDERSICHERUNG_CTRL_next_state, align 1
  br label %50

; <label>:50                                      ; preds = %49, %46
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 11), align 1
  %51 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 16), align 1
  %52 = icmp ne i8 %51, 0
  br i1 %52, label %54, label %53

; <label>:53                                      ; preds = %50
  store i8 1, i8* @EINKLEMMSCHUTZ_CTRL_EINKLEMMSCHUTZ_CTRL_next_state, align 1
  br label %54

; <label>:54                                      ; preds = %53, %50
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  %55 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 19), align 1
  %56 = icmp ne i8 %55, 0
  br i1 %56, label %58, label %57

; <label>:57                                      ; preds = %54
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 0), align 1
  store i8 1, i8* @BLOCK_ERKENNUNG_CTRL_BLOCK_ERKENNUNG_CTRL_next_state, align 1
  br label %58

; <label>:58                                      ; preds = %57, %54
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 20), align 1
  %59 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 13), align 1
  %60 = icmp ne i8 %59, 0
  br i1 %60, label %62, label %61

; <label>:61                                      ; preds = %58
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 4), align 1
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 6), align 1
  store i8 2, i8* @B_FH_TUERMODUL_CTRL_next_state, align 1
  store i32 0, i32* @FH_TUERMODUL_CTRL__N, align 4
  store i8 1, i8* @A_FH_TUERMODUL_CTRL_next_state, align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 5), align 1
  store i8 1, i8* @WIEDERHOLSPERRE_FH_TUERMODUL_CTRL_next_state, align 1
  br label %62

; <label>:62                                      ; preds = %61, %58
  store i8 0, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 14), align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 11), align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 20), align 1
  store i8 1, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 14), align 1
  %63 = load i8* @FH_DU__S_FH_TMBFZUCAN, align 1
  %64 = sext i8 %63 to i32
  %65 = load i8* @FH_DU__S_FH_TMBFZUCAN_old, align 1
  %66 = sext i8 %65 to i32
  %67 = icmp ne i32 %64, %66
  br i1 %67, label %68, label %74

; <label>:68                                      ; preds = %62
  %69 = load i8* @FH_DU__DOOR_ID, align 1
  %70 = icmp ne i8 %69, 0
  br i1 %70, label %73, label %71

; <label>:71                                      ; preds = %68
  %72 = load i8* @FH_DU__S_FH_TMBFZUCAN, align 1
  store i8 %72, i8* @FH_DU__S_FH_FTZU, align 1
  br label %73

; <label>:73                                      ; preds = %71, %68
  br label %74

; <label>:74                                      ; preds = %73, %62
  %75 = load i8* @FH_DU__S_FH_TMBFZUDISC, align 1
  %76 = sext i8 %75 to i32
  %77 = load i8* @FH_DU__S_FH_TMBFZUDISC_old, align 1
  %78 = sext i8 %77 to i32
  %79 = icmp ne i32 %76, %78
  br i1 %79, label %80, label %86

; <label>:80                                      ; preds = %74
  %81 = load i8* @FH_DU__DOOR_ID, align 1
  %82 = icmp ne i8 %81, 0
  br i1 %82, label %83, label %85

; <label>:83                                      ; preds = %80
  %84 = load i8* @FH_DU__S_FH_TMBFZUDISC, align 1
  store i8 %84, i8* @FH_DU__S_FH_TMBFZUCAN, align 1
  br label %85

; <label>:85                                      ; preds = %83, %80
  br label %86

; <label>:86                                      ; preds = %85, %74
  %87 = load i8* @FH_DU__S_FH_TMBFAUFCAN, align 1
  %88 = sext i8 %87 to i32
  %89 = load i8* @FH_DU__S_FH_TMBFAUFCAN_old, align 1
  %90 = sext i8 %89 to i32
  %91 = icmp ne i32 %88, %90
  br i1 %91, label %92, label %98

; <label>:92                                      ; preds = %86
  %93 = load i8* @FH_DU__DOOR_ID, align 1
  %94 = icmp ne i8 %93, 0
  br i1 %94, label %97, label %95

; <label>:95                                      ; preds = %92
  %96 = load i8* @FH_DU__S_FH_TMBFAUFCAN, align 1
  store i8 %96, i8* @FH_DU__S_FH_FTAUF, align 1
  br label %97

; <label>:97                                      ; preds = %95, %92
  br label %98

; <label>:98                                      ; preds = %97, %86
  %99 = load i8* @FH_DU__S_FH_TMBFAUFDISC, align 1
  %100 = sext i8 %99 to i32
  %101 = load i8* @FH_DU__S_FH_TMBFAUFDISC_old, align 1
  %102 = sext i8 %101 to i32
  %103 = icmp ne i32 %100, %102
  br i1 %103, label %104, label %110

; <label>:104                                     ; preds = %98
  %105 = load i8* @FH_DU__DOOR_ID, align 1
  %106 = icmp ne i8 %105, 0
  br i1 %106, label %107, label %109

; <label>:107                                     ; preds = %104
  %108 = load i8* @FH_DU__S_FH_TMBFAUFDISC, align 1
  store i8 %108, i8* @FH_DU__S_FH_TMBFAUFCAN, align 1
  br label %109

; <label>:109                                     ; preds = %107, %104
  br label %110

; <label>:110                                     ; preds = %109, %98
  %111 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 12), align 1
  store i8 %111, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 10), align 1
  %112 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 15), align 1
  store i8 %112, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 13), align 1
  %113 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 18), align 1
  store i8 %113, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 16), align 1
  %114 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 21), align 1
  store i8 %114, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 19), align 1
  %115 = load i8* @FH_DU__S_FH_AUFDISC, align 1
  store i8 %115, i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %116 = load i8* @FH_DU__S_FH_FTAUF, align 1
  store i8 %116, i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %117 = load i8* @FH_DU__S_FH_ZUDISC, align 1
  store i8 %117, i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %118 = load i8* @FH_DU__S_FH_FTZU, align 1
  store i8 %118, i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  call void @generic_KINDERSICHERUNG_CTRL()
  %119 = load i8* @FH_TUERMODUL__MFHA, align 1
  store i8 %119, i8* @FH_DU__MFHA, align 1
  %120 = load i8* @FH_TUERMODUL__MFHZ, align 1
  store i8 %120, i8* @FH_DU__MFHZ, align 1
  %121 = load i32* @FH_TUERMODUL__I_EIN, align 4
  store i32 %121, i32* @FH_DU__I_EIN, align 4
  %122 = load i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV, align 1
  store i8 %122, i8* @FH_DU__EKS_LEISTE_AKTIV, align 1
  %123 = load i32* @FH_TUERMODUL__POSITION, align 4
  store i32 %123, i32* @FH_DU__POSITION, align 4
  %124 = load i8* @FH_TUERMODUL__FT, align 1
  store i8 %124, i8* @FH_DU__FT, align 1
  %125 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  store i8 %125, i8* @FH_DU__S_FH_AUFDISC, align 1
  %126 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  store i8 %126, i8* @FH_DU__S_FH_FTAUF, align 1
  %127 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  store i8 %127, i8* @FH_DU__S_FH_ZUDISC, align 1
  %128 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  store i8 %128, i8* @FH_DU__S_FH_FTZU, align 1
  %129 = load i8* @FH_TUERMODUL__KL_50, align 1
  store i8 %129, i8* @FH_DU__KL_50, align 1
  %130 = load i8* @FH_TUERMODUL__BLOCK, align 1
  store i8 %130, i8* @FH_DU__BLOCK, align 1
  %131 = load i8* @FH_DU__S_FH_AUFDISC, align 1
  store i8 %131, i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %132 = load i8* @FH_DU__S_FH_FTAUF, align 1
  store i8 %132, i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %133 = load i8* @FH_DU__S_FH_ZUDISC, align 1
  store i8 %133, i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %134 = load i8* @FH_DU__S_FH_FTZU, align 1
  store i8 %134, i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  call void @generic_FH_TUERMODUL_CTRL()
  %135 = load i8* @FH_TUERMODUL__MFHA, align 1
  store i8 %135, i8* @FH_DU__MFHA, align 1
  %136 = load i8* @FH_TUERMODUL__MFHZ, align 1
  store i8 %136, i8* @FH_DU__MFHZ, align 1
  %137 = load i32* @FH_TUERMODUL__I_EIN, align 4
  store i32 %137, i32* @FH_DU__I_EIN, align 4
  %138 = load i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV, align 1
  store i8 %138, i8* @FH_DU__EKS_LEISTE_AKTIV, align 1
  %139 = load i32* @FH_TUERMODUL__POSITION, align 4
  store i32 %139, i32* @FH_DU__POSITION, align 4
  %140 = load i8* @FH_TUERMODUL__FT, align 1
  store i8 %140, i8* @FH_DU__FT, align 1
  %141 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  store i8 %141, i8* @FH_DU__S_FH_AUFDISC, align 1
  %142 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  store i8 %142, i8* @FH_DU__S_FH_FTAUF, align 1
  %143 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  store i8 %143, i8* @FH_DU__S_FH_ZUDISC, align 1
  %144 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  store i8 %144, i8* @FH_DU__S_FH_FTZU, align 1
  %145 = load i8* @FH_TUERMODUL__KL_50, align 1
  store i8 %145, i8* @FH_DU__KL_50, align 1
  %146 = load i8* @FH_TUERMODUL__BLOCK, align 1
  store i8 %146, i8* @FH_DU__BLOCK, align 1
  %147 = load i8* @FH_DU__S_FH_AUFDISC, align 1
  store i8 %147, i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %148 = load i8* @FH_DU__S_FH_FTAUF, align 1
  store i8 %148, i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %149 = load i8* @FH_DU__S_FH_ZUDISC, align 1
  store i8 %149, i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %150 = load i8* @FH_DU__S_FH_FTZU, align 1
  store i8 %150, i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  call void @generic_EINKLEMMSCHUTZ_CTRL()
  %151 = load i8* @FH_TUERMODUL__MFHA, align 1
  store i8 %151, i8* @FH_DU__MFHA, align 1
  %152 = load i8* @FH_TUERMODUL__MFHZ, align 1
  store i8 %152, i8* @FH_DU__MFHZ, align 1
  %153 = load i32* @FH_TUERMODUL__I_EIN, align 4
  store i32 %153, i32* @FH_DU__I_EIN, align 4
  %154 = load i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV, align 1
  store i8 %154, i8* @FH_DU__EKS_LEISTE_AKTIV, align 1
  %155 = load i32* @FH_TUERMODUL__POSITION, align 4
  store i32 %155, i32* @FH_DU__POSITION, align 4
  %156 = load i8* @FH_TUERMODUL__FT, align 1
  store i8 %156, i8* @FH_DU__FT, align 1
  %157 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  store i8 %157, i8* @FH_DU__S_FH_AUFDISC, align 1
  %158 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  store i8 %158, i8* @FH_DU__S_FH_FTAUF, align 1
  %159 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  store i8 %159, i8* @FH_DU__S_FH_ZUDISC, align 1
  %160 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  store i8 %160, i8* @FH_DU__S_FH_FTZU, align 1
  %161 = load i8* @FH_TUERMODUL__KL_50, align 1
  store i8 %161, i8* @FH_DU__KL_50, align 1
  %162 = load i8* @FH_TUERMODUL__BLOCK, align 1
  store i8 %162, i8* @FH_DU__BLOCK, align 1
  %163 = load i8* @FH_DU__S_FH_AUFDISC, align 1
  store i8 %163, i8* @FH_TUERMODUL__SFHA_MEC, align 1
  %164 = load i8* @FH_DU__S_FH_FTAUF, align 1
  store i8 %164, i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  %165 = load i8* @FH_DU__S_FH_ZUDISC, align 1
  store i8 %165, i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  %166 = load i8* @FH_DU__S_FH_FTZU, align 1
  store i8 %166, i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  call void @generic_BLOCK_ERKENNUNG_CTRL()
  %167 = load i8* @FH_TUERMODUL__MFHA, align 1
  store i8 %167, i8* @FH_DU__MFHA, align 1
  %168 = load i8* @FH_TUERMODUL__MFHZ, align 1
  store i8 %168, i8* @FH_DU__MFHZ, align 1
  %169 = load i32* @FH_TUERMODUL__I_EIN, align 4
  store i32 %169, i32* @FH_DU__I_EIN, align 4
  %170 = load i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV, align 1
  store i8 %170, i8* @FH_DU__EKS_LEISTE_AKTIV, align 1
  %171 = load i32* @FH_TUERMODUL__POSITION, align 4
  store i32 %171, i32* @FH_DU__POSITION, align 4
  %172 = load i8* @FH_TUERMODUL__FT, align 1
  store i8 %172, i8* @FH_DU__FT, align 1
  %173 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  store i8 %173, i8* @FH_DU__S_FH_AUFDISC, align 1
  %174 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  store i8 %174, i8* @FH_DU__S_FH_FTAUF, align 1
  %175 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  store i8 %175, i8* @FH_DU__S_FH_ZUDISC, align 1
  %176 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  store i8 %176, i8* @FH_DU__S_FH_FTZU, align 1
  %177 = load i8* @FH_TUERMODUL__KL_50, align 1
  store i8 %177, i8* @FH_DU__KL_50, align 1
  %178 = load i8* @FH_TUERMODUL__BLOCK, align 1
  store i8 %178, i8* @FH_DU__BLOCK, align 1
  %179 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 10), align 1
  store i8 %179, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 11), align 1
  %180 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 13), align 1
  store i8 %180, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 14), align 1
  %181 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 16), align 1
  store i8 %181, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 17), align 1
  %182 = load i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 19), align 1
  store i8 %182, i8* getelementptr inbounds ([64 x i8]* @Bitlist, i32 0, i64 20), align 1
  %183 = load i32* @FH_TUERMODUL_CTRL__N, align 4
  store i32 %183, i32* @FH_TUERMODUL_CTRL__N_old, align 4
  %184 = load i32* @FH_TUERMODUL__I_EIN, align 4
  store i32 %184, i32* @FH_TUERMODUL__I_EIN_old, align 4
  %185 = load i32* @FH_DU__MFH_copy, align 4
  store i32 %185, i32* @FH_DU__MFH, align 4
  %186 = load i32* @FH_DU__I_EIN, align 4
  store i32 %186, i32* @FH_DU__I_EIN_old, align 4
  %187 = load i32* @BLOCK_ERKENNUNG_CTRL__N, align 4
  store i32 %187, i32* @BLOCK_ERKENNUNG_CTRL__N_old, align 4
  %188 = load i8* @FH_TUERMODUL__SFHZ_ZENTRAL, align 1
  store i8 %188, i8* @FH_TUERMODUL__SFHZ_ZENTRAL_old, align 1
  %189 = load i8* @FH_TUERMODUL__SFHZ_MEC, align 1
  store i8 %189, i8* @FH_TUERMODUL__SFHZ_MEC_old, align 1
  %190 = load i8* @FH_TUERMODUL__SFHA_ZENTRAL, align 1
  store i8 %190, i8* @FH_TUERMODUL__SFHA_ZENTRAL_old, align 1
  %191 = load i8* @FH_TUERMODUL__SFHA_MEC, align 1
  store i8 %191, i8* @FH_TUERMODUL__SFHA_MEC_old, align 1
  %192 = load i8* @FH_TUERMODUL__BLOCK_copy, align 1
  store i8 %192, i8* @FH_TUERMODUL__BLOCK, align 1
  %193 = load i8* @FH_TUERMODUL__BLOCK, align 1
  store i8 %193, i8* @FH_TUERMODUL__BLOCK_old, align 1
  %194 = load i8* @FH_TUERMODUL__SFHZ_copy, align 1
  store i8 %194, i8* @FH_TUERMODUL__SFHZ, align 1
  %195 = load i8* @FH_TUERMODUL__SFHZ, align 1
  store i8 %195, i8* @FH_TUERMODUL__SFHZ_old, align 1
  %196 = load i8* @FH_TUERMODUL__SFHA_copy, align 1
  store i8 %196, i8* @FH_TUERMODUL__SFHA, align 1
  %197 = load i8* @FH_TUERMODUL__SFHA, align 1
  store i8 %197, i8* @FH_TUERMODUL__SFHA_old, align 1
  %198 = load i8* @FH_TUERMODUL__MFHZ_copy, align 1
  store i8 %198, i8* @FH_TUERMODUL__MFHZ, align 1
  %199 = load i8* @FH_TUERMODUL__MFHZ, align 1
  store i8 %199, i8* @FH_TUERMODUL__MFHZ_old, align 1
  %200 = load i8* @FH_TUERMODUL__MFHA_copy, align 1
  store i8 %200, i8* @FH_TUERMODUL__MFHA, align 1
  %201 = load i8* @FH_TUERMODUL__MFHA, align 1
  store i8 %201, i8* @FH_TUERMODUL__MFHA_old, align 1
  %202 = load i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV, align 1
  store i8 %202, i8* @FH_TUERMODUL__EKS_LEISTE_AKTIV_old, align 1
  %203 = load i8* @FH_DU__EKS_LEISTE_AKTIV, align 1
  store i8 %203, i8* @FH_DU__EKS_LEISTE_AKTIV_old, align 1
  %204 = load i8* @FH_DU__S_FH_TMBFAUFCAN, align 1
  store i8 %204, i8* @FH_DU__S_FH_TMBFAUFCAN_old, align 1
  %205 = load i8* @FH_DU__S_FH_TMBFZUCAN, align 1
  store i8 %205, i8* @FH_DU__S_FH_TMBFZUCAN_old, align 1
  %206 = load i8* @FH_DU__S_FH_TMBFZUDISC, align 1
  store i8 %206, i8* @FH_DU__S_FH_TMBFZUDISC_old, align 1
  %207 = load i8* @FH_DU__S_FH_TMBFAUFDISC, align 1
  store i8 %207, i8* @FH_DU__S_FH_TMBFAUFDISC_old, align 1
  %208 = load i8* @FH_DU__BLOCK_copy, align 1
  store i8 %208, i8* @FH_DU__BLOCK, align 1
  %209 = load i8* @FH_DU__BLOCK, align 1
  store i8 %209, i8* @FH_DU__BLOCK_old, align 1
  %210 = load i8* @FH_DU__MFHZ_copy, align 1
  store i8 %210, i8* @FH_DU__MFHZ, align 1
  %211 = load i8* @FH_DU__MFHZ, align 1
  store i8 %211, i8* @FH_DU__MFHZ_old, align 1
  %212 = load i8* @FH_DU__MFHA_copy, align 1
  store i8 %212, i8* @FH_DU__MFHA, align 1
  %213 = load i8* @FH_DU__MFHA, align 1
  store i8 %213, i8* @FH_DU__MFHA_old, align 1
  br label %1

; <label>:214                                     ; preds = %1
  ret void
}

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  store i32 0, i32* %1
  call void @init()
  call void @interface()
  call void @FH_DU()
  ret i32 0
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf"="true" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "unsafe-fp-math"="false" "use-soft-float"="false" }
