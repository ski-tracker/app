import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/utils/local_storage_service.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../model/request/activity_request.dart';
import '../model/response/activity_response.dart';
import '../model/response/location_response.dart';
import '../model/request/location_request.dart';
import '../../domain/entities/location.dart';

/// Local storage implementation of ActivityRepository
final localActivityRepositoryProvider =
    Provider<ActivityRepository>((ref) => LocalActivityRepoImpl());

interface class LocalActivityRepoImpl extends ActivityRepository {
  LocalActivityRepoImpl();

  @override
  Future<List<Activity>> getActivities() async {
    return await LocalStorageService.getActivities();
  }

  @override
  Future<Activity> getActivityById({required String id}) async {
    final activity = await LocalStorageService.getActivityById(id);
    if (activity == null) {
      throw Exception('Activity not found');
    }
    return activity;
  }

  @override
  Future<String?> removeActivity({required String id}) async {
    await LocalStorageService.deleteActivity(id);
    return 'Activity deleted';
  }

  @override
  Future<Activity?> addActivity(ActivityRequest request) async {
    // Generate a unique ID
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Calculate speed and time from the request
    final duration = request.endDatetime.difference(request.startDatetime);
    final time = duration.inSeconds.toDouble();
    final speed = time > 0 ? (request.distance / time) * 3.6 : 0.0; // km/h

    // Convert LocationRequest to Location
    final locations = request.locations.map((locReq) {
      return Location(
        id: locReq.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        datetime: locReq.datetime,
        latitude: locReq.latitude,
        longitude: locReq.longitude,
      );
    }).toList();

    final activity = Activity(
      id: id,
      type: request.type,
      startDatetime: request.startDatetime,
      endDatetime: request.endDatetime,
      distance: request.distance,
      speed: speed,
      time: time,
      locations: locations,
    );

    await LocalStorageService.saveActivity(activity);
    return activity;
  }

  @override
  Future<Activity> editActivity(ActivityRequest request) async {
    if (request.id == null) {
      throw Exception('Activity ID is required for editing');
    }

    // Get existing activity to preserve calculated values
    final existing = await LocalStorageService.getActivityById(request.id!);
    if (existing == null) {
      throw Exception('Activity not found');
    }

    // Calculate speed and time
    final duration = request.endDatetime.difference(request.startDatetime);
    final time = duration.inSeconds.toDouble();
    final speed = time > 0 ? (request.distance / time) * 3.6 : 0.0;

    // Convert LocationRequest to Location
    final locations = request.locations.map((locReq) {
      return Location(
        id: locReq.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        datetime: locReq.datetime,
        latitude: locReq.latitude,
        longitude: locReq.longitude,
      );
    }).toList();

    final activity = Activity(
      id: request.id!,
      type: request.type,
      startDatetime: request.startDatetime,
      endDatetime: request.endDatetime,
      distance: request.distance,
      speed: speed,
      time: time,
      locations: locations,
    );

    await LocalStorageService.saveActivity(activity);
    return activity;
  }
}

