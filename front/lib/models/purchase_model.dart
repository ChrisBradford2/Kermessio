class Purchase {
  final int id;
  final int userId;
  final int stockId;
  final String itemName;
  final int quantity;
  final int price;
  final String validationCode;
  final String status;

  Purchase({
    required this.id,
    required this.userId,
    required this.stockId,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.validationCode,
    required this.status,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      userId: json['user_id'],
      stockId: json['stock_id'],
      itemName: json['stock']['item_name'],
      quantity: json['quantity'],
      price: json['price'],
      validationCode: json['validation_code'],
      status: json['status'],
    );
  }
}
