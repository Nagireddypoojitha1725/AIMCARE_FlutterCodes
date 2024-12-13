import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dashboard.dart'; // Import DashboardScreen
import 'loginscreen.dart'; // Import your LoginScreen

class PatientDetails extends StatefulWidget {
  const PatientDetails({super.key});

  @override
  _PatientDetailsState createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  String? _selectedGender; // Variable to hold selected gender
  final TextEditingController _ageController = TextEditingController();

  void addPatientDetails() async {
    String name = _nameController.text;
    String id = _idController.text;
    String sex = _selectedGender ?? ''; // Get the selected gender
    String age = _ageController.text;

    var url = Uri.parse('http://180.235.121.245/Alzeihmersdisease/AddPatientDetails.php'); // Update with your PHP backend URL
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patientName': name,
          'patientId': id,
          'age': age,
          'sex': sex,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(),
            ),
          );
        } else {
          showErrorDialog(data['message']);
        }
      } else {
        showErrorDialog('Failed to connect to the server. Please try again later.');
      }
    } catch (error) {
      showErrorDialog('An error occurred. Please try again later.');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate back to LoginScreen when back button is pressed
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE0EAF1),
        appBar: AppBar(
          title: const Text(
            'PATIENT DETAILS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          backgroundColor: const Color(0xFF6699CC),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView( // Add SingleChildScrollView here
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6699CC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildTextField(_nameController, 'Patient Name', Icons.person),
                    const SizedBox(height: 20),
                    buildTextField(_idController, 'Patient ID', Icons.card_membership),
                    const SizedBox(height: 20),
                    buildGenderDropdown(), // Add gender dropdown here
                    const SizedBox(height: 20),
                    buildTextField(_ageController, 'Age', Icons.calendar_today),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: addPatientDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Add Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade400), // Optional border color
        ),
        prefixIcon: Icon(icon), // Add the icon here
      ),
    );
  }

  Widget buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade400), // Optional border color
        ),
        prefixIcon: const Icon(Icons.wc), // Add the icon here
      ),
      items: <String>['Male', 'Female']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue; // Update the selected gender
        });
      },
      hint: const Text('Select Gender'), // Hint text for dropdown
      isExpanded: true, // Makes the dropdown take full width of the container
      dropdownColor: Colors.white, // Dropdown background color
      icon: const Icon(Icons.arrow_drop_down),
      borderRadius: BorderRadius.circular(20),
      itemHeight: 48, // Set itemHeight to the minimum interactive dimension
    );
  }
}
