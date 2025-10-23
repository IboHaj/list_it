import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:list_it/screens/login_page.dart';
import 'package:list_it/utils/auth.dart';
import 'package:list_it/utils/extensions.dart';

import '../models/list_item_model.dart';
import '../utils/shared_preferences.dart';
import '../widgets/measurement_units_ddm.dart';

class Client extends ChangeNotifier {
  bool editingListItem = false;

  bool editingList = false;

  bool loggedIn = false;

  bool logging = false;

  String _pickedList = "";

  Map<String, List<ListItemModel>> _list = {};

  Map<String, List<ListItemModel>> get list => _list;

  String get currentSelectedList => _pickedList;

  set pickedList(String listName) {
    _pickedList = listName;
    notifyListeners();
  }

  set userList(Map<String, List<ListItemModel>> newList) {
    _list = newList;
    notifyListeners();
  }

  void notify(Function() doSomething) {
    doSomething.call();
    notifyListeners();
  }

  void toggleEditingListItems() {
    editingListItem = !editingListItem;
    notifyListeners();
  }

  void toggleEditingLists() {
    editingList = !editingList;
    notifyListeners();
  }

  void addList(String listName) {
    _list[listName] = [];
    notifyListeners();
  }

  Future<void> updateOrAddListItem(
    BuildContext context, {
    String? title,
    String? amount,
    String? description,
    String? measurementUnit,
    bool isEditMode = false,
  }) async {
    final TextEditingController itemNameTEC = TextEditingController(text: title ?? "");
    final TextEditingController amountTEC = TextEditingController(text: amount ?? "0");
    final TextEditingController measurementUnitsTEC = TextEditingController(text: measurementUnit ?? "");
    final TextEditingController descriptionTEC = TextEditingController(text: description ?? "");

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Item details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      color: context.primaryContainer,
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (isEditMode) {
                          List<ListItemModel> newList = [];
                          List<ListItemModel> items = list[currentSelectedList]!;
                          for (var e in items) {
                            e.title == title
                                ? newList.add(
                                    ListItemModel(
                                      title: itemNameTEC.text,
                                      description: descriptionTEC.text,
                                      amount: amountTEC.text,
                                      measurementUnit: measurementUnitsTEC.text,
                                    ),
                                  )
                                : newList.add(e);
                            list[currentSelectedList] = newList;
                            editingListItem = false;
                          }
                        } else {
                          list[currentSelectedList]?.add(
                            ListItemModel(
                              title: title ?? itemNameTEC.text,
                              description: description ?? descriptionTEC.text,
                              amount: amount ?? amountTEC.text,
                              measurementUnit: measurementUnit ?? measurementUnitsTEC.text,
                            ),
                          );
                        }
                        Map<String, List<String>> dbList = {};
                        for (var e in list.entries) {
                          List<String> valueList = [];
                          for (var e in e.value) {
                            valueList.add(json.encode(e.toJson()));
                          }
                          dbList[e.key] = valueList;
                        }
                        loggedIn
                            ? Prefs.saveToDB(Auth.user!.email!, dbList, Prefs.db)
                            : Prefs.save("User_List", json.encode(list));
                        notifyListeners();
                        Navigator.pop(context);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 10),
                          Text(isEditMode ? "Update Item" : "Add Item"),
                        ],
                      ),
                    ),
                  ),
                ],
              ).paddingOnlyT(10),
              TextField(
                controller: itemNameTEC,
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Item name"),
              ).paddingSymmetric(),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: amountTEC,
                      decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Amount"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  MeasurementUnitsDDM(measurementUnitsTEC: measurementUnitsTEC),
                ],
              ).paddingSymmetric(10, 0),
              TextField(
                controller: descriptionTEC,
                decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Description/notes"),
                maxLines: 3,
              ).paddingLTRB(10, 10, 10, 40),
            ],
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  Future updateOrAddList(BuildContext context, {bool isEditMode = false, String listName = ""}) async {
    final TextEditingController listNameTEC = isEditMode
        ? TextEditingController(text: listName)
        : TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEditMode ? "Update List" : "New List"),
            Divider(thickness: 3, indent: 20, endIndent: 20),
            TextField(
              controller: listNameTEC,
              decoration: InputDecoration(border: OutlineInputBorder(), labelText: "New list name"),
            ).paddingSymmetric(0, 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close", style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {
                    if (isEditMode) {
                      Map<String, List<ListItemModel>> newMap = {};
                      for (var e in list.entries) {
                        e.key == listName ? newMap[listNameTEC.text] = e.value : newMap[e.key] = e.value;
                      }
                      userList = newMap;
                    } else {
                      addList(listNameTEC.text);
                    }
                    Map<String, List<String>> dbList = {};
                    for (var e in list.entries) {
                      List<String> valueList = [];
                      for (var e in e.value) {
                        valueList.add(json.encode(e.toJson()));
                      }
                      dbList[e.key] = valueList;
                    }
                    loggedIn ? Prefs.saveToDB(Auth.user!.email!, dbList, Prefs.db) : null; //save(listNameTEC.text, "");
                    editingList = false;
                    pickedList = listNameTEC.text;
                    listNameTEC.clear();
                    Navigator.pop(context);
                    notifyListeners();
                  },
                  child: Text(isEditMode ? "Update" : "Save", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ).paddingAll(20),
      ),
    );
  }

  Future showAccountDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_circle_outlined, size: 100, color: context.scheme.secondary),
            Text(Auth.user!.email!, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: context.primaryContainer, borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () async => updateUserStatus(true, context),
                      child: Center(
                        child: Text(
                          "Sign Out",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: context.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: context.primaryContainer, borderRadius: BorderRadius.circular(8)),
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    padding: EdgeInsets.all(10),
                    child: InkWell(
                      onTap: () async => updateUserStatus(true, context),
                      child: Center(
                        child: Text(
                          "Delete Account",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: context.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingSymmetric(0, 10),
          ],
        ),
      ),
    );
  }

  void removeList(String listName) {
    _list.remove(listName);
    editingList = false;
    notifyListeners();
  }

  void addListItems(String listName, String title, String description, String amount, String measurementUnit) {
    _list[listName]?.add(
      ListItemModel(title: title, description: description, amount: amount, measurementUnit: measurementUnit),
    );
    notifyListeners();
  }

  void removeListItem(String listName, String title) {
    List<ListItemModel> entries = _list[listName]!;
    entries.removeWhere((e) => e.title == title);
    editingListItem = false;
    notifyListeners();
  }

  Future<void> updateUserStatus(bool delete, BuildContext context) async {
    delete ? await Auth.auth.currentUser?.delete() : await Auth.auth.signOut();
    Auth.user = null;
    await Prefs.secureStorage?.delete(key: "User_Email");
    await Prefs.secureStorage?.delete(key: "User_Password");
    Prefs.prefs?.remove("Account_Use");
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (predicate) => false,
      );
    }
  }
}
