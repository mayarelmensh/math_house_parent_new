import 'package:math_house_parent_new/domain/entities/get_students_response_entity.dart';

class GetStudentsResponseDm extends GetStudentsResponseEntity {
  GetStudentsResponseDm({super.students, super.myStudents});

  GetStudentsResponseDm.fromJson(dynamic json) {
    if (json['students'] != null) {
      students = [];
      json['students'].forEach((v) {
        students?.add(StudentsDm.fromJson(v));
      });
    }
    if (json['my_students'] != null) {
      myStudents = [];
      json['my_students'].forEach((v) {
        myStudents?.add(MyStudentsDm.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (students != null) {
      map['students'] = students?.map((v) => v.toJson()).toList();
    }
    if (myStudents != null) {
      map['my_students'] = myStudents?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class MyStudentsDm extends MyStudentsEntity {
  MyStudentsDm({
    super.id,
    super.email,
    super.phone,
    super.nickName,
    super.imageLink,
    super.categoryId,
    super.category,
  });

  MyStudentsDm.fromJson(dynamic json) {
    id = json['id'];
    email = json['email'];
    phone = json['phone'];
    nickName = json['nick_name'];
    imageLink = json['image_link'];
    categoryId = json['category_id'];
    category = json['category'] != null ? CategoryDm.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['email'] = email;
    map['phone'] = phone;
    map['nick_name'] = nickName;
    map['image_link'] = imageLink;
    map['category_id'] = categoryId;
    if (category != null) {
      map['category'] = category!.toJson();
    }
    return map;
  }
}

class CategoryDm extends CategoryEntity {
  CategoryDm({
    super.id,
    super.cateName,
    super.imageLink,
  });

  CategoryDm.fromJson(dynamic json) {
    id = json['id'];
    cateName = json['cate_name'];
    imageLink = json['image_link'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['cate_name'] = cateName;
    map['image_link'] = imageLink;
    return map;
  }
}

class StudentsDm extends StudentsEntity {
  StudentsDm({
    super.id,
    super.email,
    super.phone,
    super.nickName,
    super.imageLink,
  });

  StudentsDm.fromJson(dynamic json) {
    id = json['id'];
    email = json['email'];
    phone = json['phone'];
    nickName = json['nick_name'];
    imageLink = json['image_link'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['email'] = email;
    map['phone'] = phone;
    map['nick_name'] = nickName;
    map['image_link'] = imageLink;
    return map;
  }
}