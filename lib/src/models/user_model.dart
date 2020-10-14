class UserModel {
  String name;
  String number;

  UserModel(this.name, this.number);

  //TODO - case where numbers might not be unique
  int get hashCode => number.hashCode;

  bool operator ==(Object other) =>
      other is UserModel && other.number == number;

  enterName(String newName) {
    name = newName;
  }

  enterNumber(String newNumber) {
    number = newNumber;
  }
}
