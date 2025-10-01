class MyPackageModel {
  final int? exams;
  final int? questions;
  final int? lives;
  final List<LiveDetail>? liveDetails;
  final List<ExamDetail>? examDetails;
  final List<QuestionDetail>? questionDetails;
  final List<Course>? courses;

  MyPackageModel({
    this.exams,
    this.questions,
    this.lives,
    this.liveDetails,
    this.examDetails,
    this.questionDetails,
    this.courses,
  });

  factory MyPackageModel.fromJson(Map<String, dynamic> json) {
    return MyPackageModel(
      exams: json['exams'] is int
          ? json['exams']
          : int.tryParse(json['exams']?.toString() ?? '0'),
      questions: json['questions'] is int
          ? json['questions']
          : int.tryParse(json['questions']?.toString() ?? '0'),
      lives: json['lives'] is int
          ? json['lives']
          : int.tryParse(json['lives']?.toString() ?? '0'),
      liveDetails: json['live_details'] != null
          ? (json['live_details'] as List)
          .map((item) => LiveDetail.fromJson(item))
          .toList()
          : null,
      examDetails: json['exam_details'] != null
          ? (json['exam_details'] as List)
          .map((item) => ExamDetail.fromJson(item))
          .toList()
          : null,
      questionDetails: json['question_details'] != null
          ? (json['question_details'] as List)
          .map((item) => QuestionDetail.fromJson(item))
          .toList()
          : null,
      courses: json['courses'] != null
          ? (json['courses'] as List)
          .map((item) => Course.fromJson(item))
          .toList()
          : null,
    );
  }
}

class LiveDetail {
  final String? number;
  final String? course;

  LiveDetail({this.number, this.course});

  factory LiveDetail.fromJson(Map<String, dynamic> json) {
    return LiveDetail(
      number: json['number']?.toString(),
      course: json['course']?.toString(),
    );
  }
}

class ExamDetail {
  final String? number;
  final String? course;

  ExamDetail({this.number, this.course});

  factory ExamDetail.fromJson(Map<String, dynamic> json) {
    return ExamDetail(
      number: json['number']?.toString(),
      course: json['course']?.toString(),
    );
  }
}

class QuestionDetail {
  final String? number;
  final String? course;

  QuestionDetail({this.number, this.course});

  factory QuestionDetail.fromJson(Map<String, dynamic> json) {
    return QuestionDetail(
      number: json['number']?.toString(),
      course: json['course']?.toString(),
    );
  }
}

class Course {
  final String? courseName;
  final int? id;
  final String? imageLink;
  final List<Package>? packages;

  Course({this.courseName, this.id, this.imageLink, this.packages});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseName: json['course_name']?.toString(),
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0'),
      imageLink: json['image_link']?.toString(),
      packages: json['packages'] != null
          ? (json['packages'] as List)
          .map((item) => Package.fromJson(item))
          .toList()
          : null,
    );
  }
}

class Package {
  final int? id;
  final String? name;
  final int? courseId;
  final int? price;
  final int? number;
  final int? duration;
  final String? module;

  Package({
    this.id,
    this.name,
    this.courseId,
    this.price,
    this.number,
    this.duration,
    this.module,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0'),
      name: json['name']?.toString(),
      courseId: json['course_id'] is int
          ? json['course_id']
          : int.tryParse(json['course_id']?.toString() ?? '0'),
      price: json['price'] is int
          ? json['price']
          : int.tryParse(json['price']?.toString() ?? '0'),
      number: json['number'] is int
          ? json['number']
          : int.tryParse(json['number']?.toString() ?? '0'),
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0'),
      module: json['module']?.toString(),
    );
  }
}