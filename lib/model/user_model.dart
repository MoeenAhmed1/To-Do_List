class UserData {
  String name;
  String email;
  String uid;

  UserData({this.email, this.name, this.uid});

  factory UserData.fromJson(Map<String, dynamic> data) {
    return UserData(name: data['name'], email: data['email'], uid: data['uid']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
    };
  }
}
