# Ski Tracker
A Flutter ski tracking app - live tracking - Clean architecture.

It's a ski tracker app to track the distance, speed and time of your skiing activities (skiing, running, walking, cycling, etc.).

### State Management
- Riverpod

## Location related technologies used
Location tracking packages
1. **geolocator**: ^9.0.2 — GPS location
Purpose: Gets GPS coordinates from the device
Features:
Real-time location updates via getPositionStream()
Permission handling
Location accuracy information
Usage: Tracks your position continuously during activities
2. **flutter_map**: ^4.0.0 — Map display
Purpose: Displays maps and routes
Features:
OpenStreetMap tile support
Markers and polylines for routes
Map controls (zoom, pan)
Usage: Shows your current location and route on the map
3. **latlong2**: ^0.8.1 — Coordinates
Purpose: Handles latitude/longitude calculations
Features:
LatLng class for coordinates
Distance calculations
Usage: Used with flutter_map for map points
Supporting packages
wakelock_plus: ^1.2.8 — Keeps screen awake during tracking
shared_preferences: ^2.1.2 — Stores location data locally
How they work together
geolocator → Gets GPS coordinates     ↓latlong2 → Converts to LatLng format     ↓flutter_map → Displays on map     ↓Haversine formula → Calculates distance between points
Summary
GPS tracking: geolocator
Map display: flutter_map + latlong2
Distance calculation: Custom Haversine formula (in the code)
Speed calculation: Distance ÷ Time
These are standard Flutter packages for location tracking and mapping.

