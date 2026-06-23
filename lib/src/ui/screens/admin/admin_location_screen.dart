import 'package:flutter/material.dart';
import '../../widgets/location_map_widget.dart';

class AdminLocationScreen extends StatelessWidget {
  const AdminLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LocationMapWidget(title: 'Localizador de Sedes'),
    );
  }
}
