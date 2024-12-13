import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'loginscreen.dart';
import 'viewHistory.dart';
import 'patientdetails.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  Uint8List? _webImage;
  String _className = "";
  double _confidenceScore = 0.0;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_image != null || _webImage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An image is already selected.')),
      );
      return; // Prevent further selection
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (kIsWeb) {
        final webImageBytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = webImageBytes;
          _image = null;
          _resetPredictionState(); // Clear previous state on new image pick
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
          _webImage = null;
          _resetPredictionState(); // Clear previous state on new image pick
        });
      }
    }
  }

  Future<void> _predictImage() async {
    if (_image == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Disable button while loading
    });

    try {
      final uri = Uri.parse('http://180.235.121.245:5004/predict'); // Update with your Flask server IP
      var request = http.MultipartRequest('POST', uri);

      if (!kIsWeb && _image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      } else if (kIsWeb && _webImage != null) {
        request.files.add(http.MultipartFile.fromBytes('image', _webImage!, filename: 'web_image.jpg'));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _className = result['class_name']; // Match with Flask response
          _confidenceScore = result['confidence_score']; // Match with Flask response
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get prediction.')));
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      });
    }
  }

  void _resetPredictionState() {
    _className = '';
    _confidenceScore = 0.0;
    // Do not set _isLoading to false here; it is controlled in _predictImage.
  }

  void _onMenuItemSelected(String choice) {
    if (choice == 'Patient Details') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewHistoryScreen()),
      );
    } else if (choice == 'Logout') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientDetails()),
        ); // Navigate to PatientDetailsScreen
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'DASHBOARD',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color(0x0A6BB1).withOpacity(0.6),
          actions: [
            PopupMenuButton<String>(
              onSelected: _onMenuItemSelected,
              itemBuilder: (BuildContext context) {
                return {'Patient Details', 'Logout'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Container(
          color: Color(0xFFE3EBF5), // Set background color for the entire screen
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adjusted padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          const SizedBox(height: 20),
                          Text(
                            'Alzheimer’s Disease Prediction Using MRI Image',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0966AA),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          const SizedBox(height: 20),
                          _image == null && _webImage == null
                              ? Text('No image selected.', style: TextStyle(color: Colors.red))
                              : Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: kIsWeb ? MemoryImage(_webImage!) : FileImage(_image!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          SingleChildScrollView( // Added SingleChildScrollView for Row
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  child: Text('Capture Image', style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0x0A6BB1).withOpacity(0.6),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  child: Text('Select from Gallery', style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0x0A6BB1).withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _predictImage,
                            child: _isLoading
                                ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                : Text('Predict', style: TextStyle(color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0x0A6BB1).withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_className.isNotEmpty)
                            Column(
                              children: [
                                Text('Prediction: $_className', style: TextStyle(fontSize: 20, color: Color(0xFF0966AA))),
                                Text('Confidence: ${(50.00 + (_confidenceScore * 100)).toStringAsFixed(2)}%', style: TextStyle(fontSize: 20)),
                                SizedBox(height: 20),
                              ],
                            ),
                        ],
                      ),
                    ),
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
