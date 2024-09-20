import 'package:flutter/cupertino.dart';

import '../../models/user_model.dart';
import '../../repositories/stock_repository.dart';
import '../../screens/home/child_view.dart';

class ChildView extends StatefulWidget {
  final User user;
  final StockRepository stockRepository;

  const ChildView({
    super.key,
    required this.user,
    required this.stockRepository,
  });

  @override
  ChildViewState createState() => ChildViewState();
}
