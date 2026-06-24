import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_home_screen.dart';
import 'user_store_screen.dart';
import 'user_cart_screen.dart';
import 'user_ai_screen.dart';
import 'user_location_screen.dart';
import 'bubble_level_screen.dart';
import 'metal_detector_screen.dart';
import '../auth/login_screen.dart';
import '../../../core/utils/session_manager.dart';

class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => UserShellState();
}

class UserShellState extends State<UserShell> {
  int _currentIndex = 0;

  void setSelectedIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    const UserHomeScreen(),
    const UserStoreScreen(),
    const UserCartScreen(),
    const UserAiScreen(),
    const UserLocationScreen(),
  ];

  static const List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
    BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Tienda'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Carrito'),
    BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), activeIcon: Icon(Icons.smart_toy), label: 'Asistencia IA'),
    BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: 'Ubicación'),
  ];

  @override
  Widget build(BuildContext context) {
    return SessionManager(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF001B5A)),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: Image.asset(
            'assets/images/Aceros_Logo.png',
            height: 32,
            fit: BoxFit.contain,
          ),
          centerTitle: true,
          actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF001B5A)),
            onPressed: () {
              setState(() => _currentIndex = 2); // Switch to Cart screen
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF001B5A),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Aceros_Logo.png',
                      height: 48,
                      width: 48,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cargando...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }

                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        final name = data['name'] ?? 'Usuario';
                        final docType = data['documentType'] ?? 'DNI';
                        final document = data['document'] ?? '';
                        final role = data['role'] == 'admin' ? 'Administrador' : 'Cliente Normal';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$docType: $document • $role',
                              style: const TextStyle(
                                color: Color(0xFFBFCFEF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF0A3D91)),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.storefront, color: Color(0xFF0A3D91)),
              title: const Text('Tienda / Catálogo'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Color(0xFF0A3D91)),
              title: const Text('Mi Carrito'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy, color: Color(0xFF0A3D91)),
              title: const Text('Asistencia IA'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_pin, color: Color(0xFF0A3D91)),
              title: const Text('Puntos de Distribución'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.architecture, color: Color(0xFF001B5A)),
              title: const Text('Nivel de Burbuja (Tool)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BubbleLevelScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.radar, color: Color(0xFF001B5A)),
              title: const Text('Detector de Acero (Tool)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MetalDetectorScreen()),
                );
              },
            ),
            const Divider(),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0A3D91),
        unselectedItemColor: const Color(0xFF64748B),
        currentIndex: _currentIndex,
        items: _items,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    ));
  }
}
