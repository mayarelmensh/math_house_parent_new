// Model for the student_data object
class StudentData {
  final String? nickName; // Nullable للتعامل مع قيم null
  final String? grade; // Nullable للتعامل مع قيم null
  final String? category; // Nullable للتعامل مع قيم null

  StudentData({
    this.nickName,
    this.grade,
    this.category,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      nickName: json['nick_name'] as String?,
      grade: json['grade']?.toString(), // تحويل إلى String لو كان int
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nick_name': nickName,
      'grade': grade,
      'category': category,
    };
  }
}

// Model for live_details, question_details, and exam_details objects
class Detail {
  final String? number; // Nullable وString للتعامل مع int أو String
  final String? course; // Nullable للتعامل مع null

  Detail({this.number, this.course});

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      number: json['number']?.toString(), // تحويل إلى String لو كان int
      course: json['course'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'course': course,
    };
  }
}

// Main model for the entire response
class StudentResponse {
  final StudentData? studentData; // Nullable للتعامل مع null
  final List<Detail>? liveDetails; // Nullable للتعامل مع null
  final List<Detail>? questionDetails; // Nullable للتعامل مع null
  final List<Detail>? examDetails; // Nullable للتعامل مع null
  final int? questions; // Nullable للتعامل مع null
  final int? exam; // Nullable للتعامل مع null
  final int? lives; // Nullable للتعامل مع null
  final int? notifications; // Nullable للتعامل مع null

  StudentResponse({
    this.studentData,
    this.liveDetails,
    this.questionDetails,
    this.examDetails,
    this.questions,
    this.exam,
    this.lives,
    this.notifications,
  });

  factory StudentResponse.fromJson(Map<String, dynamic> json) {
    return StudentResponse(
      studentData: json['student_data'] != null
          ? StudentData.fromJson(json['student_data'] as Map<String, dynamic>)
          : null,
      liveDetails: json['live_details'] != null
          ? (json['live_details'] as List<dynamic>)
          .map((item) => Detail.fromJson(item as Map<String, dynamic>))
          .toList()
          : null,
      questionDetails: json['question_details'] != null
          ? (json['question_details'] as List<dynamic>)
          .map((item) => Detail.fromJson(item as Map<String, dynamic>))
          .toList()
          : null,
      examDetails: json['exam_details'] != null
          ? (json['exam_details'] as List<dynamic>)
          .map((item) => Detail.fromJson(item as Map<String, dynamic>))
          .toList()
          : null,
      questions: json['questions'] as int?,
      exam: json['exam'] as int?,
      lives: json['lives'] as int?,
      notifications: json['notifications'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_data': studentData?.toJson(),
      'live_details': liveDetails?.map((detail) => detail.toJson()).toList(),
      'question_details':
      questionDetails?.map((detail) => detail.toJson()).toList(),
      'exam_details': examDetails?.map((detail) => detail.toJson()).toList(),
      'questions': questions,
      'exam': exam,
      'lives': lives,
      'notifications': notifications,
    };
  }
}