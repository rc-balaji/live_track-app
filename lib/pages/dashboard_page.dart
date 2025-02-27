import 'package:flutter/material.dart';
import 'package:live_track_app/pages/live_location_page.dart';
import 'package:live_track_app/pages/show_location_page.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart'; // Import the ApiService for fetching locations
import 'login_page.dart'; // Import LoginPage to navigate directly

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true; // Track the loading state
  bool _addingLocation = false; // Track if we're adding a location
  List<dynamic> _locations = []; // To store locations data

  @override
  void initState() {
    super.initState();
    _fetchLocations(); // Fetch locations when the page is initialized
  }

  // Function to fetch locations from the API
  Future<void> _fetchLocations() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final response = await ApiService().fetchLocations(userProvider.userId);

    setState(() {
      _locations = response; // Assuming the response is a list of locations
      _loading = false; // Set loading to false after data is fetched
    });
  }

  // Function to add a location
  Future<void> _addLocation() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final name = await _showLocationDialog();

    if (name.isEmpty) {
      return;
    }

    setState(() {
      _addingLocation = true; // Show loading while adding location
    });

    final response = await ApiService().addLocation(userProvider.userId, name);

    if (response != null && response.containsKey('location_id')) {
      _fetchLocations(); // Fetch the updated list of locations after adding a new one
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LiveLocationPage(
                  locationId: response['location_id'],
                  userId: userProvider.userId,
                )),
      );
    } else {
      _showErrorDialog(response['message']);
    }

    setState(() {
      _addingLocation = false; // Hide loading after the location is added
    });
  }

  // Function to show the dialog for adding a location
  Future<String> _showLocationDialog() async {
    String locationName = '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Location Name'),
          content: TextField(
            onChanged: (value) {
              locationName = value;
            },
            decoration: InputDecoration(hintText: "Location Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(locationName);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
    return locationName;
  }

  // Function to show error messages
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              userProvider.logout();
              // Directly navigate to LoginPage without named routes
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Add Location Button
            ElevatedButton(
              onPressed: _addingLocation ? null : _addLocation,
              child:
                  Text(_addingLocation ? 'Adding Location...' : 'Add Location'),
            ),
            SizedBox(height: 20),
            // Loading indicator while fetching locations
            if (_loading)
              CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    final location = _locations[index];
                    return ListTile(
                      title: Text(location['name']),
                      subtitle: Text('Status: ${location['status']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowLocationPage(
                              locationId: location['_id'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
