import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:list_it/utils/extensions.dart';

class ListItem extends StatelessWidget {
  final String title;
  final String description;
  final String measurementUnit;
  final int amount;
  final Function() onLongPressed;
  final bool isEditMode;
  final Function() editPressed;
  final Function() deletePressed;

  const ListItem({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.measurementUnit,
    required this.isEditMode,
    required this.onLongPressed,
    required this.editPressed,
    required this.deletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      child: Material(
        color: context.primaryContainer,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: context.tertiaryContainer,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Stack(
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: badges.Badge(
                  onTap: editPressed.call,
                  showBadge: isEditMode,
                  badgeContent: Icon(Icons.edit, color: context.onTertiary),
                  badgeStyle: badges.BadgeStyle(badgeColor: context.onTertiaryContainer),
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                child: badges.Badge(
                  onTap: deletePressed.call,
                  showBadge: isEditMode,
                  badgeContent: Icon(Icons.remove, color: context.onTertiary),
                  badgeStyle: badges.BadgeStyle(badgeColor: context.onErrorContainer),
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                title: Text(title),
                subtitle: Text(description),
                trailing: Text("$amount $measurementUnit"),
                onLongPress: onLongPressed.call,
              ).paddingLTRB(5, 20, 5, 0),
            ],
          ),
        ),
      ),
    );
  }
}
