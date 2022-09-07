
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  late final GetStorage box;
  Future<StorageService> init() async {
    print("start storage service...");
    GetStorage.init();
    box = GetStorage();
    print("storage service started...");
    return this;
  }
}