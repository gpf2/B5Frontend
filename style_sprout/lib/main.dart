import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; 
import 'dart:convert';
import 'dart:developer' as dev;

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
  StyleSproutHomeState createState() => StyleSproutHomeState();
}

class StyleSproutHomeState extends State<StyleSproutHome> {
  String outfitResult = 'Style Sprout'; 
  bool? hasAcceptedPrivacyNotice;

  @override
  void initState() {
    super.initState();
    checkPrivacyNotice();
  }

  Future<void> checkPrivacyNotice() async {
    final String url = 'http://ipaddress:8000/privacy_notice/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          hasAcceptedPrivacyNotice = result == 1;
        });
        if (!hasAcceptedPrivacyNotice!) {
          showPrivacyNoticePopup();
        }
      } else {
        dev.log("Failed to fetch privacy notice status.");
      }
    } catch (e) {
      dev.log("Error fetching privacy notice status: $e");
    }
  }

  Future<void> acceptPrivacyNotice() async {
    final String url = 'http://ipaddress:8000/privacy_notice/accept';
    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          hasAcceptedPrivacyNotice = true;
        });
        Navigator.pop(context); // close popup
      } else {
        dev.log("Failed to accept privacy notice.");
      }
    } catch (e) {
      dev.log("Error accepting privacy notice: $e");
    }
  }

   void showPrivacyNoticePopup() {
    bool hasAccepted = false;
    String errorMessage = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Colors.green, width: 2),
              ),
              title: const Text(
                'Privacy Notice',
                style: TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "This application will save images of clothing you scan. "
                    "These images are private to your account and will not be shared. "
                    "They will only be used for generating outfits and displaying your closet.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: hasAccepted,
                        onChanged: (bool? value) {
                          dialogSetState(() {
                            hasAccepted = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "I accept these terms.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (hasAccepted) {
                      acceptPrivacyNotice();
                    } else {
                      dialogSetState(() {
                        errorMessage = "You must accept the terms before using the application.";
                      });
                    }
                  },
                  child: const Text(
                    "Submit",
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
      },
    );
  }


  void showSettingsMenu(BuildContext context) {
    const String laundryMessage = "Uses Before Dirty (1 to 100)";
    const String locationMessage = "Enter a Location";
    String errorMessage = "";
    int value = -1;
    String selectedLocation = "-1"; // default
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState){
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              // Uses before dirty input
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
                    value = int.parse(newValue);                    
                  }
                },
              ),
              const SizedBox(height: 20),
              // Location input
              TextField(
                decoration: const InputDecoration(
                  labelText: locationMessage,
                ),
                onChanged: (String? newLocation) {
                  if (newLocation != null && newLocation.isNotEmpty){
                    dialogSetState(() {
                      selectedLocation = newLocation;
                    });
                  }
                },
              ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  bool success = await changeSettings(value, selectedLocation);
                  if (!success) {
                    // Display error message
                    dialogSetState(() {
                      errorMessage = "Failed to update settings";
                    });
                  } else {
                    // Close 
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "Change",
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
      },
    );
  }

  Future<bool> changeSettings(int uses, String location) async {
    final String url = 'http://ipaddress:8000/settings/update/$uses/$location';
    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        return true;
      } else {
        dev.log("Invalid location: $location");
        return false;
      }
    } catch (e) {
      dev.log("Error changing uses/location");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasAcceptedPrivacyNotice == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  // Do Laundry Button
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          const String url = 'http://ipaddress:8000/laundry/reset';
                          try {
                            http.post(Uri.parse(url));
                          } catch (e) {
                            dev.log(e.toString());
                          }
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
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ClosetPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                          backgroundColor: Colors.green,
                        ),
                        child: const Icon(
                          Icons.checkroom,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Closet',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
  GenerateOutfitPageState createState() => GenerateOutfitPageState();
}

