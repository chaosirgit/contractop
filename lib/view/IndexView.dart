import 'package:contractop/controllers/IndexController.dart';
import 'package:contractop/utils/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class IndexView extends GetView<IndexController> {
  /// GetX Controller 加载
  @override
  final IndexController controller = Get.put(IndexController());

  //TODO
  //提交之后改变焦点
  //列表更新后 List 不刷新

  @override
  Widget build(BuildContext context) {
    controller.getOperators();
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.title),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: defaultPadding),
            /// Name 输入框
            SizedBox(
              width: 400,
              height: 50,
              child: TextField(
                autofocus: true,
                onSubmitted: (d) {
                  controller.secret.value = d;
                },
                decoration: const InputDecoration(
                    labelText: "Operator Name",
                    hintText: "Input your operation alis name",
                    prefixIcon: Icon(Icons.swipe_right_alt)),
              ),
            ),
            const SizedBox(height: defaultPadding),
            /// Secret 输入框
            SizedBox(
              width: 400,
              height: 50,
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Secret Key",
                    hintText: "Input your operation wallet secret key",
                    prefixIcon: Icon(Icons.lock)),
              ),
            ),
            const SizedBox(height: defaultPadding),
            SizedBox(
              width: 200,
              height: 50,
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
            const SizedBox(height: defaultPadding),
            Container(
              alignment: Alignment.center,
              width: 700,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Operators",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  SizedBox(
                    width: double.infinity,
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
                                DataCell(Text(
                                    "${controller.operators[index]["public_key"]}")),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                        color: Colors.red,
                                        onPressed: () async {
                                           var res = await controller.selectOperator(controller.operators[index]);

                                        },
                                        icon: const Icon(Icons.delete)),
                                    IconButton(
                                        color: Colors.blue,
                                        onPressed: () => controller.selectOperator(controller.operators[index]),
                                        icon: const Icon(Icons.start))
                                  ],
                                )),
                              ])),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
