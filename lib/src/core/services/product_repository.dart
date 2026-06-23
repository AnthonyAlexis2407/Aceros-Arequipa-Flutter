import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductRepository {
  ProductRepository._() {
    _initFirestoreListener();
  }
  static final ProductRepository instance = ProductRepository._();

  final ValueNotifier<List<Product>> products = ValueNotifier<List<Product>>([]);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _initFirestoreListener() {
    _firestore.collection('products').snapshots().listen((snapshot) {
      final List<Product> fetchedProducts = snapshot.docs.map((doc) {
        return Product.fromJson(doc.data(), doc.id);
      }).toList();
      products.value = fetchedProducts;
    });
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).set(product.toJson());
  }

  Future<void> updateStock(String id, int newStock) async {
    await _firestore.collection('products').doc(id).update({'stock': newStock});
  }

  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update(product.toJson());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }

  Product? findById(String id) {
    try {
      return products.value.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }


}
