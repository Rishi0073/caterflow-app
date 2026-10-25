import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // FOR GOOGLE MAPS LINK
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // FOR QR SCANNER
import 'firebase_options.dart';

// ==========================================
// MODELS & DATA
// ==========================================
class Job {
  final String id,
      title,
      location,
      distance,
      time,
      price,
      image,
      date,
      shift,
      description,
      address;
  final String? mapLink; // Google Maps Link
  final double distanceValue, priceValue;
  final int peopleNeeded;

  Job({
    required this.id,
    required this.title,
    required this.location,
    required this.distance,
    required this.distanceValue,
    required this.time,
    required this.price,
    required this.priceValue,
    required this.peopleNeeded,
    required this.image,
    required this.date,
    required this.shift,
    required this.description,
    required this.address,
    this.mapLink,
  });
}

// ==========================================
// MAIN APP ENTRY
// ==========================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  runApp(const CaterFlowApp());
}

class CaterFlowApp extends StatelessWidget {
  const CaterFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaterFlow Elite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        primaryColor: const Color(0xFF800020),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800020)),
        textTheme: GoogleFonts.interTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF800020), width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.red, width: 1)),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(
                  child: CircularProgressIndicator(color: Color(0xFF800020))));
        }
        if (snapshot.hasData) return const MainNavigation();
        return const LoginScreen();
      },
    );
  }
}

// ==========================================
// AUTHENTICATION SCREENS
// ==========================================
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'Must be at least 8 characters';
  if (!value.contains(RegExp(r'[A-Z]')))
    return 'Must contain at least one uppercase letter';
  if (!value.contains(RegExp(r'[a-z]')))
    return 'Must contain at least one lowercase letter';
  if (!value.contains(RegExp(r'[0-9]')))
    return 'Must contain at least one number';
  if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
    return 'Must contain at least one special character';
  return null;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'worker@caterflow.com');
  final _passwordController = TextEditingController(text: 'Worker@123');
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.message ?? 'Login failed'),
            backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.restaurant_menu,
                      size: 80, color: Color(0xFF800020)),
                  const SizedBox(height: 20),
                  const Text('Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF800020))),
                  const Text('Login to CaterFlow Elite',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 40),
                  TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty || !v.contains('@')
                          ? 'Enter a valid email'
                          : null),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                            icon: Icon(_obscureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscureText = !_obscureText))),
                    validator: (v) => v!.isEmpty ? 'Enter your password' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen())),
                      child: const Text('Forgot Password?',
                          style: TextStyle(
                              color: Color(0xFF800020),
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800020),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('LOGIN',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MainNavigation())),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: const Text('TEST LOGIN (BYPASS FIREBASE)',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen())),
                        child: const Text("Sign Up",
                            style: TextStyle(
                                color: Color(0xFF800020),
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureRePass = true;
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passController.text.trim());
      await userCredential.user?.updateDisplayName(
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}');
      if (mounted)
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    PhoneOtpScreen(phone: _phoneController.text.trim())));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'Sign up failed'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF800020))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Account',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF800020))),
              const Text('Join CaterFlow Elite today',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          controller: _firstNameController,
                          decoration:
                              const InputDecoration(labelText: 'First Name'),
                          validator: (v) => v!.isEmpty ? 'Required' : null)),
                  const SizedBox(width: 15),
                  Expanded(
                      child: TextFormField(
                          controller: _lastNameController,
                          decoration:
                              const InputDecoration(labelText: 'Last Name'),
                          validator: (v) => v!.isEmpty ? 'Required' : null)),
                ],
              ),
              const SizedBox(height: 15),
              TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Phone Number (with country code)',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: '+91 9876543210'),
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v!.length < 10 ? 'Enter valid phone number' : null),
              const SizedBox(height: 15),
              TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@')
                      ? 'Enter a valid email'
                      : null),
              const SizedBox(height: 15),
              TextFormField(
                  controller: _passController,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          icon: Icon(_obscurePass
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass))),
                  validator: validatePassword),
              const SizedBox(height: 15),
              TextFormField(
                  obscureText: _obscureRePass,
                  decoration: InputDecoration(
                      labelText: 'Re-enter Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                          icon: Icon(_obscureRePass
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () => setState(
                              () => _obscureRePass = !_obscureRePass))),
                  validator: (v) => v != _passController.text
                      ? 'Passwords do not match'
                      : null),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800020),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('SIGN UP',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneOtpScreen extends StatefulWidget {
  final String phone;
  const PhoneOtpScreen({super.key, required this.phone});
  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _otpController = TextEditingController();
  String _verificationId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
        if (mounted)
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigation()),
              (route) => false);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.message ?? 'Verification failed'),
            backgroundColor: Colors.red));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _verificationId = verificationId);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('OTP Sent!'), backgroundColor: Colors.green));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() => _verificationId = verificationId);
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) return;
    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: _otpController.text);
      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
      if (mounted)
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
            (route) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'Invalid OTP'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF800020))),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Verify Phone',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800020))),
            Text('Enter the 6-digit OTP sent to ${widget.phone}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 10,
                    fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: '••••••'),
                maxLength: 6),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800020),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('VERIFY & ENTER APP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter a valid email'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Password reset link sent to your email!'),
            backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? 'Failed to send reset email'),
          backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF800020))),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Forgot Password',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800020))),
            const Text(
                'Enter your email to receive a secure password reset link.',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800020),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('SEND RESET LINK',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MAIN NAVIGATION & APP SCREENS
// ==========================================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  Set<String> appliedJobIds = {};
  Set<String> appliedDates = {};

  void _applyForJob(Job job) {
    if (appliedDates.contains(job.date)) return;
    setState(() {
      appliedJobIds.add(job.id);
      appliedDates.add(job.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      JobsScreen(
          appliedJobIds: appliedJobIds,
          appliedDates: appliedDates,
          onApply: _applyForJob),
      EarningsScreen(activeJobsCount: appliedJobIds.length),
      const ProfileScreen(),
    ];

    return Scaffold(
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          screens[_currentIndex],
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                  color: const Color(0xF21A1A1A),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: const [
                    BoxShadow(color: Color(0x4D000000), blurRadius: 20)
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.work_outline, 'Jobs'),
                  _buildNavItem(
                      1, Icons.account_balance_wallet_outlined, 'Earnings'),
                  _buildNavItem(2, Icons.person_outline, 'Profile'),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF800020),
                child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const QRScannerScreen())),
              ),
            )
          : null,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? const Color(0xFF800020) : Colors.grey,
              size: 24),
          Text(label.toUpperCase(),
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      backgroundColor: const Color(0xFFFDFBF7),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF800020)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://picsum.photos/seed/portrait/200/200')),
                const SizedBox(height: 10),
                Text(user?.displayName ?? 'CaterFlow User',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(user?.email ?? 'worker@caterflow.com',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () => Navigator.pop(context)),
          ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Terms of Service'),
              onTap: () => Navigator.pop(context)),
          ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted)
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
              }),
        ],
      ),
    );
  }
}

