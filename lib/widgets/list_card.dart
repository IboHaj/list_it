import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:list_it/utils/extensions.dart';

class ListCard extends StatelessWidget {
  final String title;
  final Function() onPressed;
  final Function() onLongPress;
  final bool editing;
  final Function() editPressed;
  final Function() deletePressed;

  const ListCard({
    super.key,
    required this.title,
    required this.onLongPress,
    required this.onPressed,
    required this.editing,
    required this.editPressed,
    required this.deletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              color: context.tertiaryContainer,
            ),
            width: double.infinity,
            height: 50,
            child: TextButton(
              onLongPress: onLongPress.call,
              onPressed: onPressed.call,
              child: Text(title, style: TextStyle(color: context.inverseSurface)),
            ),
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          child: badges.Badge(
            showBadge: editing,
            badgeContent: Icon(Icons.edit, color: context.onTertiary),
            badgeStyle: badges.BadgeStyle(badgeColor: context.onTertiaryContainer),
            onTap: editPressed.call,
          ),
        ),
        Container(
          alignment: Alignment.topRight,
          child: badges.Badge(
            onTap: deletePressed.call,
            showBadge: editing,
            badgeContent: Icon(Icons.remove, color: context.onTertiary),
            badgeStyle: badges.BadgeStyle(badgeColor: context.onErrorContainer),
          ),
        ),
      ],
    );
  }
}
