import 'package:contractop/controllers/IndexController.dart';
import 'package:contractop/utils/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class IndexView extends GetView<IndexController> {
  @override
  IndexController controller = Get.put(IndexController());
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
            SizedBox(
              width: 400,
              height: 50,
              child: TextField(
                onChanged: (a) {
                  controller.secret = a;
                },
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Secret Key",
                    hintText: "Input your operation wallet secret key",
                    prefixIcon: Icon(Icons.lock)
                ),
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
                  if (res.code == 200){
                    ///添加成功 刷新列表
                    await controller.getOperators();
                  }else{
                    Get.snackbar("Error",res.message);
                  }
                },
              ),
            ),
            const SizedBox(height: defaultPadding),
            Container(
              alignment: Alignment.center,
              width: 100,
              height: 50,
              child: const Text("Operator List"),
            ),
            const SizedBox(height: defaultPadding),
            Container(
              color: Colors.cyanAccent,
              width: 400,
              height: 1,
            ),
            const SizedBox(height: defaultPadding),
            Expanded(
                child: Container(
                  alignment: Alignment.center,
                  width: 500,
                  child: GetBuilder<IndexController>(
                    builder: (ic) => ListView.builder(
                      itemCount: ic.operators.length,
                      itemExtent: 50,
                      itemBuilder: (context,index) {
                        return ListTile(title: Text("Public Address: ${ic.operators[index]["public_key"]}"),onTap: () async {
                          var res = await ic.selectOperator(ic.operators[index]);
                          if (res.code == 200){
                            Get.offAllNamed('/main');
                          }
                        },);
                      },
                    ),
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
