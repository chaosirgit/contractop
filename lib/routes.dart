import 'package:contractop/view/IndexView.dart';
import 'package:contractop/view/MainView.dart';
import 'package:get/get.dart';
import 'package:contractop/middleware/SelectWalletMiddleware.dart';

final routes = [
  GetPage(name: '/', page: () => IndexView()),
  GetPage(name: '/main', page: () => MainView(),middlewares: [SelectWalletMiddleware(priority: 0)]),
];