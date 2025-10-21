import 'package:flutter/material.dart';
import 'package:list_it/ChangeNotifiers/client.dart';
import 'package:list_it/utils/extensions.dart';

class ListItemButton extends StatelessWidget {
  final Client client;

  const ListItemButton({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async => client.updateOrAddListItem(context),
      tooltip: 'Add shopping item',
      label: const Text("Add shopping item"),
      icon: const Icon(Icons.add),
      backgroundColor: context.tertiaryContainer,
    );
  }
}
