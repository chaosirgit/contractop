import 'package:contractop/models/Contract.dart';
import 'package:contractop/models/Operator.dart';
import 'package:contractop/service/StorageService.dart';
import 'package:contractop/utils/helpers.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  final title = "".obs;
  final storage = Get.find<StorageService>();
  final sendMethods = [].obs;
  final readMethods = [].obs;


  void getTitle() async {
    var opId = await storage.box.read("operatorId");
    var cId = await storage.box.read("contractId");
    var op = await Operator.find(opId);
    var c = await Contract.find(cId);
    title.value = "Hi ${op['name']}, you operating ${c['name']} now!";
  }

  void getAbiMethods() async {
    var cId = await storage.box.read("contractId");
    var c = await Contract.find(cId);
    var p = parseAbi(c["abi"] as String);
    sendMethods.value = p["send"].map((i) {
      i['input_format'] = i['inputs'].map((u) => u['name']).toList().join(",");
      return i;
    }).toList();
    readMethods.value = p["read"].map((i) {
      i['input_format'] = i['inputs'].map((u) => u['name']).toList().join(",");
      return i;
    }).toList();
    update();
  }



}