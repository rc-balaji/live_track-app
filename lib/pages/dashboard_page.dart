import 'package:flutter/material.dart';
import 'package:live_track_app/pages/live_location_page.dart';
import 'package:live_track_app/pages/show_location_page.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  bool _addingLocation = false;
  List<dynamic> _locations = [];
  String _filter = 'All'; // Default filter

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final response = await ApiService().fetchLocations(userProvider.userId);

    if (!mounted) return;

    setState(() {
      _locations = response;
      _loading = false;
    });
  }

  Future<void> _addLocation() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final name = await _showLocationDialog();

    if (name.isEmpty) return;

    setState(() {
      _addingLocation = true;
    });

    final response = await ApiService().addLocation(userProvider.userId, name);

    if (!mounted) return;

    if (response != null && response.containsKey('location_id')) {
      _fetchLocations();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LiveLocationPage(
              locationId: response['location_id'],
              userId: userProvider.userId,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        _showErrorDialog(response['message']);
      }
    }

    if (mounted) {
      setState(() {
        _addingLocation = false;
      });
    }
  }

  Future<String> _showLocationDialog() async {
    String locationName = '';
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Location Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          content: TextField(
            onChanged: (value) {
              locationName = value;
            },
            decoration: InputDecoration(
                hintText: "Location Name", border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(locationName);
              },
              child: Text('Submit', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
    return locationName;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    List<dynamic> filteredLocations = _locations.where((location) {
      if (_filter == 'Live') {
        return location['status'] == 'live';
      } else if (_filter == 'End') {
        return location['status'] == 'end';
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Location List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              userProvider.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Location List',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: _addingLocation ? null : _addLocation,
                  child: _addingLocation
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Filter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: ['All', 'Live', 'End'].map((filter) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _filter == filter ? Colors.blueAccent : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _filter = filter;
                      });
                    },
                    child: Text(filter, style: TextStyle(color: Colors.white)),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            if (_loading)
              Center(child: CircularProgressIndicator())
            else if (filteredLocations.isEmpty)
              Center(child: Text('No locations found.'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index) {
                    final location = filteredLocations[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${index + 1}. ${location['name']}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${location['status']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: location['status'] == 'live'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
