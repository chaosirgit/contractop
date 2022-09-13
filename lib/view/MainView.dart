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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Text(

                      "Read Methods",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  /// 读方法列表
                  Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: SizedBox(
                      height: 600,
                      child: GetBuilder<MainController>(
                        builder: (_) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(defaultPadding),
                            itemCount: mc.readMethods.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: const Icon(Icons.read_more,color: Colors.blueAccent,),
                                title: Text("${mc.readMethods[index]['name']}"),
                                subtitle: Text("(${mc.readMethods[index]['input_format']})"),
                                onTap: () {
                                  Get.toNamed("/operation",arguments: {"methodName":mc.readMethods[index]['name'],"color":Colors.blueAccent});
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Text(
                      "Write Methods",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  /// 写方法列表
                  Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: SizedBox(
                      height: 600,
                      child: GetBuilder<MainController>(
                        builder: (_) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(defaultPadding),
                            itemCount: mc.sendMethods.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: const Icon(Icons.edit_calendar_outlined,color: Colors.orangeAccent,),
                                title: Text("${mc.sendMethods[index]['name']}"),
                                subtitle: Text("(${mc.sendMethods[index]['input_format']})"),
                                onTap: () {
                                  Get.toNamed("/operation",arguments: {"methodName":mc.sendMethods[index]['name'],"color":Colors.orangeAccent});
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
