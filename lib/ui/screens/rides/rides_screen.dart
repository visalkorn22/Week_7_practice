import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week_3_blabla_project/ui/provider/ride_pref_provider.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPref = context.watch<RidesPreferencesProvider>().currentPreference;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(currentPref != null 
          ? 'Rides from ${currentPref.departure.name}'
          : 'Available Rides'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back to Preferences'),
        ),
      ),
    );
  }
}