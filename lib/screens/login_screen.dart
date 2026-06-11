import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color _pageBg = Color(0xFFF4F7FA);
  static const Color _inputBg = Color(0xFFF0F4F8);
  static const Color _inputBorder = Color(0xFFD8E0E8);
  static const Color _dividerColor = Color(0xFFE2E8F0);
  static const Color _footerBg = Color(0xFFEEF2F6);
  static const Color _linkGreen = Color(0xFF004D3D);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _keepMeSignedIn = false;
  bool _isSimulatingLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _inputBorder, width: 1),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: SystemColors.textGray,
        fontSize: 14,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: SystemColors.corporateGreen, width: 1.2),
      ),
    );
  }

  void _handleStandardLogin() {
    setState(() => _errorMessage = '');

    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _errorMessage = 'Please enter corporate ID');
      return;
    }

    setState(() => _isSimulatingLoading = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isSimulatingLoading = false);
        widget.onLoginSuccess();
      }
    });
  }

  void _handleBiometricLogin() {
    setState(() {
      _errorMessage = '';
      _isSimulatingLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isSimulatingLoading = false);
        widget.onLoginSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: _buildLoginCard(),
                      ),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 64,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Order Approval Portal',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SystemColors.corporateGreen,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Enterprise procurement management',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: SystemColors.textGray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: GoogleFonts.inter(
                color: Colors.red.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 28),
          _buildFieldLabel('Username'),
          const SizedBox(height: 8),
          TextField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            style: GoogleFonts.inter(fontSize: 14, color: SystemColors.textDark),
            decoration: _inputDecoration(
              hint: 'Enter corporate ID',
              prefixIcon: const Icon(Icons.person_outline, color: SystemColors.textGray, size: 22),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldLabel('Password'),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Forgot?',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _linkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleStandardLogin(),
            style: GoogleFonts.inter(fontSize: 14, color: SystemColors.textDark),
            decoration: _inputDecoration(
              hint: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, color: SystemColors.textGray, size: 22),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: SystemColors.textGray,
                  size: 22,
                ),
                onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildKeepSignedInRow(),
          const SizedBox(height: 24),
          _buildSignInButton(),
          const SizedBox(height: 28),
          _buildBiometricDivider(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBiometricCard(
                  icon: Icons.face_outlined,
                  label: 'Face ID',
                  onTap: _handleBiometricLogin,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBiometricCard(
                  icon: Icons.fingerprint,
                  label: 'Fingerprint',
                  onTap: _handleBiometricLogin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: SystemColors.textDark,
      ),
    );
  }

  Widget _buildKeepSignedInRow() {
    return InkWell(
      onTap: () => setState(() => _keepMeSignedIn = !_keepMeSignedIn),
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: _keepMeSignedIn,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              activeColor: SystemColors.corporateGreen,
              side: const BorderSide(color: _inputBorder, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (val) => setState(() => _keepMeSignedIn = val ?? false),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Keep me signed in for 24 hours',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: SystemColors.textBody,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: SystemColors.corporateGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: SystemColors.corporateGreen.withValues(alpha: 0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: _isSimulatingLoading ? null : _handleStandardLogin,
        child: _isSimulatingLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign In',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.login_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildBiometricDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: _dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR BIOMETRIC',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: SystemColors.textGray,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Expanded(child: Divider(color: _dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildBiometricCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: _isSimulatingLoading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 96,
          decoration: BoxDecoration(
            border: Border.all(color: _inputBorder, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: SystemColors.corporateGreen),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SystemColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: _footerBg,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 8,
            children: [
              _buildFooterLink('Privacy Policy'),
              _buildFooterLink('Terms of Service'),
              _buildFooterLink('Security Standards'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '© 2024 HLW Enterprise Systems. All rights reserved.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: SystemColors.textGray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: SystemColors.textGray,
        ),
      ),
    );
  }
}
