import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; 
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

  void showSettingsMenu(BuildContext context) {
    const String laundryMessage = "Uses Before Dirty";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(color: Colors.green, width: 2),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Color(0xFF1B5E20), 
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: laundryMessage),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only numbers can be entered
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                //add something here
              },
              child: const Text(
                'Change',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  void showGenerateOutfitMenu(BuildContext context) {
    String selectedOutfitType = 'casual'; // Default dropdown value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: const BorderSide(color: Colors.green, width: 2),
          ),
          title: const Text(
            'Select Outfit Type',
            style: TextStyle(
              color: Color(0xFF1B5E20), 
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                generateOutfit(selectedOutfitType);
                Navigator.of(context).pop(); 
              },
              child: const Text(
                'Generate',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> generateOutfit(String usage) async {
    final String url = 'http://ipaddress:8000/outfit/warm/$usage';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          outfitResult = "top: ${data["top"]} \n \n bottom: ${data["bottom"]}";
        });
      } else {
        setState(() {
          outfitResult =
              "Failed to fetch outfit. Status code: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        outfitResult = "generated $usage outfit";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    Size screenSize = MediaQuery.of(context).size;
    double displayWidthInPixels = screenSize.width * devicePixelRatio;
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
                      showSettingsMenu(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Display outfit result or placeholder art  for aesthetics
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
                    child:  Image(
                      image: const AssetImage('assets/background.png'),
                      width: displayWidthInPixels,
                      height: displayWidthInPixels,
                      fit: BoxFit.cover,
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
                  // Generate Outfit Button
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showGenerateOutfitMenu(context); // Open popup menu
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
