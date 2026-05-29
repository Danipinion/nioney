import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_navigation.dart';

enum PinMode { unlock, setup, change, disable }

class PinLockScreen extends StatefulWidget {
  final PinMode mode;
  const PinLockScreen({super.key, required this.mode});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  String _enteredCode = '';
  String _firstStepCode = ''; // For matching confirmation pin
  String _message = '';
  bool _isError = false;
  int _setupStep = 1; // 1: Enter new, 2: Confirm new

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _initMessage();
  }

  void _initMessage() {
    setState(() {
      _isError = false;
      switch (widget.mode) {
        case PinMode.unlock:
          _message = 'Masukkan PIN untuk Masuk';
          break;
        case PinMode.setup:
          _message = 'Buat PIN Keamanan Baru';
          _setupStep = 1;
          break;
        case PinMode.change:
          _message = 'Masukkan PIN Lama Anda';
          _setupStep = 0; // 0 means verify old pin first
          break;
        case PinMode.disable:
          _message = 'Masukkan PIN untuk Menonaktifkan';
          break;
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerError(String msg) {
    setState(() {
      _message = msg;
      _isError = true;
      _enteredCode = '';
    });
    _shakeController.forward(from: 0.0);
  }

  void _onKeyPress(String digit) {
    if (_enteredCode.length >= 4) return;

    setState(() {
      _isError = false;
      _enteredCode += digit;
    });

    if (_enteredCode.length == 4) {
      // Small delay before verifying to let the UI update and show the 4th dot filled
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        _verifyCode();
      });
    }
  }

  void _onDelete() {
    if (_enteredCode.isEmpty) return;
    setState(() {
      _isError = false;
      _enteredCode = _enteredCode.substring(0, _enteredCode.length - 1);
    });
  }

  void _verifyCode() {
    final provider = Provider.of<AppProvider>(context, listen: false);

    switch (widget.mode) {
      case PinMode.unlock:
        final success = provider.unlock(_enteredCode);
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeNavigation(),
            ),
          );
        } else {
          _triggerError('PIN Salah. Silakan coba lagi.');
        }
        break;

      case PinMode.setup:
        if (_setupStep == 1) {
          _firstStepCode = _enteredCode;
          setState(() {
            _setupStep = 2;
            _enteredCode = '';
            _message = 'Konfirmasi PIN Baru Anda';
          });
        } else if (_setupStep == 2) {
          if (_enteredCode == _firstStepCode) {
            provider.setPin(_enteredCode);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN Keamanan berhasil diaktifkan!'),
                backgroundColor: Colors.teal,
              ),
            );
            Navigator.pop(context);
          } else {
            _triggerError('PIN Tidak Cocok. Mulai ulang.');
            setState(() {
              _setupStep = 1;
              _firstStepCode = '';
            });
          }
        }
        break;

      case PinMode.change:
        if (_setupStep == 0) {
          if (_enteredCode == provider.pinCode) {
            setState(() {
              _setupStep = 1;
              _enteredCode = '';
              _message = 'Masukkan PIN Baru Anda';
            });
          } else {
            _triggerError('PIN Lama Salah.');
          }
        } else if (_setupStep == 1) {
          _firstStepCode = _enteredCode;
          setState(() {
            _setupStep = 2;
            _enteredCode = '';
            _message = 'Konfirmasi PIN Baru Anda';
          });
        } else if (_setupStep == 2) {
          if (_enteredCode == _firstStepCode) {
            provider.setPin(_enteredCode);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN Keamanan berhasil diubah!'),
                backgroundColor: Colors.teal,
              ),
            );
            Navigator.pop(context);
          } else {
            _triggerError('PIN Tidak Cocok. Mulai ulang.');
            setState(() {
              _setupStep = 1;
              _firstStepCode = '';
            });
          }
        }
        break;

      case PinMode.disable:
        if (_enteredCode == provider.pinCode) {
          provider.disablePin();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN Keamanan telah dinonaktifkan.'),
              backgroundColor: Colors.teal,
            ),
          );
          Navigator.pop(context);
        } else {
          _triggerError('PIN Salah.');
        }
        break;
    }
  }

  Widget _buildDot(int index) {
    final isFilled = _enteredCode.length > index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        color: isFilled
            ? (_isError ? Colors.redAccent : Theme.of(context).primaryColor)
            : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isFilled
              ? Colors.transparent
              : (isDark ? Colors.white30 : Colors.black26),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String label, {VoidCallback? onPressed, IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final btnBgColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.025);
    final btnHoverColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () => _onKeyPress(label),
        customBorder: const CircleBorder(),
        splashColor: primaryColor.withValues(alpha: 0.2),
        highlightColor: btnHoverColor,
        child: Container(
          height: 72,
          width: 72,
          decoration: BoxDecoration(
            color: btnBgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    size: 26,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Outfit',
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subColor = isDark ? Colors.white54 : Colors.black54;

    final isUnlockMode = widget.mode == PinMode.unlock;

    return PopScope(
      canPop: !isUnlockMode, // Disable back button on unlock mode to enforce security
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: !isUnlockMode
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // App Icon or Lock Illustration
                  Column(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: _isError ? Colors.redAccent.withValues(alpha: 0.1) : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isError ? Icons.error_outline_rounded : Icons.lock_outline_rounded,
                          color: _isError ? Colors.redAccent : Theme.of(context).primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isError ? Colors.redAccent : textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (isUnlockMode)
                        Text(
                          'Data finansial Anda aman terenkripsi.',
                          style: TextStyle(color: subColor, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),

                  // Pin Dots indicator
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      final shakeVal = _shakeAnimation.value;
                      final isForward = _shakeController.status == AnimationStatus.forward;
                      // Generate a simple sinusoidal movement based on time
                      final double translation = isForward ? (shakeVal * (shakeVal % 2 == 0 ? 1 : -1)) : 0.0;
                      return Transform.translate(
                        offset: Offset(translation, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) => _buildDot(index)),
                        ),
                      );
                    },
                  ),

                  // Keypad Numeric Grid
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('1'),
                          _buildKeypadButton('2'),
                          _buildKeypadButton('3'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('4'),
                          _buildKeypadButton('5'),
                          _buildKeypadButton('6'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKeypadButton('7'),
                          _buildKeypadButton('8'),
                          _buildKeypadButton('9'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Left extra key: Empty or Exit
                          const SizedBox(width: 72, height: 72),
                          _buildKeypadButton('0'),
                          _buildKeypadButton('', onPressed: _onDelete, icon: Icons.backspace_rounded),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
