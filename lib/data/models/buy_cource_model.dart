import 'package:math_house_parent_new/domain/entities/courses_response_entity.dart';

class BuyCourseResponseEntity {
  final CourseEntity? course;
  final String? paymentMethod;
  final double? price; // Changed from int? to double? to handle decimal strings
  final String? paymentLink;

  BuyCourseResponseEntity({
    this.course,
    this.paymentMethod,
    this.price,
    this.paymentLink,
  });

  factory BuyCourseResponseEntity.fromJson(Map<String, dynamic> json) {
    print('JSON Data for BuyCourseResponse: $json');
    return BuyCourseResponseEntity(
      course: json['course'] != null
          ? CourseEntity.fromJson(json['course'])
          : null,
      paymentMethod: json['payment_method']?.toString(),
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : double.tryParse(json['price'].toString()),
      paymentLink: json['payment_link'], // Corrected key to match JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course': course?.toJson(),
      'payment_method': paymentMethod,
      'price': price,
      'payment_link': paymentLink, // Consistent with JSON key
    };
  }
}

class CourseEntity {
  final int? id;
  final String? courseName;
  final int? categoryId;
  final String? courseDescription;
  final String? courseUrl;
  final String? preRequisition;
  final String? gain;
  final String? createdAt;
  final String? updatedAt;
  final int? teacherId;
  final int? userId;
  final String? type;
  final int? currencyId;
  final String? imageLink;
  final List<PriceEntity>? prices;

  CourseEntity({
    this.id,
    this.courseName,
    this.categoryId,
    this.courseDescription,
    this.courseUrl,
    this.preRequisition,
    this.gain,
    this.createdAt,
    this.updatedAt,
    this.teacherId,
    this.userId,
    this.type,
    this.currencyId,
    this.imageLink,
    this.prices,
  });

  factory CourseEntity.fromJson(Map<String, dynamic> json) {
    return CourseEntity(
      id: json['id'],
      courseName: json['course_name']?.toString(),
      categoryId: json['category_id'],
      courseDescription: json['course_des']?.toString(),
      courseUrl: json['course_url']?.toString(),
      preRequisition: json['pre_requisition']?.toString(),
      gain: json['gain']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      teacherId: json['teacher_id'],
      userId: json['user_id'],
      type: json['type']?.toString(),
      currencyId: json['currancy_id'],
      imageLink: json['image_link']?.toString(),
      prices: json['prices'] != null
          ? (json['prices'] as List)
          .map((e) => PriceEntity.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
      'category_id': categoryId,
      'course_des': courseDescription,
      'course_url': courseUrl,
      'pre_requisition': preRequisition,
      'gain': gain,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'teacher_id': teacherId,
      'user_id': userId,
      'type': type,
      'currancy_id': currencyId,
      'image_link': imageLink,
      'prices': prices?.map((e) => e.toJson()).toList(),
    };
  }
}

class PriceEntity {
  final int? id;
  final int? courseId;
  final int? duration; // Kept as int? but parsing handled in fromJson
  final int? price;
  final int? discount;
  final String? createdAt;
  final String? updatedAt;

  PriceEntity({
    this.id,
    this.courseId,
    this.duration,
    this.price,
    this.discount,
    this.createdAt,
    this.updatedAt,
  });

  factory PriceEntity.fromJson(Map<String, dynamic> json) {
    return PriceEntity(
      id: json['id'],
      courseId: json['course_id'],
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration'].toString() ?? ''),
      price: json['price'] is int
          ? json['price']
          : int.tryParse(json['price'].toString() ?? ''),
      discount: json['discount'],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'duration': duration,
      'price': price,
      'discount': discount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}