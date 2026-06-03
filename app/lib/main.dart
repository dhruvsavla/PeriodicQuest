import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app.dart';
import 'core/audio/element_audio_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ElementAudioService.instance.init();
  runApp(
    ScreenUtilInit(
      designSize: const Size(834, 1194),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: child,
        );
      },
      child: const AppEntry(),
    ),
  );
}
