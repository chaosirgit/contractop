import 'package:contractop/controllers/IndexController.dart';
import 'package:contractop/utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class IndexView extends GetView<IndexController> {
  /// GetX Controller 加载
  @override
  final IndexController controller = Get.put(IndexController());
  FocusNode nameFocusNode = FocusNode();
  FocusNode secretFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    /// 获取初始列表
    controller.getOperators();
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: 800,
            child: Column(
              children: [
                /// Name 输入框
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                    child: TextField(
                      autofocus: true,
                      focusNode: nameFocusNode,

                      /// 提交后切换焦点
                      onSubmitted: (d) {
                        nameFocusNode.unfocus();
                        FocusScope.of(context).requestFocus(secretFocusNode);
                      },

                      /// change 赋值
                      onChanged: (d) {
                        controller.name.value = d;
                      },
                      decoration: const InputDecoration(
                          labelText: "Operator Name",
                          hintText: "Input your operation alis name",
                          prefixIcon: Icon(Icons.swipe_right_alt)),
                    ),
                  ),
                ),

                /// Secret 输入框
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                    child: TextField(
                      ///提交后赋值并请求新建
                      onSubmitted: (d) async {
                        var res = await controller.addOperator();
                        if (res.code == 200) {
                          ///添加成功 刷新列表
                          await controller.getOperators();
                        } else {
                          Get.snackbar("Error", res.message);
                        }
                      },

                      /// 赋值
                      onChanged: (d) {
                        controller.secret.value = d;
                      },
                      focusNode: secretFocusNode,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: "Secret Key",
                          hintText: "Input your operation wallet secret key",
                          prefixIcon: Icon(Icons.lock)),
                    ),
                  ),
                ),

                /// 添加按钮
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Wallet"),
                      onPressed: () async {
                        var res = await controller.addOperator();
                        if (res.code == 200) {
                          ///添加成功 刷新列表
                          await controller.getOperators();
                        } else {
                          Get.snackbar("Error", res.message);
                        }
                      },
                    ),
                  ),
                ),

                /// 列表
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Operators",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: GetBuilder<IndexController>(
                          builder: (_) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: defaultPadding,
                                columns: const [
                                  DataColumn(label: Text("ID")),
                                  DataColumn(label: Text("Name")),
                                  DataColumn(label: Text("Public Key")),
                                  DataColumn(label: Text("Op")),
                                ],
                                rows: List<DataRow>.generate(
                                    controller.operators.length,
                                    (index) => DataRow(cells: <DataCell>[
                                          DataCell(Text(
                                              "${controller.operators[index]["id"]}")),
                                          DataCell(Text(
                                              "${controller.operators[index]["name"]}")),
                                          DataCell(
                                              Text(
                                                  "${controller.operators[index]["public_key"]}"),
                                              onTap: () => Clipboard.setData(
                                                  ClipboardData(
                                                      text:
                                                          "${controller.operators[index]["public_key"]}"))),
                                          DataCell(Row(
                                            children: [
                                              IconButton(
                                                  color: Colors.red,
                                                  onPressed: () async {
                                                    var res = await controller
                                                        .deleteOperator(
                                                            controller
                                                                    .operators[
                                                                index]);
                                                    if (res.code == 200) {
                                                      ///删除成功 刷新列表
                                                      await controller
                                                          .getOperators();
                                                    } else {
                                                      Get.snackbar(
                                                          "Error", res.message);
                                                    }
                                                  },
                                                  icon:
                                                      const Icon(Icons.delete)),
                                              IconButton(
                                                  color: Colors.blue,
                                                  onPressed: () async {
                                                    var res = await controller
                                                        .selectOperator(
                                                            controller
                                                                    .operators[
                                                                index]);
                                                    if (res.code == 200) {
                                                      Get.offAllNamed(
                                                          "/contract");
                                                    } else {
                                                      Get.snackbar(
                                                          "Error", res.message);
                                                    }
                                                  },
                                                  icon: const Icon(Icons.start))
                                            ],
                                          )),
                                        ])),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
