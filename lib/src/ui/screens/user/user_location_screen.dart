import 'package:flutter/material.dart';
import '../../widgets/location_map_widget.dart';

class UserLocationScreen extends StatelessWidget {
  const UserLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LocationMapWidget(title: 'Localizador de Sedes'),
    );
  }
}
