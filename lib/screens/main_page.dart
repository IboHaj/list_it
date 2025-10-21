import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:list_it/ChangeNotifiers/client.dart';
import 'package:list_it/screens/login_page.dart';
import 'package:list_it/utils/extensions.dart';
import 'package:list_it/utils/shared_preferences.dart';
import 'package:list_it/widgets/custom_appbar.dart';
import 'package:list_it/widgets/list_card.dart';
import 'package:list_it/widgets/list_item.dart';
import 'package:list_it/widgets/list_item_button.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, this.title, this.autoLogin = false, this.localUser = false});

  final String? title;
  final bool autoLogin;
  final bool localUser;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final newListTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.autoLogin) {
        autoLogin(Provider.of<Client>(context, listen: false));
      }

      if (widget.localUser) {
        Provider.of<Client>(context, listen: false).userList = await Prefs.getFromLocal();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Client>(
      builder: (context, client, child) => Scaffold(
        backgroundColor: context.primaryFixed,
        appBar: CustomAppBar(
          bgColor: context.primaryFixed,
          size: 60,
          actions: [
            Container(
              height: 40,
              width: 40,
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Theme.of(context).colorScheme.surfaceContainer),
                borderRadius: BorderRadius.circular(10),
                color: context.primaryContainer,
              ),
              child: InkWell(
                onTap: () => client.loggedIn
                    ? client.showAccountDialog(context)
                    : Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())),
                borderRadius: BorderRadius.circular(5),
                child: Icon(Icons.account_circle, color: context.primaryFixed),
              ),
            ),
          ],
        ),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(8, 20, 8, 20),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: context.primaryContainer,
                ),
                width: double.infinity,
                height: context.height / 4,
                child: Consumer<Client>(
                  builder: (context, client, child) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Your lists",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ).paddingSymmetric(20, 0),
                          TextButton(
                            onPressed: () async => await client.updateOrAddList(context),
                            child: Container(
                              width: 125,
                              height: 30,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                color: context.tertiaryContainer,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add, size: 20, color: context.inverseSurface),
                                  SizedBox(width: 10),
                                  Text("Add a new list", style: TextStyle(fontSize: 14, color: context.inverseSurface)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: context.width / 1.17,
                        height: context.height / 5.1,
                        child: client.list.keys.isEmpty
                            ? Center(
                                child: Text(
                                  "No available lists currently",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              )
                            : GridView.count(
                                crossAxisCount: 2,
                                childAspectRatio: 0.5,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 0,
                                padding: EdgeInsets.all(5),
                                primary: true,
                                scrollDirection: Axis.horizontal,
                                children: client.list.keys
                                    .map(
                                      (e) => ListCard(
                                        title: e,
                                        onPressed: () => client.pickedList = e,
                                        onLongPress: () => client.toggleEditingLists(),
                                        editing: client.editingList,
                                        deletePressed: () {
                                          if (e == client.currentSelectedList) {
                                            client.pickedList = "";
                                          }
                                          client.removeList(e);
                                        },
                                        editPressed: () =>
                                            client.updateOrAddList(context, isEditMode: true, listName: e),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: ShapeDecoration(
                    color: context.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  ),
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 20, 10, 0),
                        child: Text("List items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(height: 10),
                      Consumer<Client>(
                        builder: (context, mainList, child) => Expanded(
                          child: mainList.currentSelectedList.isEmpty
                              ? Center(
                                  child: Text(
                                    "No list is currently selected OR there are no items in the currently selected list",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                  ).paddingAll(8),
                                )
                              : Container(
                                  color: context.primaryContainer,
                                  child: ListView(
                                    children: mainList.list[mainList.currentSelectedList]!
                                        .map(
                                          (e) => ListItem(
                                            title: e.title,
                                            description: e.description,
                                            amount: int.tryParse(e.amount)!,
                                            measurementUnit: e.measurementUnit,
                                            isEditMode: client.editingListItem,
                                            onLongPressed: () => client.toggleEditingListItems(),
                                            editPressed: () async => await client.updateOrAddListItem(
                                              context,
                                              title: e.title,
                                              amount: e.amount.toString(),
                                              description: e.description,
                                              measurementUnit: e.measurementUnit,
                                              isEditMode: true,
                                            ),
                                            deletePressed: () =>
                                                client.removeListItem(client.currentSelectedList, e.title),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: ListItemButton(client: client),
      ),
    );
  }

  Future<void> autoLogin(Client client) async {
    client.notify(() async => client.userList = await Prefs.loadUserData());
  }

  Future deleteFromDB() async {}

  Future<void> logout(FirebaseAuth auth) async => auth.signOut();

  Future<void> deleteAccount(FirebaseAuth auth) async => auth.currentUser!.delete();
}
