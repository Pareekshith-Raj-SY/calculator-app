import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calc_button.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  static const _buttons = [
    ['AC', '+/-', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['⌫', '0', '.', '='],
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.height > 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F4FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Calculator',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.history_rounded),
                          color: const Color(0xFF1565C0),
                          tooltip: 'History',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Display area
              Expanded(
                flex: isLargeScreen ? 3 : 2,
                child: _DisplayArea(),
              ),

              // Divider
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF2979FF).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Buttons area
              Expanded(
                flex: isLargeScreen ? 4 : 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: _buttons.map((row) {
                      return Expanded(
                        child: Row(
                          children: row.map((btn) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: CalcButton(label: btn),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Built by Pareekshith',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF1565C0).withOpacity(0.5),
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisplayArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CalculatorProvider>(
      builder: (_, calc, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expression
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  key: ValueKey(calc.displayExpression),
                  calc.displayExpression.isEmpty
                      ? ' '
                      : calc.displayExpression,
                  style: TextStyle(
                    fontSize: 20,
                    color: const Color(0xFF1565C0).withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              // Result
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Text(
                  key: ValueKey(calc.result),
                  calc.result,
                  style: TextStyle(
                    fontSize: _getFontSize(calc.result),
                    fontWeight: FontWeight.w300,
                    color: calc.isError
                        ? Colors.red
                        : const Color(0xFF0D47A1),
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _getFontSize(String result) {
    if (result.length > 12) return 36;
    if (result.length > 8) return 48;
    return 64;
  }
}
