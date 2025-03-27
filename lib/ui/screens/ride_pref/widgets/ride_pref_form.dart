import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:week_3_blabla_project/ui/provider/ride_pref_provider.dart';

import '../../../../Domain/model/location/locations.dart';
import '../../../../Domain/model/ride/ride_pref.dart';
import '../../../theme/theme.dart';
import '../../../../utils/animations_util.dart';
import '../../../../utils/date_time_util.dart';
import '../../../widgets/actions/bla_button.dart';
import '../../../widgets/display/bla_divider.dart';
import '../../../widgets/inputs/bla_location_picker.dart';
import 'ride_pref_input_tile.dart';

class RidePrefForm extends StatefulWidget {
  const RidePrefForm({
    super.key,
    required this.initialPreference,
    required this.onSubmit,
  });

  final RidePreference? initialPreference;
  final Function(RidePreference preference) onSubmit;

  @override
  State<RidePrefForm> createState() => _RidePrefFormState();
}

class _RidePrefFormState extends State<RidePrefForm> {
  Location? departure;
  late DateTime departureDate;
  Location? arrival;
  late int requestedSeats;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync with provider changes
    final providerPref = Provider.of<RidesPreferencesProvider>(context, listen: true).currentPreference;
    if (providerPref != null && providerPref != widget.initialPreference) {
      _initializeForm();
    }
  }

  @override
  void didUpdateWidget(covariant RidePrefForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPreference != oldWidget.initialPreference) {
      _initializeForm();
    }
  }

  void _initializeForm() {
    final current = widget.initialPreference;
    setState(() {
      departure = current?.departure;
      arrival = current?.arrival;
      departureDate = current?.departureDate ?? DateTime.now();
      requestedSeats = current?.requestedSeats ?? 1;
    });
  }

  Future<void> onDeparturePressed() async {
    final selectedLocation = await Navigator.of(context).push<Location>(
      AnimationUtils.createBottomToTopRoute(
        BlaLocationPicker(initLocation: departure),
      ),
    );

    if (selectedLocation != null) {
      setState(() => departure = selectedLocation);
    }
  }

  Future<void> onArrivalPressed() async {
    final selectedLocation = await Navigator.of(context).push<Location>(
      AnimationUtils.createBottomToTopRoute(
        BlaLocationPicker(initLocation: arrival),
      ),
    );

    if (selectedLocation != null) {
      setState(() => arrival = selectedLocation);
    }
  }

  Future<void> onDatePressed() async {
    final date = await showDatePicker(
      context: context,
      initialDate: departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => departureDate = date);
    }
  }

  Future<void> onPassengerPressed() async {
    final count = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Select seats"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (i) => ListTile(
            title: Text("${i + 1}"),
            onTap: () => Navigator.pop(ctx, i + 1),
          )),
        ),
      ),
    );
    if (count != null) {
      setState(() => requestedSeats = count);
    }
  }

  void onSubmit() {
    if (departure != null && arrival != null) {
      final newPreference = RidePreference(
        departure: departure!,
        departureDate: departureDate,
        arrival: arrival!,
        requestedSeats: requestedSeats,
      );
      widget.onSubmit(newPreference);
    }
  }

  void onSwappingLocationPressed() {
    if (departure != null && arrival != null) {
      setState(() {
        final temp = departure;
        departure = arrival;
        arrival = temp;
      });
    }
  }

  String get departureLabel => departure?.name ?? "Leaving from";
  String get arrivalLabel => arrival?.name ?? "Going to";
  bool get showDeparturePlaceHolder => departure == null;
  bool get showArrivalPlaceHolder => arrival == null;
  String get dateLabel => DateTimeUtils.formatDateTime(departureDate);
  String get numberLabel => requestedSeats == 1 ? "1 Passenger" : "$requestedSeats Passengers";
  bool get switchVisible => arrival != null && departure != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BlaSpacings.m),
          child: Column(
            children: [
              RidePrefInputTile(
                isPlaceHolder: showDeparturePlaceHolder,
                title: departureLabel,
                leftIcon: Icons.location_on,
                onPressed: onDeparturePressed,
                rightIcon: switchVisible ? Icons.swap_vert : null,
                onRightIconPressed: switchVisible ? onSwappingLocationPressed : null,
              ),
              const BlaDivider(),
              RidePrefInputTile(
                isPlaceHolder: showArrivalPlaceHolder,
                title: arrivalLabel,
                leftIcon: Icons.location_on,
                onPressed: onArrivalPressed,
              ),
              const BlaDivider(),
              RidePrefInputTile(
                title: dateLabel,
                leftIcon: Icons.calendar_month,
                onPressed: onDatePressed,
              ),
              const BlaDivider(),
              RidePrefInputTile(
                title: numberLabel,
                leftIcon: Icons.person_2_outlined,
                onPressed: onPassengerPressed,
              ),
            ],
          ),
        ),
        BlaButton(text: 'Search', onPressed: onSubmit),
      ],
    );
  }
}