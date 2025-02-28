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
  bool _isTracking = false; // Initially not tracking
  bool _isPaused = false;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    // Start tracking automatically when the page loads
    _startTracking();
  }

  @override
  void dispose() {
    _stopTracking(); // Ensure tracking is stopped when the widget is disposed
    super.dispose();
  }

  // Start GPS tracking and make API call to update location
  Future<void> _startTracking() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return;

    if (mounted) {
      setState(() {
        _isTracking = true;
        _isPaused = false;
      });
    }

    _positionStreamSubscription = Geolocator.getPositionStream().listen(
      (Position position) {
        if (!mounted) return;
        setState(() {
          _currentPosition = position;
        });

        // If not paused, send location update to the API
        if (!_isPaused) {
          ApiService().updateLocation(
            widget.locationId,
            position.latitude,
            position.longitude,
            widget.userId,
          );
        }
      },
    );
  }

  // Pause tracking without making API call
  Future<void> _pauseTracking() async {
    if (mounted) {
      setState(() {
        _isPaused = true;
      });
    }
  }

  // Stop tracking and call API to stop tracking
  Future<void> _stopTracking() async {
    if (_positionStreamSubscription != null) {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
    }

    // Stop tracking API call
    await ApiService().stopTracking(widget.locationId);

    // Check if the widget is still mounted before calling setState
    if (mounted) {
      setState(() {
        _isTracking = false;
        _isPaused = false;
      });
    }

    // Navigate to Dashboard after stopping tracking
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Location'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display tracking status
              Text(
                _isTracking
                    ? _isPaused
                        ? 'Tracking Paused'
                        : 'Tracking Active'
                    : 'Tracking Inactive',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _isTracking
                      ? (_isPaused ? Colors.orange : Colors.green)
                      : Colors.red,
                ),
              ),
              SizedBox(height: 20),
              // Show latitude and longitude if available
              if (_currentPosition != null)
                Column(
                  children: [
                    Text(
                      'Latitude: ${_currentPosition!.latitude}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Longitude: ${_currentPosition!.longitude}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              SizedBox(height: 30),
              // Action buttons: Start, Pause, Stop
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isTracking && !_isPaused
                        ? null
                        : () => _startTracking(),
                    child: Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: !_isTracking || _isPaused
                        ? null
                        : () => _pauseTracking(),
                    child: Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: !_isTracking ? null : () => _stopTracking(),
                    child: Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