// --- JOBS SCREEN ---
class JobsScreen extends StatefulWidget {
  final Set<String> appliedJobIds;
  final Set<String> appliedDates;
  final Function(Job) onApply;

  const JobsScreen(
      {super.key,
      required this.appliedJobIds,
      required this.appliedDates,
      required this.onApply});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  late String selectedDate;
  String selectedCategory = 'All';
  List<Map<String, String>> dynamicDates = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateFormat('yyyy-MM-dd').format(now);
    dynamicDates = List.generate(5, (index) {
      final date = now.add(Duration(days: index));
      return {
        'id': DateFormat('yyyy-MM-dd').format(date),
        'label': index == 0 ? 'Today' : DateFormat('E').format(date),
        'day': date.day.toString()
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.only(bottom: 20),
            decoration: const BoxDecoration(
                color: Color(0xFF800020),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40))),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer()),
                        const Column(children: [
                          Text('CATERFLOW ELITE',
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.bold)),
                          Text('Available Jobs',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold))
                        ]),
                        IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: Colors.white),
                            onPressed: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: dynamicDates.length,
                      itemBuilder: (context, index) {
                        bool isSelected =
                            selectedDate == dynamicDates[index]['id'];
                        return GestureDetector(
                          onTap: () => setState(
                              () => selectedDate = dynamicDates[index]['id']!),
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0x1AFFFFFF),
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(dynamicDates[index]['label']!,
                                      style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFF800020)
                                              : Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                  Text(dynamicDates[index]['day']!,
                                      style: TextStyle(
                                          color: isSelected
                                              ? const Color(0xFF800020)
                                              : Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold))
                                ]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                        children: ['All', 'Catering', 'Event'].map((cat) {
                      bool isSelected = selectedCategory == cat;
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              border:
                                  Border.all(color: const Color(0x33FFFFFF)),
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(cat,
                              style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF800020)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ),
                      );
                    }).toList()),
                  ),
                ],
              ),
            ),
          ),
        ),

        // FETCH LIVE DATA FROM FIREBASE
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('jobs')
              .where('date', isEqualTo: selectedDate)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF800020)))));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
              return const SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                          child: Text('No jobs available for this date.',
                              style: TextStyle(color: Colors.grey)))));

            List<Job> liveJobs = snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return Job(
                id: doc.id,
                title: data['title'] ?? 'Job',
                location: data['location'] ?? '',
                distance: data['distance'] ?? '3.5 km',
                distanceValue: (data['distanceValue'] ?? 3.5).toDouble(),
                time: data['time'] ?? '',
                price: data['price'] ?? '₹0',
                priceValue: (data['priceValue'] ?? 0).toDouble(),
                peopleNeeded: data['peopleNeeded'] ?? 1,
                image: data['image'] ??
                    'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=800&q=80',
                date: data['date'] ?? '',
                shift: data['shift'] ?? '',
                description: data['description'] ?? '',
                address: data['address'] ?? '',
                mapLink: data['mapLink'], // READS GOOGLE MAPS LINK
              );
            }).toList();

            if (selectedCategory != 'All')
              liveJobs =
                  liveJobs.where((j) => j.title == selectedCategory).toList();
            if (liveJobs.isEmpty)
              return const SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                          child: Text('No jobs match your filter.',
                              style: TextStyle(color: Colors.grey)))));

            return SliverPadding(
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final job = liveJobs[index];
                    final isApplied = widget.appliedJobIds.contains(job.id);
                    final isDateBooked =
                        widget.appliedDates.contains(job.date) && !isApplied;
                    return _buildJobCard(context, job, isApplied, isDateBooked);
                  },
                  childCount: liveJobs.length,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildJobCard(
      BuildContext context, Job job, bool isApplied, bool isDateBooked) {
    bool isDisabled = isApplied || isDateBooked;
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => JobDetailsScreen(
                  job: job,
                  isApplied: isApplied,
                  isDateBooked: isDateBooked,
                  onApply: () => widget.onApply(job)))),
      child: Container(
        height: 240,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            image: DecorationImage(
                image: NetworkImage(job.image), fit: BoxFit.cover)),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xE6000000), Colors.transparent])),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text('${job.location} • ${job.distance} | ${job.time}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 15),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(job.price,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: isDisabled ? null : () => widget.onApply(job),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isDisabled
                          ? Colors.grey[800]
                          : const Color(0xFF800020),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: Text(
                      isApplied
                          ? 'Applied'
                          : isDateBooked
                              ? 'Date Booked'
                              : 'Apply Now',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// --- JOB DETAILS SCREEN ---
class JobDetailsScreen extends StatefulWidget {
  final Job job;
  final bool isApplied;
  final bool isDateBooked;
  final VoidCallback onApply;

  const JobDetailsScreen(
      {super.key,
      required this.job,
      required this.isApplied,
      required this.isDateBooked,
      required this.onApply});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  // OPENS THE GOOGLE MAPS LINK PROVIDED BY EMPLOYER
  Future<void> _handleGetDirections() async {
    if (widget.job.mapLink != null && widget.job.mapLink!.isNotEmpty) {
      final Uri url = Uri.parse(widget.job.mapLink!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No valid map link provided by employer.'),
          backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    bool isDisabled = widget.isApplied || widget.isDateBooked;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(widget.job.image),
                        fit: BoxFit.cover)),
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0xE6000000), Colors.transparent])),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.job.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold)),
                        Text(widget.job.price,
                            style: const TextStyle(
                                color: Color(0xFF800020),
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                                Icons.access_time, 'Time', widget.job.time),
                            _buildStat(Icons.people, 'Staff',
                                '${widget.job.peopleNeeded}'),
                            _buildStat(
                                Icons.location_on, 'Dist', widget.job.distance),
                          ]),
                      const SizedBox(height: 30),
                      const Text('DESCRIPTION',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      Text(widget.job.description,
                          style: const TextStyle(fontSize: 16, height: 1.5)),
                      const SizedBox(height: 30),
                      const Text('LOCATION',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      const SizedBox(height: 10),
                      Text(widget.job.address,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),

                      // GET DIRECTIONS BUTTON
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                              onPressed: _handleGetDirections,
                              icon: const Icon(Icons.navigation,
                                  color: Colors.white),
                              label: const Text('Get Directions (Google Maps)',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15)))),
                    ]),
              )
            ]),
          ),
          Positioned(
              top: 50,
              left: 20,
              child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context)))),
          Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                  onPressed: isDisabled
                      ? null
                      : () {
                          widget.onApply();
                          Navigator.pop(context);
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800020),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25))),
                  child: Text(
                      widget.isApplied
                          ? 'Already Applied'
                          : widget.isDateBooked
                              ? 'Limit: 1 Job Per Day'
                              : 'Apply for this Job',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) =>
      Column(children: [
        Icon(icon, color: const Color(0xFF800020)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
      ]);
}

