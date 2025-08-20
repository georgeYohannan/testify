import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';

enum ElephantState {
  idle,
  happy,
  celebrating,
  encouraging,
  thinking,
  waving,
}

class ElephantMascot extends StatefulWidget {
  final ElephantState state;
  final String? message;
  final double size;
  final bool showMessage;

  const ElephantMascot({
    super.key,
    this.state = ElephantState.idle,
    this.message,
    this.size = 150,
    this.showMessage = false,
  });

  @override
  State<ElephantMascot> createState() => _ElephantMascotState();
}

class _ElephantMascotState extends State<ElephantMascot>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _blinkController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startIdleAnimation();
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _blinkAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));
  }

  void _startIdleAnimation() {
    _bounceController.repeat(reverse: true);
    
    // Random blinking
    Future.delayed(Duration(milliseconds: 2000 + (1000 * (0.5 - 0.5)).round()), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse();
          _startIdleAnimation();
        });
      }
    });
  }

  @override
  void didUpdateWidget(ElephantMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _handleStateChange();
    }
  }

  void _handleStateChange() {
    switch (widget.state) {
      case ElephantState.happy:
        _bounceController.forward().then((_) => _bounceController.reverse());
        break;
      case ElephantState.celebrating:
        _bounceController.repeat(reverse: true);
        break;
      case ElephantState.encouraging:
        _bounceController.forward().then((_) => _bounceController.reverse());
        break;
      case ElephantState.thinking:
        _bounceController.stop();
        break;
      case ElephantState.waving:
        _bounceController.repeat(reverse: true);
        break;
      case ElephantState.idle:
      default:
        _startIdleAnimation();
        break;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: _buildElephant(isDark),
            );
          },
        ),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          _buildMessageBubble(context),
        ],
      ],
    );
  }

  Widget _buildElephant(bool isDark) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: ElephantPainter(
          blinkValue: _blinkAnimation.value,
          state: widget.state,
          isDark: isDark,
        ),
      ),
    ).animate(
      effects: widget.state == ElephantState.celebrating
          ? [
              const ShakeEffect(
                duration: Duration(milliseconds: 500),
                hz: 4,
                offset: Offset(5, 0),
              ),
              const ScaleEffect(
                duration: Duration(milliseconds: 300),
                begin: Offset(1, 1),
                end: Offset(1.1, 1.1),
              ),
            ]
          : widget.state == ElephantState.waving
              ? [
                  const RotateEffect(
                    duration: Duration(milliseconds: 800),
                    begin: -0.05,
                    end: 0.05,
                  ),
                ]
              : [],
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.size + 50),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.message!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0);
  }
}

class ElephantPainter extends CustomPainter {
  final double blinkValue;
  final ElephantState state;
  final bool isDark;

