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
  final data = [].obs; //提交的参数
  final payable = false.obs; //是否可以支付主币
  final payValue = "0".obs; //支付的金额
  final isLoading = false.obs; //loading
  Map select = {}; //选择的方法
  Map<String, Object?> op = {}; //用户
  Map<String, Object?> c = {}; //合约
  late Client httpClient;
  late Web3Client ethereumClient;

  void getTitle() async {
    var opId = await storage.box.read("operatorId");
    var cId = await storage.box.read("contractId");
    op = await Operator.find(opId);
    c = await Contract.find(cId);
    data.value = [];
    methodName.value = Get.arguments['methodName'];
    color.value = Get.arguments['color'];
    title.value =
        "Hi ${op['name']}, you operating (${c['name']}).$methodName now!";
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
    update();
  }

  Future<myResponse> requestBlockChain() async {
    isLoading.value = true;

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
    try {
      final credentials =
          EthPrivateKey.fromHex(decrypt(op['secret_key'] as String));
      EtherAmount balance =
          await ethereumClient.getBalance(credentials.address);
      final ownAddress = await credentials.extractAddress();
      final EthereumAddress contractAddr =
          EthereumAddress.fromHex(c['public_key'] as String);
      final contract = DeployedContract(
          ContractAbi.fromJson(c['abi'] as String, c['name'] as String),
          contractAddr);
      //TODO 展示余额
      //TODO 测试写方法
      print(balance.getValueInUnit(EtherUnit.ether));
      String response = "";

      ///格式化提交参数
      var p = [];

      for (var j = 0; j < data.value.length; j++) {
        if (data.value[j]['type'] == "uint256") {
          p.add(BigInt.parse(data.value[j]['value']));
        } else if (data.value[j]['type'] == "address") {
          p.add(EthereumAddress.fromHex(data.value[j]['value']));
        } else if (data.value[j]['type'] == "bool") {
          if (data.value[j]['value'] == "true") {
            p.add(true);
          } else if (data.value[j]['value'] == "false") {
            p.add(false);
          } else {
            p.add(false);
          }
        } else if (data.value[j]['type'] == "string") {
          p.add(data.value[j]['value']);
        } else if (data.value[j]['type'] == "uint8") {
          p.add(BigInt.parse(data.value[j]['value']));
        } else if (data.value[j]['type'] == "uint256[]") {
          var str = data.value[j]['value'] as String;
          var jde = str.replaceAll("[", "").replaceAll("]", "").split(",");
          p.add(jde.map((e) => BigInt.parse(e)).toList());
        } else if (data.value[j]['type'] == "string[]") {
          var str = data.value[j]['value'] as String;
          var jde = str.replaceAll("[", "").replaceAll("]", "").split(",");
          p.add(jde.map((e) => e).toList());
        } else if (data.value[j]['type'] == "address[]") {
          var str = data.value[j]['value'] as String;
          var jde = str.replaceAll("[", "").replaceAll("]", "").split(",");
          p.add(jde
              .map((e) => EthereumAddress.fromHex(
                  e.replaceAll("'", "").replaceAll("\"", "")))
              .toList());
        } else if (data.value[j]['type'] == "uint8[]") {
          var str = data.value[j]['value'] as String;
          var jde = str.replaceAll("[", "").replaceAll("]", "").split(",");
          p.add(jde.map((e) => BigInt.parse(e)).toList());
        } else {
          p.add(data.value[j]['value']);
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
                value:
                    EtherAmount.fromUnitAndValue(EtherUnit.wei, payValue.value),
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
