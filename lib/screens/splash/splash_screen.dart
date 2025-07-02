import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../app.dart';
import '../home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoPulseController;
  late Animation<double> _logoPulse;
  late AnimationController _backgroundController;
  late Animation<Alignment> _beginAlignment;
  late Animation<Alignment> _endAlignment;

  double _progress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    // Logo pulse animation
    _logoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _logoPulse = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _logoPulseController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _logoPulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _logoPulseController.forward();
      }
    });
    _logoPulseController.forward();

    // Animated gradient background
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _beginAlignment = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
    _endAlignment = AlignmentTween(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    ).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Progress simulation
    const totalDuration = 5; // seconds
    const tick = Duration(milliseconds: 50);
    _progressTimer = Timer.periodic(tick, (timer) {
      setState(() {
        _progress += tick.inMilliseconds / (totalDuration * 1000);
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _navigateNext();
        }
      });
    });
  }

  void _navigateNext() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (context, animation, secondaryAnimation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            );
            return FadeTransition(opacity: curved, child: const MainScreen());
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoPulseController.dispose();
    _backgroundController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          // Calculate parallax offset for glow circles
          final dx = sin(_backgroundController.value * 2 * pi) * 20;
          final dy = cos(_backgroundController.value * 2 * pi) * 20;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _beginAlignment.value,
                end: _endAlignment.value,
                colors: const [
                  Color(0xFF0F0F0F),
                  Color(0xFF1A1A1A),
                  Color(0xFF0F0F0F),
                ],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Animated glow circles
                Positioned(
                  top: -60 + dy,
                  left: -40 + dx,
                  child: _buildGlowCircle(
                    180,
                    Colors.tealAccent.withOpacity(0.04),
                  ),
                ),
                Positioned(
                  bottom: -80 + dx,
                  right: -50 + dy,
                  child: _buildGlowCircle(
                    240,
                    Colors.purpleAccent.withOpacity(0.03),
                  ),
                ),
                // Main content
                child!,
              ],
            ),
          );
        },
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _logoPulse,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset('assets/ai.json', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Yükleniyor: ${(_progress * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 180,
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 4,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.tealAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 50, spreadRadius: 10)],
      ),
    );
  }
}
