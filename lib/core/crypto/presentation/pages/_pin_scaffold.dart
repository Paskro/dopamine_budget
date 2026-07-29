import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinScaffold extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? errorMessage;
  final Future<void> Function(String pin) onComplete;
  final Widget? leadingAction;
  final Widget? bottomAction;

  const PinScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.errorMessage,
    required this.onComplete,
    this.leadingAction,
    this.bottomAction,
  });

  @override
  State<PinScaffold> createState() => _PinScaffoldState();
}

class _PinScaffoldState extends State<PinScaffold> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void didUpdateWidget(PinScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Сбрасываем поле при появлении ошибки
    if (widget.errorMessage != null && oldWidget.errorMessage == null) {
      _controller.clear();
    }
  }

  Future<void> _onChanged(String value) async {
    if (value.length < 4 || _isLoading) return;
    setState(() => _isLoading = true);
    await widget.onComplete(value);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.leadingAction != null
          ? AppBar(leading: widget.leadingAction, backgroundColor: Colors.transparent)
          : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(widget.subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 40),
            _PinDots(length: _controller.text.length),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
              style: const TextStyle(color: Colors.transparent),
              cursorColor: Colors.transparent,
              enableSuggestions: false,
              autocorrect: false,
              onChanged: _onChanged,
            ),
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
            if (widget.bottomAction != null) ...[
              const SizedBox(height: 32),
              widget.bottomAction!,
            ],
          ],
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int length;
  const _PinDots({required this.length});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final filled = i < length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        );
      }),
    );
  }
}