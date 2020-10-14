import 'package:CommunityHelp/src/models/user_model.dart';
import 'package:CommunityHelp/src/resources/repository.dart';
import 'package:CommunityHelp/src/screens/add_group.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'screens/groups_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/add_group_confirm.dart';
import 'models/group_model.dart';

class App extends StatelessWidget {
  Widget build(context) {
    return MultiProvider(
      providers: [
        Provider<Repository>(
            create: (context) => Repository(FirebaseFirestore.instance)),
        ChangeNotifierProvider(create: (context) => GroupModel()),
        Provider(
          create: (context) => UserModel('attempt_name', 'attempt_number'),
        )
      ],
      child: MaterialApp(
        title: 'Chat App',
        onGenerateRoute: routes,
      ),
    );
  }

  //TODO - clean up
  Route routes(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(builder: (context) {
        return LoginScreen();
      });
    } else {
      String content = settings.name.replaceFirst('/', '');
      print('$content');
      if (content == 'add_group') {
        return MaterialPageRoute(builder: (context) {
          return AddGroup();
        });
      } else {
        if (content == 'confirm_group') {
          return MaterialPageRoute(builder: (context) {
            return ConfirmGroup();
          });
        } else {
          content = content.replaceFirst('{', '');
          content = content.replaceFirst('}', '');
          //var split = content.split(': ');
          //print('${split[0]} and ${split[1]}');
          if (content.startsWith('h')) {
            var split = content.split(': ');
            split[0] = split[0].replaceFirst('h', '');
            //TODO - change content to return user & groupId
            return MaterialPageRoute(builder: (context) {
              return GroupsScreen(name: split[0], number: split[1]);
            });
          } else {
            var split = content.split(': ');
            return MaterialPageRoute(builder: (context) {
              //final name = settings.name.replaceFirst('/', '');
              return ChatScreen(
                user: split[0],
                groupId: split[1],
                //chatId: split[2],
              );
            });
          }
        }
      }
    }
  }
}
