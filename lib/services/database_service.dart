import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'chiyuhada_vita_buddy.db');
    return await openDatabase(
      path,
      version: 4,  // 즐겨찾기 및 최근 음식 기능 추가
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 음식 테이블 생성
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories_per_100g REAL NOT NULL,
        category TEXT,
        is_user_added INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 체중 기록 테이블 생성
    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 음식 섭취 기록 테이블 생성
    await db.execute('''
      CREATE TABLE food_intakes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER,
        quantity REAL NOT NULL,
        calories REAL NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (food_id) REFERENCES foods (id)
      )
    ''');

    // 운동 기록 테이블 생성
    await db.execute('''
      CREATE TABLE exercise_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        calories_burned REAL NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        source TEXT DEFAULT 'manual',
        exercise_type TEXT,
        distance_meters REAL,
        average_heart_rate INTEGER,
        steps INTEGER,
        external_id TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 헬스 동기화 로그 테이블 생성
    await db.execute('''
      CREATE TABLE health_sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        platform TEXT NOT NULL,
        data_type TEXT NOT NULL,
        last_sync_timestamp TEXT NOT NULL,
        records_synced INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 즐겨찾기 테이블 생성
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        food_id INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (food_id) REFERENCES foods (id)
      )
    ''');

    // 기본 음식 데이터 삽입
    await _insertDefaultFoods(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 버전 1, 2 → 3: 운동 기록 기능 추가 및 안정화
    if (oldVersion < 3) {
      // 1. exercise_records 테이블이 존재하는지 확인
      // 1. exercise_records 테이블이 존재하는지 확인
      var tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='exercise_records'"
      );

      if (tableExists.isEmpty) {
        // 테이블이 없으면 생성 (새 스키마로)
        await db.execute('''
          CREATE TABLE exercise_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise_name TEXT NOT NULL,
            duration_minutes INTEGER NOT NULL,
            calories_burned REAL NOT NULL,
            date TEXT NOT NULL,
            time TEXT NOT NULL,
            source TEXT DEFAULT 'manual',
            exercise_type TEXT,
            distance_meters REAL,
            average_heart_rate INTEGER,
            steps INTEGER,
            external_id TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      } else {
        // 테이블이 이미 있으면 컬럼 추가 (기존 사용자 마이그레이션)
        // 컬럼 존재 여부 확인 후 추가하는 것이 안전하지만, 
        // 여기서는 try-catch로 감싸서 중복 추가 에러 방지
        try { await db.execute('ALTER TABLE exercise_records ADD COLUMN source TEXT DEFAULT "manual"'); } catch (e) { /* ignore */ }
        try { await db.execute('ALTER TABLE exercise_records ADD COLUMN exercise_type TEXT'); } catch (e) { /* ignore */ }
        try { await db.execute('ALTER TABLE exercise_records ADD COLUMN distance_meters REAL'); } catch (e) { /* ignore */ }
        try { await db.execute('ALTER TABLE exercise_records ADD COLUMN average_heart_rate INTEGER'); } catch (e) { /* ignore */ }
        try { await db.execute('ALTER TABLE exercise_records ADD COLUMN steps INTEGER'); } catch (e) { /* ignore */ }
        try { await db.execute('ALTER TABLE exercise_records ADD COLUMN external_id TEXT'); } catch (e) { /* ignore */ }
      }
      
      // health_sync_log 테이블 생성 (존재하지 않을 경우)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS health_sync_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          platform TEXT NOT NULL,
          data_type TEXT NOT NULL,
          last_sync_timestamp TEXT NOT NULL,
          records_synced INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    }
    
    // 버전 3 → 4: 즐겨찾기 기능 추가
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          food_id INTEGER NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (food_id) REFERENCES foods (id)
        )
      ''');
    }
  }

  Future<void> _insertDefaultFoods(Database db) async {
    List<Map<String, dynamic>> defaultFoods = [
      {'name': '사과', 'calories_per_100g': 52.0, 'category': '과일'},
      {'name': '바나나', 'calories_per_100g': 89.0, 'category': '과일'},
      {'name': '쌀밥', 'calories_per_100g': 130.0, 'category': '주식'},
      {'name': '김치찌개', 'calories_per_100g': 45.0, 'category': '국'},
      {'name': '된장찌개', 'calories_per_100g': 38.0, 'category': '국'},
      {'name': '불고기', 'calories_per_100g': 180.0, 'category': '육류'},
      {'name': '생선구이', 'calories_per_100g': 120.0, 'category': '어류'},
      {'name': '김치', 'calories_per_100g': 15.0, 'category': '반찬'},
      {'name': '콩나물', 'calories_per_100g': 16.0, 'category': '반찬'},
      {'name': '시금치', 'calories_per_100g': 20.0, 'category': '야채'},
      {'name': '우유', 'calories_per_100g': 61.0, 'category': '유제품'},
      {'name': '요거트', 'calories_per_100g': 59.0, 'category': '유제품'},
      {'name': '빵', 'calories_per_100g': 265.0, 'category': '제과'},
      {'name': '케이크', 'calories_per_100g': 257.0, 'category': '제과'},
      {'name': '초콜릿', 'calories_per_100g': 546.0, 'category': '과자'},
      {'name': '감자칩', 'calories_per_100g': 536.0, 'category': '과자'},
      {'name': '콜라', 'calories_per_100g': 42.0, 'category': '음료'},
      {'name': '주스', 'calories_per_100g': 49.0, 'category': '음료'},
      {'name': '커피', 'calories_per_100g': 1.0, 'category': '음료'},
      {'name': '녹차', 'calories_per_100g': 1.0, 'category': '음료'},
    ];

    for (var food in defaultFoods) {
      await db.insert('foods', food);
    }
  }

  // 음식 관련 메서드들
  Future<List<Map<String, dynamic>>> getFoods({
    String? category,
    String? searchQuery,
  }) async {
    Database db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null && category.isNotEmpty) {
      whereClause += 'category = ?';
      whereArgs.add(category);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'name LIKE ?';
      whereArgs.add('%$searchQuery%');
    }

    return await db.query(
      'foods',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'name ASC',
    );
  }

  Future<int> addFood(
    String name,
    double caloriesPer100g, {
    String? category,
  }) async {
    Database db = await database;
    return await db.insert('foods', {
      'name': name,
      'calories_per_100g': caloriesPer100g,
      'category': category ?? '기타',
      'is_user_added': 1,
    });
  }

  // 체중 기록 관련 메서드들
  Future<List<Map<String, dynamic>>> getWeightRecords({int? limit}) async {
    Database db = await database;
    return await db.query('weight_records', orderBy: 'date DESC', limit: limit);
  }

  Future<int> addWeightRecord(double weight, {String? notes}) async {
    Database db = await database;
    String today = DateTime.now().toIso8601String().split('T')[0];
    return await db.insert('weight_records', {
      'weight': weight,
      'date': today,
      'notes': notes,
    });
  }

  Future<Map<String, dynamic>?> getLatestWeightRecord() async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'weight_records',
      orderBy: 'date DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // 음식 섭취 기록 관련 메서드들
  Future<List<Map<String, dynamic>>> getFoodIntakesForDate(String date) async {
    Database db = await database;
    return await db.rawQuery(
      '''
      SELECT fi.*, f.name as food_name, f.calories_per_100g
      FROM food_intakes fi
      JOIN foods f ON fi.food_id = f.id
      WHERE fi.date = ?
      ORDER BY fi.time ASC
    ''',
      [date],
    );
  }

  Future<int> addFoodIntake(
    int foodId,
    double quantity,
    double calories,
  ) async {
    Database db = await database;
    String today = DateTime.now().toIso8601String().split('T')[0];
    String now = DateTime.now().toIso8601String();
    return await db.insert('food_intakes', {
      'food_id': foodId,
      'quantity': quantity,
      'calories': calories,
      'date': today,
      'time': now,
    });
  }

  Future<double> getTotalCaloriesForDate(String date) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT SUM(calories) as total
      FROM food_intakes
      WHERE date = ?
    ''',
      [date],
    );

    if (results.isNotEmpty && results.first['total'] != null) {
      return results.first['total'] as double;
    }
    return 0.0;
  }

  Future<void> deleteFoodIntake(int id) async {
    Database db = await database;
    await db.delete('food_intakes', where: 'id = ?', whereArgs: [id]);
  }

  /// 최근 먹은 음식 (고유 음식 목록, 중복 제거)
  /// 저장된 모든 음식의 고유 카테고리 목록을 조회합니다.
  Future<List<String>> getUniqueCategories() async {
    final db = await database;
    final result = await db.rawQuery('SELECT DISTINCT category FROM foods WHERE category IS NOT NULL ORDER BY category');
    return result.map((row) => row['category'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentFoods({int days = 7}) async {
    Database db = await database;
    DateTime startDate = DateTime.now().subtract(Duration(days: days));
    String startDateStr = startDate.toIso8601String().split('T')[0];
    
    // 최근 N일 내에 먹은 고유한 음식들, 가장 최근 섭취 시간 기준 정렬
    return await db.rawQuery('''
      SELECT DISTINCT
        f.id,
        f.name,
        f.calories_per_100g,
        f.category,
        MAX(fi.created_at) as last_eaten,
        COUNT(fi.id) as eat_count
      FROM foods f
      INNER JOIN food_intakes fi ON f.id = fi.food_id
      WHERE fi.date >= ?
      GROUP BY f.id
      ORDER BY last_eaten DESC
      LIMIT 20
    ''', [startDateStr]);
  }

  /// 즐겨찾기 추가
  Future<int> addFavorite(int foodId) async {
    Database db = await database;
    
    // 이미 즐겨찾기인지 확인
    List<Map<String, dynamic>> existing = await db.query(
      'favorites',
      where: 'food_id = ?',
      whereArgs: [foodId],
    );
    
    if (existing.isNotEmpty) {
      return existing.first['id'] as int; // 이미 존재하면 기존 ID 반환
    }
    
    return await db.insert('favorites', {
      'food_id': foodId,
    });
  }

  /// 즐겨찾기 제거
  Future<void> removeFavorite(int foodId) async {
    Database db = await database;
    await db.delete('favorites', where: 'food_id = ?', whereArgs: [foodId]);
  }

  /// 즐겨찾기 목록 조회
  Future<List<Map<String, dynamic>>> getFavorites() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT 
        f.id,
        f.name,
        f.calories_per_100g,
        f.category,
        fav.created_at as favorited_at
      FROM favorites fav
      INNER JOIN foods f ON fav.food_id = f.id
      ORDER BY fav.created_at DESC
    ''');
  }

  /// 특정 음식이 즐겨찾기인지 확인
  Future<bool> isFavorite(int foodId) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'favorites',
      where: 'food_id = ?',
      whereArgs: [foodId],
    );
    return results.isNotEmpty;
  }

  // 운동 기록 관련 메서드들
  Future<int> addExerciseRecord(
    String exerciseName,
    int durationMinutes,
    double caloriesBurned,
  ) async {
    Database db = await database;
    String today = DateTime.now().toIso8601String().split('T')[0];
    String now = DateTime.now().toIso8601String();
    return await db.insert('exercise_records', {
      'exercise_name': exerciseName,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'date': today,
      'time': now,
    });
  }

  Future<List<Map<String, dynamic>>> getExerciseRecordsForDate(String date) async {
    Database db = await database;
    return await db.query(
      'exercise_records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time ASC',
    );
  }

  Future<double> getTotalBurnedCaloriesForDate(String date) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT SUM(calories_burned) as total
      FROM exercise_records
      WHERE date = ?
    ''',
      [date],
    );

    if (results.isNotEmpty && results.first['total'] != null) {
      return results.first['total'] as double;
    }
    return 0.0;
  }

  Future<void> deleteExerciseRecord(int id) async {
    Database db = await database;
    await db.delete('exercise_records', where: 'id = ?', whereArgs: [id]);
  }

  // 📊 히스토리 요약 데이터 가져오기 (섭취, 소비, 체중 병합)
  Future<List<Map<String, dynamic>>> getDailySummaries({int limit = 7}) async {
    Database db = await database;
    
    // 1. 날짜별 섭취 칼로리
    final intakeResults = await db.rawQuery('''
      SELECT date, SUM(calories) as total_intake
      FROM food_intakes
      GROUP BY date
      ORDER BY date DESC
      LIMIT ?
    ''', [limit]);

    // 2. 날짜별 소비 칼로리
    final burnedResults = await db.rawQuery('''
      SELECT date, SUM(calories_burned) as total_burned
      FROM exercise_records
      GROUP BY date
      ORDER BY date DESC
      LIMIT ?
    ''', [limit]);

    // 3. 날짜별 체중 (해당 날짜의 가장 마지막 기록)
    final weightResults = await db.rawQuery('''
      SELECT date, weight
      FROM weight_records
      WHERE id IN (
        SELECT MAX(id)
        FROM weight_records
        GROUP BY date
      )
      ORDER BY date DESC
      LIMIT ?
    ''', [limit]);

    // 4. 데이터 병합 (날짜 기준)
    Map<String, Map<String, dynamic>> mergedData = {};

    // 헬퍼 함수
    void merge(List<Map<String, dynamic>> results, String key) {
      for (var row in results) {
        String date = row['date'] as String;
        if (!mergedData.containsKey(date)) {
          mergedData[date] = {'date': date};
        }
        mergedData[date]![key] = row[key];
      }
    }

    merge(intakeResults, 'total_intake');
    merge(burnedResults, 'total_burned');
    merge(weightResults, 'weight');

    // 리스트로 변환 및 정렬
    List<Map<String, dynamic>> summaryList = mergedData.values.toList();
    summaryList.sort((a, b) => b['date'].compareTo(a['date'])); // 최신순 정렬

    return summaryList;
  }

  Future<void> close() async {
    Database? db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
