import 'package:app/core/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/core/cubit/SplashScreen/splashScreen_cubit.dart';
import 'package:app/core/cubit/customer/recomPage_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SplashCubit()),
          // BlocProvider(create: (context) => AIteacherCubit()),
        ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}


