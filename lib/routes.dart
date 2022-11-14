import 'package:contractop/view/IndexView.dart';
import 'package:contractop/view/ContractView.dart';
import 'package:contractop/view/MainView.dart';
import 'package:contractop/view/OperationView.dart';
import 'package:contractop/view/RpcView.dart';
import 'package:get/get.dart';
import 'package:contractop/middleware/SelectWalletMiddleware.dart';

final routes = [
  GetPage(name: '/', page: () => IndexView()),
  GetPage(name: '/rpc', page: () => RpcView()),
  GetPage(name: '/contract', page: () => ContractView(),middlewares: [SelectWalletMiddleware(priority: 0)]),
  GetPage(name: '/main', page: () => MainView(),middlewares: [SelectWalletMiddleware(priority: 0)]),
  GetPage(name: '/operation', page: () => OperationView(),middlewares: [SelectWalletMiddleware(priority: 0)]),

];