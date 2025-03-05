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
    // Create the folders table.
    await db.execute('''
      CREATE TABLE $folderTable (
        $columnFolderId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnFolderName TEXT NOT NULL,
        $columnFolderTimeStamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create the cards table
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



// Helper methods
// Inserts a row in the database where each key in the
//Map is a column name
// and the value is the column value. The return value
//is the id of the
// inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    return await _db.insert(table, row);
  }

// All of the rows are returned as a list of maps, where each map is
// a key-value list of columns.
// Returns all rows form the db as a list of maps.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return await _db.query(table);
  }

// All of the methods (insert, query, update, delete) can also be done using
// raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

// We are assuming here that the id column in the map is set. The other
// column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

// Deletes the row specified by the id. The number of affected rows is
// returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    return await _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

// Query a specific row by ID
  Future<Map<String, dynamic>?> queryRowById(int id) async {
    final results = await _db.query(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

// Delete all records from db
  Future<int> deleteAllRecords() async {
    return await _db.delete(table);
  }

}
