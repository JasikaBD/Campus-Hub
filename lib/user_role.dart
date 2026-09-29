class UserRole {
  final bool isCR;
  final String department;
  final String year;
  final String semester;
  final String section;
  final String email;

  UserRole({
    required this.isCR,
    required this.department,
    required this.year,
    required this.semester,
    required this.section,
    required this.email,
  });

  String get classId => '${department}_${year}_${semester}_$section';

  String get classLabel {
    final dept = department.toUpperCase();
    final sec = section.replaceFirst('sec', 'Sec-').toUpperCase();
    return '$dept | $year.$semester $sec';
  }

  static UserRole? fromEmail(String email) {
    final lower = email.trim().toLowerCase();
    final atIndex = lower.indexOf('@');
    if (atIndex == -1) return null;
    final local = lower.substring(0, atIndex);
    final parts = local.split('.');
    if (parts.length < 5) return null;
    final role = parts[0];
    if (role != 'cr' && role != 'student') return null;
    final dept    = parts[1];
    final year    = parts[2];
    final sem     = parts[3];
    final section = parts.sublist(4).join('.');
    return UserRole(
      isCR:       role == 'cr',
      department: dept,
      year:       year,
      semester:   sem,
      section:    section,
      email:      email.trim(),
    );
  }
}