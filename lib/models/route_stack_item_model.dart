// Flutter imports:
import 'package:flutter/material.dart';

class RouteStackItemModel {
  String? name;
  Object? args;

  RouteStackItemModel({this.name, this.args});

  factory RouteStackItemModel.fromRoute(Route route) => RouteStackItemModel(
    name: route.settings.name,
    args: route.settings.arguments,
  );
}
