import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import 'dashboard_page.dart';

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
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _stopTracking(disposeCall: true);
    super.dispose();
  }

  Future<void> _startTracking() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return;

    if (mounted) {
      setState(() => _isTracking = true);
    }

    _positionStreamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        if (!mounted) return;
        setState(() => _currentPosition = position);

        ApiService().updateLocation(
          widget.locationId,
          position.latitude,
          position.longitude,
          widget.userId,
        );
      },
    );
  }

  Future<void> _stopTracking({bool disposeCall = false}) async {
    if (_positionStreamSubscription != null) {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
    }

    if (!disposeCall && mounted) {
      setState(() => _isTracking = false);
    }

    await ApiService().stopTracking(widget.locationId);

    // Prevent navigation when disposing
    if (!disposeCall && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    }
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
            SizedBox(height: 10),
            if (_currentPosition != null)
              Column(
                children: [
                  Text('Latitude: ${_currentPosition!.latitude}'),
                  Text('Longitude: ${_currentPosition!.longitude}'),
                ],
              ),
            SizedBox(height: 20),
            _isTracking
                ? ElevatedButton(
                    onPressed: () => _stopTracking(),
                    child: Text('Stop Tracking'),
                  )
                : ElevatedButton(
                    onPressed: () => _startTracking(),
                    child: Text('Start Tracking'),
                  ),
          ],
        ),
      ),
    );
  }
}
