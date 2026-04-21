import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';

class CalcButton extends StatefulWidget {
  final String label;

  const CalcButton({super.key, required this.label});

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ButtonStyle get _style {
    final label = widget.label;
    if (label == '=') return _ButtonStyle.equals;
    if (['+', '-', '×', '÷'].contains(label)) return _ButtonStyle.operator;
    if (['AC', '+/-', '%', '⌫'].contains(label)) return _ButtonStyle.function;
    return _ButtonStyle.number;
  }

  Color get _bgColor {
    switch (_style) {
      case _ButtonStyle.equals:
        return const Color(0xFF2979FF);
      case _ButtonStyle.operator:
        return const Color(0xFFE3EEFF);
      case _ButtonStyle.function:
        return const Color(0xFFF0F4FF);
      case _ButtonStyle.number:
        return Colors.white;
    }
  }

  Color get _textColor {
    switch (_style) {
      case _ButtonStyle.equals:
        return Colors.white;
      case _ButtonStyle.operator:
        return const Color(0xFF1565C0);
      case _ButtonStyle.function:
        return const Color(0xFF37474F);
      case _ButtonStyle.number:
        return const Color(0xFF212121);
    }
  }

  Color get _shadowColor {
    switch (_style) {
      case _ButtonStyle.equals:
        return const Color(0xFF2979FF).withOpacity(0.4);
      case _ButtonStyle.operator:
        return const Color(0xFF2979FF).withOpacity(0.15);
      default:
        return Colors.black.withOpacity(0.06);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        context.read<CalculatorProvider>().onButtonPressed(widget.label);
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: _isPressed ? _bgColor.withOpacity(0.85) : _bgColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _shadowColor,
                blurRadius: _isPressed ? 4 : 10,
                offset: _isPressed ? const Offset(0, 2) : const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: _buildLabel(),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    if (widget.label == '⌫') {
      return Icon(
        Icons.backspace_outlined,
        color: _textColor,
        size: 22,
      );
    }
    if (widget.label == '÷') {
      return Text('÷', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: _textColor));
    }
    return Text(
      widget.label,
      style: TextStyle(
        fontSize: _style == _ButtonStyle.operator ? 26 : 24,
        fontWeight: _style == _ButtonStyle.number
            ? FontWeight.w400
            : FontWeight.w600,
        color: _textColor,
        height: 1,
      ),
    );
  }
}

enum _ButtonStyle { equals, operator, function, number }
