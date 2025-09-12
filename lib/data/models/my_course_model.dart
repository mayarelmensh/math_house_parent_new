import 'dart:convert';

// Chapter Model
class MyChapter {
  final int id;
  final String chapterName;
  final String image;
  final String? teacher;

  MyChapter({
    required this.id,
    required this.chapterName,
    required this.image,
    this.teacher,
  });

  // Factory constructor to create a MyChapter from JSON
  factory MyChapter.fromJson(Map<String, dynamic> json) {
    return MyChapter(
      id: json['id'] as int,
      chapterName: json['chapter_name'] as String,
      image: json['image'] as String,
      teacher: json['teacher'] as String?,
    );
  }

  // Convert MyChapter to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_name': chapterName,
      'image': image,
      'teacher': teacher,
    };
  }

  // Create a copy of MyChapter with optional updates
  MyChapter copyWith({
    int? id,
    String? chapterName,
    String? image,
    String? teacher,
  }) {
    return MyChapter(
      id: id ?? this.id,
      chapterName: chapterName ?? this.chapterName,
      image: image ?? this.image,
      teacher: teacher ?? this.teacher,
    );
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyChapter &&
        other.id == id &&
        other.chapterName == chapterName &&
        other.image == image &&
        other.teacher == teacher;
  }

  @override
  int get hashCode => Object.hash(id, chapterName, image, teacher);

  @override
  String toString() {
    return 'MyChapter(id: $id, chapterName: $chapterName, image: $image, teacher: $teacher)';
  }
}

// Course Model
class MyCourse {
  final int id;
  final String courseName;
  final String courseDescription;
  final String? teacher;
  final String image;
  final List<MyChapter> chapters;

  MyCourse({
    required this.id,
    required this.courseName,
    required this.courseDescription,
    this.teacher,
    required this.image,
    required this.chapters,
  });

  // Factory constructor to create a MyCourse from JSON
  factory MyCourse.fromJson(Map<String, dynamic> json) {
    return MyCourse(
      id: json['id'] as int,
      courseName: json['course_name'] as String,
      courseDescription: json['course_des'] as String,
      teacher: json['teacher'] as String?,
      image: json['image'] as String,
      chapters: (json['chapters'] as List<dynamic>)
          .map((chapterJson) => MyChapter.fromJson(chapterJson))
          .toList(),
    );
  }

  // Convert MyCourse to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
      'course_des': courseDescription,
      'teacher': teacher,
      'image': image,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    };
  }

  // Create a copy of MyCourse with optional updates
  MyCourse copyWith({
    int? id,
    String? courseName,
    String? courseDescription,
    String? teacher,
    String? image,
    List<MyChapter>? chapters,
  }) {
    return MyCourse(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      courseDescription: courseDescription ?? this.courseDescription,
      teacher: teacher ?? this.teacher,
      image: image ?? this.image,
      chapters: chapters ?? this.chapters,
    );
  }

  // Get unique chapters (removing duplicates by id)
  List<MyChapter> get uniqueChapters {
    final Map<int, MyChapter> uniqueMap = {};
    for (final chapter in chapters) {
      uniqueMap[chapter.id] = chapter;
    }
    return uniqueMap.values.toList();
  }

  // Count of unique chapters
  int get uniqueChapterCount => uniqueChapters.length;

  // Check if the course has a valid description
  bool get hasDescription =>
      courseDescription.isNotEmpty && courseDescription != '.';

  // Check if the course has a teacher
  bool get hasTeacher => teacher != null && teacher!.isNotEmpty;

  // Search chapters by query
  List<MyChapter> searchChapters(String query) {
    if (query.isEmpty) return uniqueChapters;
    return uniqueChapters
        .where((chapter) =>
        chapter.chapterName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyCourse &&
        other.id == id &&
        other.courseName == courseName &&
        other.courseDescription == courseDescription &&
        other.teacher == teacher &&
        other.image == image &&
        _listEquals(other.chapters, chapters);
  }

  @override
  int get hashCode =>
      Object.hash(id, courseName, courseDescription, teacher, image, chapters);

  @override
  String toString() {
    return 'MyCourse(id: $id, courseName: $courseName, courseDescription: $courseDescription, teacher: $teacher, image: $image, chaptersCount: ${uniqueChapterCount})';
  }
}

// Course Response Model
class MyCourseResponse {
  final List<MyCourse> courses;

  MyCourseResponse({required this.courses});

  // Factory constructor to create a MyCourseResponse from JSON
  factory MyCourseResponse.fromJson(Map<String, dynamic> json) {
    return MyCourseResponse(
      courses: (json['courses'] as List<dynamic>)
          .map((courseJson) => MyCourse.fromJson(courseJson))
          .toList(),
    );
  }

  // Factory constructor to create a MyCourseResponse from JSON string
  factory MyCourseResponse.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return MyCourseResponse.fromJson(json);
  }

  // Convert MyCourseResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'courses': courses.map((course) => course.toJson()).toList(),
    };
  }

  // Convert MyCourseResponse to JSON string
  String toJsonString() => jsonEncode(toJson());

  // Create a copy of MyCourseResponse with optional updates
  MyCourseResponse copyWith({List<MyCourse>? courses}) {
    return MyCourseResponse(courses: courses ?? this.courses);
  }

  // Search courses by query
  List<MyCourse> searchCourses(String query) {
    if (query.isEmpty) return courses;
    return courses
        .where((course) =>
    course.courseName.toLowerCase().contains(query.toLowerCase()) ||
        course.courseDescription.toLowerCase().contains(query.toLowerCase()) ||
        (course.teacher?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
  }

  // Filter courses by teacher
  List<MyCourse> getCoursesByTeacher(String teacherName) {
    return courses.where((course) => course.teacher == teacherName).toList();
  }

  // Get course by ID
  MyCourse? getCourseById(int courseId) {
    try {
      return courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }

  // Get all unique teachers
  List<String> get allTeachers {
    final Set<String> teacherSet = {};
    for (final course in courses) {
      if (course.hasTeacher) {
        teacherSet.add(course.teacher!);
      }
      for (final chapter in course.uniqueChapters) {
        if (chapter.teacher != null && chapter.teacher!.isNotEmpty) {
          teacherSet.add(chapter.teacher!);
        }
      }
    }
    return teacherSet.toList()..sort();
  }

  // Get course statistics
  Map<String, dynamic> get statistics {
    int totalCourses = courses.length;
    int totalChapters = 0;
    int coursesWithTeacher = 0;
    int coursesWithoutTeacher = 0;
    int coursesWithDescription = 0;

    for (final course in courses) {
      totalChapters += course.uniqueChapterCount;
      if (course.hasTeacher) {
        coursesWithTeacher++;
      } else {
        coursesWithoutTeacher++;
      }
      if (course.hasDescription) {
        coursesWithDescription++;
      }
    }

    return {
      'totalCourses': totalCourses,
      'totalChapters': totalChapters,
      'coursesWithTeacher': coursesWithTeacher,
      'coursesWithoutTeacher': coursesWithoutTeacher,
      'coursesWithDescription': coursesWithDescription,
      'uniqueTeachers': allTeachers.length,
    };
  }

  // Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyCourseResponse && _listEquals(other.courses, courses);
  }

  @override
  int get hashCode => courses.hashCode;

  @override
  String toString() {
    return 'MyCourseResponse(coursesCount: ${courses.length})';
  }
}

// Helper function to compare lists
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int index = 0; index < a.length; index++) {
    if (a[index] != b[index]) return false;
  }
  return true;
}