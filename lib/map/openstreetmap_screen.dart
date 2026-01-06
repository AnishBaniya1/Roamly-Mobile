import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class OpenstreetmapScreen extends StatefulWidget {
  const OpenstreetmapScreen({super.key});

  @override
  State<OpenstreetmapScreen> createState() => _OpenstreetmapScreenState();
}

class _OpenstreetmapScreenState extends State<OpenstreetmapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = true;
  bool _isSatelliteView = false;
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];

  // Add these for autocomplete
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _showSuggestions = false;
  DateTime? _lastRequestTime;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeMap();

    // Listen to text changes for autocomplete
    _locationController.addListener(() {
      if (_locationController.text.length >= 3) {
        _fetchSearchSuggestions(_locationController.text);
      } else {
        setState(() {
          _searchSuggestions = [];
          _showSuggestions = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _mapController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not get location')),
          );
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      try {
        final position = await Geolocator.getCurrentPosition();
        final location = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentLocation = location;
        });
        _mapController.move(location, 15);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not get location')),
          );
        }
      }
    }
  }

  // New method for autocomplete search suggestions
  Future<void> _fetchSearchSuggestions(String query) async {
    // Rate limiting (Nominatim requires 1 req/sec)
    if (_lastRequestTime != null) {
      final timeSince = DateTime.now().difference(_lastRequestTime!);
      if (timeSince.inSeconds < 1) {
        await Future.delayed(
          Duration(milliseconds: 1000 - timeSince.inMilliseconds),
        );
      }
    }
    _lastRequestTime = DateTime.now();

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1",
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'RoamlyApp/1.0 (contact@yourapp.com)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (mounted) {
          setState(() {
            _searchSuggestions = data
                .map(
                  (item) => {
                    'display_name': item['display_name'],
                    'lat': item['lat'],
                    'lon': item['lon'],
                  },
                )
                .toList();
            _showSuggestions = data.isNotEmpty;
          });
        }
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  // New method to handle suggestion selection
  void _selectSuggestion(Map<String, dynamic> suggestion) {
    final lat = double.parse(suggestion['lat']);
    final lon = double.parse(suggestion['lon']);
    final destination = LatLng(lat, lon);

    setState(() {
      _destination = destination;
      _locationController.text = suggestion['display_name'];
      _showSuggestions = false;
      _searchSuggestions = [];
    });

    // Remove focus from search field
    _searchFocusNode.unfocus();

    // Fit bounds to show both current location and destination
    if (_currentLocation != null) {
      final bounds = LatLngBounds.fromPoints([_currentLocation!, destination]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    }

    fetchRoute();
  }

  Future<void> _fetchCordinatesPoint(String location) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1",
    );

    // Add User-Agent header (REQUIRED by Nominatim)
    final response = await http.get(
      url,
      headers: {
        'User-Agent':
            'RoamlyApp/1.0 (contact@yourapp.com)', // Change to your app details
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        final destination = LatLng(lat, lon);

        setState(() {
          _destination = destination;
        });

        // Fit bounds to show both current location and destination
        if (_currentLocation != null && mounted) {
          final bounds = LatLngBounds.fromPoints([
            _currentLocation!,
            destination,
          ]);
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
          );
        }

        await fetchRoute();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Location not found')));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch location (${response.statusCode})'),
          ),
        );
      }
    }
  }

  Future<void> fetchRoute() async {
    if (_currentLocation == null || _destination == null) return;
    final url = Uri.parse(
      "http://router.project-osrm.org/route/v1/driving/"
      '${_currentLocation!.longitude},${_currentLocation!.latitude};'
      '${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyline(geometry);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch route. Try again later'),
          ),
        );
      }
    }
  }

  void _decodePolyline(String encodedPolyline) {
    List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(
      encodedPolyline,
    );

    setState(() {
      _route = decodedPoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenStreetMap'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(_isSatelliteView ? Icons.map : Icons.satellite),
            onPressed: () {
              setState(() {
                _isSatelliteView = !_isSatelliteView;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        _currentLocation ?? const LatLng(28.3949, 84.1240),
                    initialZoom: 13,
                    minZoom: 2,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _isSatelliteView
                          ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.roamly_app',
                      additionalOptions: const {'lang': 'en'},
                    ),
                    const CurrentLocationLayer(
                      style: LocationMarkerStyle(
                        marker: DefaultLocationMarker(
                          child: Icon(Icons.location_pin, color: Colors.white),
                        ),
                        markerSize: Size(35, 35),
                        markerDirection: MarkerDirection.heading,
                      ),
                    ),
                    if (_destination != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _destination!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    if (_currentLocation != null &&
                        _destination != null &&
                        _route.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _route,
                            strokeWidth: 5,
                            color: Colors.red,
                          ),
                        ],
                      ),
                  ],
                ),

          // Updated search bar with autocomplete dropdown
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _locationController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Enter a Location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            suffixIcon: _locationController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _locationController.clear();
                                      setState(() {
                                        _searchSuggestions = [];
                                        _showSuggestions = false;
                                        _destination = null;
                                        _route = [];
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (value) {
                            final location = value.trim();
                            if (location.isNotEmpty) {
                              _fetchCordinatesPoint(location);
                              setState(() {
                                _showSuggestions = false;
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          final location = _locationController.text.trim();
                          if (location.isNotEmpty) {
                            _fetchCordinatesPoint(location);
                            setState(() {
                              _showSuggestions = false;
                            });
                          }
                        },
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),

                  // Autocomplete dropdown suggestions
                  if (_showSuggestions && _searchSuggestions.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchSuggestions.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final suggestion = _searchSuggestions[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                            ),
                            title: Text(
                              suggestion['display_name'],
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSuggestion(suggestion),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: _moveToCurrentLocation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, size: 30, color: Colors.white),
      ),
    );
  }
}