class GenerateOutfitPageState extends State<GenerateOutfitPage> {
  String selectedOutfitType = 'Casual';
  String generatedOutfit = 'Generated outfit will appear here';
  String? topImageUrl;
  String? bottomImageUrl;
  String? jacketImageUrl;
  String? overwearImageUrl;
  Map<String, dynamic>? outfitData;
  int divisionAmount = 12;
  String errorMessage = "";

  Future<void> generateOutfit(String usage) async {
    final String url = 'http://ipaddress:8000/outfit/$usage';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          generatedOutfit = "jacket: ${data["jacket"]} \n \n top: ${data["top"]} \n \n bottom: ${data["bottom"]}";
          topImageUrl = data["top"]["URL"];
          bottomImageUrl = data["bottom"] != null ? data["bottom"]["URL"] : "none";
          jacketImageUrl = data["jacket"] != null ? data["jacket"]["URL"] : "none";
          overwearImageUrl = data["overwear"] != null ? data["overwear"]["URL"] : "none";
          outfitData = data;
        });
      } else {
        errorMessage = "Failed to generate outfit. ${response.statusCode}";
        setState(() {
          errorMessage = "Failed to generate outfit. ${jsonDecode(response.body)["detail"]}.";
          topImageUrl = null;
          bottomImageUrl = null;
          jacketImageUrl = null;
          overwearImageUrl = null;
          outfitData = null;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to generate outfit. ${e.toString()}";
        generatedOutfit = "generated $usage outfit";
        topImageUrl = null;
        bottomImageUrl = null;
        jacketImageUrl = null;
        overwearImageUrl = null;
        outfitData = null;
      });
    }
  }

  Future<void> dislikeOutfitAndRegenerate() async {
    final String itemId1 = outfitData!["top"]["ItemID"].toString();
    final String itemId2 = outfitData!["bottom"] != null
        ? outfitData!["bottom"]["ItemID"].toString()
        : "-1";

    final String url = 'http://ipaddress:8000/dislike/$itemId1/$itemId2';

    try {
      await http.post(Uri.parse(url));
      dev.log("Dislike successful");
    } catch (e) {
      dev.log("Error disliking: $e");
    }

    // Generate new outfit after disliking current one
    generateOutfit(selectedOutfitType);
  }

