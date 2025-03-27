import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week_3_blabla_project/Data/repository/local/ride_pref_local_repo.dart';
import 'package:week_3_blabla_project/ui/provider/ride_pref_provider.dart';
import 'ui/screens/ride_pref/ride_pref_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefsRepo = LocalRidePreferencesRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RidesPreferencesProvider(repository: prefsRepo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const RidePrefScreen(),
    );
  }
}
