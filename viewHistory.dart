import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewHistoryScreen extends StatefulWidget {
  const ViewHistoryScreen({Key? key}) : super(key: key);

  @override
  _ViewHistoryScreenState createState() => _ViewHistoryScreenState();
}

class _ViewHistoryScreenState extends State<ViewHistoryScreen> {
  List<dynamic> patientHistory = [];
  List<dynamic> filteredPatients = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
    searchController.addListener(() {
      filterSearchResults(searchController.text);
    });
  }

  Future<void> fetchPatientDetails() async {
    var url = Uri.parse('http://180.235.121.245/Alzeihmersdisease/fetch.php'); // Replace with your actual URL
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            patientHistory = data['patients'];
            // Sort patientHistory by patientName in alphabetical order
            patientHistory.sort((a, b) => a['patientName'].compareTo(b['patientName']));
            filteredPatients = patientHistory; // Update filteredPatients after sorting
          });
        } else {
          print('Error: ${data['message']}');
        }
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void filterSearchResults(String query) {
    List<dynamic> tempSearchList = [];
    if (query.isNotEmpty) {
      tempSearchList = patientHistory
          .where((patient) => patient['patientName'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      tempSearchList = patientHistory;
    }
    setState(() {
      filteredPatients = tempSearchList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A6BB1).withOpacity(0.6), // Solid light blue color
        title: Text(
          'PATIENTS HISTORY',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Enter patient name',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5.0,
                        height: 100.0,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient['patientName'],
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Text(
                                    'ID: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  Text(
                                    patient['patientId'].toString(), // Convert patientId to a string
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Age: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  Text(
                                    patient['age'].toString(), // Convert age to a string
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Sex: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  Text(
                                    patient['sex'], // Assuming sex is already a string
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
