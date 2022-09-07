import 'package:contractop/service/DbService.dart';
import 'package:get/get.dart';

abstract class Model {
  late final int? id;
  static final dbService = Get.find<DbService>();
  Map<String,Object?> toMap();

}