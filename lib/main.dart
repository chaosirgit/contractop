import 'package:contractop/middleware/SelectWalletMiddleware.dart';
import 'package:contractop/service/DbService.dart';
import 'package:contractop/service/StorageService.dart';
import 'package:contractop/view/IndexView.dart';
import 'package:contractop/view/MainView.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

Future<void> main() async {
  await initService(); //服务初始化
  runApp(App());
}

Future<void> initService() async {
  print("start service...");
  await Get.putAsync(() => DbService().init());
  await Get.putAsync(() => StorageService().init());
  print("all service started...");
}




class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.dark().copyWith(
        backgroundColor: Colors.black12,
      ),
      initialRoute: '/main',
      getPages: [
        GetPage(name: '/', page: () => IndexView()),
        GetPage(name: '/main', page: () => MainView(),middlewares: [SelectWalletMiddleware(priority: 1)]),
      ],
    );
  }
}

