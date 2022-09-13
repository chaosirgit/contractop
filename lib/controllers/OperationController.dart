import 'dart:convert';
import 'dart:io';

import 'package:contractop/models/Contract.dart';
import 'package:contractop/models/Operator.dart';
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

  void init() async {
    /// 准备数据
    var opId = await storage.box.read("operatorId");
    var cId = await storage.box.read("contractId");
    op = await Operator.find(opId);
    c = await Contract.find(cId);

    /// 操作的方法名
    methodName.value = Get.arguments['methodName'];
    color.value = Get.arguments['color'];

    ///建立web3
    String rpc = "";
    if (c['chain_id'] == 56) {
      rpc = "https://bsc-dataseed1.binance.org";
    } else if (c['chain_id'] == 97) {
      rpc = "https://data-seed-prebsc-1-s1.binance.org:8545";
    } else if (c['chain_id'] == 1) {
      rpc = "https://cloudflare-eth.com";
    }
    httpClient = Client();
    ethereumClient = Web3Client(rpc, httpClient);

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
    getBalance();
    update();
  }

  void getBalance() async {
    ///获取余额
    balanceStr.value = "getting...";
    balance = await ethereumClient.getBalance(credentials.address);
    balanceStr.value = balance.getValueInUnit(EtherUnit.ether).toString();
  }

  void getTitle() async {
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
        if (params[j]['type'] == "uint256") {
          p.add(BigInt.parse(editControllers[j].text));
        } else if (params[j]['type'] == "address") {
          var hex = editControllers[j].text as String;
          p.add(EthereumAddress.fromHex(
              hex.trim().replaceAll("'", '').replaceAll("\"", '')));
        } else if (params[j]['type'] == "bool") {
          if (editControllers[j].text == "true") {
            p.add(true);
          } else if (editControllers[j].text == "false") {
            p.add(false);
          } else {
            p.add(false);
          }
        } else if (params[j]['type'] == "string") {
          p.add(editControllers[j].text);
        } else if (params[j]['type'] == "uint8") {
          p.add(BigInt.parse(editControllers[j].text));
        } else if (params[j]['type'] == "uint16") {
          p.add(BigInt.parse(editControllers[j].text));
        } else if (params[j]['type'] == "uint256[]") {
          var str = editControllers[j].text as String;
          var jde = str.replaceAll("[", "").replaceAll("]", "").split(",");
          p.add(jde.map((e) => BigInt.parse(e)).toList());
        } else if (params[j]['type'] == "string[]") {
          var str = editControllers[j].text as String;
          var jde = str.replaceAll("[", "").replaceAll("]", "").split(",");
          p.add(jde.map((e) => e).toList());
        } else if (params[j]['type'] == "address[]") {
          var str = editControllers[j].text as String;
          var jde = str.replaceAll("[", "").replaceAll("]", "").split(",");
          p.add(jde
              .map((e) => EthereumAddress.fromHex(
                  e.trim().replaceAll("'", "").replaceAll("\"", "")))
              .toList());
        } else if (params[j]['type'] == "uint8[]") {
          var str = editControllers[j].text as String;
          var jde = str.replaceAll("[", "").replaceAll("]", "").split(",");
          p.add(jde.map((e) => BigInt.parse(e)).toList());
        } else if (params[j]['type'] == "uint16[]") {
          var str = editControllers[j].text as String;
          var jde = str.replaceAll("[", "").replaceAll("]", "").split(",");
          p.add(jde.map((e) => BigInt.parse(e)).toList());
        } else {
          p.add(editControllers[j].text);
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
