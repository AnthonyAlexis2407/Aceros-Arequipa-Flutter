import 'dart:async';
import 'package:flutter/material.dart';
import '../../ui/screens/auth/login_screen.dart';

class SessionManager extends StatefulWidget {
  final Widget child;

  const SessionManager({super.key, required this.child});

  @override
  State<SessionManager> createState() => _SessionManagerState();
}

class _SessionManagerState extends State<SessionManager> with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  static const Duration _inactivityDuration = Duration(minutes: 5);

  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityDuration, _logout);
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _logout() {
    _inactivityTimer?.cancel();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      // Record the time the app was minimized
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // When app comes back, check if 5 minutes have passed
      if (_pausedTime != null) {
        final difference = DateTime.now().difference(_pausedTime!);
        if (difference >= _inactivityDuration) {
          _logout();
        } else {
          _resetInactivityTimer();
        }
        _pausedTime = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetInactivityTimer(),
      onPointerMove: (_) => _resetInactivityTimer(),
      onPointerUp: (_) => _resetInactivityTimer(),
      child: widget.child,
    );
  }
}
