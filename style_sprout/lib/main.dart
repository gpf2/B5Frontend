import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; 
import 'dart:convert';

void main() {
  runApp(const StyleSproutApp());
}

class StyleSproutApp extends StatelessWidget {
  const StyleSproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StyleSproutHome(),
    );
  }
}

class StyleSproutHome extends StatefulWidget {
  const StyleSproutHome({super.key});

  @override
  _StyleSproutHomeState createState() => _StyleSproutHomeState();
}

class _StyleSproutHomeState extends State<StyleSproutHome> {
  String outfitResult = 'Style Sprout'; 

  void showSettingsMenu(BuildContext context) {
    const String laundryMessage = "Uses Before Dirty (1 to 100)";
    int value = 1;
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
                    decoration: const InputDecoration(
                      labelText: laundryMessage
                      ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ], // Only numbers can be entered
                    onChanged: (String? newValue) {
                      if (newValue != null && newValue.isNotEmpty) {
                        int temp = int.parse(newValue);
                        if (temp>0 || temp<=100){
                          value = temp;
                        }
                      }
                    }
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                changeUses( value);
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

  Future<void> changeUses(int uses) async {
    /*
    final String url = 'http://ipaddress:8000/laundry/$uses';
    try {
      http.post(Uri.parse(url));
    } catch (e) {
      dev.log("Error changing uses");
    }
    */
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

            // Display selected outfit
            Expanded(
              child: Center(
                child: Container(
                  width: displayWidthInPixels,
                  height: displayWidthInPixels,
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
                  // Navigate to Generate Outfit Page Button
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Navigate to Generate Outfit Page and get selected outfit if any
                          final selectedOutfit = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GenerateOutfitPage()),
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
  const GenerateOutfitPage({super.key});

  @override
  _GenerateOutfitPageState createState() => _GenerateOutfitPageState();
}

class _GenerateOutfitPageState extends State<GenerateOutfitPage> {
  String selectedOutfitType = 'casual';
  String generatedOutfit = 'Generated outfit will appear here';
  String? topImageUrl;
  String? bottomImageUrl;
  String? jacketImageUrl;

  Future<void> generateOutfit(String usage) async {
    final String url = 'http://ipaddress:8000/outfit/warm/$usage';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          generatedOutfit = "jacket: ${data["jacket"]} \n \n top: ${data["top"]} \n \n bottom: ${data["bottom"]}";
    
          topImageUrl = "${"assets/images/" + data["top"]["ImageUrl"]}.jpg";
          bottomImageUrl = data["bottom"] != 'undefined' ? "${"assets/images/" + data["bottom"]["ImageUrl"]}.jpg": "none";
          jacketImageUrl = data["jacket"] != 'undefined' ? "${"assets/images/" + data["jacket"]["ImageUrl"]}.jpg": "none";
        });
      } else {
        setState(() {
          generatedOutfit =
              "Failed to fetch outfit. Status code: ${response.statusCode}";
          topImageUrl = null;
          bottomImageUrl = null;
          jacketImageUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        generatedOutfit = "generated $usage outfit";
        topImageUrl = null;
        bottomImageUrl = null;
        jacketImageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    Size screenSize = MediaQuery.of(context).size;
    double displayHeightInPixels = screenSize.height * devicePixelRatio;
    // Home button
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.green),
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
                child: SizedBox(
                  width: 250,
                  height: 500,
                  child: SingleChildScrollView(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (jacketImageUrl != null && jacketImageUrl!="none")
                          ? Image(
                            image: AssetImage (jacketImageUrl!),
                            height: displayHeightInPixels/15,)
                          : Container(height: 0),
                      const SizedBox(height: 10),
                      (topImageUrl != null && topImageUrl!="none")
                          ? Image(
                            image: AssetImage (topImageUrl!),
                            height: displayHeightInPixels/15,)
                          : Container(height: 0),
                      const SizedBox(height: 10),
                      (bottomImageUrl != null && bottomImageUrl!="none")
                          ? Image(
                            image: AssetImage (bottomImageUrl!),
                            height: displayHeightInPixels/15,)
                          : Container(height: 0),
                      const SizedBox(height: 10),
                      (topImageUrl == null || bottomImageUrl == null || bottomImageUrl == null) ||
                      (topImageUrl == "none" && bottomImageUrl == "none" && bottomImageUrl == "none")
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
