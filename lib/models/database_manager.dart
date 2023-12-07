// import 'package:sqflite/sqflite.dart';
//
// class DatabaseManager {
//   static Database? _database;
//
//   static Future<Database> get database async {
//     if (_database != null) {
//       return _database!;
//     }
//
//     _database = await openDatabase(
//       'analysis_db.db',
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE gg (
//             id INTEGER PRIMARY KEY
//           )
//         ''');
//       },
//     );
//
//     return _database!;
//   }
// }
