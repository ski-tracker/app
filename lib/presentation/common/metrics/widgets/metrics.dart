import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../view_model/metrics_view_model.dart';

/// A widget that displays the metrics information such as speed and distance.
class Metrics extends HookConsumerWidget {
  final double? speed;
  final double? distance;

  /// Creates a Metrics widget.
  const Metrics({Key? key, this.speed, this.distance}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(metricsViewModelProvider);
    const textStyle = TextStyle(fontSize: 30.0);

    double speedToDisplay = state.globalSpeed;
    double distanceToDisplay = state.distance;

    if (speed != null) {
      speedToDisplay = speed!;
    }
    if (distance != null) {
      distanceToDisplay = distance!;
    }

    // Format distance: show meters if < 1 km, otherwise show km
    String distanceText;
    if (distanceToDisplay < 1.0) {
      final meters = (distanceToDisplay * 1000).round();
      distanceText = '$meters m';
    } else {
      distanceText = '${distanceToDisplay.toStringAsFixed(2)} km';
    }

    // Format speed: show m/s if < 1 km/h (very slow), otherwise show km/h
    String speedText;
    if (speedToDisplay < 1.0 && speedToDisplay > 0) {
      final metersPerSecond = (speedToDisplay / 3.6).toStringAsFixed(2);
      speedText = '$metersPerSecond m/s';
    } else {
      speedText = '${speedToDisplay.toStringAsFixed(2)} km/h';
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.location_on),
          const SizedBox(width: 8),
          Text(
            distanceText,
            style: textStyle,
          ),
          const SizedBox(width: 40),
          const Icon(Icons.speed),
          const SizedBox(width: 8),
          Text(
            speedText,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
