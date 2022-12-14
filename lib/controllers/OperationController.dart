import 'dart:convert';
import 'dart:io';

import 'package:contractop/models/Contract.dart';
import 'package:contractop/models/Operator.dart';
import 'package:contractop/models/Rpc.dart';
import 'package:contractop/service/StorageService.dart';
import 'package:contractop/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class OperationController extends GetxController with StateMixin {
  final title = "".obs;
  final methodName = "".obs; //方法名称
  final color = Colors.orangeAccent.obs; //颜色
  final storage = Get.find<StorageService>();
  final RxList params = [].obs; //参数数组
  final payable = false.obs; //是否可以支付主币
  final payValue = "0".obs; //支付的金额
  final isLoading = false.obs; //loading
  final List editControllers = [];
  final payValueEditController = TextEditingController();
  Map select = {}; //选择的方法
  Map<String, Object?> op = {}; //用户
  Map<String, Object?> c = {}; //合约
  late Client httpClient;
  late Web3Client ethereumClient;
  late EthPrivateKey credentials;
  late EtherAmount balance;
  final balanceStr = "getting...".obs;
  late int cId;

  Future<void> init() async {
    /// 准备数据
    var opId = await storage.box.read("operatorId");
    cId = await storage.box.read("contractId");
    op = await Operator.find(opId);
    c = await Contract.find(cId);

    /// 操作的方法名
    methodName.value = Get.arguments['methodName'];
    color.value = Get.arguments['color'];

    ///建立web3
    var rpcUri = "";
    var rpc = await Rpc.first(where: "id = ?",whereArgs: [c['chain_id']]);
    if (rpc != null) {
      rpcUri = rpc['uri'];
    } else {
      return Get.dialog(AlertDialog(
        title: const Text("Error"),
        content: Text("未设置 RPC"),
        actions: [
          IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.close))
        ],
      ));
    }
    httpClient = Client();
    ethereumClient = Web3Client(rpcUri, httpClient);

    ///获取本人凭证
    credentials = EthPrivateKey.fromHex(decrypt(op['secret_key'] as String));

    /// 解析ABI
    var abiObj = parseAbi(c['abi'] as String);

    ///读
    if (color.value == Colors.blueAccent) {
      select = abiObj['read']
          .where((i) => i['name'] == methodName.value)
          .toList()
          .first;
      params.value = select['inputs'];
    } else {
      select = abiObj['send']
          .where((i) => i['name'] == methodName.value)
          .toList()
          .first;
      if (select['stateMutability'] == "payable") {
        payable.value = true;
      }
      params.value = select['inputs'];
    }

    ///  初始化 textEditController
    for (var i = 0; i < params.length; i++) {
      editControllers.add(TextEditingController());
    }
    /// 获取草稿
    var draft = await storage.box.read("draft.$cId.$methodName");
    if (draft != null) {
      for (var j = 0; j < params.length; j++) {
        editControllers[j].text = draft[j];
      }
    }

    getBalance();
    update();
  }

  //设置草稿
  Future<void> setDraft(methodName,index,data) async {
      var draftData = await storage.box.read("draft.$cId.$methodName");
      if (draftData == null) {
        draftData = [];
        for (var i = 0; i < params.length; i++) {
          draftData.add("");
        }
      }
      draftData[index] = data;
      storage.box.write("draft.$cId.$methodName",draftData);
  }

  Future<void> getBalance() async {
    ///获取余额
    balanceStr.value = "getting...";
    balance = await ethereumClient.getBalance(credentials.address);
    balanceStr.value = balance.getValueInUnit(EtherUnit.ether).toString();
  }

  Future<void> getTitle() async {
    title.value =
        "Hi ${op['name']}, you operating (${c['name']}).$methodName now!";
  }

  Future<myResponse> requestBlockChain() async {
    isLoading.value = true;

    try {
      final EthereumAddress contractAddr =
          EthereumAddress.fromHex(c['public_key'] as String);
      final contract = DeployedContract(
          ContractAbi.fromJson(c['abi'] as String, c['name'] as String),
          contractAddr);
      String response = "";

      ///格式化提交参数
      var p = [];

      for (var j = 0; j < editControllers.length; j++) {
        var type = params[j]['type'] as String;
        var typeArr = type.split("[");
        /// 非数组类型
        if (typeArr.length == 1){
           if (typeArr[0].startsWith("uint")){
             p.add(BigInt.parse(editControllers[j].text));
           }else if (typeArr[0].startsWith("bool")){
             p.add(editControllers[j].text == "true");
           }else if (typeArr[0].startsWith("address")){
             var hex = editControllers[j].text as String;
             p.add(EthereumAddress.fromHex(hex.trim().replaceAll("'", '').replaceAll("\"", '')));
           }else if (typeArr[0].startsWith("string")){
             p.add(editControllers[j].text);
           }else{
             p.add(editControllers[j].text);
           }
        /// 数组类型
        }else if (typeArr.length == 2){
          var str = editControllers[j].text as String;
          var jde = str.trim().replaceAll("[", "").replaceAll("]", "").replaceAll("'", "").replaceAll("\"", "").split(",");
          if (typeArr[0].startsWith("uint")){
            p.add(jde.map((e) => BigInt.parse(e)).toList());
          }else if (typeArr[0].startsWith("bool")){
            p.add(jde.map((e) => e == "true").toList());
          }else if (typeArr[0].startsWith("address")){
            p.add(jde.map((e) => EthereumAddress.fromHex(e.trim())).toList());
          }else if (typeArr[0].startsWith("string")){
            p.add(jde.map((e) => e).toList());
          }else{
            p.add(jde.map((e) => e).toList());
          }
        }
      }

      /// 读合约
      if (select['stateMutability'] == "view") {
        var res = await ethereumClient.call(
            contract: contract,
            function: contract.function(select['name']),
            params: p);
        response = res.toString();
      } else {
        ///不支付 写合约
        if (select['stateMutability'] == "nonpayable") {
          var res = await ethereumClient.sendTransaction(
              credentials,
              Transaction.callContract(
                contract: contract,
                function: contract.function(select['name']),
                parameters: p,
              ),
              fetchChainIdFromNetworkId: true,
              chainId: null);
          response = res.toString();

          ///支付
        } else if (select['stateMutability'] == "payable") {
          var res = await ethereumClient.sendTransaction(
              credentials,
              Transaction.callContract(
                contract: contract,
                function: contract.function(select['name']),
                parameters: p,
                value: EtherAmount.fromUnitAndValue(
                    EtherUnit.wei, payValueEditController.text),
              ),
              fetchChainIdFromNetworkId: true,
              chainId: null);
          response = res.toString();
        }
      }
      isLoading.value = false;
      return myResponse.success(message: 'ok', data: response);
    } catch (e) {
      isLoading.value = false;
      return myResponse.error(message: "$e");
    } finally {
      ethereumClient.dispose();
    }
  }
}
