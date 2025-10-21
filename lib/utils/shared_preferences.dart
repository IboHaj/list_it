import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:list_it/screens/login_page.dart';
import 'package:list_it/screens/main_page.dart';
import 'package:list_it/utils/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/list_item_model.dart';

class Prefs {
  static SharedPreferences? prefs;

  static final db = FirebaseFirestore.instance;

  static FlutterSecureStorage? secureStorage;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    secureStorage = FlutterSecureStorage();
  }

  static Future<void> save(String listName, String items) async => secureStorage!.write(key: listName, value: items);

  static Future retrieve() async {
    return  await secureStorage!.readAll().then((map) => json.decode(map["User_List"]!));
  }

  static Future<void> delete() async => prefs!.clear();

  static Future saveToDB(String email, Map<String, List<String>> lists, FirebaseFirestore db) async {
    return db.collection("users").doc(email).set(lists);
  }

  static Future getFromDB(String email, FirebaseFirestore db) async {
    var data = await db.collection("users").doc(email).get().then((e) => e.data());
    Map<String, List<ListItemModel>> userList = {};
    data?.entries.forEach((e) {
      List<ListItemModel> convertedList = [];
      for (var item in e.value) {
        convertedList.add(ListItemModel.fromJson(json.decode(item)));
      }
      userList[e.key] = convertedList;
    });
    return userList;
  }

  static Future getFromLocal() async {
    var encodedData = await retrieve();
    Map<String, List<ListItemModel>> userList = {};
    for (var e in encodedData.entries) {
      List<ListItemModel> convertedList = [];
      for (var item in e.value) {
        convertedList.add(ListItemModel.fromJson(item));
      }
      userList[e.key] = convertedList;
    }
    FlutterNativeSplash.remove();
    return userList;
  }

  static Future determineRoute() async {
    if (Prefs.prefs?.getBool("Account_Use") ?? false) {
      return MainPage(autoLogin: true);
    } else if (Prefs.prefs?.getBool("Local_Use") ?? false) {
      return MainPage(localUser: true,);
    } else {
      FlutterNativeSplash.remove();
      return LoginPage();
    }
  }

  static Future loadUserData() async {
    Auth.user = await Auth.loginUserWithEmailAndPassword(
      (await Prefs.secureStorage!.read(key: "User_Email"))!,
      (await Prefs.secureStorage!.read(key: "User_Password"))!,
      Auth.auth,
    );
    var dbList = await Prefs.getFromDB(Auth.user!.email!, Prefs.db);
    FlutterNativeSplash.remove();
    return dbList;
  }
}
