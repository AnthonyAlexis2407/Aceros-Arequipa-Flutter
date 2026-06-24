import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BubbleLevelScreen extends StatefulWidget {
  const BubbleLevelScreen({super.key});

  @override
  State<BubbleLevelScreen> createState() => _BubbleLevelScreenState();
}

class _BubbleLevelScreenState extends State<BubbleLevelScreen> {
  double _x = 0;
  double _y = 0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Constantes de diseño
  final double bubbleSize = 50;
  final double containerSize = 250;

  @override
  void initState() {
    super.initState();
    // Suscribirse a los eventos del acelerómetro
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      setState(() {
        // En los teléfonos, X es izquierda/derecha, Y es arriba/abajo
        // Al rotar la pantalla plana sobre una mesa, X e Y deben ser 0.
        // Se aplica un factor de suavizado básico
        _x = event.x;
        _y = event.y;
      });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  // Convertir aceleración a grados
  double _getDegreesX() {
    // Si la aceleración excede la gravedad, la limitamos a 9.81 para el cálculo
    double xVal = _x.clamp(-9.81, 9.81);
    return asin(xVal / 9.81) * 180 / pi;
  }

  double _getDegreesY() {
    double yVal = _y.clamp(-9.81, 9.81);
    return asin(yVal / 9.81) * 180 / pi;
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos los grados
    double degreesX = _getDegreesX();
    double degreesY = _getDegreesY();

    // Verificamos si está nivelado (margen de error de +/- 1 grado)
    bool isLevel = degreesX.abs() < 1.0 && degreesY.abs() < 1.0;

    // Posición visual de la burbuja (limitada al círculo interior)
    // Multiplicamos por un factor para que se mueva por todo el contenedor
    double maxOffset = (containerSize / 2) - (bubbleSize / 2);
    
    // Invertimos las coordenadas para que la burbuja suba hacia el lado más alto
    double visualX = -(_x / 9.81) * maxOffset;
    double visualY = (_y / 9.81) * maxOffset;

    // Asegurarnos de que no salga del círculo usando el teorema de Pitágoras
    double distance = sqrt(visualX * visualX + visualY * visualY);
    if (distance > maxOffset) {
      visualX = visualX * (maxOffset / distance);
      visualY = visualY * (maxOffset / distance);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F0EA),
      appBar: AppBar(
        title: const Text(
          'Nivel de Burbuja',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF001B5A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Herramienta de Calibración',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001B5A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coloca el dispositivo sobre una\nsuperficie para medir la inclinación.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 50),
            
            // Contenedor principal del nivel
            Container(
              width: containerSize + 20,
              height: containerSize + 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo de fondo líquido
                  Container(
                    width: containerSize,
                    height: containerSize,
                    decoration: BoxDecoration(
                      color: isLevel ? Colors.green.withValues(alpha: 0.2) : const Color(0xFFBFCFEF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  // Líneas guía de mira (Cruz)
                  Container(width: 1, height: containerSize, color: Colors.black12),
                  Container(width: containerSize, height: 1, color: Colors.black12),
                  
                  // Círculo central objetivo (Nivel perfecto)
                  Container(
                    width: bubbleSize + 10,
                    height: bubbleSize + 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isLevel ? Colors.green : const Color(0xFF001B5A),
                        width: 2,
                      ),
                    ),
                  ),
                  
                  // La burbuja animada
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOutCubic,
                    left: (containerSize / 2) - (bubbleSize / 2) + visualX,
                    top: (containerSize / 2) - (bubbleSize / 2) + visualY,
                    child: Container(
                      width: bubbleSize,
                      height: bubbleSize,
                      decoration: BoxDecoration(
                        color: isLevel ? Colors.green : const Color(0xFF0A3D91),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                        gradient: RadialGradient(
                          colors: isLevel 
                            ? [Colors.lightGreenAccent, Colors.green]
                            : [Colors.lightBlueAccent, const Color(0xFF0A3D91)],
                          center: const Alignment(-0.3, -0.3),
                          radius: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Indicadores numéricos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAngleIndicator('EJE X', degreesX, isLevel),
                  Container(
                    height: 40,
                    width: 1,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  _buildAngleIndicator('EJE Y', degreesY, isLevel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAngleIndicator(String label, double angle, bool isLevel) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${angle.abs().toStringAsFixed(1)}°',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isLevel ? Colors.green : const Color(0xFF001B5A),
          ),
        ),
      ],
    );
  }
}
