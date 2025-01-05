
import 'package:app/ui/home/page.dart';
import 'package:app/ui/SplashScreen/page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/ui/imageInput/page.dart';
import 'package:app/ui/help/page.dart';
import 'package:app/ui/settings/setting.dart';

final GoRouter router = GoRouter(
  initialLocation: '/welcome',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const Home(),
      routes: [
        GoRoute(
          path: 'welcome',
          builder: (BuildContext context, GoRouterState state) =>
              const SplashScreen(),
        ),

        GoRoute(
            path: 'imageInput',
            builder: (BuildContext context, GoRouterState state) =>
                CameraApp(),
            ),
         GoRoute(
          path: 'help',
          builder: (BuildContext context, GoRouterState state) =>
              const Help(),
        ), GoRoute(
          path: 'setting',
          builder: (BuildContext context, GoRouterState state) =>
              Setting(),
        ),
      ],
    ),
  ],
);
