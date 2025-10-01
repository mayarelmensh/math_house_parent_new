class GetStudentsResponseEntity {
  GetStudentsResponseEntity({this.students, this.myStudents});

  List<StudentsEntity>? students;
  List<MyStudentsEntity>? myStudents;
}

class MyStudentsEntity {
  MyStudentsEntity({
    this.id,
    this.email,
    this.phone,
    this.nickName,
    this.imageLink,
    this.categoryId,
    this.category,
  });

  MyStudentsEntity.fromJson(dynamic json) {
    id = json['id'];
    email = json['email'];
    phone = json['phone'];
    nickName = json['nick_name'];
    imageLink = json['image_link'];
    categoryId = json['category_id'];
    category = json['category'] != null ? CategoryEntity.fromJson(json['category']) : null;
  }

  int? id;
  String? email;
  String? phone;
  String? nickName;
  dynamic imageLink;
  int? categoryId;
  CategoryEntity? category;

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

class CategoryEntity {
  CategoryEntity({
    this.id,
    this.cateName,
    this.imageLink,
  });

  CategoryEntity.fromJson(dynamic json) {
    id = json['id'];
    cateName = json['cate_name'];
    imageLink = json['image_link'];
  }

  int? id;
  String? cateName;
  dynamic imageLink;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['cate_name'] = cateName;
    map['image_link'] = imageLink;
    return map;
  }
}

class StudentsEntity {
  StudentsEntity({
    this.id,
    this.email,
    this.phone,
    this.nickName,
    this.imageLink,
  });

  StudentsEntity.fromJson(dynamic json) {
    id = json['id'];
    email = json['email'];
    phone = json['phone'];
    nickName = json['nick_name'];
    imageLink = json['image_link'];
  }

  int? id;
  String? email;
  String? phone;
  String? nickName;
  dynamic imageLink;

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