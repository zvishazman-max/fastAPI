import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hitster/routes/routes.dart' show AppRouter;
import 'firebase_options.dart';
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter_web_plugins/url_strategy.dart' show usePathUrlStrategy;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'היטסר - Hitster',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        fontFamily: 'Poppins',
        scrollbarTheme: ScrollbarThemeData(thumbColor: WidgetStateProperty.all(Colors.grey[500]), trackBorderColor: WidgetStateProperty.all(Colors.grey[500])),
        textSelectionTheme: TextSelectionThemeData(cursorColor: const Color(0xff4195D2), selectionColor: Colors.blue[200]),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: Color(0xffFFFFFF)),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xff171821)),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xffFFFFFF), fontFamily: 'Poppins'),
          bodyMedium:  TextStyle(fontFamily: 'Poppins', color: Color(0xffFFFFFF)),
          bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xffFFFFFF), fontFamily: 'Poppins'),
        ),
        iconTheme: const IconThemeData(color: Color(0xffF6F2EB)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              backgroundColor: const Color(0x00FFFFFF),
              minimumSize: const Size(200,50), maximumSize: const Size(200,50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),side: const BorderSide(color: Color(0xffFFFFFF))),
              textStyle: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400, color: Color(0xffFFFFFF))
          ),
        ),
        buttonTheme: const ButtonThemeData(minWidth: 15, padding: EdgeInsets.only(left: 5, right: 5)),
        scaffoldBackgroundColor: const Color(0xFF1E1E2A),
        colorScheme: const ColorScheme(
          surface: Color(0xff171821),
          surfaceDim: Color(0x8AFFFFFF),
          onSurface: Color(0xffF6F2EB),
          primary: Color(0xffFFFFFF),
          onPrimary: Color(0xffE9E9ED),
          onSecondary: Color(0xff000000),
          onSecondaryFixed: Color(0xFF2D2D3A),
          secondary: Color(0xffFFFFFF),
          error: Colors.redAccent,
          onError: Color(0xffFFFFFF),
          primaryContainer: Color(0xff21222D),
          surfaceContainer: Color(0xffC2CDD2),
          shadow: Color(0xff252630),
          onSecondaryContainer: Color(0xff303139),
          onPrimaryContainer: Color(0xff171821),
          surfaceContainerHigh: Color(0xffD8DFE2),
          tertiaryContainer: Color(0xff1E1F28),
          outline: Color(0xff434450),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            //labelStyle: TextStyle(color: const Color(0xffFFFFFF), fontSize: 18),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffC0C0C2)),borderRadius: BorderRadius.circular(6)),
            focusedBorder: OutlineInputBorder(borderSide: const BorderSide(width: 2, color: Color(0xff4195D2)),borderRadius: BorderRadius.circular(6)),
            errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffF44336)),borderRadius: BorderRadius.circular(6)),
            focusedErrorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xffF44336)),borderRadius: BorderRadius.circular(6)),
            disabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0x00FFFFFF)),borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.only(left: 10, right: 10),
            prefixIconColor: Color(0x8AFFFFFF),
            suffixIconColor: Color(0xFFFFFFFF),
            //prefixStyle: TextStyle(color: const Color(0xffFFFFFF), fontSize: 16),
            hintStyle: const TextStyle(color: Color(0xff9E9E9E), fontSize: 16),
            constraints: const BoxConstraints(minWidth: 40, maxWidth: double.infinity, minHeight: 40, maxHeight: 40)
        ),
      ),
      //showSemanticsDebugger: true,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routerDelegate: AppRouter.router.routerDelegate,
      backButtonDispatcher: AppRouter.router.backButtonDispatcher,
      // localizationsDelegates: const [
      //   //AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en'), // English
      //   Locale('he', 'IL'), // Hebrew
      // ],
      // locale: const Locale('he', 'IL'),
    );
  }
}

