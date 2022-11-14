import 'package:contractop/controllers/RpcController.dart';
import 'package:contractop/utils/constants.dart';
import 'package:contractop/utils/helpers.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class RpcView extends GetView<RpcController> {
  /// GetX Controller 加载
  @override
  final RpcController rc = Get.put(RpcController());
  FocusNode nameFocusNode = FocusNode();
  FocusNode uriFocusNode = FocusNode();
  FocusNode chainIdFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {

    /// 获取初始列表
    rc.getRpc();
    return Scaffold(
      appBar: AppBar(
        title: Text("${rc.title}"),
      ),
      floatingActionButton: IconButton(
        onPressed: () => Get.offAllNamed("/"),
        icon: const Icon(Icons.first_page),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 1400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// ChainID 输入框
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                    child: TextField(
                      autofocus: true,
                      focusNode: chainIdFocusNode,
                      controller: rc.chainIdTextEditController.value,

                      /// 提交后切换焦点
                      onSubmitted: (d) {
                        nameFocusNode.unfocus();
                        FocusScope.of(context).requestFocus(nameFocusNode);
                      },
                      decoration: const InputDecoration(
                          labelText: "Chain ID",
                          hintText: "Input Chain ID",
                          prefixIcon: Icon(Icons.numbers)),
                    ),
                  ),
                ),
                /// Name 输入框
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                    child: TextField(
                      focusNode: nameFocusNode,
                      controller: rc.nameTextEditController.value,

                      /// 提交后切换焦点
                      onSubmitted: (d) {
                        nameFocusNode.unfocus();
                        FocusScope.of(context).requestFocus(uriFocusNode);
                      },
                      decoration: const InputDecoration(
                          labelText: "Chain Name",
                          hintText: "Input chain name",
                          prefixIcon: Icon(Icons.rate_review)),
                    ),
                  ),
                ),

                /// uri 输入框
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                    child: TextField(
                      focusNode: uriFocusNode,
                      controller: rc.uriTextEditController.value,

                      /// 提交后切换焦点
                      onSubmitted: (d) {
                        nameFocusNode.unfocus();
                      },

                      decoration: const InputDecoration(
                          labelText: "uri Address",
                          hintText: "Input uri address",
                          prefixIcon: Icon(Icons.meeting_room)),
                    ),
                  ),
                ),

                /// 按钮
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                    child: Obx(() => ElevatedButton.icon(
                      icon: rc.id > 0 ? const Icon(Icons.edit) : const Icon(Icons.add),
                      label: rc.id > 0 ? const Text("Edit Rpc") : const Text("Add Rpc"),
                      onPressed: () async {
                        myResponse res;
                        if (rc.id > 0){
                          res = await rc.editRpc();
                        }else{
                          res = await rc.addRpc();
                        }
                        if (res.code == 200) {
                          ///添加成功 刷新列表
                          await rc.getRpc();
                        } else {
                          Get.snackbar("Error", res.message);
                        }
                      },
                    )),
                  ),
                ),

                /// 列表
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Text(
                        "Rpc",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: GetBuilder<RpcController>(
                        builder: (_) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: defaultPadding,
                              columns: const [
                                DataColumn(label: Text("ID")),
                                DataColumn(label: Text("Name")),
                                DataColumn(label: Text("Uri")),
                                DataColumn(label: Text("Op")),
                              ],
                              rows: List<DataRow>.generate(
                                  rc.rpc.length,
                                      (index) => DataRow(cells: <DataCell>[
                                    DataCell(Text(
                                        "${rc.rpc[index]["id"]}")),
                                    DataCell(Text(
                                        "${rc.rpc[index]["name"]}")),
                                    DataCell(Text(
                                        "${rc.rpc[index]["uri"]}")),
                                    DataCell(Row(
                                      children: [
                                        IconButton(
                                            color: Colors.red,
                                            onPressed: () async {
                                              var res = await rc
                                                  .deleteRpc(rc
                                                  .rpc[index]);
                                              if (res.code == 200) {
                                                ///删除成功 刷新列表
                                                await rc.getRpc();
                                              } else {
                                                Get.snackbar(
                                                    "Error", res.message);
                                              }
                                            },
                                            icon:
                                            const Icon(Icons.delete)),
                                        IconButton(
                                          color: Colors.orangeAccent,
                                          onPressed: () async {
                                            ///点击编辑
                                            rc.nameTextEditController.value.text = rc.rpc[index]['name'];
                                            rc.uriTextEditController.value.text = rc.rpc[index]['uri'];
                                            rc.chainIdTextEditController.value.text = rc.rpc[index]['id'].toString();
                                            rc.id.value = rc.rpc[index]['id'];
                                          },
                                          icon: const Icon(Icons.edit),
                                        ),
                                        // IconButton(
                                        //     color: Colors.blue,
                                        //     onPressed: () async {
                                        //       var res = await rc
                                        //           .selectRpc(rc
                                        //           .rpc[index]);
                                        //       if (res.code == 200) {
                                        //         Get.toNamed("/main");
                                        //       } else {
                                        //         Get.snackbar(
                                        //             "Error", res.message);
                                        //       }
                                        //     },
                                        //     icon:
                                        //     const Icon(Icons.start)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}