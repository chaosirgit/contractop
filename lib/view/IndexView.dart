import 'package:contractop/controllers/IndexController.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class IndexView extends GetView<IndexController> {

  final IndexController ic = Get.put(IndexController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ic.title),
      ),
      body: Center(
        child: Row(
          children: [
            ElevatedButton(
              child: Text("Add Wallet"),
              onPressed: () => {
                IndexController().addWallet()
              },
            ),
            SizedBox(
              height: 400,
              width: 500,
              child: ListView.builder(
                itemCount: ic.wallets.length,
                itemBuilder: (context, index){
                  return ListTile(
                    title: Obx(() => Text(ic.wallets[index]["public_key"])),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
