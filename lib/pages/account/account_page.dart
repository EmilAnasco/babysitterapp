import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../requirement/requirement_page.dart';
import '../../styles/colors.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirestoreService firestoreService = FirestoreService();
  UserModel? currentUser;
  final formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  File? _profileImage;
  late User _user;

  final Map<String, Map<String, bool>> _availability = {
    'Monday': {
      'Morning': false,
      'Afternoon': false,
      'Evening': false,
      'Night': false
    },
    'Tuesday': {
      'Morning': false,
      'Afternoon': false,
      'Evening': false,
      'Night': false
    },
    'Wednesday': {
      'Morning': false,
      'Afternoon': false,
      'Evening': false,
      'Night': false
    },
    'Thursday': {
      'Morning': false,
      'Afternoon': false,
      'Evening': false,
      'Night': false
    },
    'Friday': {
      'Morning': false,
      'Afternoon': false,
      'Evening': false,
      'Night': false
    },
    'Saturday': {
      'Morning': false,
      'Afternoon': false,
      'Evening': false,
      'Night': false
    },
    'Sunday': {
      'Morning': false,
      'Afternoon': false,
      'Evening': false,
      'Night': false
    },
  };

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _reloadUser();
    _loadUserData();
  }

  Future<void> _reloadUser() async {
    await _user.reload();
    setState(() {
      _user = _auth.currentUser!;
    });
  }

  Future<void> _loadUserData() async {
    final user = await firestoreService.loadUserData();
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _saveUserData() async {
    if (formKey.currentState!.validate() && currentUser != null) {
      formKey.currentState!.save();
      try {
        await firestoreService.saveUserData(currentUser!);
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: primaryColor,
        actions: [
          TextButton(
            onPressed: _isEditing
                ? _saveUserData
                : () => setState(() => _isEditing = true),
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _user.emailVerified
                                ? Icons.verified
                                : Icons.warning_amber_rounded,
                            color: _user.emailVerified
                                ? Colors.green
                                : Colors.black,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _user.emailVerified
                                  ? "Verified account."
                                  : "You need to verify your account.",
                            ),
                          ),
                          if (!_user.emailVerified)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Reqpage(),
                                  ),
                                ).then((_) => _reloadUser());
                              },
                              child: const Text(
                                "Verify Now",
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : const AssetImage(
                                      'assets/images/default_user.png')
                                  as ImageProvider,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final pickedImage = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);
                                if (pickedImage != null) {
                                  setState(() {
                                    _profileImage = File(pickedImage.path);
                                  });
                                }
                              },
                              child: const CircleAvatar(
                                radius: 18,
                                child: Icon(Icons.edit,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildProfileField(
                      label: 'Full Name',
                      initialValue: currentUser!.name,
                      onSaved: (value) => currentUser!.name = value,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter a name' : null,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      label: 'Email',
                      initialValue: currentUser!.email,
                      onSaved: (value) => currentUser!.email = value,
                      validator: null,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      label: 'Role',
                      initialValue: currentUser!.role,
                      onSaved: (value) => currentUser!.role = value,
                      validator: null,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      label: 'Phone Number',
                      initialValue: currentUser!.phone ?? '',
                      onSaved: (value) => currentUser!.phone = value,
                      validator: (value) => value != null &&
                              value.isNotEmpty &&
                              !RegExp(r'^\d+$').hasMatch(value)
                          ? 'Enter a valid phone number'
                          : null,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 20),
                    _buildAvailabilityWidget(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAvailabilityWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Table(
          columnWidths: const {0: FixedColumnWidth(100.0)},
          children: [
            TableRow(
              children: [
                const SizedBox(),
                ..._availability.keys.map(
                  (day) => Center(
                    child: Text(
                      day.substring(0, 2),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            ...['Morning', 'Afternoon', 'Evening', 'Night'].map((time) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        time,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ..._availability.keys.map(
                    (day) => GestureDetector(
                      onTap: _isEditing
                          ? () {
                              setState(() {
                                _availability[day]?[time] =
                                    !(_availability[day]?[time] ?? false);
                              });
                            }
                          : null,
                      child: Center(
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                            color: _availability[day]?[time] == true
                                ? Colors.deepPurple
                                : Colors.transparent,
                          ),
                          child: _availability[day]?[time] == true
                              ? const Icon(Icons.check,
                                  size: 16, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileField({
    required String label,
    required initialValue,
    required onSaved,
    required validator,
    bool enabled = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      enabled: enabled,
      maxLines: maxLines,
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.purple),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(15),
        ),
        labelText: label,
      ),
    );
  }
}