// --- ANTI-PROXY QR SCANNER ---
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;

  void _handleScan(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    setState(() => _isProcessing = true);
    String rawData = barcodes.first.rawValue!;

    try {
      List<String> parts = rawData.split('|');
      if (parts.length != 2) throw Exception("Invalid QR Format");

      String jobId = parts[0];
      int qrTimestamp = int.parse(parts[1]);
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      // ANTI-PROXY CHECK: QR code must be less than 10 seconds old
      if (currentTimestamp - qrTimestamp > 10000) {
        _showResult(false,
            'QR Code Expired! Please scan directly from the employer\'s screen.');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Not logged in");

      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .collection('attendance')
          .doc(user.uid)
          .set({
        'workerId': user.uid,
        'workerName': user.email?.split('@')[0] ?? 'Worker',
        'status': 'Present',
        'checkInTime': FieldValue.serverTimestamp(),
      });

      _showResult(true, 'Check-in Successful!');
    } catch (e) {
      _showResult(false, 'Invalid QR Code or Error: $e');
    }
  }

  void _showResult(bool success, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Icon(success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red, size: 50),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Employer QR')),
      body: Column(
        children: [
          const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                  'Scan the QR code on the Employer\'s phone to check in. Screenshots will not work!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold))),
          Expanded(child: MobileScanner(onDetect: _handleScan)),
        ],
      ),
    );
  }
}

