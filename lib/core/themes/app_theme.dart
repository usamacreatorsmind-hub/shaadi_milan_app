import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFB11226); // Deep Wedding Red
  static const Color accentRed = Color(0xFFE53935); // Bright Red

  // -------------------- LIGHT THEME --------------------
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryRed,
      scaffoldBackgroundColor: Colors.white,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardColor: Colors.white,
      // setfont family
      fontFamily: 'Roboto',

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
      ),

      colorScheme: ColorScheme.light(
        primary: primaryRed,
        secondary: accentRed,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onError: Colors.white,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      // appbar theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryRed),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        labelStyle: const TextStyle(color: primaryRed),
        hintStyle: TextStyle(color: Colors.grey.shade600),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryRed,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryRed,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
      ),

      // Add a custom theme for the switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return primaryRed;
          }
          return null; // Use default color
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return primaryRed.withOpacity(0.5);
          }
          return null; // Use default color
        }),
      ),

      // Add a custom theme for the radio button
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return primaryRed;
          }
          return null; // Use default color
        }),
      ),

      // Add a custom theme for the checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return primaryRed;
          }
          return null; // Use default color
        }),
      ),

      // Add a custom theme for the dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: Colors.grey[800]),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ),

      // Add a custom theme for the text selection
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryRed,
        selectionColor: primaryRed.withOpacity(0.3),
        selectionHandleColor: primaryRed,
      ),

      // Add a custom theme for the date picker
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: primaryRed,
        headerForegroundColor: Colors.white,
        dayForegroundColor: WidgetStateProperty.all(Colors.black87),
        yearForegroundColor: WidgetStateProperty.all(Colors.black87),
        todayBackgroundColor: WidgetStateProperty.all(
          primaryRed.withOpacity(0.2),
        ),
        todayForegroundColor: WidgetStateProperty.all(primaryRed),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: primaryRed),

        cancelButtonStyle: TextButton.styleFrom(foregroundColor: Colors.grey),
      ),
    );
  }

  // -------------------- DARK THEME --------------------
  static ThemeData get darkTheme {
    const Color background = Color(0xFF0F0F0F);
    const Color surface = Color(0xFF1A1A1A);
    const Color card = Color(0xFF1F1F1F);

    const Color primaryRed = Color(0xFFB71C1C); // deep red
    const Color accentRed = Color(0xFFE53935); // soft red highlight

    return ThemeData(
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      scaffoldBackgroundColor: background,
      primaryColor: primaryRed,

      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: accentRed,
        surface: surface,
        error: Color(0xFFEF5350),
      ),

      // ---------------- BUTTONS ----------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentRed,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: accentRed.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),

      // ---------------- INPUT FIELDS ----------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),

      // ---------------- APP BAR ----------------
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // ---------------- CARDS ----------------
      cardTheme: CardThemeData(
        color: card,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // ---------------- SNACKBAR ----------------
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // ---------------- TEXT ----------------
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
        headlineMedium: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.white,
          fontWeight: FontWeight.w600,
        ),

        titleMedium: TextStyle(
          color: Colors.white,

          fontWeight: FontWeight.w600,
        ),
      ),

      // ---------------- ICONS ----------------
      iconTheme: const IconThemeData(color: Colors.white70),

      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.08),
        thickness: 1,
      ),
    );
  }
}
