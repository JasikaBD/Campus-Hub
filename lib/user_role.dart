class UserRole {
  final bool isCR;
  final String department;
  final String year;
  final String semester;
  final String section;
  final String email;
  final String fullName;
  final String studentId;

  final String? savedClassId;

  UserRole({
    required this.isCR,
    required this.department,
    required this.year,
    required this.semester,
    required this.section,
    required this.email,
    this.fullName = '',
    this.studentId = '',
    this.savedClassId,
  });

  /// Normalizes cohort component (e.g., '2nd Year' -> '2', 'Section A' -> 'a')
  static String normalizeCohortPart(String value) {
    String s = value.trim().toLowerCase();
    // If it has digits (e.g. 2nd Year -> 2, 1st Semester -> 1), extract the number
    final digitMatch = RegExp(r'\d+').firstMatch(s);
    if (digitMatch != null) {
      return digitMatch.group(0)!;
    }
    // Otherwise clean words like 'section', 'sec' and keep letters
    s = s.replaceAll('section', '').replaceAll('sec', '');
    s = s.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return s;
  }

  /// Generates a standardized class ID so all students and CR in the same
  /// department, year, semester, and section share the exact same data.
  static String buildClassId({
    required String department,
    required String year,
    required String semester,
    required String section,
  }) {
    String d = department.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    String y = normalizeCohortPart(year);
    String sem = normalizeCohortPart(semester);
    String sec = normalizeCohortPart(section);

    if (d.isEmpty) d = 'cse';
    if (y.isEmpty) y = '1';
    if (sem.isEmpty) sem = '1';
    if (sec.isEmpty) sec = 'a';

    return '${d}_${y}_${sem}_$sec';
  }

  String get classId {
    if (savedClassId != null && savedClassId!.trim().isNotEmpty) {
      return savedClassId!.trim().toLowerCase();
    }
    return buildClassId(
      department: department,
      year: year,
      semester: semester,
      section: section,
    );
  }

  String get classLabel {
    final dept = department.trim().toUpperCase();
    final y = year.contains('Year') ? year : '$year Year';
    final sem = semester.contains('Sem') ? semester : '$semester Sem';
    final sec = section.toUpperCase().contains('SEC')
        ? section.toUpperCase()
        : 'Sec-$section'.toUpperCase();
    return '$dept | $y | $sem | $sec';
  }

  Map<String, dynamic> toMap() {
    return {
      'isCR': isCR,
      'department': department,
      'year': year,
      'semester': semester,
      'section': section,
      'email': email,
      'fullName': fullName,
      'studentId': studentId,
      'classId': classId,
    };
  }

  factory UserRole.fromFirestore(Map<String, dynamic> data, {String email = ''}) {
    final studentType = (data['studentType'] ?? '').toString().toLowerCase();
    final bool isCR = data['isCR'] == true ||
        studentType.contains('cr') ||
        studentType.contains('admin');

    final dept = (data['department'] ?? '').toString().trim();
    final yr = (data['year'] ?? '').toString().trim();
    final sem = (data['semester'] ?? '').toString().trim();
    final sec = (data['section'] ?? '').toString().trim();
    final rawClassId = (data['classId'] ?? '').toString().trim();

    return UserRole(
      isCR: isCR,
      department: dept.isNotEmpty ? dept : 'CSE',
      year: yr.isNotEmpty ? yr : '1st Year',
      semester: sem.isNotEmpty ? sem : '1st Semester',
      section: sec.isNotEmpty ? sec : 'Section A',
      email: (data['email'] ?? email).toString(),
      fullName: (data['fullName'] ?? '').toString(),
      studentId: (data['studentId'] ?? '').toString(),
      savedClassId: rawClassId.isNotEmpty ? rawClassId : null,
    );
  }

  static UserRole? fromEmail(String email) {
    final lower = email.trim().toLowerCase();
    final atIndex = lower.indexOf('@');
    if (atIndex == -1) return null;
    final local = lower.substring(0, atIndex);
    final parts = local.split('.');
    if (parts.length < 4) return null;
    final role = parts[0];
    if (role != 'cr' && role != 'student') return null;
    final dept = parts[1];
    String year;
    String sem;
    String section;
    if (parts.length == 4) {
      year = parts[2];
      sem = '';
      section = parts[3];
    } else {
      year = parts[2];
      sem = parts[3];
      section = parts.sublist(4).join('.');
    }
    return UserRole(
      isCR: role == 'cr',
      department: dept,
      year: year,
      semester: sem,
      section: section,
      email: email.trim(),
    );
  }
}