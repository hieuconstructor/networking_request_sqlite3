import 'User.dart';
import 'UserApi.dart';

void main() async {
  await UserApi.createUserTable();
  final userList = await UserApi.fetchUsers();
  await UserApi.insertUsers(userList);

  for (var user in userList) {
    print(
        'Id: ${user.id}, Fist name: ${user.lastName}, Last name: ${user.lastName}, Email: ${user.email}');
  }

  final List<User> listUserInsert = [
    User(
        id: 1,
        firstName: 'Nguyen Viet',
        lastName: 'Hieu',
        email: 'viethieuk13@gmail.com')
  ];
  await UserApi.insertUsers(listUserInsert);

  final userInsert = await UserApi.createUser(User(
      id: 1,
      firstName: 'Nguyen Viet',
      lastName: 'Hieu',
      email: 'viethieuk13@gmail.com'));
  print(userInsert);
}
