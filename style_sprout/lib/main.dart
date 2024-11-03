import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const StyleSproutApp());
}

class StyleSproutApp extends StatelessWidget {
  const StyleSproutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StyleSproutHome(),
    );
  }
}

class StyleSproutHome extends StatefulWidget {
  @override
  _StyleSproutHomeState createState() => _StyleSproutHomeState();
}

class _StyleSproutHomeState extends State<StyleSproutHome> {
  String outfitResult = 'Style Sprout';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Style Sprout',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.green,
                      size: 30,
                    ),
                    onPressed: () {
                      // TODO: Add action for settings button
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Display selected outfit
            Expanded(
              child: Center(
                child: Container(
                  width: 250,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      outfitResult,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Navigate to Generate Outfit Page Button
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Navigate to Generate Outfit Page and get selected outfit if any
                          final selectedOutfit = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GenerateOutfitPage()),
                          );
                          if (selectedOutfit != null) {
                            setState(() {
                              outfitResult = selectedOutfit;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                          backgroundColor: Colors.green,
                        ),
                        child: const Icon(
                          Icons.star_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Generate Outfit',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

                  // Do Laundry Button
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Add the action function for the do laundry button
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                          backgroundColor: Colors.green,
                        ),
                        child: const Icon(
                          Icons.local_laundry_service_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Do Laundry',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GenerateOutfitPage extends StatefulWidget {
  @override
  _GenerateOutfitPageState createState() => _GenerateOutfitPageState();
}

class _GenerateOutfitPageState extends State<GenerateOutfitPage> {
  String selectedOutfitType = 'casual';
  String generatedOutfit = 'Generated outfit will appear here';
  String? topImageUrl;
  String? bottomImageUrl;

  Future<void> generateOutfit(String usage) async {
    final String url = 'http://ipaddress:8000/outfit/warm/$usage';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          generatedOutfit = "top: ${data["top"]} \n \n bottom: ${data["bottom"]}";
    
          topImageUrl = "assets/images/" + data["top"]["ImageUrl"] + ".jpg";
          bottomImageUrl = "assets/images/" + data["bottom"]["ImageUrl"] + ".jpg";
        });
      } else {
        setState(() {
          generatedOutfit =
              "Failed to fetch outfit. Status code: ${response.statusCode}";
          topImageUrl = null;
          bottomImageUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        generatedOutfit = "generated $usage outfit";
        topImageUrl = null;
        bottomImageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Home button
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.green),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Style Sprout',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display generated outfit
            Expanded(
              child: Center(
                child: Container(
                  width: 250,
                  height: 500,
                  child: SingleChildScrollView(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      topImageUrl != null
                          ? Image.asset(topImageUrl!)
                          : Container(height: 120),
                      const SizedBox(height: 10),
                      bottomImageUrl != null
                          ? Image.asset(bottomImageUrl!)
                          : Container(height: 120),
                      const SizedBox(height: 10),
                      topImageUrl == null || bottomImageUrl == null
                      ? Text(
                        generatedOutfit,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ) : Container(height: 120),
                      
                    ],
                  ),
                ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
              child: Column(
                children: [
                  // Dropdown for Outfit Type
                  DropdownButton<String>(
                    value: selectedOutfitType,
                    isExpanded: true,
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontSize: 18,
                    ),
                    items: <String>['casual', 'athletic', 'formal']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedOutfitType = newValue!;
                      });
                    },
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(height: 20),

                  // Generate Button & Select Outfit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          generateOutfit(selectedOutfitType);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Generate',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, generatedOutfit); 
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          'Select Outfit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
