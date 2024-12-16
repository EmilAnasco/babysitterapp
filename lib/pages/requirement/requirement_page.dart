import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:babysitterapp/pages/account/account_page.dart';

class Reqpage extends StatefulWidget {
  const Reqpage({super.key});

  @override
  _ReqpageState createState() => _ReqpageState();
}

class _ReqpageState extends State<Reqpage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _sendVerificationEmail();

    // Delay showing the modal until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showVerificationModal();
      _waitForVerification();
    });
  }

  // Send verification email to the user
  Future<void> _sendVerificationEmail() async {
    if (!_user.emailVerified) {
      try {
        await _user.sendEmailVerification();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending verification email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Continuously check for email verification status
  void _waitForVerification() async {
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        await _user.reload(); // Reload Firebase user data
        if (_auth.currentUser!.emailVerified) {
          Navigator.of(context).pop(); // Close the modal dialog
          _showSuccessPrompt(); // Show success message
        } else {
          _waitForVerification(); // Keep checking if not verified
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking verification status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  // Show success message upon verification
  void _showSuccessPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Success! Your email is verified.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AccountPage()),
    );
  }

  // Open Gmail app or fallback to Gmail website
  void _openGmailApp() async {
    final Uri gmailAppUri = Uri.parse("googlegmail://");
    final Uri fallbackUri = Uri.parse("https://mail.google.com/");

    if (await canLaunchUrl(gmailAppUri)) {
      await launchUrl(gmailAppUri);
    } else {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    }
  }

  // Show modal dialog for email verification
  void _showVerificationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mark_email_unread_rounded,
                color: Colors.deepPurple,
                size: 50,
              ),
              const SizedBox(height: 20),
              const Text(
                'Verification Email Sent!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please check your Gmail inbox to verify your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.deepPurple),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _openGmailApp,
                icon: const Icon(Icons.mail_outline, color: Colors.white),
                label: const Text(
                  'Open Gmail',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Verifying your email...',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}
