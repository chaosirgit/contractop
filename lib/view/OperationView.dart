import 'package:contractop/controllers/OperationController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:contractop/utils/constants.dart';
import 'package:get/get_navigation/src/dialog/dialog_route.dart';

class OperationView extends GetView<OperationController> {
  final OperationController oc = Get.put(OperationController());

  @override
  Widget build(BuildContext context)  {
    // TODO: implement build
    oc.init().then((value) => oc.getTitle());

    /// 获取 title

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text("${oc.title}")),
        actions: [
          Obx(() => ElevatedButton.icon(
              onPressed: () {
                oc.getBalance();
              },
              icon: Icon(Icons.currency_bitcoin),
              label: Text("${oc.balanceStr}")))
        ],
      ),
      floatingActionButton: IconButton(
        onPressed: () => Get.offAllNamed("/"),
        icon: const Icon(Icons.first_page),
      ),
      body: Center(
        child: Container(
          width: 800,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Obx(() => Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: ElevatedButton.icon(
                      icon: !oc.isLoading.value
                          ? const Icon(Icons.send)
                          : const CircularProgressIndicator(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: oc.color.value,
                        minimumSize: const Size(160.0, 80.0),
                      ),
                      label: Text(!oc.isLoading.value
                          ? "${oc.methodName}"
                          : "Requesting..."),
                      onPressed: () async {
                        var res = await oc.requestBlockChain();
                        if (res.code == 200) {
                          return await Get.dialog(SimpleDialog(
                            title: Text("${oc.methodName}"),
                            titlePadding: const EdgeInsets.all(defaultPadding),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6))),
                            children: [
                              ListTile(
                                title: const Text("OK"),
                                subtitle: Text("${res.data}"),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(defaultPadding),
                                child: ElevatedButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(
                                          ClipboardData(text: "${res.data}"));
                                      Get.back();
                                    },
                                    icon: const Icon(Icons.copy),
                                    label: const Text("Copy Result")),
                              )
                            ],
                          ));
                        } else {
                          print(res.message);
                          return await Get.dialog(AlertDialog(
                            title: const Text("Error"),
                            content: Text(res.message),
                            actions: [
                              IconButton(
                                  onPressed: () => Get.back(),
                                  icon: Icon(Icons.close))
                            ],
                          ));
                        }
                      },
                    ),
                  )),

              /// 参数列表
              Expanded(
                child: GetBuilder<OperationController>(builder: (_) {
                  List<Widget> list = [];

                  /// 声明相应的焦点变量
                  List<FocusNode> nods = [];
                  for (var i = 0; i < oc.params.length; i++) {
                    nods.add(FocusNode());
                  }

                  /// 列表
                  for (var i = 0; i < oc.params.length; i++) {
                    String paramsName = oc.params[i]['name'];
                    list.add(TextField(
                      focusNode: nods[i],
                      controller: oc.editControllers[i],

                      /// 提交后切换焦点
                      onSubmitted: (d) {
                        nods[i].unfocus();
                        if (i < oc.params.length - 1) {
                          FocusScope.of(context).requestFocus(nods[i + 1]);
                        }
                      },

                      decoration: InputDecoration(
                          labelText: paramsName,
                          hintText: oc.params[i]['type'],
                          prefixIcon: Icon(Icons.abc)),
                    ));
                  }

                  /// 需要支付
                  if (oc.payable.value == true) {
                    list.add(TextField(
                      /// change 赋值
                      controller: oc.payValueEditController,

                      decoration: const InputDecoration(
                          labelText: 'coin',
                          hintText: 'uint256',
                          prefixIcon: Icon(Icons.currency_bitcoin)),
                    ));
                  }
                  return ListView(
                    children: list,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