@override
Widget build(BuildContext context) {
  double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
  Size screenSize = MediaQuery.of(context).size;
  double displayHeightInPixels = screenSize.height * devicePixelRatio;

  // Get # of valid images
  List<String?> validImages = [
    jacketImageUrl,
    overwearImageUrl,
    topImageUrl,
    bottomImageUrl
  ].where((image) => image != null && image != "none").toList();

  dev.log("urls: jacket- $jacketImageUrl overwear-  $overwearImageUrl  top- $topImageUrl  bottom - $bottomImageUrl");
  // Get division amount based on # of valid images
  int imageCount = validImages.length;
  if (imageCount == 2) {
    divisionAmount = 10;
  } else if (imageCount == 3) {
    divisionAmount = 12;
  } else if (imageCount == 4) {
    divisionAmount = 12; 
  } else {
    divisionAmount = 10; 
  }

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
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                errorMessage,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ), 
                textAlign: TextAlign.center,
              ),
            ),
          // Display generated outfit
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: imageCount == 4
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: Jacket & Overwear
                          Column(
                            children: [
                              if (jacketImageUrl != null &&
                                  jacketImageUrl != "none")
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Image.network(
                                    jacketImageUrl!,
                                    height: displayHeightInPixels / divisionAmount,
                                  ),
                                ),
                              if (overwearImageUrl != null &&
                                  overwearImageUrl != "none")
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Image.network(
                                    overwearImageUrl!,
                                    height: displayHeightInPixels / divisionAmount,
                                  ),
                                ),
                            ],
                          ),
                          // Right column: Top & Bottom
                          Column(
                            children: [
                              if (topImageUrl != null && topImageUrl != "none")
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Image.network(
                                    topImageUrl!,
                                    height: displayHeightInPixels / divisionAmount,
                                  ),
                                ),
                              if (bottomImageUrl != null &&
                                  bottomImageUrl != "none")
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Image.network(
                                    bottomImageUrl!,
                                    height: displayHeightInPixels / divisionAmount,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (jacketImageUrl != null && jacketImageUrl != "none")
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Image.network(
                                jacketImageUrl!,
                                height: displayHeightInPixels / divisionAmount,
                              ),
                            ),
                          if (overwearImageUrl != null &&
                              overwearImageUrl != "none")
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Image.network(
                                overwearImageUrl!,
                                height: displayHeightInPixels / divisionAmount,
                              ),
                            ),
                          if (topImageUrl != null && topImageUrl != "none")
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Image.network(
                                topImageUrl!,
                                height: displayHeightInPixels / divisionAmount,
                              ),
                            ),
                          if (bottomImageUrl != null && bottomImageUrl != "none")
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Image.network(
                                bottomImageUrl!,
                                height: displayHeightInPixels / divisionAmount,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
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
                  items: <String>['Casual', 'Formal']
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
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
                        final String? primary = outfitData!["top"]["Color"];
                        final String? secondary = outfitData!["bottom"] != null 
                            ? outfitData!["bottom"]["Color"] 
                            : primary;
                        final String itemId1 = outfitData!["top"]["ItemID"].toString();
                        final String itemId2 = outfitData!["bottom"] != null 
                            ? outfitData!["bottom"]["ItemID"].toString() 
                            : "-1"; 
                        final String itemId3 = outfitData!["overwear"] != null
                            ? outfitData!["overwear"]["ItemID"].toString()
                            : "-1";
                        final String itemId4 = outfitData!["jacket"] != null
                            ? outfitData!["jacket"]["ItemID"].toString()
                            : "-1";
                        final String url =
                            'http://ipaddress:8000/select/$primary/$secondary/$itemId1/$itemId2/$itemId3/$itemId4';
                        try {
                          http.post(Uri.parse(url));
                        } catch (e) {
                          dev.log("Error saving outfit");
                        }
                        Navigator.pop(context, generatedOutfit);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
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
                    ElevatedButton(
                        onPressed: dislikeOutfitAndRegenerate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
                          backgroundColor: Colors.red,
                        ),
                        child: const Icon(
                          Icons.thumb_down,
                          color: Colors.white,
                          size: 24,
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

class ClosetPage extends StatefulWidget {
  const ClosetPage({super.key});

  @override
  ClosetPageState createState() => ClosetPageState();
}

class ClosetPageState extends State<ClosetPage> {
  int currentPage = 0;
  List<String> imagePaths = [];
  List<String> imageIDs = [];
  bool lastPage = false;
  String closetErrorMessage = '';
  String labelsErrorMessage = '';
  List<String> labels = [];

  Future<void> fetchImagePaths(int page) async {
    final String url = 'http://ipaddress:8000/closet_images/$page';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          imagePaths = List<String>.from(data['urls']);
          imageIDs = List<String>.from(data['ids']);
          lastPage = data['last_page'] as bool;
          closetErrorMessage = '';
        });
      } else {
        setState(() {
          imagePaths = [];
          imageIDs = [];
          currentPage = 0;
          int statusCode = response.statusCode;
          closetErrorMessage = 'HTTP error encountered: $statusCode';
        });
      }
    } catch (e) {
      dev.log(e.toString());
      setState(() {
        imagePaths = [];
        imageIDs = [];
        currentPage = 0;
        closetErrorMessage = e.toString();
      });
    }
  }

  Future<void> updateLabel(String id, String usage, String color, int num_uses, String item_type) async {
    final String url = 'http://ipaddress:8000/update/$id/$usage/$color/$num_uses/$item_type';
    try {
      http.post(Uri.parse(url));
    } catch (e) {
      dev.log("Error updating label");
    }
  }

  Future<List<String>> getLabels(String id) async {
    final String url = 'http://ipaddress:8000/image_labels/$id';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          labels = List<String>.from(data['labels']);
          labelsErrorMessage = '';
        });
      } else {
        setState(() {
          labels = [];
          int statusCode = response.statusCode;
          labelsErrorMessage = 'HTTP error encountered: $statusCode';
        });
      }
    } catch (e) {
      setState(() {
        labels = [];
        labelsErrorMessage = e.toString();
      });
    }
    return labels;
  }

  @override
  void initState() {
    super.initState();
    fetchImagePaths(currentPage);
  }

  void showImagePopup(String imagePath, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<String>>(
          future: getLabels(id),
          builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                title: Text('Loading...'),
                content: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            }
            if (snapshot.hasData) {
              List<String> labels = snapshot.data!;
              String color = labels[0];
              String clothingType = labels[1];
              String usage = labels[2];
              int numUses = int.parse(labels[3]);
              if (labels.isNotEmpty){
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return AlertDialog(
                      title: const Text('Change/Confirm Labels'),
                      content: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 300),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                imagePath,
                                fit: BoxFit.cover,
                                height: 150,
                                width: 150,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Clothing Type',
                                style: TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DropdownButton<String>(
                                value: clothingType,
                                isExpanded: true,
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 14,
                                ),
                                items: <String>[
                                  'Blazers', 'Cardigan', 'Dresses', 'Hoodie', 'Jackets',
                                  'Jeans', 'Jumpsuit', 'Leggings', 'Lounge Pants', 'Shorts',
                                  'Skirts', 'Sweaters', 'Tank', 'Tops', 'Trousers', 'Tshirts'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                    setState(() {
                                      if (newValue!=null){
                                        clothingType = newValue;
                                      }
                                    });
                                  },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Color',
                                style: TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DropdownButton<String>(
                                value: color,
                                isExpanded: true,
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 14,
                                ),
                                items: <String>[
                                  'Beige', 'Black', 'Blue', 'Brown', 'Green', 'Grey',
                                  'Orange', 'Pink', 'Purple', 'Red', 'White', 'Yellow'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue!=null){
                                      color = newValue;
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Usage',
                                style: TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              DropdownButton<String>(
                                value: usage,
                                isExpanded: true,
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 14,
                                ),
                                items: <String>['Casual', 'Formal'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    if (newValue!=null){
                                      usage = newValue;
                                    }
                                  });
                                },
                              ),
                              TextField(
                                decoration:  InputDecoration(
                                  labelText: 'Current Uses: $numUses',
                                  labelStyle: TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                  ),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ], // Only numbers can be entered
                                onChanged: (String? newValue) {
                                  if (newValue != null && newValue.isNotEmpty) {
                                    int temp = int.parse(newValue);
                                    if (temp>0 || temp<=100){
                                      numUses = temp;
                                    }
                                  }
                                }
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            updateLabel(id, usage, color, 
                              numUses, clothingType);
                          },
                          child: const Text('Submit'),
                        ),
                        TextButton(
                        onPressed: () async {
                          await deleteItem(id);
                          Navigator.of(context).pop();
                          fetchImagePaths(currentPage);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                      ],
                    );
                  }
                );
              }
              else{
                return AlertDialog(
                title: Text(labelsErrorMessage),
              );
              }
            } else {
              return AlertDialog(
                title: const Text('No Labels Available'),
                content: const Text('The labels could not be fetched.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Future<void> deleteItem(String id) async {
    final String url = 'http://ipaddress:8000/delete/$id';
    try {
      await http.post(Uri.parse(url));
    } catch (e) {
      dev.log("Error deleting item: $id");
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
            if(closetErrorMessage!='')
              Text(
                '$closetErrorMessage',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showImagePopup(imagePaths[index], imageIDs[index]);
                      },
                      child: Image.network(
                        imagePaths[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      if(currentPage>0){
                        currentPage -= 1;
                      }
                      fetchImagePaths(currentPage);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                    backgroundColor: Colors.green,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      if (!lastPage){
                        currentPage += 1;
                      }
                      fetchImagePaths(currentPage);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                    backgroundColor: Colors.green,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ]
        )
      )
    );
  }
}
