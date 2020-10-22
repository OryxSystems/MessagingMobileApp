class UserModel {
  String name;
  String number;
  bool isAdmin;

  UserModel(this.name, this.number, this.isAdmin);

  //TODO - case where numbers might not be unique
  int get hashCode => number.hashCode;

  bool operator ==(Object other) =>
      other is UserModel && other.number == number;

  setName(String newName) {
    name = newName;
  }

  setNumber(String newNumber) {
    number = newNumber;
  }

  setAdmin(bool admin) {
    isAdmin = admin;
  }
}
