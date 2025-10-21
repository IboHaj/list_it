class ListItemModel {
  String title;
  String amount;
  String measurementUnit;
  String description;

  ListItemModel({required this.title, required this.description, required this.amount, required this.measurementUnit});

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "measurementUnit": measurementUnit,
    "amount": amount,
  };

  factory ListItemModel.fromJson(Map<String, dynamic> json) => ListItemModel(
    title: json["title"]!,
    description: json["description"]!,
    measurementUnit: json["measurementUnit"]!,
    amount: json["amount"]!,
  );
}
