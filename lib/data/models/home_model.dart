// Model for the student_data object
class StudentData {
  final String nickName;
  final String grade;
  final String category;

  StudentData({
    required this.nickName,
    required this.grade,
    required this.category,
  });

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      nickName: json['nick_name'] as String,
      grade: json['grade'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'nick_name': nickName, 'grade': grade, 'category': category};
  }
}

// Model for live_details, question_details, and exam_details objects
class Detail {
  final String number;
  final String course;

  Detail({required this.number, required this.course});

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      number: json['number'] as String,
      course: json['course'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'number': number, 'course': course};
  }
}

// Main model for the entire response
class StudentResponse {
  final StudentData studentData;
  final List<Detail> liveDetails;
  final List<Detail> questionDetails;
  final List<Detail> examDetails;
  final int questions;
  final int exam;
  final int lives;
  final int notifications;

  StudentResponse({
    required this.studentData,
    required this.liveDetails,
    required this.questionDetails,
    required this.examDetails,
    required this.questions,
    required this.exam,
    required this.lives,
    required this.notifications,
  });

  factory StudentResponse.fromJson(Map<String, dynamic> json) {
    return StudentResponse(
      studentData: StudentData.fromJson(
        json['student_data'] as Map<String, dynamic>,
      ),
      liveDetails: (json['live_details'] as List<dynamic>)
          .map((item) => Detail.fromJson(item as Map<String, dynamic>))
          .toList(),
      questionDetails: (json['question_details'] as List<dynamic>)
          .map((item) => Detail.fromJson(item as Map<String, dynamic>))
          .toList(),
      examDetails: (json['exam_details'] as List<dynamic>)
          .map((item) => Detail.fromJson(item as Map<String, dynamic>))
          .toList(),
      questions: json['questions'] as int,
      exam: json['exam'] as int,
      lives: json['lives'] as int,
      notifications: json['notifications'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_data': studentData.toJson(),
      'live_details': liveDetails.map((detail) => detail.toJson()).toList(),
      'question_details': questionDetails
          .map((detail) => detail.toJson())
          .toList(),
      'exam_details': examDetails.map((detail) => detail.toJson()).toList(),
      'questions': questions,
      'exam': exam,
      'lives': lives,
      'notifications': notifications,
    };
  }
}
