import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../data/model/request/location_request.dart';
import '../../metrics/view_model/metrics_view_model.dart';
import '../../timer/viewmodel/timer_view_model.dart';
import 'location_state.dart';

/// Provider for the [LocationViewModel].
final locationViewModelProvider =
    StateNotifierProvider.autoDispose<LocationViewModel, LocationState>(
  (ref) => LocationViewModel(ref),
);

/// View model for managing location-related functionality.
class LocationViewModel extends StateNotifier<LocationState> {
  final Ref ref;
  final MapController mapController = MapController();
  StreamSubscription<Position>? _positionStream;

  /// Creates a [LocationViewModel] instance.
  ///
  /// The [ref] is a reference to the current provider reference.
  LocationViewModel(this.ref) : super(LocationState.initial());

  @override
  void dispose() {
    super.dispose();
    cancelLocationStream();
  }

  /// Starts getting the user's location updates.
  Future<void> startGettingLocation() async {
    final metricsProvider = ref.read(metricsViewModelProvider.notifier);

    print('📍 [LOCATION] Requesting location permission...');
    final permission = await Geolocator.requestPermission();
    print('📍 [LOCATION] Permission status: $permission');
    
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      print('❌ [LOCATION] Permission denied! Cannot track location.');
      return;
    }
    
    print('✅ [LOCATION] Permission granted! Starting location stream...');
    _positionStream ??=
        Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        print('📍 [LOCATION] GPS Update: lat=${position.latitude}, lon=${position.longitude}, accuracy=${position.accuracy}m');
        
        mapController.move(
          LatLng(position.latitude, position.longitude),
          17,
        );

        final timerProvider = ref.read(timerViewModelProvider.notifier);
        final isRunning = timerProvider.isTimerRunning();
        final hasStarted = timerProvider.hasTimerStarted();
        
        print('⏱️ [TIMER] isRunning=$isRunning, hasStarted=$hasStarted');
        
        if (isRunning && hasStarted) {
          print('✅ [TRACKING] Timer is active - processing location update');
          
          // Update state first to ensure lastPosition is set before calculating metrics
          final oldLastPosition = state.lastPosition;
          state = state.copyWith(
            currentPosition: position,
            lastPosition: state.currentPosition ?? position,
          );
          
          print('📍 [POSITION] lastPosition: ${oldLastPosition?.latitude},${oldLastPosition?.longitude}');
          print('📍 [POSITION] currentPosition: ${state.currentPosition?.latitude},${state.currentPosition?.longitude}');
          
          // Only update metrics if we have both current and last position
          if (state.currentPosition != null && state.lastPosition != null) {
            print('📊 [METRICS] Calling updateMetrics()...');
            metricsProvider.updateMetrics();
          } else {
            print('⚠️ [METRICS] Skipping - missing positions: current=${state.currentPosition != null}, last=${state.lastPosition != null}');
          }

          final positions = List<LocationRequest>.from(state.savedPositions);
          positions.add(
            LocationRequest(
              datetime: DateTime.now(),
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          );
          state = state.copyWith(savedPositions: positions);
          print('💾 [SAVED] Total positions saved: ${state.savedPositions.length}');
        } else {
          print('⏸️ [TRACKING] Timer not active - updating position for map only');
          // Update position even when timer not running (for map display)
          state = state.copyWith(
            currentPosition: position,
            lastPosition: state.currentPosition ?? position,
          );
        }
      }
    });
  }

  /// Retrieves the saved positions as a list of [LatLng] objects.
  List<LatLng> savedPositionsLatLng() {
    return state.savedPositions
        .map((position) => LatLng(position.latitude, position.longitude))
        .toList();
  }

  /// Resets the saved positions to an empty list.
  void resetSavedPositions() {
    state = state.copyWith(savedPositions: []);
  }

  /// Pauses the location stream.
  void stopLocationStream() {
    _positionStream?.pause();
  }

  /// Resumes the location stream.
  void resumeLocationStream() {
    _positionStream?.resume();
  }

  /// Cancels the location stream and cleans up resources.
  void cancelLocationStream() async {
    await _positionStream?.cancel().whenComplete(() {
      _positionStream = null;
      state = state.copyWith(currentPosition: null);
    });
  }

  /// Checks if the location stream is currently paused.
  bool isLocationStreamPaused() {
    return _positionStream?.isPaused ?? false;
  }
}
