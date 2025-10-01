import 'package:math_house_parent_new/domain/entities/courses_response_entity.dart';

class CoursesResponseDm extends CoursesResponseEntity {
  CoursesResponseDm({super.courses, super.paymentMethods});

  CoursesResponseDm.fromJson(dynamic json) {
    if (json['courses'] != null) {
      courses = [];
      json['courses'].forEach((v) {
        courses?.add(CourseDm.fromJson(v));
      });
    }
    if (json['payment_methods'] != null) {
      paymentMethods = [];
      json['payment_methods'].forEach((v) {
        paymentMethods?.add(PaymentMethodsDm.fromJson(v));
      });
    }
  }
}

class PaymentMethodsDm extends PaymentMethodsEntity {
  PaymentMethodsDm({
    super.id,
    super.payment,
    super.description,
    super.logo,
    super.statue,
    super.createdAt,
    super.updatedAt,
    super.logoLink,
  });

  PaymentMethodsDm.fromJson(dynamic json) {
    id = json['id'];
    payment = json['payment'];
    description = json['description'];
    logo = json['logo'];
    statue = json['statue'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    logoLink = json['logo_link'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['payment'] = payment;
    map['description'] = description;
    map['logo'] = logo;
    map['statue'] = statue;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['logo_link'] = logoLink;
    return map;
  }
}

class CourseDm extends CourseEntity {
  CourseDm({
    super.id,
    super.videosCount,
    super.chaptersCount,
    super.lessonsCount,
    super.questionsCount,
    super.quizsCount,
    super.pdfsCount,
    super.price,
    super.allPrices,
    super.courseName,
    super.courseDescription,
    super.courseImage,
    super.teacher,
    super.chapters,
  });

  CourseDm.fromJson(dynamic json) {
    id = json['id'];
    videosCount = json['videos_count'];
    chaptersCount = json['chapters_count'];
    lessonsCount = json['lessons_count'];
    questionsCount = json['questions_count'];
    quizsCount = json['quizs_count'];
    pdfsCount = json['pdfs_count'];
    price = json['price'];
    if (json['all_prices'] != null) {
      allPrices = [];
      json['all_prices'].forEach((v) {
        allPrices?.add(AllPricesDm.fromJson(v));
      });
    }
    courseName = json['course_name'];
    courseDescription = json['course_description'];
    courseImage = json['course_image'];
    teacher = json['teacher'];
    if (json['chapters'] != null) {
      chapters = [];
      json['chapters'].forEach((v) {
        chapters?.add(ChaptersDm.fromJson(v));
      });
    }
  }
}

class ChaptersDm extends ChaptersEntity {
  ChaptersDm({
    super.id,
    super.chapterPrice,
    super.chapterAllPrices,
    super.chapterName,
    super.lessons,
  });

  ChaptersDm.fromJson(dynamic json) {
    id = json['id'];
    chapterPrice = json['chapter_price'];
    if (json['chapter_all_prices'] != null) {
      chapterAllPrices = [];
      json['chapter_all_prices'].forEach((v) {
        chapterAllPrices?.add(ChapterAllPricesDm.fromJson(v));
      });
    }
    chapterName = json['chapter_name'];
    if (json['lessons'] != null) {
      lessons = [];
      json['lessons'].forEach((v) {
        lessons?.add(LessonsDm.fromJson(v));
      });
    }
  }
}

class LessonsDm extends LessonsEntity {
  LessonsDm({super.id, super.lessonName});

  LessonsDm.fromJson(dynamic json) {
    id = json['id'];
    lessonName = json['lesson_name'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['lesson_name'] = lessonName;
    return map;
  }
}

class ChapterAllPricesDm extends ChapterAllPricesEntity {
  ChapterAllPricesDm({
    super.id,
    super.duration,
    super.price,
    super.discount,
    super.chapterId,
    super.createdAt,
    super.updatedAt,
  });

  ChapterAllPricesDm.fromJson(dynamic json) {
    id = json['id'];
    duration = json['duration'];
    price = json['price'];
    discount = json['discount'];
    chapterId = json['chapter_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['duration'] = duration;
    map['price'] = price;
    map['discount'] = discount;
    map['chapter_id'] = chapterId;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class AllPricesDm extends AllPricesEntity {
  AllPricesDm({
    super.id,
    super.courseId,
    super.duration,
    super.price,
    super.discount,
    super.createdAt,
    super.updatedAt,
  });

  AllPricesDm.fromJson(dynamic json) {
    id = json['id'];
    courseId = json['course_id'];
    duration = json['duration'];
    price = json['price'];
    discount = json['discount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['course_id'] = courseId;
    map['duration'] = duration;
    map['price'] = price;
    map['discount'] = discount;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}