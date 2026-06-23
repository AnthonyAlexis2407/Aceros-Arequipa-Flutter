import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationData {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String schedule;
  final LatLng position;
  final int categoryIndex;
  final String categoryName;

  LocationData({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.schedule,
    required this.position,
    required this.categoryIndex,
    required this.categoryName,
  });
}

class LocationMapWidget extends StatefulWidget {
  final String title;

  const LocationMapWidget({super.key, this.title = 'Localizador de Sedes'});

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? _mapController;

  final List<LocationData> _locations = [
    LocationData(
      id: 'pisco',
      name: 'Sede Pisco - Planta',
      address: 'Km. 240 Panamericana Sur, Pisco, Ica',
      phone: '(01) 517-1800',
      schedule: '24/7 Ops',
      position: const LatLng(-13.7000, -76.2000),
      categoryIndex: 2,
      categoryName: 'ALMACÉN CENTRAL',
    ),
    LocationData(
      id: 'lima',
      name: 'Lima - Sede Principal',
      address: 'Av. Enrique Meiggs 297, Callao',
      phone: '(01) 517-1800',
      schedule: 'L-V: 8am - 5pm',
      position: const LatLng(-12.0464, -77.0428),
      categoryIndex: 1,
      categoryName: 'DISTRIBUIDOR AUTORIZADO',
    ),
    LocationData(
      id: 'arequipa',
      name: 'Arequipa - Almacén',
      address: 'Variante de Uchumayo Km 4.5',
      phone: '(054) 211-800',
      schedule: 'L-V: 8am - 6pm',
      position: const LatLng(-16.4090, -71.5375),
      categoryIndex: 2,
      categoryName: 'ALMACÉN CENTRAL',
    ),
  ];

  int _selectedFilter = 0; // 0: Todo, 1: Distribuidor, 2: Almacén
  LocationData? _selectedLocation;

  static const String _darkMapStyle = '''
  [
    {"elementType": "geometry","stylers": [{"color": "#212121"}]},
    {"elementType": "labels.icon","stylers": [{"visibility": "off"}]},
    {"elementType": "labels.text.fill","stylers": [{"color": "#757575"}]},
    {"elementType": "labels.text.stroke","stylers": [{"color": "#212121"}]},
    {"featureType": "administrative","elementType": "geometry","stylers": [{"color": "#757575"}]},
    {"featureType": "administrative.country","elementType": "labels.text.fill","stylers": [{"color": "#9e9e9e"}]},
    {"featureType": "administrative.land_parcel","stylers": [{"visibility": "off"}]},
    {"featureType": "administrative.locality","elementType": "labels.text.fill","stylers": [{"color": "#bdbdbd"}]},
    {"featureType": "poi","elementType": "labels.text.fill","stylers": [{"color": "#757575"}]},
    {"featureType": "poi.park","elementType": "geometry","stylers": [{"color": "#181818"}]},
    {"featureType": "poi.park","elementType": "labels.text.fill","stylers": [{"color": "#616161"}]},
    {"featureType": "poi.park","elementType": "labels.text.stroke","stylers": [{"color": "#1b1b1b"}]},
    {"featureType": "road","elementType": "geometry.fill","stylers": [{"color": "#2c2c2c"}]},
    {"featureType": "road","elementType": "labels.text.fill","stylers": [{"color": "#8a8a8a"}]},
    {"featureType": "road.arterial","elementType": "geometry","stylers": [{"color": "#373737"}]},
    {"featureType": "road.highway","elementType": "geometry","stylers": [{"color": "#3c3c3c"}]},
    {"featureType": "road.highway.controlled_access","elementType": "geometry","stylers": [{"color": "#4e4e4e"}]},
    {"featureType": "road.local","elementType": "labels.text.fill","stylers": [{"color": "#616161"}]},
    {"featureType": "transit","elementType": "labels.text.fill","stylers": [{"color": "#757575"}]},
    {"featureType": "water","elementType": "geometry","stylers": [{"color": "#000000"}]},
    {"featureType": "water","elementType": "labels.text.fill","stylers": [{"color": "#3d3d3d"}]}
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _selectedLocation = _locations.firstWhere((loc) => loc.id == 'pisco');
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    _mapController = controller;
  }

  void _onFilterTapped(int index) {
    setState(() {
      _selectedFilter = index;
      if (index == 0) {
        _selectedLocation = _locations.first;
      } else {
        try {
          _selectedLocation = _locations.firstWhere((loc) => loc.categoryIndex == index);
        } catch (_) {
          _selectedLocation = null;
        }
      }
    });

    if (_selectedLocation != null) {
      _moveToLocation(_selectedLocation!.position);
    }
  }

  void _moveToLocation(LatLng position) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 13.0),
        ),
      );
    }
  }

  void _onMarkerTapped(LocationData location) {
    setState(() {
      _selectedLocation = location;
      if (_selectedFilter != 0 && location.categoryIndex != _selectedFilter) {
         _selectedFilter = 0;
      }
    });
    _moveToLocation(location.position);
  }

  @override
  Widget build(BuildContext context) {
    List<LocationData> visibleLocations = _selectedFilter == 0
        ? _locations
        : _locations.where((loc) => loc.categoryIndex == _selectedFilter).toList();

    Set<Marker> markers = visibleLocations.map((loc) {
      bool isSelected = _selectedLocation?.id == loc.id;
      return Marker(
        markerId: MarkerId(loc.id),
        position: loc.position,
        onTap: () => _onMarkerTapped(loc),
        icon: loc.categoryIndex == 1
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        alpha: isSelected ? 1.0 : 0.7,
      );
    }).toSet();

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por ciudad o distrito...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.blue.shade800),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Toggles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  _buildFilterButton('Todo', 0),
                  _buildFilterButton('Distribuidor', 1),
                  _buildFilterButton('Almacén', 2),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Details Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _selectedLocation == null 
            ? Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    "Seleccione una ubicación en el mapa",
                    style: TextStyle(color: Colors.grey.shade500),
                  )
                ),
              )
            : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _selectedLocation!.categoryIndex == 1 
                              ? Colors.orange.shade50 
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _selectedLocation!.categoryName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _selectedLocation!.categoryIndex == 1 
                                ? Colors.orange.shade800 
                                : Colors.blue.shade800,
                          ),
                        ),
                      ),
                      Icon(Icons.verified, color: Colors.green.shade500, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedLocation!.name,
                    style: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _selectedLocation!.address,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.phone_rounded, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 6),
                      Text(
                        _selectedLocation!.phone, 
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.w500)
                      ),
                      const Spacer(),
                      Icon(Icons.access_time_filled, size: 14, color: Colors.orange.shade600),
                      const SizedBox(width: 6),
                      Text(
                        _selectedLocation!.schedule, 
                        style: TextStyle(color: Colors.grey.shade800, fontSize: 13, fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Google Map 
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  style: _darkMapStyle,
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation?.position ?? const LatLng(-9.189967, -75.015152),
                    zoom: 5.0,
                  ),
                  markers: markers,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    bool isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onFilterTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
