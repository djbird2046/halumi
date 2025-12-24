import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class MacosWindowControls extends StatelessWidget {
  const MacosWindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _TrafficLightButton(
          color: Color(0xFFff5f57),
          hoverColor: Color(0xFFff5f57),
          action: _WindowAction.close,
        ),
        SizedBox(width: 8),
        _TrafficLightButton(
          color: Color(0xFFfebc2e),
          hoverColor: Color(0xFFfebc2e),
          action: _WindowAction.minimize,
        ),
        SizedBox(width: 8),
        _TrafficLightButton(
          color: Color(0xFF28c840),
          hoverColor: Color(0xFF28c840),
          action: _WindowAction.toggleFullScreen,
        ),
      ],
    );
  }
}

enum _WindowAction { close, minimize, toggleFullScreen }

class _TrafficLightButton extends StatefulWidget {
  const _TrafficLightButton({
    required this.color,
    required this.hoverColor,
    required this.action,
  });

  final Color color;
  final Color hoverColor;
  final _WindowAction action;

  @override
  State<_TrafficLightButton> createState() => _TrafficLightButtonState();
}

class _TrafficLightButtonState extends State<_TrafficLightButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      cursor: SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hovering ? widget.hoverColor : widget.color,
            boxShadow: hovering
                ? [
                    BoxShadow(
                      color: widget.color.withAlpha((0.35 * 255).round()),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: hovering ? 1 : 0,
            child: CustomPaint(
              painter: _TrafficLightGlyphPainter(widget.action),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap() async {
    switch (widget.action) {
      case _WindowAction.close:
        await windowManager.minimize();
        break;
      case _WindowAction.minimize:
        await windowManager.minimize();
        break;
      case _WindowAction.toggleFullScreen:
        final isFullScreen = await windowManager.isFullScreen();
        await windowManager.setFullScreen(!isFullScreen);
        break;
    }
  }
}

class _TrafficLightGlyphPainter extends CustomPainter {
  _TrafficLightGlyphPainter(this.action);

  final _WindowAction action;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha((0.55 * 255).round())
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (action) {
      case _WindowAction.close:
        canvas.drawLine(
          Offset(size.width * 0.35, size.height * 0.35),
          Offset(size.width * 0.65, size.height * 0.65),
          paint,
        );
        canvas.drawLine(
          Offset(size.width * 0.65, size.height * 0.35),
          Offset(size.width * 0.35, size.height * 0.65),
          paint,
        );
        break;
      case _WindowAction.minimize:
        canvas.drawLine(
          Offset(size.width * 0.3, size.height * 0.5),
          Offset(size.width * 0.7, size.height * 0.5),
          paint,
        );
        break;
      case _WindowAction.toggleFullScreen:
        canvas.drawLine(
          Offset(size.width * 0.3, size.height * 0.5),
          Offset(size.width * 0.7, size.height * 0.5),
          paint,
        );
        canvas.drawLine(
          Offset(size.width * 0.5, size.height * 0.3),
          Offset(size.width * 0.5, size.height * 0.7),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
