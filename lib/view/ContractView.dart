import 'package:contractop/controllers/ContractController.dart';
import 'package:contractop/utils/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ContractView extends GetView<ContractController> {
  /// GetX Controller 加载
  @override
  final ContractController cc = Get.put(ContractController());
  FocusNode nameFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode abiFocusNode = FocusNode();
  FocusNode chainIdFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    /// 获取 title
    cc.getTitle();

    /// 获取初始列表
    cc.getContracts();
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text("${cc.title}")),
      ),
      floatingActionButton: IconButton(
        onPressed: () => Get.offAllNamed("/"),
        icon: const Icon(Icons.first_page),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    FocusScope.of(context).requestFocus(addressFocusNode);
                  },

                  /// change 赋值
                  onChanged: (d) {
                    cc.name.value = d;
                  },
                  decoration: const InputDecoration(
                      labelText: "Contract Name",
                      hintText: "Input contract alis name",
                      prefixIcon: Icon(Icons.rate_review)),
                      ),
                    ),
                ),
                /// address 输入框
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                      child: TextField(
                  autofocus: true,
                  focusNode: addressFocusNode,

                  /// 提交后切换焦点
                  onSubmitted: (d) {
                    nameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(chainIdFocusNode);
                  },

                  /// change 赋值
                  onChanged: (d) {
                    cc.publicKey.value = d;
                  },
                  decoration: const InputDecoration(
                      labelText: "Contract Address",
                      hintText: "Input contract address",
                      prefixIcon: Icon(Icons.meeting_room)),
                      ),
                    ),
                ),
                /// ChainID 输入框
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                      child: TextField(
                  autofocus: true,
                  focusNode: chainIdFocusNode,

                  /// 提交后切换焦点
                  onSubmitted: (d) {
                    nameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(abiFocusNode);
                  },

                  /// change 赋值
                  onChanged: (d) {
                    cc.chainId.value = d;
                  },
                  decoration: const InputDecoration(
                      labelText: "Chain ID",
                      hintText: "Input Chain ID",
                      prefixIcon: Icon(Icons.numbers)),
                      ),
                    ),
                ),
                /// Abi 输入框
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                      child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  ///提交后赋值并请求新建
                  onSubmitted: (d) async {
                    var res = await cc.addContract();
                    if (res.code == 200) {
                      ///添加成功 刷新列表
                      await cc.getContracts();
                    } else {
                      Get.snackbar("Error", res.message);
                    }
                  },

                  /// 赋值
                  onChanged: (d) {
                    cc.abi.value = d;
                  },
                  focusNode: abiFocusNode,
                  decoration: const InputDecoration(
                      labelText: "Abi Json",
                      hintText: "Input Contract Abi Json String",
                      prefixIcon: Icon(Icons.code_off)),
                      ),
                    ),
                ),
                /// 按钮
                Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: SizedBox(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Contract"),
                      onPressed: () async {
                        var res = await cc.addContract();
                        if (res.code == 200) {
                          ///添加成功 刷新列表
                          await cc.getContracts();
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
                        "Contracts",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: GetBuilder<ContractController>(
                          builder: (_) {
                            return DataTable(
                              columnSpacing: defaultPadding,
                              columns: const [
                                DataColumn(label: Text("ID")),
                                DataColumn(label: Text("Name")),
                                DataColumn(label: Text("Chain ID")),
                                DataColumn(label: Text("Public Key")),
                                DataColumn(label: Text("Op")),
                              ],
                              rows: List<DataRow>.generate(
                                  cc.contracts.length,
                                  (index) => DataRow(cells: <DataCell>[
                                        DataCell(
                                            Text("${cc.contracts[index]["id"]}")),
                                        DataCell(
                                            Text("${cc.contracts[index]["name"]}")),
                                        DataCell(Text(
                                            "${cc.contracts[index]["chain_id"]}")),
                                        DataCell(Text(
                                            "${cc.contracts[index]["public_key"]}")),
                                        DataCell(Row(
                                          children: [
                                            IconButton(
                                                color: Colors.red,
                                                onPressed: () async {
                                                  var res = await cc.deleteContract(
                                                      cc.contracts[index]);
                                                  if (res.code == 200) {
                                                    ///删除成功 刷新列表
                                                    await cc.getContracts();
                                                  } else {
                                                    Get.snackbar(
                                                        "Error", res.message);
                                                  }
                                                },
                                                icon: const Icon(Icons.delete)),
                                            IconButton(
                                                color: Colors.blue,
                                                onPressed: () async {
                                                  var res = await cc.selectContract(
                                                      cc.contracts[index]);
                                                  if (res.code == 200) {
                                                    Get.toNamed("/main");
                                                  } else {
                                                    Get.snackbar(
                                                        "Error", res.message);
                                                  }
                                                },
                                                icon: const Icon(Icons.start))
                                          ],
                                        )),
                                      ])),
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
