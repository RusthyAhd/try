import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_on/Tool_Provider/TP_Dashboard.dart';
import 'package:tap_on/widgets/Loading.dart';
import 'package:http/http.dart' as http;

class TP_AddTool extends StatefulWidget {
  const TP_AddTool({super.key});

  @override
  _TP_AddToolState createState() => _TP_AddToolState();
}

class _TP_AddToolState extends State<TP_AddTool> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  bool isNew = true;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  File? _image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _qytController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String availability = "Available"; // Track availability status

  final List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  List<String> selectedWeekdays = [];

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> handleSaveTool() async {
    LoadingDialog.show(context);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final baseURL = dotenv.env['BASE_URL'];
      final token = prefs.getString('token');
      final providerEmail = prefs.getString('toolProviderEmail');

      final toolData = {
        'title': _nameController.text,
        'pic': _image != null ? base64Encode(_image!.readAsBytesSync()) : 'N/A',
        'qty': _qytController.text,
        'item_price': _priceController.text,
        'availability': availability, // Use selected availability status
        'available_days': selectedWeekdays,
        'available_hours': '${startTime?.format(context) ?? 'Not Set'} - ${endTime?.format(context) ?? 'Not Set'}',
      };

      final response = await http.post(
        Uri.parse('$baseURL/tool/new/$providerEmail'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: json.encode(toolData),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == 200) {
        LoadingDialog.hide(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TP_Dashboard()),
        );
      } else {
        LoadingDialog.hide(context);
        _showError(data['message']);
      }
    } catch (e) {
      LoadingDialog.hide(context);
      _showError('Failed to save service details');
    }
  }

  void _showError(String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Oops...',
      text: message,
      backgroundColor: Colors.black,
      titleColor: Colors.white,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Name *'),
              const SizedBox(height: 16),
              _buildTextField(
                _descriptionController,
                'Description',
                maxLength: 280,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 16),
              _buildTextField(_qytController, 'Limit(available quantity)', inputType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_priceController, 'Price', inputType: TextInputType.number),
              const SizedBox(height: 16),
              _buildAvailability(),
              const SizedBox(height: 16),
              _buildWeekdaysSelector(),
              const SizedBox(height: 16),
              _buildTimeRangeSelector(),
              const SizedBox(height: 16),
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLength = 100, int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: inputType,
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _image == null
            ? const Center(child: Text('image selected'))
            : Image.file(_image!, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildAvailability() {
    return Column(
      children: [
        RadioListTile(
          title: const Text("Available"),
          value: "Available",
          groupValue: availability,
          onChanged: (value) => setState(() => availability = value as String),
        ),
        RadioListTile(
          title: const Text("Unavailable"),
          value: "Unavailable",
          groupValue: availability,
          onChanged: (value) => setState(() => availability = value as String),
        ),
      ],
    );
  }

  Widget _buildWeekdaysSelector() {
    return Wrap(
      spacing: 8.0,
      children: weekdays.map((day) {
        return FilterChip(
          label: Text(day),
          selected: selectedWeekdays.contains(day),
          onSelected: (isSelected) {
            setState(() {
              isSelected ? selectedWeekdays.add(day) : selectedWeekdays.remove(day);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimeRangeSelector() {
    return ListTile(
      title: Text(
        startTime == null || endTime == null
            ? 'Set available time range'
            : 'Selected Time Range: ${startTime!.format(context)} - ${endTime!.format(context)}',
      ),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        await _selectTime(context, true);
        await _selectTime(context, false);
      },
    );
  }

  Widget _buildAddButton() {
    return Center(
      child: ElevatedButton(
        onPressed: handleSaveTool,
        child: const Text('Add Tool'),
      ),
    );
  }
}
