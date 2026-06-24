import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MetalDetectorScreen extends StatefulWidget {
  const MetalDetectorScreen({super.key});

  @override
  State<MetalDetectorScreen> createState() => _MetalDetectorScreenState();
}

class _MetalDetectorScreenState extends State<MetalDetectorScreen> with SingleTickerProviderStateMixin {
  double _smoothMagnitude = 0.0;
  double _baseline = 0.0;
  bool _isCalibrated = false;
  
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  late AnimationController _animationController;

  // Umbrales fijos sobre la línea base
  final double warningOffset = 15.0; // +15 µT sobre el ambiente
  final double dangerOffset = 40.0;  // +40 µT sobre el ambiente

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _magnetometerSubscription = magnetometerEventStream().listen((MagnetometerEvent event) {
      double currentMagnitude = sqrt((event.x * event.x) + (event.y * event.y) + (event.z * event.z));
      
      setState(() {
        if (_smoothMagnitude == 0.0) {
          _smoothMagnitude = currentMagnitude;
        } else {
          _smoothMagnitude = (_smoothMagnitude * 0.8) + (currentMagnitude * 0.2);
        }
        
        // Autocalibración inicial si no se ha hecho
        if (!_isCalibrated && _smoothMagnitude > 10) {
          _baseline = _smoothMagnitude;
          _isCalibrated = true;
        }
      });
    });
  }

  void _calibrate() {
    setState(() {
      _baseline = _smoothMagnitude;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calibración base ajustada. Se detectará cualquier incremento desde ahora.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  void dispose() {
    _magnetometerSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // Obtenemos cuánto aumentó respecto al ambiente base
  double get _relativeMagnitude {
    // Si no está calibrado usamos 45 como base normal de la tierra
    double base = _isCalibrated ? _baseline : 45.0;
    double diff = _smoothMagnitude - base;
    return diff < 0 ? 0 : diff; 
  }

  Color _getIndicatorColor() {
    if (_relativeMagnitude < warningOffset) return Colors.greenAccent;
    if (_relativeMagnitude < dangerOffset) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _getStatusMessage() {
    if (_relativeMagnitude < warningOffset) return "Escaneando...";
    if (_relativeMagnitude < dangerOffset) return "Aproximándose...";
    return "¡ACERO DETECTADO!";
  }

  String _getDistanceEstimation() {
    if (_relativeMagnitude < 5) return "Sin presencia";
    if (_relativeMagnitude < warningOffset) return "Lejos (> 15 cm)";
    if (_relativeMagnitude < dangerOffset) return "Cerca (5 - 15 cm)";
    return "Contacto (< 5 cm)";
  }

  @override
  Widget build(BuildContext context) {
    Color indicatorColor = _getIndicatorColor();
    double visualMagnitude = _relativeMagnitude.clamp(0.0, 100.0);
    double fillPercentage = visualMagnitude / 100.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Detector de Acero', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF001B5A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Calibrar Ambiente',
            onPressed: _calibrate,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Guía de Uso Optimizada
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blueAccent, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'TIP: El sensor magnético suele estar en la parte superior del teléfono, cerca de la cámara. Pasa esa zona sobre la pared.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Medidor Visual Circular
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white12, width: 2),
                  ),
                ),
                
                // Efecto de pulso animado
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      width: 280 * _animationController.value,
                      height: 280 * _animationController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: indicatorColor.withValues(alpha: 1.0 - _animationController.value),
                          width: 2,
                        ),
                        color: indicatorColor.withValues(alpha: (1.0 - _animationController.value) * 0.1),
                      ),
                    );
                  },
                ),

                // Círculo Central Dinámico
                Container(
                  width: 140 + (fillPercentage * 40),
                  height: 140 + (fillPercentage * 40),
                  decoration: BoxDecoration(
                    color: indicatorColor.withValues(alpha: 0.15 + (fillPercentage * 0.3)),
                    shape: BoxShape.circle,
                    border: Border.all(color: indicatorColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: indicatorColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5 * fillPercentage,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '+${_relativeMagnitude.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'µT (Incremento)',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),

            // Indicador de Distancia Estimada y Estado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStatusMessage(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: indicatorColor,
                          letterSpacing: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: indicatorColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: indicatorColor),
                        ),
                        child: Text(
                          _getDistanceEstimation(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: indicatorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Botón de calibración manual
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _calibrate,
                      icon: const Icon(Icons.settings_backup_restore, size: 20),
                      label: const Text('CALIBRAR A CERO (AMBIENTE ACTUAL)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
