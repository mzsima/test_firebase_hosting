import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_hosting_test/model/diary.dart';
import 'package:firebase_hosting_test/screens/get_started_page.dart';
import 'package:firebase_hosting_test/screens/login_page.dart';
import 'package:firebase_hosting_test/screens/main_page.dart';
import 'package:firebase_hosting_test/screens/page_not_found.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final userDiaryDataStream = FirebaseFirestore.instance
      .collection('diaries')
      .snapshots()
      .map((diaries) {
    return diaries.docs.map((diary) {
      return Diary.fromDocument(diary);
    }).toList();
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider(
            create: (context) => FirebaseAuth.instance.authStateChanges(),
            initialData: null),
        StreamProvider<List<Diary>>(
            create: (context) => userDiaryDataStream, initialData: [])
      ],
      child: MaterialApp(
        title: 'YARIKIRI β',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primarySwatch: Colors.green,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) {
            return RouteController(settingsName: settings.name!);
          });
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => PageNotFound(),
        ),
      ),
    );
  }
}

class RouteController extends StatelessWidget {
  final String settingsName;

  const RouteController({Key? key, required this.settingsName})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final userSignedIn = Provider.of<User?>(context) != null;
    final notSignedInGotoMain = !userSignedIn && settingsName == '/main';

    if (settingsName == '/' && !userSignedIn) {
      return GettingStartedPage();
    } else if (settingsName == '/main' && notSignedInGotoMain) {
      return LoginPage();
    } else if (settingsName == '/login' || notSignedInGotoMain) {
      return LoginPage();
    } else if (userSignedIn) {
      return MainPage();
    } else {
      return PageNotFound();
    }
  }
}
