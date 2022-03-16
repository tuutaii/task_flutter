class UserModel {
  final String name;
  final int age;
  final String bio;
  final String position;
  final String job;
  final String company;
  final String address;
  final bool isPremium;
  final String avatar;

  UserModel(
      {required this.name,
      required this.age,
      required this.bio,
      required this.position,
      required this.job,
      required this.company,
      required this.address,
      required this.isPremium,
      required this.avatar});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        name: json['name'],
        age: json['age'],
        bio: json['bio'],
        position: json['position'],
        job: json['job'],
        company: json['company'],
        address: json['address'],
        isPremium: json['isPremium'],
        avatar: json['avatar']);
  }
}
