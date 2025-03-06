import 'dart:math';

import 'package:flutter/material.dart';
import 'database_helper.dart';

// Main function
void main() async {
  // Widget binding is initialized to use async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the SQLite database
  await DatabaseHelper.instance.database;

  runApp(const CardOrganizerApp());
}

class CardOrganizerApp extends StatelessWidget {
  const CardOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      // Set the initial home screen to the FoldersScreen widget.
      home: const FoldersScreen(),
    );
  }
}

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

    @override
    State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {

  // Eventually holds the list of folders from DB
  late Future<List<Map<String, dynamic>>> foldersFuture;

  @override
  void initState() {
    super.initState();
    // Query all folders from DB
    foldersFuture = DatabaseHelper.instance.queryAllFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with a title for Folders screen
      appBar: AppBar(
        title: const Text('Folders'),
      ),
body: FutureBuilder<List<Map<String, dynamic>>>(
        future: foldersFuture,
        builder: (context, snapshot) {
          
          // While waiting for data, loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Once data available, display list of folders
          if (snapshot.hasData) {
            final folders = snapshot.data!;
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                
                // Extract folder id and name from folder map
                int folderId = folder[DatabaseHelper.columnFolderId];
                String folderName = folder[DatabaseHelper.columnFolderName];

                // Create a list tile for each folder
                return ListTile(
                  title: Text(folderName),
                  trailing: const Icon(Icons.arrow_forward),
                  
                  // When tapped, navigate to CardsScreen for selected folder
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardsScreen(
                          folderId: folderId,
                          folderName: folderName,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
          // If no folders are found, display error message
          return const Center(child: Text('No folders found.'));
        },
      ),
    );
  }
}

// Displays cards inside a folder
class CardsScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  const CardsScreen({super.key, required this.folderId, required this.folderName});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {

  // Eventually holds list of cards
  late Future<List<Map<String, dynamic>>> cardsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the cards for the current folder
    _refreshCards();
  }
  
  // Refreshes cards by querying the DB
  void _refreshCards() {
    setState(() {
      cardsFuture = DatabaseHelper.instance.queryCardsByFolder(widget.folderId);
    });
  }

  // Method to add card to folder
  Future<void> _addCard() async {


    Map<int, String> cardNames = {
  1: 'Ace',
  2: 'Two',
  3: 'Three',
  4: 'Four',
  5: 'Five',
  6: 'Six',
  7: 'Seven',
  8: 'Eight',
  9: 'Nine',
  10: 'Ten',
  11: 'Jack',
  12: 'Queen',
  13: 'King',
};
    
    String suit = widget.folderName;
    String? cardUrl;
    int cardNumber = Random().nextInt(13) + 1;
    if(suit =='Spades'){
      cardUrl = DatabaseHelper.spadeUrl[cardNumber];
    }
    else if (suit == 'Clubs'){
      cardUrl = DatabaseHelper.clubsUrl[cardNumber];
    }
     else if (suit == 'Hearts'){
      cardUrl = DatabaseHelper.heartsUrl[cardNumber];
    }
    else{
      cardUrl= DatabaseHelper.diamondUrl[cardNumber];
    }

    Map<String, dynamic> row = {
        DatabaseHelper.columnFolderId: widget.folderId,
        DatabaseHelper.columnCardSuit: suit,
        DatabaseHelper.columnCardImageUrl: cardUrl,
        DatabaseHelper.columnCardName:  cardNames[cardNumber]

      //DatabaseHelper.columnName: 'Bob',
      //DatabaseHelper.columnAge: 23,
    };
    await DatabaseHelper.instance.insertCard(row);
    //debugPrint('Inserted row id: $insertedId');
  
  }

  // Method to delete card given id
  Future<void> _deleteCard(int cardId) async {
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      
      // FutureBuilder waits for cards data
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cardsFuture,
        builder: (context, snapshot) {
          
          // While waiting, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Once data available, display cards in a grid
          if (snapshot.hasData) {
            final cards = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                // 3 columns
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                return GestureDetector(
                  
                  // On long press, delete card
                  onLongPress: () async {
                    await _deleteCard(card[DatabaseHelper.columnCardId]);
                  },
                  
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        
                        // Display card image using Image.network.
                        Expanded(
                          child: Image.network(
                            card[DatabaseHelper.columnCardImageUrl],
                            fit: BoxFit.cover,
                          ),
                        ),
                        
                        // Display the card's name below the image.
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            card[DatabaseHelper.columnCardName],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          // If no cards in folder, display error message
          return const Center(child: Text('No cards in this folder.'));
        },
      ),
      
      // Floating action button to add a new card
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: const Icon(Icons.add),
      ),
    );
  }
}