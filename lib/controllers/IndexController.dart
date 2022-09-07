import 'package:contractop/models/Wallet.dart';
import 'package:contractop/service/DbService.dart';
import 'package:get/get.dart';

class IndexController extends GetxController {
    final title = "This is Index";
    final dbService = Get.find<DbService>();
    final wallets = [].obs;

    Future<void> addWallet() async {
        var data = {
            "public_key":"112",
            "secret_key" : "332234",
        };
        await Wallet.fromMap(data).save();
        await getWallets();
    }

    Future<void> getWallets() async {
        var any = await Wallet.all();
        wallets.assignAll(any);
        print(wallets);
    }

}
