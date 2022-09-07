import 'package:contractop/service/StorageService.dart';
import 'package:contractop/view/IndexView.dart';
import 'package:get/get.dart';

class SelectWalletMiddleware extends GetMiddleware {
  @override
  int? priority;
  SelectWalletMiddleware({this.priority});
  @override
  GetPage? onPageCalled(GetPage? page) {
    // TODO: implement onPageCalled
    final storage = Get.find<StorageService>();
    if (storage.box.read("walletId") == null) {
      return GetPage(name: '/', page: () => IndexView());
    }
    return super.onPageCalled(page);
  }
}
