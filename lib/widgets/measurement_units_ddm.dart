import 'package:flutter/material.dart';
import 'package:list_it/utils/extensions.dart';

class MeasurementUnitsDDM extends StatefulWidget {
  const MeasurementUnitsDDM({super.key, required this.measurementUnitsTEC});

  final TextEditingController measurementUnitsTEC;

  @override
  State<StatefulWidget> createState() => _MeasurementUnitsDDM();
}

class _MeasurementUnitsDDM extends State<MeasurementUnitsDDM> {
  late final TextEditingController unitsTEC = widget.measurementUnitsTEC;
  final List<String> measurementUnitsValues = ["Cm(s)", "M(s)", "Mm(s)", "KG(s)", "Pieces", "Bags"];
  late List<DropdownMenuEntry> measurementUnitsDDM = measurementUnitsValues.map((e) {
    return DropdownMenuEntry(value: e, label: e);
  }).toList();

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      dropdownMenuEntries: measurementUnitsDDM,
      label: const Text("Measurement Units"),
      width: context.width / 1.7,
      controller: unitsTEC,
      onSelected: (value) {
        unitsTEC.text = value;
      },
    );
  }
}
