import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'screens/edit_group.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/add_group_confirm.dart';
import 'screens/incident_report.dart';
import 'screens/add_group.dart';

import 'models/group_model.dart';
import 'models/user_model.dart';
import 'resources/repository.dart';

class App extends StatelessWidget {
  Widget build(context) {
    return MultiProvider(
      providers: [
        // Provider to access the firebase
        Provider<Repository>(
            create: (context) => Repository(FirebaseFirestore.instance)),
        // Provider for adding a group (whether or not a user is seleted)
        ChangeNotifierProvider(create: (context) => GroupModel()),
        // Provider for the logged in user - creates it here but initialised in home_screen
        Provider(
          create: (context) =>
              UserModel('attempt_name', 'attempt_number', false),
        )
      ],
      child: MaterialApp(
        title: 'Chat App',
        onGenerateRoute: routes,
      ),
    );
  }

  Route routes(RouteSettings settings) {
    String content = settings.name.replaceFirst('/', '');
    if (content == '') {
      return MaterialPageRoute(builder: (context) {
        return LoginScreen();
      });
    } else {
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
          if (content.startsWith('home')) {
            content = content.replaceFirst('home', '');
            var split = content.split(': ');
            return MaterialPageRoute(builder: (context) {
              return HomeScreen(name: split[0], number: split[1]);
            });
          } else {
            if (content.startsWith('report_incident')) {
              content = content.replaceFirst('report_incident', '');
              return MaterialPageRoute(builder: (context) {
                return NewReport(
                  groupId: content,
                );
              });
            } else {
              if (content.startsWith('edit_group')) {
                print(content);
                content = content.replaceFirst('edit_group', '');
                var split = content.split(': ');
                print('id: ${split[0]}; name: ${split[1]}');

                return MaterialPageRoute(builder: (context) {
                  return EditGroup(
                    groupId: split[0],
                    groupName: split[1],
                  );
                });
              } else {
                return MaterialPageRoute(builder: (context) {
                  content = content.replaceFirst('chat', '');
                  var split = content.split(': ');
                  print('id: ${split[0]}; name: ${split[1]}');
                  return ChatScreen(
                    groupId: split[0],
                    groupName: split[1],
                  );
                });
              }
            }
          }
        }
      }
    }
  }
}