  ElephantPainter({
    required this.blinkValue,
    required this.state,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final elephantSize = size.width * 0.4;

    // Draw elephant body (circle)
    canvas.drawCircle(center, elephantSize, paint);
    canvas.drawCircle(center, elephantSize, outlinePaint);

    // Draw trunk
    final trunkPath = Path();
    final trunkStart = Offset(center.dx - elephantSize * 0.3, center.dy + elephantSize * 0.2);
    final trunkEnd = Offset(center.dx - elephantSize * 0.8, center.dy + elephantSize * 0.6);
    
    trunkPath.moveTo(trunkStart.dx, trunkStart.dy);
    trunkPath.quadraticBezierTo(
      center.dx - elephantSize * 0.7,
      center.dy + elephantSize * 0.1,
      trunkEnd.dx,
      trunkEnd.dy,
    );
    
    canvas.drawPath(trunkPath, Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = elephantSize * 0.3
      ..strokeCap = StrokeCap.round);

    // Draw ears
    final leftEar = Offset(center.dx - elephantSize * 0.8, center.dy - elephantSize * 0.2);
    final rightEar = Offset(center.dx + elephantSize * 0.8, center.dy - elephantSize * 0.2);
    
    canvas.drawCircle(leftEar, elephantSize * 0.4, paint);
    canvas.drawCircle(rightEar, elephantSize * 0.4, paint);
    canvas.drawCircle(leftEar, elephantSize * 0.4, outlinePaint);
    canvas.drawCircle(rightEar, elephantSize * 0.4, outlinePaint);

    // Draw eyes
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final pupilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final leftEye = Offset(center.dx - elephantSize * 0.3, center.dy - elephantSize * 0.2);
    final rightEye = Offset(center.dx + elephantSize * 0.3, center.dy - elephantSize * 0.2);
    
    // Eye whites
    canvas.drawCircle(leftEye, elephantSize * 0.15, eyePaint);
    canvas.drawCircle(rightEye, elephantSize * 0.15, eyePaint);

    // Pupils (affected by blinking)
    if (blinkValue < 1) {
      final pupilRadius = elephantSize * 0.08 * (1 - blinkValue);
      canvas.drawCircle(leftEye, pupilRadius, pupilPaint);
      canvas.drawCircle(rightEye, pupilRadius, pupilPaint);
    }

    // Draw mouth based on state
    _drawMouth(canvas, center, elephantSize);

    // Draw Bible (held in trunk for some states)
    if (state == ElephantState.thinking || state == ElephantState.idle) {
      _drawBible(canvas, trunkEnd, elephantSize * 0.15);
    }
  }

  void _drawMouth(Canvas canvas, Offset center, double elephantSize) {
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final mouthCenter = Offset(center.dx, center.dy + elephantSize * 0.2);

    switch (state) {
      case ElephantState.happy:
      case ElephantState.celebrating:
        // Happy smile
        final smilePath = Path();
        smilePath.addArc(
          Rect.fromCenter(
            center: mouthCenter,
            width: elephantSize * 0.4,
            height: elephantSize * 0.2,
          ),
          0,
          3.14159,
        );
        canvas.drawPath(smilePath, mouthPaint);
        break;
      case ElephantState.encouraging:
        // Encouraging smile
        final encouragePath = Path();
        encouragePath.addArc(
          Rect.fromCenter(
            center: mouthCenter,
            width: elephantSize * 0.3,
            height: elephantSize * 0.15,
          ),
          0,
          3.14159,
        );
        canvas.drawPath(encouragePath, mouthPaint);
        break;
      case ElephantState.thinking:
        // Thoughtful expression
        canvas.drawLine(
          Offset(mouthCenter.dx - elephantSize * 0.1, mouthCenter.dy),
          Offset(mouthCenter.dx + elephantSize * 0.1, mouthCenter.dy),
          mouthPaint,
        );
        break;
      default:
        // Neutral smile
        final neutralPath = Path();
        neutralPath.addArc(
          Rect.fromCenter(
            center: mouthCenter,
            width: elephantSize * 0.25,
            height: elephantSize * 0.1,
          ),
          0,
          3.14159,
        );
        canvas.drawPath(neutralPath, mouthPaint);
    }
  }

  void _drawBible(Canvas canvas, Offset position, double size) {
    final biblePaint = Paint()
      ..color = const Color(0xFF8B4513) // Brown color for Bible
      ..style = PaintingStyle.fill;

    final pagesPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Bible cover
    final bibleRect = Rect.fromCenter(
      center: position,
      width: size * 1.2,
      height: size,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bibleRect, const Radius.circular(4)),
      biblePaint,
    );

    // Bible pages
    final pagesRect = Rect.fromCenter(
      center: Offset(position.dx + 2, position.dy),
      width: size * 1.1,
      height: size * 0.9,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pagesRect, const Radius.circular(2)),
      pagesPaint,
    );

    // Cross on cover
    final crossPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final crossCenter = position;
    canvas.drawLine(
      Offset(crossCenter.dx, crossCenter.dy - size * 0.2),
      Offset(crossCenter.dx, crossCenter.dy + size * 0.2),
      crossPaint,
    );
    canvas.drawLine(
      Offset(crossCenter.dx - size * 0.15, crossCenter.dy - size * 0.05),
      Offset(crossCenter.dx + size * 0.15, crossCenter.dy - size * 0.05),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
