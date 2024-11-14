import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Home%20page.dart';

class UH_Profile extends StatefulWidget {
  const UH_Profile({super.key});

  @override
  _UH_ProfileState createState() => _UH_ProfileState();
}

class _UH_ProfileState extends State<UH_Profile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String fullName = '';
  String phoneNumber = '';
  String email = '';
  DateTime birthday = DateTime.now();
  String gender = 'Male';
  String address = '';
  String location = '';
  File? profilePhoto;
  String? profilePhotoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');
      
      if (phoneNumber == null) throw Exception('Phone number not found');

      final baseURL = dotenv.env['BASE_URL'];
      final response = await http.get(
        Uri.parse('$baseURL/profile/$phoneNumber'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['data']['user'];
        
        setState(() {
          _nameController.text = user['fullName'] ?? '';
          _phoneController.text = user['phoneNumber'] ?? '';
          _emailController.text = user['email'] ?? '';
          _addressController.text = user['address'] ?? '';
          _locationController.text = user['location'] ?? '';
          
          if (user['birthday'] != null) {
            birthday = DateTime.parse(user['birthday']);
          }
          
          gender = user['gender'] ?? 'Male';
          if (user['profilePhoto'] != null && user['profilePhoto'].isNotEmpty) {
            profilePhotoUrl = user['profilePhoto'];
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    final baseURL = dotenv.env['BASE_URL'];
    final request = http.MultipartRequest('POST', Uri.parse('$baseURL/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      return data['filePath']; // Assuming the server returns the file path
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<void> createOrUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');

      if (phoneNumber == null) {
        throw Exception('Phone number not found');
      }

      String? profilePhotoPath;
      if (profilePhoto != null) {
        profilePhotoPath = await uploadImage(profilePhoto!);
      }

      final requestBody = {
        'fullName': _nameController.text.trim(),
        'phoneNumber': phoneNumber,
        'email': _emailController.text.trim(),
        'birthday': birthday.toIso8601String(),
        'gender': gender,
        'address': _addressController.text.trim(),
        'location': _locationController.text.trim(),
        'profilePhoto': profilePhotoPath ?? 'N/A',
      };

      print('Request body: $requestBody'); // Debug log

      final baseURL = dotenv.env['BASE_URL'];
      if (baseURL == null) {
        throw Exception('BASE_URL not found in environment');
      }

      final response = await http.post(
        Uri.parse('$baseURL/profile/cu'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (!mounted) return;
      setState(() => _isLoading = false);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await saveToPrefs(requestBody);

        if (!mounted) return;

        await QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: 'Profile saved successfully!',
          confirmBtnText: 'OK',
          onConfirmBtnTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
        );
      } else {
        throw Exception(responseData['message'] ?? 'Failed to save profile');
      }
    } catch (e) {
      print('Error saving profile: $e'); // Debug log
      setState(() => _isLoading = false);
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: e.toString(),
        );
      }
    }
  }

  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');
      
      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 200) {
        await prefs.setString('token', data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveToPrefs(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('userId', data['_id'] ?? ''),
      prefs.setString('userName', data['fullName'] ?? ''),
      prefs.setString('userPhone', data['phoneNumber'] ?? ''),
      prefs.setString('userAddress', data['address'] ?? ''),
      prefs.setString('userLocation', data['location'] ?? ''),
    ]);
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        profilePhoto = File(image.path);
      });
    }
  }

  Future<void> saveProfileToDatabase() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');
      
      if (phoneNumber == null) {
        throw Exception('Phone number not found');
      }

      final loginResponse = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/profile/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
        }),
      );

      if (!mounted) return;

      if (loginResponse.statusCode != 200) {
        throw Exception('Login failed: ${loginResponse.body}');
      }

      final loginData = jsonDecode(loginResponse.body);
      final token = loginData['token'];

      final requestBody = {
        'fullName': _nameController.text.trim(),
        'phoneNumber': phoneNumber,
        'email': _emailController.text.trim(),
        'birthday': birthday.toIso8601String(),
        'gender': gender,
        'address': _addressController.text.trim(),
        'location': _locationController.text.trim(),
        'profilePhoto': profilePhoto?.path ?? '',
      };

      final saveResponse = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/profile/cu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (saveResponse.statusCode == 200 || saveResponse.statusCode == 201) {
        await saveToPrefs(requestBody);
        
        if (!mounted) return;
        
        // Use BuildContext.mounted check before showing QuickAlert
        if (context.mounted) {
          await QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            text: 'Profile saved successfully!',
            onConfirmBtnTap: () {
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              }
            },
          );
        }
      } else {
        throw Exception(jsonDecode(saveResponse.body)['message']);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      if (context.mounted) {
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: e.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green[700],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Center(
                    child: Stack(
                      children: [
                        profilePhoto != null
                            ? CircleAvatar(
                                radius: 50.0,
                                backgroundImage: FileImage(profilePhoto!),
                                backgroundColor: Colors.grey[200],
                              )
                            : CircleAvatar(
                                radius: 50.0,
                                backgroundImage: NetworkImage(profilePhotoUrl ?? ''),
                                child: profilePhotoUrl == null
                                    ? Icon(Icons.person, size: 50.0)
                                    : null,
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green[700],
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your full name'
                              : null,
                          onSaved: (value) => fullName = value!,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your phone number'
                              : null,
                          onSaved: (value) => phoneNumber = value!,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter your email' : null,
                          onSaved: (value) => email = value!,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Birthday',
                            hintText: 'Select your birthday',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: birthday,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != birthday) {
                              setState(() {
                                birthday = pickedDate!;
                              });
                            }
                          },
                          controller: TextEditingController(
                            text: "${birthday.toLocal()}"
                                .split(' ')[0], // Show selected date
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: gender,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: <String>['Male', 'Female', 'Other']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              gender = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.home),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter your address' : null,
                          onSaved: (value) => address = value!,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'District',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your district'
                              : null,
                          onSaved: (value) => location = value!,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : saveProfileToDatabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Profile', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
