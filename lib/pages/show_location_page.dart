import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // Import the user provider
import 'dashboard_page.dart'; // Import DashboardPage to navigate directly
import '../services/api_service.dart'; // Import the API service to fetch location data

class ShowLocationPage extends StatefulWidget {
  final String locationId;

  const ShowLocationPage({super.key, required this.locationId});

  @override
  _ShowLocationPageState createState() => _ShowLocationPageState();
}

class _ShowLocationPageState extends State<ShowLocationPage> {
  late String userId;
  bool isLoading = true;
  bool isError = false; // Flag to track if there's an error in fetching data
  List<LatLng> locations = [];

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false)
        .userId; // Get user_id from Provider
    _fetchLocationData(); // Fetch location data based on user_id and location_id
  }

  // Fetch location data based on user_id and location_id
  Future<void> _fetchLocationData() async {
    try {
      final locationData = await ApiService().fetchLocations(userId);

      // Search for the location by locationId
      final location = locationData.firstWhere(
          (loc) => loc['_id'] == widget.locationId,
          orElse: () => null);

      if (location != null) {
        setState(() {
          locations = _parseLocationCoordinates(location['locations']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true; // Set error if no location is found
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true; // Set error if API call fails
      });
      // Handle error (e.g., show a message)
      print('Error fetching location: $error');
    }
  }

  // Parse the location coordinates from the API response
  List<LatLng> _parseLocationCoordinates(dynamic coordinates) {
    List<LatLng> parsedLocations = [];
    if (coordinates != null) {
      for (var coordinate in coordinates) {
        parsedLocations
            .add(LatLng(coordinate['latitude'], coordinate['longitude']));
      }
    }
    return parsedLocations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // You can add any actions here like navigating to another map view
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner while fetching data
          : isError
              ? Center(
                  child: Text(
                      'Error loading location data. Please try again.')) // Error message
              : locations.isEmpty
                  ? Center(
                      child:
                          Text('No locations to display')) // Empty data message
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: locations.isNotEmpty
                            ? locations.first
                            : LatLng(0, 0),
                        initialZoom: 15.0, // Increased zoom level
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            if (locations.isNotEmpty)
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: locations.first,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.green, // Start pin (green)
                                  size: 40.0,
                                ),
                              ),
                            if (locations.isNotEmpty && locations.length > 1)
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: locations.last,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red, // End pin (red)
                                  size: 40.0,
                                ),
                              ),
                          ],
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: locations,
                              strokeWidth: 4.0,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate back to the DashboardPage directly
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }
}