// --- EARNINGS SCREEN ---
class EarningsScreen extends StatefulWidget {
  final int activeJobsCount;
  const EarningsScreen({super.key, required this.activeJobsCount});
  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  double balance = 12450.00;
  bool isWithdrawing = false;
  List<Map<String, dynamic>> transactions = [
    {
      'title': 'Corporate Gala',
      'date': 'Yesterday',
      'amount': '+₹1200',
      'color': Colors.green
    },
    {
      'title': 'Withdrawal (Completed)',
      'date': 'Apr 09, 2026',
      'amount': '-₹5000',
      'color': Colors.black
    },
  ];

  void _showWithdrawDialog() {
    TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Funds'),
        content: TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Amount to withdraw (₹)',
                border: OutlineInputBorder())),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800020)),
            onPressed: () {
              double? amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0 && amount <= balance) {
                Navigator.pop(context);
                _processWithdrawal(amount);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Invalid amount or insufficient balance'),
                    backgroundColor: Colors.red));
              }
            },
            child:
                const Text('Withdraw', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processWithdrawal(double amount) async {
    setState(() => isWithdrawing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      transactions.insert(0, {
        'title': 'Withdrawal (Processing)',
        'date': 'Just now',
        'amount': '-₹${amount.toStringAsFixed(0)}',
        'color': Colors.orange
      });
      balance -= amount;
      isWithdrawing = false;
    });
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Withdrawal request submitted. Processing takes 1-2 business days.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 380,
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Color(0xFF800020),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40))),
        child: SafeArea(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('TOTAL EARNINGS',
              style: TextStyle(
                  color: Colors.white60, fontSize: 10, letterSpacing: 3)),
          Text('₹${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildStatBox('Active', '${widget.activeJobsCount}'),
            const SizedBox(width: 20),
            _buildStatBox('Completed', '124'),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                (balance <= 0 || isWithdrawing) ? null : _showWithdrawDialog,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF800020),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: isWithdrawing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF800020)))
                : const Text('Withdraw Funds',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ])),
      ),
      Expanded(
          child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('RECENT TRANSACTIONS',
            style: TextStyle(
                color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...transactions
            .map((tx) =>
                _buildTx(tx['title'], tx['date'], tx['amount'], tx['color']))
            .toList(),
      ]))
    ]);
  }

  Widget _buildStatBox(String label, String val) => Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white10, borderRadius: BorderRadius.circular(15)),
      child: Column(children: [
        Text(val,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10))
      ]));
  Widget _buildTx(String t, String d, String a, Color c) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: c == Colors.orange ? Colors.orange : Colors.black)),
          Text(d, style: const TextStyle(color: Colors.grey, fontSize: 12))
        ]),
        Text(a,
            style:
                TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 18))
      ]));
}

// --- PROFILE SCREEN ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Column(children: [
      Container(
          height: 300,
          width: double.infinity,
          color: const Color(0xFF800020),
          child: SafeArea(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 50, color: Color(0xFF800020))),
                const SizedBox(height: 10),
                Text(user?.email ?? 'Worker Account',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const Text('4.92 ★',
                    style: TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold)),
              ]))),
      Expanded(
          child: ListView(padding: const EdgeInsets.all(20), children: [
        Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title:
                    const Text('Log Out', style: TextStyle(color: Colors.red)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted)
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                })),
      ]))
    ]);
  }
}
