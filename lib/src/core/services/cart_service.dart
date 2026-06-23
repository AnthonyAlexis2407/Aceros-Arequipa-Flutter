import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartItem {
  CartItem({required this.product, required this.quantity});

  final Product product;
  int quantity;

  double get subtotal => product.price * quantity;
}

class CartService {
  CartService._();
  static final CartService instance = CartService._();

  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  void addProduct(Product product) {
    final currentItems = [...items.value];
    final existing = currentItems.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existing.quantity == 0) {
      currentItems.add(CartItem(product: product, quantity: 1));
    } else {
      existing.quantity += 1;
    }

    items.value = currentItems;
  }

  void removeProduct(Product product) {
    final currentItems = items.value.where((item) => item.product.id != product.id).toList();
    items.value = currentItems;
  }

  void updateQuantity(Product product, int quantity) {
    final currentItems = [...items.value];
    final index = currentItems.indexWhere((item) => item.product.id == product.id);
    if (index < 0) return;
    if (quantity <= 0) {
      currentItems.removeAt(index);
    } else {
      currentItems[index].quantity = quantity;
    }
    items.value = currentItems;
  }

  void clear() {
    items.value = [];
  }

  int get totalItems => items.value.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.value.fold(0, (sum, item) => sum + item.subtotal);
}
