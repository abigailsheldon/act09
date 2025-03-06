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
    // Initialize folders list
    _refreshFolders();
  }

  // Refreshes the folder list by querying the DB
  void _refreshFolders() {
    setState(() {
      foldersFuture = DatabaseHelper.instance.queryAllFolders();
    });
  }

  // Add folder with provided folder name
  Future<void> _addFolder(String folderName) async {
    // Insert a new folder into DB
    await DatabaseHelper.instance.insertFolder({ DatabaseHelper.columnFolderName: folderName });
    // Refresh the folder list
    _refreshFolders();
  }

  // Delete folder given id
  Future<void> _deleteFolder(int folderId) async {
    await DatabaseHelper.instance.deleteFolder(folderId);
    _refreshFolders();
  }

  // Displays dialog to let the user input folder name
  void _showAddFolderDialog() {
    // Create a controller for the text field
    TextEditingController folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Folder"),
          content: TextField(
            controller: folderController,
            decoration: const InputDecoration(hintText: "Folder Name"),
          ),
          actions: [
            // Cancel button to dismiss the dialog.
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            // Add button to confirm adding the new folder.
            TextButton(
              child: const Text("Add"),
              onPressed: () async {
                String folderName = folderController.text.trim();
                if (folderName.isNotEmpty) {
                  await _addFolder(folderName);
                  Navigator.pop(context); // Close the dialog.
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          // Icon button to trigger add folder dialog
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddFolderDialog,
          ),
        ],
      ),

        body: FutureBuilder<List<Map<String, dynamic>>>(
        future: foldersFuture,
        builder: (context, snapshot) {
          // Show loading spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Display the list of folders
          if (snapshot.hasData) {
            final folders = snapshot.data!;
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                
                // Extract the folder id and name from map
                int folderId = folder[DatabaseHelper.columnFolderId];
                String folderName = folder[DatabaseHelper.columnFolderName];
                
                return Dismissible(
                  key: Key(folderId.toString()),
                  background: Container(color: Colors.red),
                  
                  // When the folder is swiped away, delete it
                  onDismissed: (direction) async {
                    await _deleteFolder(folderId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Folder '$folderName' deleted"))
                    );
                  },
                  
                  child: ListTile(
                    title: Text(folderName),
                    trailing: const Icon(Icons.arrow_forward),
                    
                    // Navigate to the CardsScreen when a folder is tapped
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
                  ),
                );
              },
            );
          }
          // If no folders are found, display message
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
  
  }

  // Method to delete card given id
  Future<void> _deleteCard(int cardId) async {
    // Call the deleteCard method from the DatabaseHelper to remove card
    await DatabaseHelper.instance.deleteCard(cardId);
    // Refresh the cards list to update UI
    _refreshCards();
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