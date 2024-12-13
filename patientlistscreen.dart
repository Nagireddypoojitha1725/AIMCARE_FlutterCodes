import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'patienthistory.dart'; // Import the PatientHistoryScreen

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  Future<List<Map<String, String>>> fetchPatients() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.164.206/php/details.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, String>>.from(
              data['data'].map((patient) => {
                'name': patient['patientName'],
                'id': patient['patientId'],
                'age': patient['age'].toString(),
                'sex': patient['sex']
              })
          );
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
        backgroundColor: const Color(0xFF6699CC),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: fetchPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No patients found'));
          } else {
            return ListView(
              children: snapshot.data!.map((patient) {
                return ListTile(
                  title: Text(patient['name']!),
                  subtitle: Text('ID: ${patient['id']} - Age: ${patient['age']} - Sex: ${patient['sex']}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PatientHistoryScreen(patientHistory: [patient]),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
