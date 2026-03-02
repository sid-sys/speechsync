import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/note_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  
  // Web-only in-memory storage fallback
  final List<NoteModel> _webInMemoryNotes = [];

  DatabaseService._init();

  Future<Database?> get database async {
    if (kIsWeb || (Platform.isWindows)) return null; 
    if (_database != null) return _database!;
    _database = await _initDB('speechsync.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  translatedContent TEXT,
  tone TEXT
)
''');
  }

  Future<void> insertNote(NoteModel note) async {
    if (kIsWeb || Platform.isWindows) {
      _webInMemoryNotes.insert(0, note);
      return;
    }
    final db = await instance.database;
    if (db != null) {
      await db.insert('notes', note.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<NoteModel>> getNotes() async {
    if (kIsWeb || Platform.isWindows) {
      return List.from(_webInMemoryNotes);
    }
    final db = await instance.database;
    if (db == null) return [];
    final result = await db.query('notes', orderBy: 'createdAt DESC');
    return result.map((json) => NoteModel.fromJson(json)).toList();
  }

  Future<void> deleteNote(String id) async {
    if (kIsWeb || Platform.isWindows) {
      _webInMemoryNotes.removeWhere((n) => n.id == id);
      return;
    }
    final db = await instance.database;
    if (db != null) {
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
