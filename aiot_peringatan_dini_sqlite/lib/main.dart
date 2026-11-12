import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'cubit/sensor_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'pages/halaman_sensor.dart';
import 'theme/app_theme.dart';
void main() {
  // Inisialisasi SQLite untuk Windows dan Desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SensorCubit()..ambilData(),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(),
        ),
      ],
      child: const AplikasiPeringatanDini(),
    ),
  );
}

class AplikasiPeringatanDini extends StatelessWidget {
  const AplikasiPeringatanDini({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, tema) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AIoT Peringatan Dini',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: tema,
          home: const HalamanSensor(),
        );
      },
    );
  }
}