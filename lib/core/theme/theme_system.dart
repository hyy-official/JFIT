import 'package:flutter/material.dart';

/// 통합 테마 시스템 - 다크/라이트 테마 지원
class JFitTheme {
  // Private constructor
  JFitTheme._();

  /// 현재 테마 모드
  static ThemeMode _themeMode = ThemeMode.dark;
  static ThemeMode get themeMode => _themeMode;

  /// 테마 모드 변경
  static void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
  }

  /// 라이트 테마
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _lightColorScheme,
        textTheme: _textTheme(Brightness.light),
        cardTheme: _cardTheme(Brightness.light),
        appBarTheme: _appBarTheme(Brightness.light),
        scaffoldBackgroundColor: JFitColors.light.background,
        fontFamily: 'Pretendard', // 또는 원하는 폰트
      );

  /// 다크 테마
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        textTheme: _textTheme(Brightness.dark),
        cardTheme: _cardTheme(Brightness.dark),
        appBarTheme: _appBarTheme(Brightness.dark),
        scaffoldBackgroundColor: JFitColors.dark.background,
        fontFamily: 'Pretendard', // 또는 원하는 폰트
      );

  /// 라이트 컬러 스킴
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: Color(0xFF6366F1), // Indigo
    onPrimary: Colors.white,
    secondary: Color(0xFF8B5CF6), // Purple
    onSecondary: Colors.white,
    surface: Color(0xFFF8FAFC), // Slate-50
    onSurface: Color(0xFF0F172A), // Slate-900
    surfaceContainer: Color(0xFFFFFFFF), // White
    outline: Color(0xFFE2E8F0), // Slate-200
    outlineVariant: Color(0xFFF1F5F9), // Slate-100
  );

  /// 다크 컬러 스킴
  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF6366F1), // Indigo
    onPrimary: Colors.white,
    secondary: Color(0xFF8B5CF6), // Purple
    onSecondary: Colors.white,
    surface: Color(0xFF1A1A1A), // 기존 bgTertiary
    onSurface: Color(0xFFFFFFFF), // White
    surfaceContainer: Color(0xFF0A0A0A), // 기존 bgPrimary
    outline: Color(0xFF262626), // 기존 border
    outlineVariant: Color(0xFF111111), // 기존 bgSecondary
  );

  /// 텍스트 테마
  static TextTheme _textTheme(Brightness brightness) {
    final colors = brightness == Brightness.light 
        ? JFitColors.light 
        : JFitColors.dark;

    return TextTheme(
      // 헤드라인
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        letterSpacing: -0.3,
      ),
      
      // 타이틀
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      
      // 바디
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colors.textMuted,
      ),
      
      // 라벨
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: colors.textMuted,
      ),
    );
  }

  /// 카드 테마
  static CardThemeData _cardTheme(Brightness brightness) {
    final colors = brightness == Brightness.light 
        ? JFitColors.light 
        : JFitColors.dark;

    return CardThemeData(
      color: colors.surface,
      elevation: brightness == Brightness.light ? 2 : 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.border,
          width: 1,
        ),
      ),
    );
  }

  /// 앱바 테마
  static AppBarTheme _appBarTheme(Brightness brightness) {
    final colors = brightness == Brightness.light 
        ? JFitColors.light 
        : JFitColors.dark;

    return AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }
}

