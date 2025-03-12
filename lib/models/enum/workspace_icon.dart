import 'package:flutter/material.dart';

enum WorkspaceIconEnum {
  business(Icons.business),
  computer(Icons.computer),
  menuBook(Icons.menu_book),
  shoppingCart(Icons.shopping_cart),
  brush(Icons.brush),
  people(Icons.people),
  analytics(Icons.analytics),
  lightbulb(Icons.lightbulb);

  final IconData icon;
  const WorkspaceIconEnum(this.icon);

  static WorkspaceIconEnum fromName(String name) {
    return WorkspaceIconEnum.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase(),
      orElse: () => WorkspaceIconEnum.business,
    );
  }
}
