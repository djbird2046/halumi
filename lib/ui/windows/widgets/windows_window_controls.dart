import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowsWindowControls extends StatelessWidget {
  const WindowsWindowControls({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _WindowControlButton(
            icon: Icons.minimize,
            tooltip: 'Minimize',
            hoverColor: colorScheme.surfaceContainerHighest,
            onPressed: () => windowManager.minimize(),
          ),
          _WindowControlButton(
            icon: Icons.crop_square,
            tooltip: 'Maximize',
            hoverColor: colorScheme.surfaceContainerHighest,
            onPressed: () async {
              final isMaximized = await windowManager.isMaximized();
              if (isMaximized) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
            },
          ),
          _WindowControlButton(
            icon: Icons.close,
            tooltip: 'Minimize',
            hoverColor: const Color(0xFFE81123),
            hoverIconColor: Colors.white,
            onPressed: () => windowManager.minimize(),
          ),
        ],
      ),
    );
  }
}

class _WindowControlButton extends StatefulWidget {
  const _WindowControlButton({
    required this.icon,
    required this.tooltip,
    required this.hoverColor,
    required this.onPressed,
    this.hoverIconColor,
  });

  final IconData icon;
  final String tooltip;
  final Color hoverColor;
  final Color? hoverIconColor;
  final VoidCallback onPressed;

  @override
  State<_WindowControlButton> createState() => _WindowControlButtonState();
}

class _WindowControlButtonState extends State<_WindowControlButton> {
  static const double _buttonWidth = 46;
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      cursor: SystemMouseCursors.basic,
      child: Tooltip(
        message: widget.tooltip,
        waitDuration: const Duration(milliseconds: 300),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: _buttonWidth,
            height: double.infinity,
            color: hovering ? widget.hoverColor : Colors.transparent,
            child: Icon(
              widget.icon,
              size: 16,
              color: hovering
                  ? (widget.hoverIconColor ?? colorScheme.onSurface)
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
