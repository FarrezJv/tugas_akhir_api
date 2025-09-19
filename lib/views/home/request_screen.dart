import 'package:flutter/material.dart';
import 'package:tugas_akhir_api/api/request.dart';
import 'package:tugas_akhir_api/model/request.dart';

class ForgotResetPasswordPage extends StatefulWidget {
  const ForgotResetPasswordPage({super.key});

  @override
  State<ForgotResetPasswordPage> createState() =>
      _ForgotResetPasswordPageState();
}

class _ForgotResetPasswordPageState extends State<ForgotResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _otpSent = false;
  String? _message;

  Future<void> _requestOtp() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      RequstOtpModel result = await AuthService.requestOtp(
        _emailController.text.trim(),
      );
      setState(() {
        _otpSent = true;
        _message = result.message ?? 'OTP berhasil dikirim ke email';
      });
    } catch (e) {
      setState(() {
        _message = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final result = await AuthService.resetPassword(
        email: _emailController.text.trim(),
        otp: _otpController.text.trim(),
        newPassword: _passwordController.text.trim(),
      );
      setState(() {
        _message = result.message ?? 'Password berhasil direset';
      });
    } catch (e) {
      setState(() {
        _message = 'Gagal reset password: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1, active: true),
        _buildStepLine(),
        _buildStepCircle(2, active: _otpSent),
      ],
    );
  }

  Widget _buildStepCircle(int step, {bool active = false}) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: active ? const Color(0xFF2563EB) : Colors.grey.shade300,
      child: Text(
        '$step',
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildRequestOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(_emailController, 'Email', icon: Icons.email_outlined),
        const SizedBox(height: 24),
        _buildMainButton('Kirim OTP', _requestOtp),
      ],
    );
  }

  Widget _buildResetPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(_otpController, 'Kode OTP', icon: Icons.verified_user),
        const SizedBox(height: 16),
        _buildTextField(
          _passwordController,
          'Password Baru',
          obscure: true,
          icon: Icons.lock_outline,
        ),
        const SizedBox(height: 24),
        _buildMainButton('Reset Password', _resetPassword),
      ],
    );
  }

  Widget _buildMainButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      child: _loading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== HEADER =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20, // disamakan dengan konten di bawah
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_reset, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ===== STEP =====
              _buildStepIndicator(),
              const SizedBox(height: 20),

              // ===== CARD FORM =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      !_otpSent
                          ? _buildRequestOtpForm()
                          : _buildResetPasswordForm(),
                      if (_message != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          _message!,
                          style: TextStyle(
                            color:
                                _message!.toLowerCase().contains('gagal') ||
                                    _message!.toLowerCase().contains(
                                      'kesalahan',
                                    )
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
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
