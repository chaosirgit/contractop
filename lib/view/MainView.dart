import 'package:contractop/controllers/MainController.dart';
import 'package:contractop/utils/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MainView extends GetView<MainController> {
  final MainController mc = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    /// 刷新 title
    mc.getTitle();

    /// 获取初始方法列表
    mc.getAbiMethods();
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text("${mc.title}")),
      ),
      floatingActionButton: IconButton(
        onPressed: () => Get.offAllNamed("/"),
        icon: const Icon(Icons.first_page),
      ),
      body: Center(
          child: Container(
        width: 800,
        child: Row(
          children: [
            Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(defaultPadding),
                  itemCount: mc.readMethods.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(title: Text("${mc.readMethods[index]}"),);
                  },
                )
            ),
            Expanded(child: Text("2")),
          ],
        ),
      )),
    );
  }
}
