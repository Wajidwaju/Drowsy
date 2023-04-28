class User {
  String name, email, password;

  User(this.name, this.email, this.password);

  // To convert the User object to a JSON representation
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    return data;
  }

  // To convert the JSON representation back into a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['name'],
      json['email'],
      json['password'],
    );
  }
}
