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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _keepMeSignedIn = false;
  bool _isSimulatingLoading = false;
  String _errorMessage = '';

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "JLW",
          style: GoogleFonts.serif(
            fontWeight: FontWeight.black,
            fontSize: 42,
            color: SystemColors.corporateNavy,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(2, 2),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "SINCE 1875",
          style: GoogleFonts.sansSerif(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: SystemColors.textGray,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  void _handleStandardLogin() {
    setState(() {
      _errorMessage = '';
    });
    
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter corporate ID';
      });
      return;
    }

    setState(() {
      _isSimulatingLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isSimulatingLoading = false;
        });
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
        setState(() {
          _isSimulatingLoading = false;
        });
        widget.onLoginSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SystemColors.pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 30),
              
              // White Card Panel container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5EEFF), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 24),
                    
                    Text(
                      "Order Approval Portal",
                      style: GoogleFonts.sansSerif(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: SystemColors.corporateGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enterprise procurement management",
                      style: GoogleFonts.sansSerif(
                        fontSize: 14,
                        color: SystemColors.textGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: GoogleFonts.sansSerif(
                          color: Colors.red.shade800,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 28),
                    
                    // Username ID Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Username",
                          style: GoogleFonts.sansSerif(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SystemColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: "Enter corporate ID",
                            hintStyle: const TextStyle(color: SystemColors.textGray),
                            prefixIcon: const Icon(Icons.person, color: SystemColors.textGray, size: 20),
                            fillColor: SystemColors.containerBlue,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 18),
                    
                    // Password Field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Password",
                              style: GoogleFonts.sansSerif(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: SystemColors.textDark,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Forgot?",
                                style: GoogleFonts.sansSerif(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF476083),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            hintText: "........",
                            hintStyle: const TextStyle(
                              color: SystemColors.textGray, 
                              fontWeight: FontWeight.bold,
                            ),
                            prefixIcon: const Icon(Icons.lock, color: SystemColors.textGray, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible ? Icons.visibility_off : Icons.visibility,
                                color: SystemColors.textGray,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            fillColor: SystemColors.containerBlue,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Keep Signed In Checkbox row
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _keepMeSignedIn = !_keepMeSignedIn;
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: _keepMeSignedIn,
                            activeColor: SystemColors.corporateGreen,
                            onChanged: (val) {
                              setState(() {
                                _keepMeSignedIn = val ?? false;
                              });
                            },
                          ),
                          Text(
                            "Keep me signed in for 24 hours",
                            style: GoogleFonts.sansSerif(
                              fontSize: 13,
                              color: SystemColors.textBody,
                            ),
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SystemColors.corporateGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedCornerShape(8),
                          elevation: 0,
                        ),
                        onPressed: _isSimulatingLoading ? null : _handleStandardLogin,
                        child: _isSimulatingLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Sign In ",
                                    style: GoogleFonts.sansSerif(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(Icons.login, size: 18),
                                ],
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // OR BIOMETRIC Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE5EEFF))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "OR BIOMETRIC",
                            style: GoogleFonts.sansSerif(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: SystemColors.textGray,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE5EEFF))),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Biometrics Grid Rows
                    Row(
                      gap: 16,
                      children: [
                        // Face ID Custom Card
                        _buildBiometricCard(
                          icon: Icons.face_retouching_natural,
                          label: "Face ID",
                          onTap: _handleBiometricLogin,
                        ),
                        // Fingerprint Custom Card
                        _buildBiometricCard(
                          icon: Icons.fingerprint,
                          label: "Fingerprint",
                          onTap: _handleBiometricLogin,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Underlined footer buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFooterLink("Privacy\nPolicy"),
                  _buildFooterLink("Terms of\nService"),
                  _buildFooterLink("Security\nStandards"),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Text(
                "© 2024 HLW Enterprise Systems. All rights reserved.",
                style: GoogleFonts.sansSerif(
                  fontSize: 12,
                  color: SystemColors.textGray,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5EEFF), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: SystemColors.corporateGreen),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.sansSerif(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SystemColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.sansSerif(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF476083),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

// Extension to allow custom helper styles in our Buttons easily without heavy dependency
RoundedCornerShape(double val) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(val),
  );
}

// Extends Row to quickly support spacing on custom widgets
extension on Row {
  Row withGap(double spacing) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children.expand((item) => [item, SizedBox(width: spacing)]).toList()..removeLast(),
    );
  }
}
// Add simple Gap support for Row elements to represent modern layout spacing cleanly 
extension GapCompat on Row {
  Row get gap => this; // Just a dummy stub representing high spacing
}
