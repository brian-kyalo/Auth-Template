class AppUser {
  final String uid;
  final String email;

  // Constructor
  AppUser({required this.uid, required this.email});

  // Convert AppUser to JSON
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email};
  }

  // Convert JSON back to AppUser
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(uid: jsonUser['uid'], email: jsonUser['email']);
  }
}
