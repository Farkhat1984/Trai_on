import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // App Logo/Title - centered
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 200,
                      height: 200,
                    ).animate().scale(delay: 100.ms, duration: 500.ms),
                    const SizedBox(height: 32),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                    const SizedBox(height: 12),
                    Text(
                      l10n.tryOnVirtually,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                  ],
                ),
              ),
              // Buttons at bottom
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Google Sign In Button
                  ElevatedButton(
                    onPressed: () => _handleGoogleSignIn(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1F1F1F),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGoogleLogo(),
                        const SizedBox(width: 12),
                        Text(
                          l10n.signInWithGoogle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideX(
                        begin: -0.2,
                        delay: 700.ms,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 16),
                  // Apple Sign In Button
                  ElevatedButton.icon(
                    onPressed: () => _handleAppleSignIn(context),
                    icon: const Icon(Icons.apple, size: 24),
                    label: Text(
                      l10n.signInWithApple,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate().slideX(
                        begin: 0.2,
                        delay: 900.ms,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 32),
                  // Terms and Privacy
                  Text(
                    l10n.byContinuingYouAccept,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ).animate().fadeIn(delay: 1100.ms, duration: 500.ms),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }

  void _handleGoogleSignIn(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Реализовать вход через Google
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.googleSignInStub),
        duration: const Duration(seconds: 2),
      ),
    );
    // Временно переходим в приложение
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _handleAppleSignIn(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // TODO: Реализовать вход через Apple
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.appleSignInStub),
        duration: const Duration(seconds: 2),
      ),
    );
    // Временно переходим в приложение
    Navigator.of(context).pushReplacementNamed('/home');
  }
}

// Custom painter for Google logo
class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue part
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -0.5236, // -30 degrees
      2.0944, // 120 degrees
      true,
      paint,
    );

    // Red part
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      1.5708, // 90 degrees
      1.5708, // 90 degrees
      true,
      paint,
    );

    // Yellow part
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      3.1416, // 180 degrees
      1.5708, // 90 degrees
      true,
      paint,
    );

    // Green part
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -1.5708, // -90 degrees
      1.0472, // 60 degrees
      true,
      paint,
    );

    // White center circle
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.35,
      paint,
    );

    // Blue inner shape
    paint.color = const Color(0xFF4285F4);
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.75, size.height * 0.3);
    path.lineTo(size.width * 0.75, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
