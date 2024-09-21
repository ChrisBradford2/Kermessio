class Stock {
  final int id;
  final String itemName;
  final int quantity;
  final int price;
  final String type;
  final int boothHolderId;
  final String? boothHolderUsername;

  Stock({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.type,
    required this.boothHolderId,
    this.boothHolderUsername,
  });

  // Convertir un JSON en instance de Stock
  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      price: json['price'],
      type: json['type'],
      boothHolderId: json['booth_holder_id'],
      boothHolderUsername: json['booth_holder_username'],
    );
  }

  // Convertir une instance de Stock en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
      'type': type,
      'booth_holder_id': boothHolderId,
    };
  }
}
