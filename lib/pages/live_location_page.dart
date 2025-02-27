import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart'; // Import DashboardPage to navigate directly

class LiveLocationPage extends StatefulWidget {
  final String locationId;
  final String userId;

  LiveLocationPage({required this.locationId, required this.userId});

  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  bool _isTracking = false;
  Position? _currentPosition;

  Future<void> _startTracking() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      setState(() => _isTracking = true);
      Geolocator.getPositionStream().listen((Position position) {
        setState(() => _currentPosition = position);
        ApiService().updateLocation(
          widget.locationId,
          position.latitude,
          position.longitude,
          widget.userId,
        );
      });
    }
  }

  Future<void> _stopTracking() async {
    setState(() => _isTracking = false);
    await ApiService().stopTracking(widget.locationId);
    // Navigate directly back to the DashboardPage without using named routes
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => DashboardPage()), // Direct navigation
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Location')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_isTracking ? 'Tracking Active' : 'Tracking Inactive'),
            SizedBox(height: 20),
            _isTracking
                ? ElevatedButton(
                    onPressed: _stopTracking,
                    child: Text('Stop Tracking'),
                  )
                : ElevatedButton(
                    onPressed: _startTracking,
                    child: Text('Start Tracking'),
                  ),
          ],
        ),
      ),
    );
  }
}
