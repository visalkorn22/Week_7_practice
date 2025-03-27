import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week_3_blabla_project/ui/provider/ride_pref_provider.dart';
import 'package:week_3_blabla_project/ui/widgets/error/bla_error_screen.dart';
import '../../../Domain/model/ride/ride_pref.dart';
import '../../../utils/animations_util.dart';
import '../rides/rides_screen.dart';
import 'widgets/ride_pref_form.dart';
import 'widgets/ride_pref_history_tile.dart';

const String blablaHomeImagePath = 'assets/images/blabla_home.png';

class RidePrefScreen extends StatelessWidget {
  const RidePrefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RidesPreferencesProvider>();

    if (provider.isLoading) return _buildLoadingState();
    if (provider.hasError) return _buildErrorState();
    if (provider.pastPreferences.isEmpty) return _buildEmptyState();

    return _buildMainContent(context, provider);
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return const BlaError(message: 'Failed to load preferences. Please try again.');
  }

  Widget _buildEmptyState() {
    return const BlaError(message: 'No ride preferences found.');
  }

  Widget _buildMainContent(BuildContext context, RidesPreferencesProvider provider) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              blablaHomeImagePath,
              fit: BoxFit.cover,
              height: 340,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Text(
                  "Your pick of rides at low prices",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                _buildFormCard(context, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, RidesPreferencesProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: RidePrefForm(
              initialPreference: provider.currentPreference,
              onSubmit: (pref) => _handlePrefSelected(context, pref, provider),
            ),
          ),
          if (provider.pastPreferences.isNotEmpty) ...[
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent searches',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: provider.pastPreferences.length,
                itemBuilder: (_, index) => RidePrefHistoryTile(
                  ridePref: provider.pastPreferences[index],
                  onPressed: () => _handlePrefSelected(
                    context, 
                    provider.pastPreferences[index],
                    provider,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handlePrefSelected(
    BuildContext context,
    RidePreference pref,
    RidesPreferencesProvider provider,
  ) {
    provider.setCurrentPreference(pref);
    Navigator.push(
      context,
      AnimationUtils.createBottomToTopRoute(const RidesScreen()),
    );
  }
}