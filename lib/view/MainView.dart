import 'package:contractop/controllers/MainController.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MainView extends GetView<MainController> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MainController().title),
      ),
    );
  }
}
