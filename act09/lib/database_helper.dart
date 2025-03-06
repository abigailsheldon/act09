import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';

// For directory
import 'dart:io';

class DatabaseHelper {
 
  // Private constructor to ensure only one instance created
  DatabaseHelper._privateConstructor();
  // DatabaseHelper that can be accessed globally
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // -- DB Information --
  static const _databaseName = "CardOrganizer.db";
  static const _databaseVersion = 1;
  
  // -- Table and Column definitions --
  // Folder table
  static const folderTable = 'folders';
  static const columnFolderId = '_id';
  static const columnFolderName = 'name';
  static const columnFolderTimeStamp = 'timeStamp';
  
  // Card table
  static const cardTable = 'cards';
  static const columnCardId = '_id';
  static const columnCardName = 'name';
  static const columnCardSuit = 'suit';
  static const columnCardImageUrl = 'imageUrl';
  static const columnCardFolderId = 'folderId';

  // Private variable to hold DB instance
  Database? _db;
 // Map variable that contains the url for all card images
 static const Map<String,String> cardUrl = {
    'Ace of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/01_of_diamonds_A.svg/309px-01_of_diamonds_A.svg.png",
    'Two of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/02_of_diamonds.svg/309px-02_of_diamonds.svg.png",
    'Three of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/03_of_diamonds.svg/309px-03_of_diamonds.svg.png",
    'Four of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/04_of_diamonds.svg/309px-04_of_diamonds.svg.png",
    'Five of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/05_of_diamonds.svg/309px-05_of_diamonds.svg.png",
    'Six of Diamonds':  "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/06_of_diamonds.svg/309px-06_of_diamonds.svg.png",
    'Seven of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/07_of_diamonds.svg/309px-07_of_diamonds.svg.png" ,
    'Eight of Diamonds':  "https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/08_of_diamonds.svg/416px-08_of_diamonds.svg.png",
    'Nine of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/09_of_diamonds.svg/309px-09_of_diamonds.svg.png", 
    'Jack of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Jack_of_diamonds_fr.svg/334px-Jack_of_diamonds_fr.svg.png",
    'Queen of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Queen_of_diamonds_fr.svg/309px-Queen_of_diamonds_fr.svg.png",
    'King of Diamonds': "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/King_of_diamonds_fr.svg/309px-King_of_diamonds_fr.svg.png",
    'Ace of clubs': "https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/01_of_clubs_A.svg/371px-01_of_clubs_A.svg.png",
    'Two of clubs': "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/02_of_clubs.svg/371px-02_of_clubs.svg.png",
    'Three of club': "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/03_of_clubs.svg/371px-03_of_clubs.svg.png",
    'Four of club': "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/04_of_clubs.svg/371px-04_of_clubs.svg.png",
    'Five of club': "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/05_of_clubs.svg/371px-05_of_clubs.svg.png",
    'Six of club':  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/06_of_clubs.svg/371px-06_of_clubs.svg.png",
    'Seven of club': "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/07_of_clubs.svg/371px-07_of_clubs.svg.png" ,
    'Eight of club':  "https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/08_of_clubs.svg/371px-08_of_clubs.svg.png",
    'Nine of club': "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/09_of_clubs.svg/371px-09_of_clubs.svg.png" ,
    'Ten of club':  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/10_of_clubs_-_David_Bellot.svg/371px-10_of_clubs_-_David_Bellot.svg.png", 
    'Jack of club': "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Queen_of_clubs_fr.svg/371px-Queen_of_clubs_fr.svg.png",
    'Queen of club': "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Queen_of_clubs_fr.svg/371px-Queen_of_clubs_fr.svg.png",
    'King of club': "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/King_of_clubs_fr.svg/371px-King_of_clubs_fr.svg.png",
    'Ace of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/01_of_hearts_A.svg/288px-01_of_hearts_A.svg.png",
    'Two of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/02_of_hearts.svg/288px-02_of_hearts.svg.png",
    'Three of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/03_of_hearts.svg/288px-03_of_hearts.svg.png",
    'Four of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/04_of_hearts.svg/288px-04_of_hearts.svg.png",
    'Five of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/05_of_hearts.svg/288px-05_of_hearts.svg.png",
    'Six of hearts':  "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/06_of_hearts.svg/288px-06_of_hearts.svg.png",
    'Seven of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/07_of_hearts.svg/288px-07_of_hearts.svg.png" ,
    'Eight of hearts':  "https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/08_of_hearts.svg/288px-08_of_hearts.svg.png",
    'Nine of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/09_of_hearts.svg/288px-09_of_hearts.svg.png" ,
    'Ten of hearts':  "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/10_of_hearts_-_David_Bellot.svg/288px-10_of_hearts_-_David_Bellot.svg.png", 
    'Jack of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Jack_of_hearts_fr.svg/288px-Jack_of_hearts_fr.svg.png",
    'Queen of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Queen_of_hearts_fr.svg/288px-Queen_of_hearts_fr.svg.png",
    'King of hearts': "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/King_of_hearts_fr.svg/288px-King_of_hearts_fr.svg.png",
    'Ace of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/01_of_spades_A.svg/371px-01_of_spades_A.svg.png",
    'Two of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/02_of_spades.svg/371px-02_of_spades.svg.png",
    'Three of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/03_of_spades.svg/371px-03_of_spades.svg.png",
    'Four of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/04_of_spades.svg/371px-04_of_spades.svg.png",
    'Five of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/05_of_spades.svg/371px-05_of_spades.svg.png",
    'Six of spades':  "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/06_of_spades.svg/371px-06_of_spades.svg.png",
    'Seven of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/07_of_spades.svg/371px-07_of_spades.svg.png" ,
    'Eight of spades':  "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/08_of_spades.svg/371px-08_of_spades.svg.png",
    'Nine of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/09_of_spades.svg/371px-09_of_spades.svg.png" ,
    'Ten of spades':  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/10_of_spades_-_David_Bellot.svg/371px-10_of_spades_-_David_Bellot.svg.png", 
    'Jack of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Jack_of_spades_fr.svg/371px-Jack_of_spades_fr.svg.png",
    'Queen of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Queen_of_spades_fr.svg/371px-Queen_of_spades_fr.svg.png",
    'King of spades': "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/King_of_diamonds_fr.svg/309px-King_of_diamonds_fr.svg.png",


 };
  // Return DB instance and initializes if not already created
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Initilizes DB
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    // Builds path to the DB file
    String path = join(documentsDirectory.path, _databaseName);
    // Open DB, create if it doesn't exist
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // When the DB is created for the first time
  Future _onCreate(Database db, int version) async {
    // Create folders table
    await db.execute('''
      CREATE TABLE $folderTable (
        $columnFolderId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnFolderName TEXT NOT NULL,
        $columnFolderTimeStamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    //db.insert(folderTable, values)


    // Create cards table
    await db.execute('''
      CREATE TABLE $cardTable (
        $columnCardId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCardName TEXT NOT NULL,
        $columnCardSuit TEXT NOT NULL,
        $columnCardImageUrl TEXT,
        $columnCardFolderId INTEGER,
        FOREIGN KEY ($columnCardFolderId) REFERENCES $folderTable ($columnFolderId)
      )
    ''');


  // Prepopulate folders table with suits
    List<String> suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    for (var suit in suits) {
      // Insert each suit as a folder.
      await db.insert(folderTable, {columnFolderName: suit});
    }

    // Prepopulate cards table with deck of cards for each suit
    for (var suit in suits) {
      for (int i = 1; i <= 13; i++) {
        // Determine the card name based on its number
        String cardName = (i == 1)
            ? 'Ace'
            : (i == 11)
                ? 'Jack'
                : (i == 12)
                    ? 'Queen'
                    : (i == 13)
                        ? 'King'
                        : '$i';
        
        // FILL THIS WITH URL
        String imageUrl = '';

        // Insert card into the cards table
        await db.insert(cardTable, {
          columnCardName: '$cardName of $suit',
          columnCardSuit: suit,
          columnCardImageUrl: imageUrl,
          columnCardFolderId: null,
        });
      }
    }
  }

  // --- Folders table CRUD ---

  Future<int> insertFolder(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(folderTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllFolders() async {
    Database db = await instance.database;
    return await db.query(folderTable);
  }

  Future<int> updateFolder(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnFolderId];
    return await db.update(folderTable, row,
        where: '$columnFolderId = ?', whereArgs: [id]);
  }

  Future<int> deleteFolder(int id) async {
    Database db = await instance.database;
    return await db.delete(folderTable,
        where: '$columnFolderId = ?', whereArgs: [id]);
  }

  // -- Cards table CRUD --
  // Inserts new card into cards table
  Future<int> insertCard(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(cardTable, row);
  }

  // Retrieves all cards that belong to folder
  Future<List<Map<String, dynamic>>> queryCardsByFolder(int folderId) async {
    Database db = await instance.database;
    return await db.query(
      cardTable,
      // Filter cards by folderId
      where: '$columnCardFolderId = ?', 
      whereArgs: [folderId],
    );
  }

  // Update card's data in the cards table
  Future<int> updateCard(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnCardId]; 
    return await db.update(
      cardTable,
      row,
      // Specify which row to update using id
      where: '$columnCardId = ?', 
      whereArgs: [id],
    );
  }

  // Deletes a card from the cards table using id
  Future<int> deleteCard(int id) async {
    Database db = await instance.database;
    return await db.delete(
      cardTable,
      where: '$columnCardId = ?',
      whereArgs: [id],
    );
  }

}