/// 색상 정의 클래스
class JFitColors {
  const JFitColors._({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.borderVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.accent,
    required this.textTertiary,
    required this.secondaryBackground1,
    required this.secondaryBackground2,
    required this.onSurface,
    required this.gradient,
    required this.scrim,
    required this.shadow,
    required this.outline,
    required this.onPrimary,
    required this.onSecondary,
    required this.onSuccess,
    required this.onError,
    required this.onBackground,
    required this.info,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color borderVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color accent;
  final Color textTertiary;
  final Color secondaryBackground1;
  final Color secondaryBackground2;
  final Color onSurface;
  final LinearGradient gradient;
  final Color scrim;
  final Color shadow;
  final Color outline;
  final Color onPrimary;
  final Color onSecondary;
  final Color onSuccess;
  final Color onError;
  final Color onBackground;
  final Color info;

  /// 라이트 테마 색상
  static const JFitColors light = JFitColors._(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF8FAFC),
    surfaceVariant: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0),
    borderVariant: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF8B5CF6),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    accent: Color(0xFFEC4899),
    textTertiary: Color(0xFF737373),
    secondaryBackground1: Color(0xFFF8FAFC),
    secondaryBackground2: Color(0xFFF1F5F9),
    onSurface: Color(0xFF0F172A),
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    scrim: Color(0x80000000),
    shadow: Color(0xFF000000),
    outline: Color(0xFFE2E8F0),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSuccess: Color(0xFFFFFFFF),
    onError: Color(0xFFFFFFFF),
    onBackground: Color(0xFF0F172A),
    info: Color(0xFF3B82F6),
  );

  /// 다크 테마 색상 (기존 SecondTheme 기반)
  static const JFitColors dark = JFitColors._(
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF1A1A1A),
    surfaceVariant: Color(0xFF111111),
    border: Color(0xFF262626),
    borderVariant: Color(0xFF404040),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA3A3A3),
    textMuted: Color(0xFF737373),
    primary: Color(0xFF6366F1),
    secondary: Color(0xFF8B5CF6),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    accent: Color(0xFFEC4899),
    textTertiary: Color(0xFF9CA3AF),
    secondaryBackground1: Color(0xFF1A1A1A),
    secondaryBackground2: Color(0xFF111111),
    onSurface: Color(0xFFFFFFFF),
    gradient: LinearGradient(
      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    scrim: Color(0x80000000),
    shadow: Color(0xFF000000),
    outline: Color(0xFF262626),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onSuccess: Color(0xFFFFFFFF),
    onError: Color(0xFFFFFFFF),
    onBackground: Color(0xFFFFFFFF),
    info: Color(0xFF3B82F6),
  );
}

/// 차트 색상 팔레트
class JFitChartColors {
  static const List<Color> palette = [
    Color(0xFF8B5CF6), // Purple
    Color(0xFF6366F1), // Indigo
    Color(0xFF22D3EE), // Cyan
    Color(0xFFA3E635), // Lime
    Color(0xFFF59E42), // Orange
    Color(0xFFEF4444), // Red
    Color(0xFF22C55E), // Green
    Color(0xFFF59E0B), // Amber
  ];

  // 운동 구성 차트 전용 색상
  static const List<Color> workoutComposition = [
    Color(0xFF8A75F5), // Purple
    Color(0xFF6A8BFF), // Blue
    Color(0xFF4EC3E0), // Cyan
    Color(0xFFB5E048), // Lime
    Color(0xFFFFA94D), // Orange
  ];

  // 영양소 차트 전용 색상
  static const List<Color> nutrition = [
    Color(0xFF6B73FF), // 탄수화물 - Primary
    Color(0xFFB794F6), // 단백질 - Purple
    Color(0xFFF687B3), // 지방 - Pink
  ];

  // 신체 변화 색상
  static const Color positiveChange = Color(0xFF4ECDC4); // 긍정적 변화 (청록색)
  static const Color negativeChange = Color(0xFFFF6B6B); // 부정적 변화 (빨간색)
  static const Color neutralChange = Color(0xFF999999); // 변화 없음 (회색)

  // 운동 타입별 색상
  static const Color strengthColor = Color(0xFF10B981); // 근력 운동
  static const Color cardioColor = Color(0xFF3B82F6); // 유산소 운동
  static const Color flexibilityColor = Color(0xFFF59E0B); // 유연성 운동
  static const Color defaultExerciseColor = Color(0xFF6B7280); // 기본 운동
}

/// 테마 확장 메서드
extension ThemeExtension on BuildContext {
  /// 현재 테마의 JFitColors 가져오기
  JFitColors get colors => Theme.of(this).brightness == Brightness.light
      ? JFitColors.light
      : JFitColors.dark;

  /// 현재 테마가 다크 모드인지 확인
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// TextTheme 접근
  TextTheme get textTheme => Theme.of(this).textTheme;
}