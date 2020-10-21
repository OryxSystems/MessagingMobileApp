import 'package:CommunityHelp/src/models/user_model.dart';
import 'package:CommunityHelp/src/resources/repository.dart';
import 'package:CommunityHelp/src/screens/add_group.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'screens/edit_group.dart';
import 'screens/groups_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/add_group_confirm.dart';
import 'screens/new_report.dart';
import 'models/group_model.dart';

class App extends StatelessWidget {
  Widget build(context) {
    return MultiProvider(
      providers: [
        Provider<Repository>(
            create: (context) => Repository(FirebaseFirestore.instance)),
        ChangeNotifierProvider(create: (context) => GroupModel()),
        Provider(
          create: (context) =>
              UserModel('attempt_name', 'attempt_number', false),
        )
      ],
      child: MaterialApp(
        title: 'Chat App',
        /*theme:
            ThemeData(primaryColor: Colors.red[200], accentColor: Colors.grey),*/
        onGenerateRoute: routes,
      ),
    );
  }

  //TODO - clean up
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
              return GroupsScreen(name: split[0], number: split[1]);
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
                content = content.replaceFirst('edit_group', '');
                return MaterialPageRoute(builder: (context) {
                  return EditGroup(
                    groupId: content,
                  );
                });
              } else {
                return MaterialPageRoute(builder: (context) {
                  content = content.replaceFirst('chat', '');
                  return ChatScreen(
                    groupId: content,
                  );
                });
              }
            }
          }
        }
      }
    }
  }

/*
  Route routes2(RouteSettings settings) {
    String content = settings.name.replaceFirst('/', '');
    content = content.replaceFirst('{', '').replaceFirst('}', '');
    switch (settings.name) {
      case '':
        return MaterialPageRoute(builder: (context) {
          return LoginScreen();
        });
        break;
      case '/':
        return MaterialPageRoute(builder: (context) {
          return LoginScreen();
        });
        break;
      default:
        print('????????????????????????????????????');
        print('THIS IS THE DEFAULT NAVIGATION');
        return MaterialPageRoute(builder: (context) {
          return LoginScreen();
        });
    }
  }*/
}
